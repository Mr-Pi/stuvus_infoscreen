gl.setup(1680, 1050)

local backgroud = resource.load_image("stuvus_bg.png")

clock = require "clock"
json = require "json"
local stuvus_logo = require "stuvus_logo"
local trains = require "trains"
main_content = require "main_content"
local door = require "door"

util.no_globals()

util.data_mapper{
	["clock/set"] = clock.set_time
}
node.event("input", function(line, _)
	trains.update_departures(line)
end)

local timers_set = false
function node.render()
	gl.clear(1, 1, 1, 1)
	backgroud:draw(0, 0, 1680, 1050)
	stuvus_logo.update()
	clock.update()
	trains.update()
	main_content.update()
	door.update()

	if not timers_set then
		main_content.init()
		door.init()
		util.set_interval(1, clock.tick)
		util.set_interval(10, stuvus_logo.start_rotate)
		util.set_interval(1, main_content.t_1)
		timers_set = true
	end
end
