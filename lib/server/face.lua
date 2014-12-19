local M = {}
M.Serverurl = "http://apicn.faceplusplus.com/v2/"
M.ServerAPIKEY = ""
M.ServerAPISecret= ""
function M.invoke(method,url,arg)
	local puri = M.Serverurl..method.."?api_key="..M.ServerAPIKEY.."&api_secret="..M.ServerAPISecret.."&url="..url.."&"..arg
	
	local res = ngx.location.capture("/proxymirror",{ vars = { proxypath = puri}})

	for name, value in pairs(res.header) do
		if name ~= "Content-Disposition"    then
			ngx.header[name] = value
		end
		
	end
	
	ngx.say(res.body)
	ngx.exit(ngx.HTTP_OK)
end
return M