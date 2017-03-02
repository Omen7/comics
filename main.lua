-------------------------------------------- Main
local index = require("dependencies.index.index")("dependencies")
local screen = require("screen")
local comics = require("comics")
	
local options = {
	animationSpeed = 10,
	skin = "intro",
	frames = {
		[1] = {
			spine = "example/intro/frame1.json",
			useAtlas = "example/intro/frame1.atlas",
			animation = "FRAME1",
			loop = false,
			time = 2000,
			x = -190,
			y = -200
		},
		[2] = {
			spine = "example/intro/frame2.json",
			useAtlas = "example/intro/frame2.atlas",
			animation = "FRAME2",
			loop = false,
			time = 2000,
			x = 185,
			y = -199
		},
		[3] = {
			spine = "example/intro/frame3.json",
			useAtlas = "example/intro/frame3.atlas",
			animation = "FRAME3",
			loop = false,
			time = 2000,
			x = -253,
			y = -30
		},
		[4] = {
			spine = "example/intro/frame4.json",
			useAtlas = "example/intro/frame4.atlas",
			animation = "FRAME4",
			loop = false,
			time = 2000,
			x = 5,
			y = -25
		},
		[5] = {
			spine = "example/intro/frame5.json",
			useAtlas = "example/intro/frame5.atlas",
			animation = "FRAME5",
			loop = true,
			time = 2000,
			x = 260,
			y = -26
		},
		[6] = {
			spine = "example/intro/frame6.json",
			useAtlas = "example/intro/frame6.atlas",
			animation = "FRAME6",
			loop = false,
			time = 2000,
			x = -260,
			y = 144
		},
		[7] = {
			spine = "example/intro/frame7.json",
			useAtlas = "example/intro/frame7.atlas",
			animation = "FRAME7",
			loop = false,
			time = 2000,
			x = 122,
			y = 138
		}
	},
	okayButton = {x = 175, y = 85},
	retryButton = {x = 175, y = 85},
	soundTapID = nil,
	soundButtonTapID = nil
}

local function onComplete()
	print("DONE")
end

local whiteBackground = display.newRect(screen.centerX, screen.centerY, screen.width, screen.height)

local comicGroup = comics.new(options, onComplete)
comicGroup.x = screen.centerX
comicGroup.y = screen.centerY

comicGroup:play()