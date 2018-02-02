pcall(function() require("mobdebug").start(debugIP) end) -- ZeroBrane debugger
pcall(function() require("mobdebug").coro() end) -- Enable coroutine debug
-------------------------------------------- Main
local index = require("dependencies.index.index")("dependencies")
local screen = require("screen")
local comics = require("comics")
local localization = require("localization")
	
local function onComplete(event)
	display.remove(event.target)
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

local interactiveComicOptions = {
	animationSpeed = 10,
	skin = "eagle",
	isInteractive = true,
	onCompleteDelay = 6500,
	frames = {
		[1] = {
			animationEvents = {
				["INTRO"] = {
					onComplete = function(event)
						if event.loopCount >= 1 then
							event.target:setAnimation("IDLE", {loop = true, fade = 0.2})
						end
					end
				},
				["SOLVED"] = {}
			},
			interactivity = {
				delay = 2500,
				{
					question = {
						operation = "3 Asteroids = ",
						fontSize = 65, 
					},
					answers = {
						{
							defaultPath = "example/interactivity/answers/K/q01/01_on.png",
							overPath = "example/interactivity/answers/K/q01/01_off.png",
							scale = 0.85,
							isCorrect = false
						},
						{
							defaultPath = "example/interactivity/answers/K/q01/03_on.png",
							overPath = "example/interactivity/answers/K/q01/03_off.png",
							scale = 0.85,
							isCorrect = true
						},
						{
							defaultPath = "example/interactivity/answers/K/q01/02_on.png",
							overPath = "example/interactivity/answers/K/q01/02_off.png",
							scale = 0.85,
							isCorrect = false
						}
					}
				},
				{
					question = {
						operation = "2 + 3 = ",
						fontSize = 80, 
					},
					answers = {
						{
							text = "4", 
							fontSize = 80,
							isCorrect = false
						},
						{
							text = "6", 
							fontSize = 80,
							isCorrect = false
						},
						{
							text = "5", 
							fontSize = 80,
							isCorrect = true
						}
					}
				},
				{
					question = {
						imagePath = "example/interactivity/rocket.png",
						repeatAmount = 7,
					},
					answers = {
						{
							text = "8", 
							fontSize = 80,
							isCorrect = false
						},
						{
							text = "9", 
							fontSize = 80,
							isCorrect = false
						},
						{
							text = "7", 
							fontSize = 80,
							isCorrect = true
						}
					}
				},
				{
					question = {
						firstText = "7 - ",
						secondText = "- 9 - 10",
						fontSize = 80,
					},
					answers = {
						{
							text = "4", 
							fontSize = 80,
							isCorrect = false
						},
						{
							text = "6", 
							fontSize = 80,
							isCorrect = false
						},
						{
							text = "8", 
							fontSize = 80,
							isCorrect = true
						}
					}
				},
				{
					question = {
						imagePath = "example/interactivity/dice.png",
					},
					answers = {
						{
							text = "5", 
							fontSize = 80,
							isCorrect = false
						},
						{
							text = "9", 
							fontSize = 80,
							isCorrect = false
						},
						{
							text = "8", 
							fontSize = 80,
							isCorrect = true
						}
					}
				},
				{
					question = {
						text = "Which has MORE?",
						fontSize = 55, 
					},
					answers = {
						{
							defaultPath = "example/interactivity/answers/K/q08/03_on.png",
							overPath = "example/interactivity/answers/K/q08/03_off.png",
							x = -190, 
							y = 270,
							scale = 0.85,
							isCorrect = false
						},
						{
							defaultPath = "example/interactivity/answers/K/q08/05_on.png",
							overPath = "example/interactivity/answers/K/q08/05_off.png",
							x = 190, 
							y = 270,
							scale = 0.85,
							isCorrect = true
						},
					}
				},
				{
					question = {
						text = "Which has LESS?",
						fontSize = 55, 
					},
					answers = {
						{
							defaultPath = "example/interactivity/answers/K/q09/02_on.png",
							overPath = "example/interactivity/answers/K/q09/02_off.png",
							x = -190, 
							y = 270,
							scale = 0.85,
							isCorrect = true
						},
						{
							defaultPath = "example/interactivity/answers/K/q09/04_on.png",
							overPath = "example/interactivity/answers/K/q09/04_off.png",
							x = 190, 
							y = 270,
							scale = 0.85,
							isCorrect = false
						},
					}
				},
				{
					question = {
						text = "Biggest number?",
						fontSize = 60, 
					},
					answers = {
						{
							text = "8", 
							fontSize = 80,
							isCorrect = false
						},
						{
							text = "6", 
							fontSize = 80,
							isCorrect = false
						},
						{
							text = "9", 
							fontSize = 80,
							isCorrect = true
						}
					}
				},
			},
			spine = "example/interactivity/spines/frame.json",
			useAtlas = "example/interactivity/spines/frame.atlas",
			animation = "INTRO",
			outroAnimation = "SOLVED",
			loop = false,
			time = 1000,
			x = 0,
			y = -15,
		}
	},
	soundAnswerID = "minigamesPop",
	soundAnimationID = "cut"
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

local function createInteractiveComic()
	localization.initialize({"en", "es", "pt", "cn", "kr", "jp"})
	local whiteBackground = display.newRect(screen.centerX, screen.centerY, screen.width, screen.height)	
	local comicGroup = comics.new(interactiveComicOptions, onComplete)
	comicGroup.x = screen.centerX
	comicGroup.y = screen.centerY
	comicGroup:play()
end

--createComic()
--createEventComic()
createInteractiveComic()