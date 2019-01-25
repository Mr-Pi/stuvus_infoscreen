local stuvus_logo = resource.load_image("stuvus_logo.png")
local stuvus_logo_h = 120
local stuvus_logo_w = 414
local stuvus_logo_speed = 5
local last_logo_rot_start = 0

local function print_logo()
	local x = sys.now() - last_logo_rot_start
	local y = x
	x = math.floor(x*stuvus_logo_w/stuvus_logo_speed*2)
	if x>stuvus_logo_w*2 then x = stuvus_logo_w*2 end
	if x>stuvus_logo_w then x = stuvus_logo_w*2-x end
	y = math.floor(y*stuvus_logo_h/stuvus_logo_speed*2)
	if y>stuvus_logo_h*2 then y = stuvus_logo_h*2 end
	if y>stuvus_logo_h then y = stuvus_logo_h*2-y end
	local x1 = x+50
	local y1 = 50+y/4
	local x2 = 50+stuvus_logo_w-x
	local y2 = 50+stuvus_logo_h
	stuvus_logo:draw(x1, y1, x2, y2)
end

local function rotate_logo()
	last_logo_rot_start = sys.now()
end

return {
	update = print_logo,
	start_rotate = rotate_logo,
}
