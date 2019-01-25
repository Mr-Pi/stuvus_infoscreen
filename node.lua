gl.setup(1920, 1080)

local backgroud = resource.load_image("stuvus_bg.png")

clock = require "clock"
json = require "json"
local stuvus_logo = require "stuvus_logo"
local trains = require "trains"
local main_content = require "main_content"

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
	backgroud:draw(0, 0, 1920, 1080)
	stuvus_logo.update()
	clock.update()
	trains.update()
	main_content.update()

	if not timers_set then
		util.set_interval(1, clock.tick)
		util.set_interval(10, stuvus_logo.start_rotate)
		timers_set = true
	end
end
