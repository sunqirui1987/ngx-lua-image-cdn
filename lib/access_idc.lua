--IDC机房
local M = {}
function M.new(config,fun)
	local app = {}
	if type(config) ~= "table" then config = {} end
	if type(config.path) ~= "string" then config.path = "" end
	app.config = config
	
	
	function app.run()
		
		--Requests per second:    8088.27 [#/sec] (mean)
		fun.ngxlog("idc app.config.path"..app.config.path)
		ngx.req.set_uri(app.config.path)
	end
		
	return app
end
return M
