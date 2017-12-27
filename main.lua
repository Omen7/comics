--pcall(function() require("mobdebug").start(debugIP) end) -- ZeroBrane debugger
--pcall(function() require("mobdebug").coro() end) -- Enable coroutine debug
-------------------------------------------- Main
local index = require("dependencies.index.index")("dependencies")
local screen = require("screen")
local comics = require("comics")
	
local function onComplete()
	print("DONE")
end
	
local comicOptions = {
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

local eventComicOptions = {
	animationSpeed = 10,
	skin = "intro",
	particlePath = "example/event/particlesComic/",
	frames = {
		[1] = {
			spine = "example/event/spines/frame1.json",
			useAtlas = "example/event/spines/frame1.atlas",
			animation = "FRAME1",
			loop = true,
			time = 10000,
			x = -230,
			y = 0
		},
		[2] = {
			spine = "example/event/spines/frame2.json",
			useAtlas = "example/event/spines/frame2.atlas",
			animation = "FRAME2",
			loop = false,
			time = 2000,
			x = 230,
			y = 0
		}
	},
	okayButton = {x = 175, y = 85},
	retryButton = {x = 175, y = 85},
	soundTapID = nil,
	soundButtonTapID = nil
}

local function createComic()
	local whiteBackground = display.newRect(screen.centerX, screen.centerY, screen.width, screen.height)	
	local comicGroup = comics.new(comicOptions, onComplete)
	comicGroup.x = screen.centerX
	comicGroup.y = screen.centerY
	comicGroup:play()
end

local function createEventComic()
	local whiteBackground = display.newRect(screen.centerX, screen.centerY, screen.width, screen.height)	
	local comicGroup = comics.new(eventComicOptions, onComplete)
	comicGroup.x = screen.centerX
	comicGroup.y = screen.centerY
	comicGroup:play()
end

--createComic()
createEventComic()