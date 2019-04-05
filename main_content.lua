local font_mono = resource.load_font("DejaVuSansMono.ttf")
local font_sans = resource.load_font("DejaVuSans.ttf")

local content_bg = resource.load_image("content_bg.png")
local weather_img_updated = sys.now()

local slides = {}
local images = {}
local slide_i = 1
local slide_prev = 1
local slide_time_start = 0
local width = 1080
local door_state = 'Unknown'

local function get_slide_time()
	return sys.now() - slide_time_start
end

local function get_slide_showtime()
	if slides[slide_i] then
		return slides[slide_i].showtime
	end
	return 0
end

local function init()
	print("Init main_content")
	util.json_watch("slides.json", function(new_slides)
		slides = new_slides
		images = {}
		for i_slide, slide in ipairs(slides) do
			images[i_slide] = {}
			for i_element, element in ipairs(slide.elements) do
				if element.type == "img" then
					images[i_slide][i_element] = {}
					images[i_slide][i_element].loading = resource.load_image(element.src)
					local state, w, h = images[i_slide][i_element].loading:state()
					if state == "loaded" then
						images[i_slide][i_element].img = images[i_slide][i_element].loading
						images[i_slide][i_element].w = w
						images[i_slide][i_element].h = h
					end
				end
			end
		end
	end)
end

local function draw_text(x, y, text, size, r, g, b, a, align)
	if align == "left" then
		font_sans:write(x, y, text, size, r, g, b, a)
	elseif align == "center" then
		local w = font_sans:width(text, size)
		font_sans:write(x+(width-w)/2, y, text, size, r, g, b, a)
	else
		local w = font_sans:width(text, size)
		font_sans:write(x+(width-w), y, text, size, r, g, b, a)
	end
end

local function draw_img(x, y, img, a, align)
	if align == "left" then
		img.img:draw(x, y, x+img.w, y+img.h, a)
	elseif align == "center" then
		img.img:draw(x+(width-img.w)/2, y, x+(width-img.w)/2+img.w, y+img.h, a)
	else
		img.img:draw(x+(width-img.w), y, x+(width-img.w)+img.w, y+img.h, a)
	end
end

local function draw_slide(x, y, id, a)
	for i, element in ipairs(slides[id].elements) do
		local r, g, b = 0, 0, 0
		if not element.color then element.color = {} end
		if element.color.r then r = element.color.r/255 end
		if element.color.g then g = element.color.g/255 end
		if element.color.b then b = element.color.b/255 end
		if not element.x then element.x = 0 end
		if not element.y then element.y = 0 end
		if not element.align then element.align = "left" end
		if not element.type then element.type = "text" end
		if element.type == "text" then
			if not element.text then element.text = "" end
			if not element.size then element.size = 50 end
			draw_text(x+element.x, y+element.y, element.text, element.size, r, g, b, a, element.align)
		elseif element.type == "header" then
			draw_text(x, y+30, element.text, 110, r, g, b, a, "center")
		elseif element.type == "img" then
			if images[id][i].img then
				draw_img(x+element.x, y+element.y, images[id][i], a, element.align)
			end
		end
	end
end

local function draw()
	local x = 550
	local y = 450
	content_bg:draw(x-25,y-25, x+1130-25, y+600-25, 0.2)
	if table.maxn(slides) < 1 then
		return
	end
	local a1 = get_slide_time()/1
	if a1 > 1 then a1 = 1 end
	local a2 = 1-a1
	draw_slide(x, y, slide_i, a1)
	if a2 > 0.001 then
		draw_slide(x, y, slide_prev, a2)
	end
end

local function t_1()
	if get_slide_time() >= slides[slide_i].showtime then
		slide_prev = slide_i
		repeat
			slide_i = slide_i + 1
			if slide_i > table.maxn(slides) then
				slide_i = 1
			end
		until not slides[slide_i].hidden
		slide_time_start = sys.now()
	end

	for i_slide, slide in ipairs(slides) do
		for i_element, element in ipairs(slide.elements) do
			if element.type == "img" then
				local state, w, h = images[i_slide][i_element].loading:state()
				if state == "loaded" then
					images[i_slide][i_element].w = w
					images[i_slide][i_element].h = h
					images[i_slide][i_element].img = images[i_slide][i_element].loading
					node.gc()
				end
				images[i_slide][i_element].loading = resource.load_image(element.src)
			end
		end
	end
end

return {
	get_slide_time = get_slide_time,
	get_slide_showtime = get_slide_showtime,
	init = init,
	update = draw,
	t_1 = t_1,
}
