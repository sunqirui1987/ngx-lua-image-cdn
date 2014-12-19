--滤镜
--裁剪
--异形图
--旋转
--IDC机房
local M = {}
function M.new(imagevar,bucketpath,local_file_cachedir,local_file_cachepath,fun)
	
	local arg = {}
	arg.local_file_out_folder = local_file_cachedir
	arg.local_file_out_path = local_file_cachepath	
	arg.imagevar = imagevar	
	arg.bucketpath = bucketpath
	
	local gm = {}
	gm.arg = {}
	
	gm.run = function ()
		
		
		
		local orginfile = arg.imagevar.var.orginfile
		local abs_file  = arg.local_file_out_path
		
		--创建目录
		local mkdir_command ="mkdir  -p  "..arg.local_file_out_folder.." >/dev/null 2>&1 "
		os.execute(mkdir_command)

		
		local commandtool = "/usr/local/bin/gm "
		
		
		gm.resize()
		gm.crop()
		gm.border()
		gm.font()
		
		local thumb_convert_command = ""
		--命令集
		local argcommand = gm.gmextraarg()
		thumb_convert_command = thumb_convert_command .. argcommand

		--如果开启了图片托管模式。则先下载图片
		if  fun.file_exists(orginfile) == false then
			 local temp_orginfile = arg.local_file_out_path
			 fun.ngxproxyossdownload(arg.bucketpath,temp_orginfile)
			 orginfile = temp_orginfile
			
		end

		--缩略图
		if true then --thumb_convert_command  ~= "" then
			local convertcommandstr = commandtool.." convert +profile '*' -strip  "..thumb_convert_command.." "..orginfile.."  "..abs_file
			ngx.log(ngx.WARN,convertcommandstr)
			os.execute(convertcommandstr)
			
			if fun.file_exists(abs_file) == true then
				orginfile = abs_file  --将目标图作为当前原图
			end
		end
		
		--水印
		local water_convert_command = gm.water()
		if water_convert_command ~= nil then				
			local compositecommandstr = commandtool.." composite "..water_convert_command.." "..orginfile.."  "..abs_file
			fun.ngxlog(compositecommandstr)
			os.execute(compositecommandstr)
			if fun.file_exists(abs_file) == true then
				orginfile = abs_file  --将目标图作为当前原图
			end
		end


	end
	
	
	gm.gmextraarg = function ()
		local convert_command_arg = ""
				
		--自动修正  -auto-orient		
		if fun.isemptyorzero(arg.imagevar.img.autoorient) == false  then
			convert_command_arg = convert_command_arg.." -auto-orient "
		end
		
		--质量
		if fun.isemptyorzero(arg.imagevar.img.quality) == false and tonumber(arg.imagevar.img.quality) ~= nil then
			convert_command_arg = convert_command_arg.." -quality "..arg.imagevar.img.quality;
		end
		
		-- 水平翻转图像
		if fun.isemptyorzero(arg.imagevar.img.flop) == false then
			convert_command_arg = convert_command_arg.." -flop "
		end
		
		-- 垂直翻转图像
		if fun.isemptyorzero(arg.imagevar.img.flip) == false then
			convert_command_arg = convert_command_arg.." -flip "
		end
		
		--黑白照
		if fun.isemptyorzero(arg.imagevar.img.monochrome) == false then
			convert_command_arg = convert_command_arg.." -monochrome "
		end
		
		--炭笔效果
		if fun.isemptyorzero(arg.imagevar.img.charcoal) == false then
			convert_command_arg = convert_command_arg.." -charcoal 2"
		end
		
		--散射毛玻璃效果
		if fun.isemptyorzero(arg.imagevar.img.spread) == false then
			convert_command_arg = convert_command_arg.." -spread 30 "
		end
		
		--漩涡
		if fun.isemptyorzero(arg.imagevar.img.swirl) == false then
			convert_command_arg = convert_command_arg.." -swirl 67 "
		end
		--漩涡
		if fun.isemptyorzero(arg.imagevar.img.raise) == false then
			convert_command_arg = convert_command_arg.." -raise 5x5 "
		end			
		
		--翻转
		if fun.isemptyorzero(arg.imagevar.img.rotate) == false and tonumber(arg.imagevar.img.rotate) ~= nil  then
			convert_command_arg = convert_command_arg.." -rotate "..arg.imagevar.img.rotate
		end
		--锐化
		if fun.isemptyorzero(arg.imagevar.img.sharp) == false and arg.imagevar.img.sharp == "on" then
			convert_command_arg = convert_command_arg.." -unsharp 1.5x1.0+0.8+0.03  "
		end
		--流顺序
		if fun.isemptyorzero(arg.imagevar.img.interlace) == false then
			convert_command_arg = convert_command_arg.." -interlace "..arg.imagevar.img.interlace
		end
		
			
		if fun.isemptyorzero(gm.arg.background) == false then
			convert_command_arg = convert_command_arg.." -background "..gm.arg.background
		end
		
		if fun.isemptyorzero(gm.arg.resize) == false then
			convert_command_arg = convert_command_arg.." -resize "..gm.arg.resize
		end
		
		if fun.isemptyorzero(gm.arg.gravity) == false then
			convert_command_arg = convert_command_arg.." -gravity "..gm.arg.gravity
		end
		
		if fun.isemptyorzero(gm.arg.crop) == false then
			convert_command_arg = convert_command_arg.." -crop "..gm.arg.crop
		end
		
		if fun.isemptyorzero(gm.arg.extent) == false then
			convert_command_arg = convert_command_arg.." -extent "..gm.arg.extent
		end
		
		
		--圆角
		if fun.isemptyorzero(arg.imagevar.img.cycle  ) == false and tonumber(arg.imagevar.img.cycle ) ~= nil  then
			convert_command_arg = convert_command_arg.." -cycle   "..arg.imagevar.img.cycle  
		end
		
		--边框
		if fun.isemptyorzero(gm.arg.borderwidth) == false then
			convert_command_arg = convert_command_arg.." -border  "..gm.arg.borderwidth.."x"..gm.arg.borderwidth
		end
		if fun.isemptyorzero(gm.arg.bordercolor) == false then
			convert_command_arg = convert_command_arg.." -bordercolor  \""..gm.arg.bordercolor.."\""
		end
		
		--字体水印
		if fun.isemptyorzero(gm.arg.font_obj_str) == false then
			convert_command_arg = convert_command_arg.."  "..gm.arg.font_obj_str
		end
		
		
		return convert_command_arg
	end
	
	
	
	--缩略
	gm.resize = function ()
		
		local thumbwidth = arg.imagevar.img.thumbwidth
		local thumbheight = arg.imagevar.img.thumbheight
		
		ngx.log(ngx.WARN,"gm.arg.resize thumbwidth"..thumbwidth..": thumbheight"..thumbheight)
		--如果宽高都不存在。则返回nil
		if  tonumber(thumbheight) == nil  and tonumber(thumbwidth) == nil then
			return nil
		end
		
		--如果宽高不为数字，则 设置数字0
		if  thumbheight ~=nil and tonumber(thumbheight) == nil  then
			thumbheight = 0
		end
		if  thumbwidth ~=nil and tonumber(thumbwidth) == nil  then
			thumbwidth = 0
		end
		
		
		
		--如果小于1，则是百分比
		if fun.isemptyorzero(thumbwidth) == false  and tonumber(thumbwidth) < 1  then
			thumbwidth = thumbwidth * arg.imagevar.var.imagewidth
		end
		if fun.isemptyorzero(thumbheight) == false  and tonumber(thumbheight) < 1  then
			thumbheight = thumbheight * arg.imagevar.var.imageheight
		end
		
		--检查参数
		if arg.imagevar.var.imagewidth  and  fun.isemptyorzero(thumbwidth) == false and tonumber(arg.imagevar.var.imagewidth) < tonumber(thumbwidth) then
			thumbwidth= tonumber(arg.imagevar.var.imagewidth)
		end
		if arg.imagevar.var.imageheight and fun.isemptyorzero(thumbheight) == false and tonumber(arg.imagevar.var.imageheight) < tonumber(thumbheight) then
			thumbheight = tonumber(arg.imagevar.var.imageheight)
		end
		
		
		--缩略模式
		local imageviewmodel  = arg.imagevar.img.thumbimageviewmodel
		if fun.isemptyorzero(imageviewmodel) == true then
			imageviewmodel = "4"
		end
		
		--如果 thumbwidth == nil .则限定高
		if  fun.isemptyorzero(thumbwidth) == true and fun.isemptyorzero(thumbheight) == false  then
			gm.arg.resize = "x"..thumbheight.."^"
			--如果 thumbheight == nil .则限定宽
		elseif  fun.isemptyorzero(thumbheight) == true and fun.isemptyorzero(thumbwidth) == false then
			gm.arg.resize = thumbwidth.."x"
			--如果thumbwidth与thumbheight同时存在
		elseif fun.isemptyorzero(thumbwidth) == false and  fun.isemptyorzero(thumbheight) == false  then			
			gm.arg.resize = thumbwidth.."x"..thumbheight
		end
		
		
		--缩略处理
		if tostring(imageviewmodel) == "1" and fun.isemptyorzero(thumbwidth) == false  then
			gm.arg.resize = thumbwidth.."x"
		elseif tostring(imageviewmodel) == "2"   and fun.isemptyorzero(thumbheight) == false then
			gm.arg.resize = "x"..thumbheight.."^"
		elseif tostring(imageviewmodel) == "3"  and fun.isemptyorzero(thumbwidth) == false  and fun.isemptyorzero(thumbheight) == false then
			gm.arg.resize = thumbwidth.."x"..thumbheight.."^"
			gm.arg.gravity = "Center"
			gm.arg.crop = thumbwidth.."x"..thumbheight.."+0+0"
		elseif tostring(imageviewmodel) == "4"  and fun.isemptyorzero(thumbwidth) == false  and fun.isemptyorzero(thumbheight) == false then
			gm.arg.resize = thumbwidth.."x"..thumbheight
		end
		
		ngx.log(ngx.WARN,"gm.arg.resize "..gm.arg.resize)
	end
	
	
	
	--裁剪
	gm.crop = function ()
		
		if fun.isemptyorzero(arg.imagevar.img.crop) == true then
			return nil
		end
		
		
		local crop_obj = {}
		local key_name_arr = fun.split(arg.imagevar.img.crop,",")
		for index,value in pairs(key_name_arr) do
			if value ~= "" then
				local pair_name_arr = fun.split(value,"_")
				for pairindex,pairvalue in pairs(pair_name_arr) do
					if pairvalue == "w" then
						crop_obj.width    = pair_name_arr[pairindex + 1]  or ""
					elseif pairvalue == "h" then
						crop_obj.height   = pair_name_arr[pairindex + 1]  or ""
					elseif pairvalue == "c" then
						crop_obj.crop     = pair_name_arr[pairindex + 1]  or ""
					elseif pairvalue == "g" then --face faces
						crop_obj.gravity  = pair_name_arr[pairindex + 1]  or ""
					elseif pairvalue == "x" then
						crop_obj.x  = pair_name_arr[pairindex + 1]  or ""
					elseif pairvalue == "y" then
						crop_obj.y  = pair_name_arr[pairindex + 1]  or ""
					end
				end
			end
		end
		
		
		--裁剪模式
		if fun.isemptyorzero(crop_obj.crop) == true then
			crop_obj.crop = "crop"
		end
		
		local thumbwidth = crop_obj.width
		local thumbheight = crop_obj.height
		
		--如果宽高都不存在。则返回nil
		if  tonumber(thumbheight) == nil  and tonumber(thumbwidth) == nil then
			return nil
		end
		
		--如果小于1，则是百分比
		if fun.isemptyorzero(thumbwidth) == false and tonumber(thumbwidth) < 1  then
			thumbwidth = thumbwidth * arg.imagevar.var.imagewidth
		end
		if fun.isemptyorzero(thumbheight) == false and tonumber(thumbheight) < 1  then
			thumbheight = thumbheight * arg.imagevar.var.imageheight
		end
		
		
		
		--crop的X，Y位置
		if crop_obj.x == nil or tonumber(crop_obj.x) == nil then
			crop_obj.x =  0
		end
		if crop_obj.y == nil or tonumber(crop_obj.y) == nil then
			crop_obj.y =  0
		end
		if tonumber(crop_obj.x) >= 0 then
			crop_obj.x = "+"..crop_obj.x			
		end
		if tonumber(crop_obj.y) >= 0 then
			crop_obj.y = "+"..crop_obj.y			
		end
		
		--位置
		gm.arg.gravity = crop_obj.gravity
		if gm.arg.gravity == nil then
			gm.arg.gravity =  "center"
		end
		
		--宽度都存在的情况
		if  tonumber(thumbheight) ~= nil  and tonumber(thumbwidth) ~= nil then
			
			-- scale （固定） fill lfill fit limit pad lpad crop thumb
			if crop_obj.crop == "scale" then  -- 固定大小
				gm.arg.resize = thumbwidth.."x"..thumbheight.."!"
			elseif  crop_obj.crop == "fit" then
				gm.arg.resize = thumbwidth.."x"..thumbheight..""
			elseif  crop_obj.crop == "fill" then
				gm.arg.resize = thumbwidth.."x"..thumbheight.."^"
			elseif  crop_obj.crop == "limit" then
				gm.arg.resize = thumbwidth.."x"..thumbheight.."^"
			elseif  crop_obj.crop == "pad" then
				gm.arg.resize = thumbwidth.."x"..thumbheight..""
				gm.arg.background = "white"
				gm.arg.extent =  thumbwidth.."x"..thumbheight..""
				gm.arg.gravity = "center"
			elseif  crop_obj.crop == "crop" then				
				gm.arg.crop = thumbwidth.."x"..thumbheight..crop_obj.x..crop_obj.y				
			end
		end
		
	end
	
	
	
	--边框
	gm.border = function ()
		if fun.isemptyorzero(arg.imagevar.img.border) == true then
			return nil
		end
		
		
		local border_obj = {}
		local key_name_arr = fun.split(arg.imagevar.img.border,",")
		for index,value in pairs(key_name_arr) do
			if value ~= "" then
				local pair_name_arr = fun.split(value,"_")
				for pairindex,pairvalue in pairs(pair_name_arr) do
					if pairvalue == "w" then
						border_obj.width    = pair_name_arr[pairindex + 1]  or ""
					elseif pairvalue == "c" then
						border_obj.color   = pair_name_arr[pairindex + 1]  or ""					
					end
				end
			end
		end
		
		if border_obj.width ~= nil and tonumber(border_obj.width) ~= nil and border_obj.color  ~= nil then
			gm.arg.borderwidth = border_obj.width 
			gm.arg.bordercolor = border_obj.color
		end
		
	end
	
	--文字
	gm.font = function ()
		if fun.isemptyorzero(arg.imagevar.img.font) == true then
			return nil
		end
		
		
		-- c_green,f_宋体,t_中文,x_10,y_20
		local font_obj = {}
		local key_name_arr = fun.split(arg.imagevar.img.font,",")
		for index,value in pairs(key_name_arr) do
			if value ~= "" then
				local pair_name_arr = fun.split(value,"_")
				for pairindex,pairvalue in pairs(pair_name_arr) do
					if pairvalue == "c" then
						font_obj.fill    = pair_name_arr[pairindex + 1]  or ""
					elseif pairvalue == "s" then
						font_obj.size    = pair_name_arr[pairindex + 1]  or ""
					elseif pairvalue == "f" then
						font_obj.font   = pair_name_arr[pairindex + 1]  or ""
						font_obj.font = fun.urldecode(font_obj.font)		
					elseif pairvalue == "t" then						
						font_obj.text   = pair_name_arr[pairindex + 1]  or ""	
						font_obj.text = fun.urldecode(font_obj.text)	
					elseif pairvalue == "x" then
						font_obj.x   = pair_name_arr[pairindex + 1]  or ""		
					elseif pairvalue == "y" then
						font_obj.y   = pair_name_arr[pairindex + 1]  or ""	
					elseif pairvalue == "g" then
						font_obj.gravity   = pair_name_arr[pairindex + 1]  or ""					
					end
				end
			end
		end

		--如果文件不存在
		if font_obj.text == nil then
			return nil
		end
		
		
		--gm convert -size 320x200 xc:white -font Arial -fill blue -encoding	Unicode -draw "text 100,100 ' \321\202\320\265\321\201\321\202'"		foo.png
		
		local font_obj_str = " "
		
		if font_obj.font ~= nil then
			font_obj_str = font_obj_str.." -font "..font_obj.font
		else
			font_obj_str = font_obj_str.." -font  Arial"
		end			
		if font_obj.fill ~= nil then
			font_obj.fill = string.gsub(font_obj.fill,"0x","#")
			font_obj_str = font_obj_str.." -fill '"..font_obj.fill.."'"
		else
			font_obj_str = font_obj_str.." -fill red"
		end
		
		if font_obj.size ~= nil then
			font_obj_str = font_obj_str.." -pointsize "..font_obj.size
		else
			font_obj_str = font_obj_str.." -pointsize 18"
		end
		
		font_obj_str = font_obj_str.." -encoding Unicode "
		
		if font_obj.gravity ~= nil then
			font_obj_str = font_obj_str.." -gravity "..font_obj.gravity
		end						
		if font_obj.text ~= nil and font_obj.x ~= nil and font_obj.y ~= nil  then		
			font_obj_str = font_obj_str.." -draw 'text "..font_obj.x..","..font_obj.y.." \""..font_obj.text.."\"'"
		end			

		gm.arg.font_obj_str = font_obj_str		
	end
	
	
	
	----------------------------------独立功能块--------------------------------------------
	--水印
	gm.water = function ()
		local waterimage = arg.imagevar.img.waterimage
		local waterdissolve = arg.imagevar.img.waterdissolve
		local waterdistancex = arg.imagevar.img.waterdistancex
		local waterdistancey = arg.imagevar.img.waterdistancey
		local watergravity = arg.imagevar.img.watergravity
		
		if  fun.isemptyorzero(waterimage) == false and
			fun.isemptyorzero(waterdissolve) == false  and
			fun.isemptyorzero(watergravity) == false  and
			fun.isemptyorzero(waterdistancex) == false  and
			fun.isemptyorzero(waterdistancey) == false  then
			local waterdistancex_str = "+"..waterdistancex
			if tonumber(waterdistancex) < 0 then
				waterdistancex_str = "-"..waterdistancex
			end
			
			local waterdistancey_str = "+"..waterdistancey
			if tonumber(waterdistancey) < 0 then
				waterdistancey_str = "-"..waterdistancey
			end
			
			--local water_orginfile = abs_file
			
			--水印地址
			waterimage = fun.urldecode(waterimage)
			local tmpwaterimage = DetuYunConfig.storePath.."/"..waterimage

			--如果开启了阿里云图片托管模式。则先下载图片
			if DetuYunConfig.isAliyunServerImage == true and fun.file_exists(tmpwaterimage) == false then
				 fun.ngxproxyossdownload(DetuYunConfig,"/"..waterimage,tmpwaterimage)
			end
			waterimage = tmpwaterimage
			
			--执行命令
			local water_convert_command = " -gravity "..watergravity.."  -geometry "..waterdistancex_str..waterdistancey_str.."  "
			water_convert_command = water_convert_command.. " -dissolve "..waterdissolve
			water_convert_command = water_convert_command.. " "..waterimage.." " --..water_orginfile.." "..abs_file
			
			return water_convert_command
		end
		return nil
	end
	
	return gm
	
end
return M
