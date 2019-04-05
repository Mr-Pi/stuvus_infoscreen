local door_state = "Unknown"

local function init()
	util.json_watch("door.json", function(new_door_state)
		door_state = new_door_state.state
	end)
end

local function draw_bar()
	local r = 200/255
	local g = 200/255
	local b = 0
	if door_state == 'Closed' then
		g = 0
	elseif door_state == 'Open' then
		r = 0
	end
	local bar = resource.create_colored_texture(r, g, b, 1)
	local w_max = (2*WIDTH+2*HEIGHT)
	local w = w_max/main_content.get_slide_showtime()*main_content.get_slide_time()
	local w1 = w
	local w2 = w-WIDTH
	local w3 = w-WIDTH-HEIGHT
	local w4 = w-2*WIDTH-HEIGHT
	if w1 > WIDTH then w1 = WIDTH end
	if w2 < 0 then w2 = 0 elseif w2 > HEIGHT then w2 = HEIGHT end
	if w3 < 0 then w3 = 0 elseif w3 > WIDTH then w3 = WIDTH end
	if w4 < 0 then w4 = 0 elseif w4 > HEIGHT then w4 = HEIGHT end
	bar:draw(0, 0, w1, 10)
	bar:draw(WIDTH-10, 0, WIDTH, w2)
	bar:draw(WIDTH, HEIGHT-10, WIDTH-w3, HEIGHT)
	bar:draw(0, HEIGHT, 10, HEIGHT-w4)
end


return {
	init = init,
	update = draw_bar,
}
