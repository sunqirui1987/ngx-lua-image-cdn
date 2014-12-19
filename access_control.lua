if ngx.var.request_uri == "" or ngx.var.request_uri == "/" then
	ngx.header["Content-Type"]="text/html; charset=utf-8"
	ngx.say("<h1>welcome use CDN</h1>")
	ngx.exit(200)
end

local json = require "json"
local fun = require "access_functions"


--除去?号结尾的字符
local requesturi = string.gsub(ngx.var.request_uri,"?.*","")
--除去//字符
bucketpath = string.gsub(requesturi,"//","/")

--连接mono数据库查出图片的元数据

--
--     略
--
--local filerow = filecol:find_one({path=bucketpath})

local username = filerow["username"]
local filesize = filerow["filesize"]
local isuploadoss = filerow["isuploadoss"]
local imageinfo = filerow["imageinfo"]
local extinfo = filerow["ext"] or "application/octet-stream"
local filecdate = filerow["cdate"]
local isuploadoss = filerow["isuploadoss"]
local imageinfoobj = json.decode(imageinfo)

local config = {bucketpath = "/"..bucketpath, imageinfo = imageinfoobj,filecdate = filecdate,requesturi=ngx.var.request_uri} 

if ngx.re.match(ngx.var.request_uri,"\.(jpg|jpeg|png|webp|gif)$","imjo")then
	--启动Server拦截 调用第三方服务
	local access_serverfilter = require("access_serverfilter").new(fun)
	access_serverfilter.run()

	--缩略图服务
	local imgapp = require("access_imagefilter").new(config,fun)
	imgapp.run()
	
end



local Is_Enter_OSS = false
local Is_Local = true --图片在本地

if DetuYunConfig.isIDC == true  then
	local path = "/data/img/".. config.path
	local file_exists_bool = fun.file_exists(path)
	
	if file_exists_bool == true then
		--IDC
		local idcapp = require("access_idc").new(config,DetuYunConfig,DetuYunFlowStat,fun,db)
		idcapp.run()
		--流量统计
		--开启线程处理
		--ngx.thread.spawn(fun.ngxflowstat)
	else
		Is_Enter_OSS = true
	end
	
end

--云存储服务器
if Is_Enter_OSS == true  then
	--OSS机房
	local ossapp = require("access_oss").new(fun)
	local status = ossapp.run()
	
	if status == 206 or status == 200 then
		--流量统计
		fun.ngxlog("OSS DetuYunFlowStat"..status)
		
		--开启线程处理
		--ngx.thread.spawn(fun.ngxflowstat)
	end

	ngx.exit(status)
end
