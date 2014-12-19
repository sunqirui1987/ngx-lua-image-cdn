local M = {}
M.Serverurl = "http://rekognition.com/func/api/"
M.ServerAPIKEY = "4321"
M.ServerAPISecret= "8765"
M.ServerNameSpace =  "apiDemo"
M.ServerUserID =  "apiDemo"
function M.invoke(method,url,arg)
	local puri = M.Serverurl.."?api_key="..M.ServerAPIKEY.."&api_secret="..M.ServerAPISecret.."&jobs="..method
	puri = puri .."&user_id="..M.ServerUserID.."&name_space="..M.ServerNameSpace.."&urls="..url.."&"..arg
	ngx.log(ngx.WARN,"puri"..puri)
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