--OSS机房
		
local M = {}
function M.new(config,fun)
	local app = {}
	if type(config) ~= "table" then config = {} end
	if type(config.path) ~= "string" then config.path = "" end
	app.config = config
	
	function app.run()
		local match = string.match
		local OSS_BUCKET = "空间" --在空间名
		local OSS_ACCESS_ID = "OSS_ID"  --在ACCESS_ID
		local OSS_ACCESS_KEY = "OSS_KEY" --在ACCESS_KEY
		local OSS_TIME =    ngx.time() + 6000 
		local function signature(str)
		  return ngx.encode_base64(ngx.hmac_sha1(OSS_ACCESS_KEY, str))
		end


		local requesturi = app.config.path
		local requesturiarr = fun.split(requesturi,"?")
		requesturi = requesturiarr[1]
		requestqstringuri = requesturiarr[2]
		if requestqstringuri == nil then
			requestqstringuri = ""
		end
		--清理前面多个//
		requesturi = string.gsub(requesturi, "//", "/") 
		--取出请求的名字。进行编码
		local requesturi_name_arr = fun.split(requesturi,"/")
		for index,value in pairs(requesturi_name_arr) do
			if value ~= "" then
				requesturi_name_arr[index] = app.urlencode(requesturi_name_arr[index])
			end
		end
		encode_requesturi = table.concat(requesturi_name_arr, "/")

		local geturi = "/"..OSS_BUCKET..requesturi
		local contenttype = ""
		local Signaturestr = signature("GET\n\n\n"..OSS_TIME.."\n"..geturi.."")
		
		local extion = string.match(geturi, ".(html)$")
		if extion then
			ngx.header["Content-Type"] = "text/html"
		end


		local qarg =  ngx.encode_args({Signature = Signaturestr})

		--判断是否有？号带参数请求
		local isqstring = string.match(geturi, "?")
		local qstring = "?"
		if isqstring then
			qstring = "&"
		end

		local hosturi = OSS_BUCKET..".oss-cn-hangzhou-internal.aliyuncs.com" --".oss.aliyuncs.com" 阿里内网
		local hostpath = encode_requesturi..qstring..contenttype.."OSSAccessKeyId="..OSS_ACCESS_ID.."&Expires="..OSS_TIME.."&"..qarg.."&"..requestqstringuri.."&cachenotime="..ngx.time().."&randtime=nocache"
		local ossuri = "http://"..hosturi..hostpath
		local status = fun.ngxossproxy(ossuri)
		return status
	end
	
	function app.psub(c)
	  return '%' .. string.format('%2X', string.byte(c, 1))
	end
	 
	function app.urlencode(s)
	  return string.gsub(s, '[^a-zA-Z0-9%-_%.~]', app.psub)
	end
	
	return app
end
return M
