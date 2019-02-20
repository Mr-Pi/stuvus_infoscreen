local font_mono = resource.load_font("DejaVuSansMono.ttf")
local font_sans = resource.load_font("DejaVuSans.ttf")

local vvs_logo = resource.load_image("VVS-Logo.png")
local s_logo = resource.load_image("s-bahn.png")
local bus_logo = resource.load_image("bus.png")

local function draw_logo()
	local x = 50
	local y = 290
	vvs_logo:draw(x, y, x+80, y+76)
	font_sans:write(80+50+20, y+26, "Abfahrten", 50, 0, 0, 0, 1)
end

local function print_striped(x, y, max_x, text, size, r, g, b, trans)
	if font_sans:width(text, size)+x <= max_x then
		font_sans:write(x, y, text, size, r, g, b, trans)
	else
		local c = text:len()
		while font_sans:width(text:sub(0,c).."...", size)+x > max_x and c > 0 do
			c = c-1
		end
		font_sans:write(x, y, text:sub(0,c).."...", size, r, g, b, trans)
	end
end

local function print_departure(i, line, destination, departure, critical)
	local y = i*80 + 410
	local r = 0
	local g = 0
	local b = 0
	local trans = 1

	if critical then
		r = 1
	end

	if line:sub(0,1) == "S" then
		util.draw_correct(s_logo, 50, y, 50+60, y+60)
	else
		util.draw_correct(bus_logo, 50, y, 50+60, y+60)
	end
	local w = font_mono:write(120, y+3, line, 60, r, g, b, trans)
	print_striped(120 + w + 10, y, 500, destination, 30, r, g, b, trans)
	font_sans:write(120 + w + 10, y+30, departure, 30, r, g, b, trans)
	return y+80
end

local departures = {}

local function update_departures(departures_str)
	departures = json.decode(departures_str)
end

local function draw()
	draw_logo()

	local i = 0
	for _, departure in ipairs(departures) do
		local remaining_time = departure.departureTime.timestamp-clock.get_timestamp()
		if i < 8 and remaining_time > 0 then
			local remaining_time_str = ""
			local critical = false

			if remaining_time > 120 then
				remaining_time_str = math.floor(remaining_time/60).." Minuten"
			elseif remaining_time >60 then
				remaining_time_str = "eine Minute"
				critical = true
			else
				remaining_time_str = "wenige Sekunden"
				critical = true
			end

			print_departure(i, departure.number, departure.direction, remaining_time_str, critical)
			i = i+1
		end
	end
end

return {
	update = draw,
	update_departures = update_departures,
}
