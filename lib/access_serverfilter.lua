local M = {}
function M.new(fun)
    local app = {}
    if type(config) ~= "table" then config = {} end
    if type(config.path) ~= "string" then config.path = "" end
    app.config = config
    
    function app.run()
        local uri_args_table = ngx.req.get_uri_args()
        if uri_args_table["imagetype"] ~= nil and uri_args_table["imagetype"] == "imageserver" then
            local imageservertype = ""
            local imageservermethod = ""
            local imageserverarg = ""

            if uri_args_table["stype"] ~= nil then
                imageservertype  = uri_args_table["stype"]
            end

            if uri_args_table["smethod"] ~= nil then
                imageservermethod  = fun.urldecode(uri_args_table["smethod"])
            end

            if uri_args_table["sarg"] ~= nil then
                imageserverarg  = fun.urldecode(uri_args_table["sarg"])
            end


            --requireurl
            local requesturi = string.gsub(ngx.var.request_uri,"?.*","")
            --除去//字符
            requesturi = string.gsub(requesturi,"//","/")

            ---后缀样式
            --取？后面的字符串
            local qstring_uri = string.gsub(ngx.var.request_uri,"[^?].*?","")
            --删除以&后面的字条串
            qstring_uri = string.gsub(qstring_uri,"&.*","")

            requesturi = requesturi.."?"..qstring_uri
            if uri_args_table["token"] ~= nil then
                requesturi  = requesturi.."&token="..uri_args_table["token"] 
            end
            if uri_args_table["expires"] ~= nil then
                requesturi  = requesturi.."&expires="..uri_args_table["expires"] 
            end
            requesturi  = "http://"..ngx.var.http_host..requesturi
            requesturi  = app.urlencode(requesturi)

            
            --face
            if imageservertype == "face" then
                require("server/face").invoke(imageservermethod,requesturi,imageserverarg)
            elseif  imageservertype == "rekogni"  then
                require("server/rekogni").invoke(imageservermethod,requesturi,imageserverarg)
            end
        end
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
