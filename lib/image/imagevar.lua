local imageVar = {}

function imageVar:tostring(obj)
	local lua = "img"
	for k, v in pairs(obj.img) do
		if v ~= "" then
			lua = lua .. "[" .. k .. "]=" .. v .. ","
		end
	end
	lua = lua .. "var"
	for k, v in pairs(obj.var) do
		if v ~= "" then
			lua = lua .. "[" .. k .. "]=" .. v .. ","
		end
	end
	return lua
end
function imageVar:new()
	local M = {}
	M.image = {}
	M.image.var = {}
	M.image.img = {}
	--图片元数据
	M.image.var.orginfile  = "" --原图地址
	M.image.var.isrefresh  = "" -- 是否强制刷新
	M.image.var.filecdate  = "" -- 图片创建时间
	M.image.var.imagewidth = 0  -- 图片原宽
	M.image.var.imageheight = 0 -- 图片原高

	----------------------------   图像处理基本参数 ----------------------
	--缩略图配置
	-- ?imageView/模式(1,2,3,4)/w/宽/h/高/q/质量/sharp/锐化
	--<mode>=1	同时指定宽度和高度，等比裁剪原图正中部分并缩放为x大小的新图片
	--<mode>=2	同时指定宽度和高度，原图缩小为不超出x大小的缩略图，避免裁剪长边
	--<mode>=2	仅指定宽度，高度等比缩小
	--<mode>=2	仅指定高度，宽度等比缩小
	M.image.img.thumbimageviewmodel = ""
	M.image.img.thumbwidth = ""
	M.image.img.thumbheight = ""


	----------------------------  水印配置处理基本参数 ----------------------
	-- ?imageView/image/地址/dissolve//dx//dy//gravity//gravity
	--//dissolve/50/gravity/SouthEast/dx/20/dy/20
	--水印配置
	M.image.img.waterimage =""
	M.image.img.watergravity = ""
	M.image.img.waterdissolve = ""
	M.image.img.waterdistancex = ""
	M.image.img.waterdistancey = ""
	

	-------------------------------高级图像处理参数 ----------------------------------

	--根据原图EXIF信息自动旋正，便于后续处理，建议放在首位
	M.image.img.autoorient = ""

	--?imageView/crop 裁剪
	-- w_100,h_150,c_scale 固定宽高
	-- w_100,h_150,c_fit 按原图的比例宽高进行裁剪
	-- w_100,h_150,c_fillg_NorthWest	
	-- 	NorthWest    |     North      |     NorthEast	
	-- --------------+----------------+--------------	
	-- West          |     Center     |          East 			
	-- --------------+----------------+--------------			
	-- SouthWest     |     South      |     SouthEast
	
	-- w_100,h_150,c_limit
	-- w_100,h_150,c_pad,g_south_east
	-- w_100,h_150,c_crop,g_north_west | w_0.4
	-- x_355,y_410,w_300,h_200,c_crop
	-- w_90,h_90,c_thumb,g_face
	M.image.img.crop = ""

	--图片质量
	M.image.img.quality = ""

	--旋转角度
	M.image.img.rotate = ""

	--锐化
	M.image.img.sharp = ""

	--图片格式，支持web|jpg|png|gif
	M.image.img.type  = ""

	---边框 w_4px,color_00390b
	M.image.img.border = ""
	
	--圆角 半径
	M.image.img.cycle  = ""

	--黑白照
	M.image.img.monochrome = ""

	--垂直翻转图像
	M.image.img.flip = ""

	--水平翻转图像
	M.image.img.flop = ""
	
	--炭笔效果 形成炭笔或者说是铅笔画的效果。 -charcoal 2 
	M.image.img.charcoal = ""
	
	--散射毛玻璃效果  -spread 30
	M.image.img.spread = ""
	
	--漩涡以图片的中心作为参照，把图片扭转，形成漩涡的效果： -swirl 67
	M.image.img.swirl = ""

	---凸起效果用 raise 5x5，照片的四周会一个5x5的边，如果你要一个凹下去的边，把-raise改为+raise就可以了。其实凸边和凹边看起来区别并不是很大。
	M.image.img.raise = ""
	
	--加文字 c_green,f_宋体,text_中文,x_10,y_20
	-- convert -fill green -pointsize 40 -font 宋体 -draw 'text 10,50 "charry.org"' foo.png bar.png
	M.image.img.font = ""
	
	--顺序
	M.image.img.interlace = ""

	--是否webp
	M.image.img.autowebp  = ""
	
	--高级滤镜
	--gotham lomo vignette
	M.image.img.filter = ""	

	return M
end

return imageVar