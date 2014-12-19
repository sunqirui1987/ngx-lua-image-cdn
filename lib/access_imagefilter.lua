local M = {}

local imagevarobj = require("image.imagevar")

function M.new(config,fun)
	local img = {}
	if type(config) ~= "table" then config = {} end
	if type(config.bucketpath) ~= "string" then config.bucketpath = "" end
	if type(config.imageinfo) ~= "table" then config.imageinfo = {} end
	
	if config.db == nil then fun.ngxsay("db is error") end
	if config.bucketname == nil then fun.ngxsay("bucketname is empty") end
	if config.conn == nil then fun.ngxsay("conn is error") end
	if config.requesturi == nil then fun.ngxsay("requesturi is error") end
	
	config.cachepath = DetuYunConfig.cachePath
	config.storepath = DetuYunConfig.storePath
	
	img.config = config
	
	--初始化变量

	
	
	function img.run()
		
		
		gmconvert_imagevarobj = imagevarobj:new()
		gmconvert_imagevar = gmconvert_imagevarobj.image

		local isImageprocessMode = false
		local imagevar_isrefresh = ""
		
		gmconvert_imagevar.var.filecdate = img.config.filecdate
		gmconvert_imagevar.var.imagewidth = img.config.imageinfo["x-detuyun-width"]
		gmconvert_imagevar.var.imageheight = img.config.imageinfo["x-detuyun-height"]
		
		
		---后缀样式
		--取？后面的字符串
		local qstring_uri = string.gsub(img.config.requesturi,"[^?].*?","")
		--删除以&后面的字条串
		qstring_uri = string.gsub(qstring_uri,"&.*","")

		local requesturiarr = fun.split(qstring_uri,"/")
		local swtichstr = requesturiarr[1]
		if swtichstr == "imageinfo" then
			img.info()
			return
		elseif string.lower(swtichstr) == "imageview" then
			--缩略图样式
			for index,value in pairs(requesturiarr) do
				
				
				---------------------------- 图片元数据	----------------------
				if value == "isrefresh" then
					imagevar_isrefresh  = requesturiarr[index + 1]  or ""
					
					----------------------------   图像处理基本参数 ----------------------
					-- 如果是这种情况 imageView/sharp/1  则跳过imageview后面的参数 
				elseif string.lower(value) == "imageview" and requesturiarr[index + 1] ~= nil and tonumber(requesturiarr[index + 1]) ~= nil then
					gmconvert_imagevar.img.thumbimageviewmodel = requesturiarr[index + 1] or ""
				elseif value == "w" then
					gmconvert_imagevar.img.thumbwidth = requesturiarr[index + 1]   or ""
				elseif value == "h" then
					gmconvert_imagevar.img.thumbheight = requesturiarr[index + 1]  or ""
					
					
					----------------------------  水印配置处理基本参数 ----------------------
				elseif value == "image" then
					gmconvert_imagevar.img.waterimage  = requesturiarr[index + 1]  or ""
				elseif value == "dissolve" then
					gmconvert_imagevar.img.waterdissolve  = requesturiarr[index + 1]  or ""
				elseif value == "dx" then
					gmconvert_imagevar.img.waterdistancex  = requesturiarr[index + 1]  or ""
				elseif value == "dy" then
					gmconvert_imagevar.img.waterdistancey  = requesturiarr[index + 1] or ""
				elseif value == "gravity" then
					gmconvert_imagevar.img.watergravity  = requesturiarr[index + 1]  or ""
					
					-------------------------------高级图像处理参数 ----------------------------------
				elseif value == "border" then
					gmconvert_imagevar.img.border = requesturiarr[index + 1]  or ""
				elseif value == "font" then
					gmconvert_imagevar.img.font = requesturiarr[index + 1]  or ""
				elseif value == "cycle " then
					gmconvert_imagevar.img.cycle  = requesturiarr[index + 1]  or ""				
				elseif value == "crop" then
					gmconvert_imagevar.img.crop = requesturiarr[index + 1]  or ""
				elseif value == "q" then
					gmconvert_imagevar.img.quality = requesturiarr[index + 1]  or ""
				elseif value == "rotate" then
					gmconvert_imagevar.img.rotate = requesturiarr[index + 1]  or ""				
				elseif value == "type" then
					gmconvert_imagevar.img.type  = requesturiarr[index + 1]  or ""
				elseif value == "filter" then
					gmconvert_imagevar.img.filter  = requesturiarr[index + 1]  or ""			
					
				---带标记但不带参数也视为自动开启 /monochrome 
				elseif value == "sharp" then
					gmconvert_imagevar.img.sharp  = requesturiarr[index + 1]  or "on"
				elseif value == "monochrome" then
					gmconvert_imagevar.img.monochrome  = requesturiarr[index + 1]  or "on"
				elseif value == "autoorient" then
					gmconvert_imagevar.img.autoorient = requesturiarr[index + 1]  or "on"
				elseif value == "flip" then
					gmconvert_imagevar.img.flip  = requesturiarr[index + 1]  or "on"
				elseif value == "flop" then
					gmconvert_imagevar.img.flop  = requesturiarr[index + 1]  or "on"
				elseif value == "charcoal" then
					gmconvert_imagevar.img.charcoal  = requesturiarr[index + 1]  or "on"
				elseif value == "spread" then
					gmconvert_imagevar.img.spread  = requesturiarr[index + 1]  or "on"
				elseif value == "swirl" then
					gmconvert_imagevar.img.swirl  = requesturiarr[index + 1]  or "on"
				elseif value == "raise" then
					gmconvert_imagevar.img.raise  = requesturiarr[index + 1]  or "on"
				elseif value == "inter" then
					gmconvert_imagevar.img.interlace  = requesturiarr[index + 1]  or "Plane"
				elseif value == "autowebp" then
					gmconvert_imagevar.img.autowebp  = requesturiarr[index + 1]  or "1"
				
				end
			end
			
			isImageprocessMode = true
		end
		
		
		--非图片处理模式
		if isImageprocessMode == false then
			return
		end
		
		
		
		--缓存参数
		local noqstring_uri = string.gsub(ngx.var.request_uri,"?.*","")
		local noqstring_uri = string.gsub(noqstring_uri,"!.*","")
		local cacheparam = imagevarobj:tostring(gmconvert_imagevar) --序列化
		noqstring_uri = noqstring_uri.."?"..cacheparam
		--ngx.log(ngx.WARN,"imagevew noqstring_uri"..noqstring_uri)
		
		config.local_file_cachename = ngx.md5(noqstring_uri)
		config.local_file_cachedir = config.cachepath.."/"..img.config.bucketname.."/"..string.sub(config.local_file_cachename,1,3)
		config.local_file_cachepath = config.local_file_cachedir.."/"..config.local_file_cachename
		
		fun.ngxlog(noqstring_uri)

		--auto webp
		local ua = ngx.var.http_user_agent
		local isautowepb = ngx.re.match(ua,"Chrome")
		if isautowepb  ~= nil and gmconvert_imagevar.img.autowebp == "1" then
			ngx.header["Content-Type"] = "image/webp"
			config.local_file_cachepath = config.local_file_cachepath..".webp"
		end
		
		if gmconvert_imagevar.img.type == "jpg" then
			ngx.header["Content-Type"] = "image/jpeg"
			config.local_file_cachepath = config.local_file_cachepath..".jpg"
		elseif gmconvert_imagevar.img.type == "png" then
			ngx.header["Content-Type"] = "image/png"
			config.local_file_cachepath = config.local_file_cachepath..".png"
		elseif gmconvert_imagevar.img.type== "gif" then
			ngx.header["Content-Type"] = "image/gif"
			config.local_file_cachepath = config.local_file_cachepath..".gif"
		elseif gmconvert_imagevar.img.type== "webp" then
			ngx.header["Content-Type"] = "image/webp"
			config.local_file_cachepath = config.local_file_cachepath..".webp"
		end
		
		
		
		
		--是否强制刷新 isrefresh不为空的时候强制刷新
		if fun.isemptyorzero(imagevar_isrefresh) == true  then
			--是否存在本地缓存 
			img.iscache()
		end
		
		
	
		
		--创建CACHE目录
		local mkdir_command ="mkdir  -p  "..config.local_file_cachedir.." >/dev/null 2>&1 "
		local msg = os.execute(mkdir_command)
			
		
		--原图地址
		gmconvert_imagevar.var.orginfile = img.config.storepath..config.bucketpath

		
		--图片处理
		local gmagick = require("image.gmagick").new(gmconvert_imagevar,config.bucketpath,img.config.local_file_cachedir,img.config.local_file_cachepath,fun)
		gmagick.run()
		

		--输出文件
		local len,content = fun.ngxoutputfile(img.config.local_file_cachepath)
		if len ~= nil then
		
		
			--fun.ngxflowstat(DetuYunFlowStat,DetuYunConfig,config.db,config.conn)	
			--开启线程处理
			--ngx.thread.spawn(fun.ngxflowstat, DetuYunFlowStat,DetuYunConfig,config.db,config.conn)	
			ngx.say(content)
			ngx.exit(200)
		end
		
	end
	
	function img:info()
		
	end
	
	
	--是否存在本地缓存
	function img:iscache(request_uri)
		local cachefile = img.config.local_file_cachepath
		
		local len,content = fun.ngxoutputfile(cachefile)
		if len ~= nil then
			

			ngx.say(content)
			ngx.exit(200)
		end
	end
	
	
	return img
end
return M