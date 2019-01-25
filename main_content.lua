local font_mono = resource.load_font("DejaVuSansMono.ttf")
local font_sans = resource.load_font("DejaVuSans.ttf")

local video = util.videoplayer("video.mp4", {
	audio = true;
	looped = true;
	paused = false;
})

local function draw()
	font_sans:write(520, 300, "TEST", 100, 0, 0, 0, 1)
	video:draw(520, 300, 520+720*1.8, 300+392*1.8)
end

return {
	update = draw,
}
