local font_mono = resource.load_font("DejaVuSansMono.ttf")
local font_sans = resource.load_font("DejaVuSans.ttf")

local vvs_logo = resource.load_image("VVS-Logo.png")
local s_logo = resource.load_image("s-bahn.png")
local bus_logo = resource.load_image("bus.png")
local s_logo_gray = resource.load_image("s-bahn-gray.png")
local bus_logo_gray = resource.load_image("bus-gray.png")

local departures = {}

local function draw_logo()
	local x = 50
	local y = 260
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

local lost_r = 190
local lost_d = 1
local function print_lost()
	lost_r = lost_r + lost_d/2
	if lost_r <= 10 or lost_r >= 200 then
		lost_r = math.floor(lost_r)
		lost_d = lost_d * -1
	end
	local y = 390
	local r = lost_r/255
	local g = 0.0
	local b = 0.0
	local trans = 1
	local time_sec = departures[1].departureTime.timestamp
	if time_sec < clock.get_timestamp() then
		time_sec = departures[2].departureTime.timestamp
	end
	local time_str = string.format('%2d:%02d Uhr', (time_sec/3600)%24, time_sec%3600/60)
	font_sans:write(100, y, "You", 120, r, g, b, trans)
	font_sans:write(60, y+125, "are", 100, r, g, b, trans)
	font_sans:write(80, y+235, "Lost", 120, r, g, b, trans)
--	font_sans:write(0, 0, r, 20, 0, 0, 0, 1)
	local r = 0
	local w1 = font_sans:write(50, y+420, "Nächste Bahn", 50, r, g, b, trans)
	local w2 = font_sans:width("fährt um", 50)
	font_sans:write(50+(w1-w2)/2, y+490, "fährt um", 50, r, g, b, trans)
	local w2 = font_mono:width(time_str, 70)
	font_mono:write(50+(w1-w2)/2, y+560, time_str, 70, r, g, b, trans)
end

local function print_departure(i, line, destination, departure, remaining_time)
	local y = i*80 + 390
	local r = 0
	local g = 0
	local b = 0
	local trans = 1
	local critical = false

	if remaining_time < 90 then
		r = 0.7
		g = 0.7
		b = 0.7
		critical = true
	elseif remaining_time < 5*60 then
		r = 0.9
	end

	if line:sub(0,1) == "S" then
		if critical then
			util.draw_correct(s_logo_gray, 50, y, 50+60, y+60)
		else
			util.draw_correct(s_logo, 50, y, 50+60, y+60)
		end
	else
		if critical then
			util.draw_correct(bus_logo_gray, 50, y, 50+60, y+60)
		else
			util.draw_correct(bus_logo, 50, y, 50+60, y+60)
		end
	end
	local w = font_mono:write(120, y+3, line, 60, r, g, b, trans)
	print_striped(120 + w + 10, y, 500, destination, 30, r, g, b, trans)
	font_sans:write(120 + w + 10, y+30, departure, 30, r, g, b, trans)
	return y+80
end

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

			if remaining_time > 120 then
				remaining_time_str = math.floor(remaining_time/60).." Minuten"
			elseif remaining_time >60 then
				remaining_time_str = "eine Minute"
			else
				remaining_time_str = "wenige Sekunden"
			end

			if remaining_time < 60*60 then  -- show only train within 60 mins
				print_departure(i, departure.number, departure.direction, remaining_time_str, remaining_time)
				i = i+1
			end
		end
	end
	if i < 1 then  -- no trains are shown
		print_lost()
	end
end

return {
	update = draw,
	update_departures = update_departures,
}
