local M = {}
function M.split(str,delimiter)
	local result = {}
	local from = 1
	local delim_from,delim_to = string.find(str,delimiter,from)
	while delim_from do
		table.insert(result, string.sub(str, from, delim_from-1) )
		from = delim_to + 1
		delim_from, delim_to =string.find(str,delimiter,from)
	end
	table.insert(result,string.sub(str,from))
	return result
end

function M.urldecode(s)
	return string.gsub(s, "%%(%x%x)", function(hex)
        return string.char(tonumber(hex, 16))
    end)
end

function M.file_exists(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
end

function M.isemptyorzero(var)
	if var == nil or var == 0 or var == "" then
		return true
	else
		return false
	end
end

function M.writefile(localfile,cotent)
	local file = io.open(localfile, "w");
		if (file) then
			file:write(cotent)
			file:close()
			return true
		end
	return false
end

function M.ngxoutputfile(localfile)
	if(M.file_exists(localfile))then        
		local file = io.open(localfile, "r");
		if (file) then
			local content= file:read("*a");
			file:close();
			
			local len = string.len(content)
			local filesize = len
			
			return filesize,content   
		end
	end	
	return nil
end



function M.ngxredirect(puri)
	ngx.log(ngx.WARN,"puri:",puri)
	ngx.redirect(puri)
	ngx.exit(302)
end

function M.ngxsay(msg)
	ngx.header["Content-Type"]="text/html; charset=utf-8"
	ngx.say(msg)
	ngx.exit(ngx.HTTP_OK)
end

function M.ngxlog(msg)
	--ngx.log(ngx.WARN,msg)
end



function M.ngxflowstat()

	--
	
end


--代理到阿里云下载
function M.ngxproxyossdownload(req_path,local_path)
	local match = string.match
	local OSS_BUCKET = 
	local OSS_BUCKET = "空间" --在空间名
	local OSS_ACCESS_ID = "OSS_ID"  --在ACCESS_ID
	local OSS_ACCESS_KEY = "OSS_KEY" --在ACCESS_KEY
	local OSS_TIME =    ngx.time() + 6000 
	
	local function signature(str)
	  return ngx.encode_base64(ngx.hmac_sha1(OSS_ACCESS_KEY, str))
	end
	
	function psub(c)
	  return '%' .. string.format('%2X', string.byte(c, 1))
	end
	 
	function urlencode(s)
	  return string.gsub(s, '[^a-zA-Z0-9%-_%.~]', psub)
	end


	local requesturi = req_path
	M.ngxlog("requesturi"..req_path)
	local requesturiarr = M.split(requesturi,"?")
	requesturi = requesturiarr[1]
	requestqstringuri = requesturiarr[2]
	if requestqstringuri == nil then
		requestqstringuri = ""
	end
	--清理前面多个//
	requesturi = string.gsub(requesturi, "//", "/") 
	--取出请求的名字。进行编码
	local requesturi_name_arr = M.split(requesturi,"/")
	for index,value in pairs(requesturi_name_arr) do
		if value ~= "" then
			requesturi_name_arr[index] = urlencode(requesturi_name_arr[index])
		end
	end
	encode_requesturi = table.concat(requesturi_name_arr, "/")
	local geturi = "/"..OSS_BUCKET..requesturi
	local contenttype = ""
	local Signaturestr = signature("GET\n\n\n"..OSS_TIME.."\n"..geturi.."")
	
	local qarg =  ngx.encode_args({Signature = Signaturestr})

	--判断是否有？号带参数请求
	local isqstring = string.match(geturi, "?")
	local qstring = "?"
	if isqstring then
		qstring = "&"
	end

	local hosturi = OSS_BUCKET..".oss-cn-hangzhou-internal.aliyuncs.com" --".oss.aliyuncs.com"
	local hostpath = encode_requesturi..qstring..contenttype.."OSSAccessKeyId="..OSS_ACCESS_ID.."&Expires="..OSS_TIME.."&"..qarg.."&"..requestqstringuri.."&cachenotime="..ngx.time().."&randtime=nocache"
	
	local ossuri = "http://"..hosturi..hostpath
	local res = ngx.location.capture("/proxyoss",{ vars = { proxypath = ossuri}})
	if res.status == 200 then
		local content = res.body
		M.writefile(local_path,content)
		return 1
	else
		ngx.exit(res.status)
	end
end

--代理到云处理
function M.ngxossproxy(puri)
	
	local res = ngx.location.capture("/proxyoss",{ vars = { proxypath = puri}})

	if res.status == 404 then
		return res.status
	end
	local extraheader = ""
	for name, value in pairs(res.header) do
		if name ~= "Content-Disposition"    then
			ngx.header[name] = value
			extraheader = extraheader..""..name..":"..value
		end
		
	end
	extraheader = extraheader
	M.ngxlog(extraheader..":"..res.status)
	ngx.status = res.status
	ngx.print(res.body)
	return res.status
end

return M



