local font = resource.load_font("AverageMono.ttf")
-- width: 60px

local view_dot = true
local base_time = 0

local function get_timestamp()
	local now = sys.now() + base_time
	return now
end

local function print_time()
	local size = 450
	local width = size/2
	local now = get_timestamp()
	local h = string.format('%2d', (now/3600)%24)
	local m = string.format('%02d', now%3600/60)
	font:write(1680-width*2-150, 25, m, size, 0, 0, 0, 0.5)
	if view_dot then
		font:write(1680-width*3-100, -20, ":", size, 0, 0, 0, 0.5)
	end
	font:write(1680-width*5-100, 25, h, size, 0, 0, 0, 0.5)
end

local function change_view_dot()
	if view_dot then
		view_dot = false
	else
		view_dot = true
	end
end

local function set_time(time)
	local itertime = time:gmatch('[0-9.]+')
	time = itertime()
	local weekday = itertime()
	local day = itertime()
	local month = itertime()
	local year = itertime()
	base_time = time - sys.now()
	print('time update', base_time, weekday, day, month, year)
end

return {
	update = print_time,
	tick = change_view_dot,
	set_time = set_time,
	get_timestamp = get_timestamp,
}
