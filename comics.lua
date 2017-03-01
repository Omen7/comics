------------------------------------------- Comic engine.
local modulePath = ...
local requirePath = modulePath.path or ""
local requireFolder = string.gsub(requirePath, "%.", "/")
local extras = require("extras") 
local screen = require("screen")
local spine = require("spine")

local comics = {}
------------------------------------------- Variables

------------------------------------------- Caches
local displayRemove = display.remove
local display = display
------------------------------------------- Constants 
local COLOR_FADE_RECT = {0, 0.85}

local TIME_FRAME_DEFAULT = 2000

local OFFSET_BUTTON = 42
local SIZE_BUTTON = {width = 102, height = 114}

local OKAY_BUTTON_DEFAULT = requireFolder.."images/continue.png"
local OKAY_BUTTON_OVER = requireFolder.."images/continue2.png"

local REPLAY_BUTTON_DEFAULT = requireFolder.."images/replay.png"
local REPLAY_BUTTON_OVER = requireFolder.."images/replay2.png"
------------------------------------------- Local functions
local function finalizeComic(event)
	local comic = event.target
	transition.cancel(comic)
	if comic.comicTimer then 
		timer.cancel(comic.comicTimer)
		comic.comicTimer = nil
	end
	if comic.replayTimer then
		timer.cancel(comic.replayTimer)
		comic.replayTimer = nil
	end
end

local function playNextVignette(event)
	local comic = event.source.comic
	comic:nextVignette()
end

local function nextVignette(self)
	local comic = self
	
	if comic.comicTimer then 
		timer.cancel(comic.comicTimer)
		comic.comicTimer = nil
	end
	
	if comic.currentFrame <= comic.frameNumber then
		local frame = comic.frameTable[comic.currentFrame]
		transition.to(frame, {time = 500, alpha = 1})	
		frame:setAnimation(frame.animation, {loop = frame.loop}) 
		comic.currentFrame = comic.currentFrame + 1
		comic.comicTimer = timer.performWithDelay(frame.time, playNextVignette)
		comic.comicTimer.comic = comic
	else
		comic:setButtonsEnabled(true)
	end
end

local function play(self)
	local comic = self
	comic.canBeTapped = true
	comic:nextVignette()
end

local function replayComic(event)
	local comic = event.source.comic
	comic:play()
end

local function onRetryButtonRelease(event)
	local retryButton = event.target
	local comic = retryButton.comic
	comic.canBeTapped = false
	comic:setButtonsEnabled(false)
	for frameIndex = 1, #comic.frameTable do
		local frame = comic.frameTable[frameIndex]
		transition.cancel(frame)
		transition.to(frame, {time = 250, alpha = 0})
	end
	comic.currentFrame = 1
	comic.replayTimer = timer.performWithDelay(500, replayComic)
	comic.replayTimer.comic = comic
end

local function onComicComplete(comic)
	if comic.onComplete and type(comic.onComplete) == "function" then
		comic.onComplete({target = comic})
	end
	displayRemove(comic)
end

local function onOkayButtonRelease(event)
	local okayButton = event.target
	local comic = okayButton.comic
	comic:setButtonsEnabled(false)
	transition.to(comic, {time = 500, alpha = 0, onComplete = onComicComplete})
end

local function tappedComic(event)
	local comic = event.target
	if comic.canBeTapped then
		comic:nextVignette()
	end
end

local function setButtonsEnabled(self, value)
	local comic = self
	local alpha = value and 1 or 0
	transition.cancel(comic.okayButton)
	transition.cancel(comic.retryButton)
	transition.to(comic.okayButton, {time = 500, alpha = alpha})
	transition.to(comic.retryButton, {time = 500, alpha = alpha})
	comic.okayButton:setEnabled(value)
	comic.retryButton:setEnabled(value)
end
------------------------------------------- Module functions
function comics.new(options, onComplete)
	options = options or {}
	
	if not (type(options) == "table") then
		error("Error. First parameter on comics.new() should be a table.", 2)
	end
	
	local globalScale = screen.height / 768
	
	local comic = display.newGroup()
	comic.anchorChildren = true
	comic.frameNumber = #options.frames
	comic.currentFrame = 1
	comic.frameTable = {}
	
	if comic.frameNumber < 1 then
		error("Error. Parameter 'frames' must receive at least one frame.", 2)
	end
	
	local fadeRect = display.newRect(0, 0, screen.width2, screen.height2)
	fadeRect:setFillColor(unpack(COLOR_FADE_RECT))
	comic:insert(fadeRect)
	
	for frameIndex = 1, comic.frameNumber do
		local frameData = options.frames[frameIndex]
		
		local animationSpeed = options.animationSpeed or 10
		local skin = options.skin
		local spinePath = frameData.spine
		local useAtlas = frameData.useAtlas
		local animation = frameData.animation
		local loop = frameData.loop or false
		local time = frameData.time or TIME_FRAME_DEFAULT
		local x = frameData.x or 0
		local y = frameData.y or 0
		
		local spineOptions = {
			animationSpeed = animationSpeed,
			useAtlas = useAtlas,
			forceUpdate = true
		}
		
		local frame = spine.new(spinePath, spineOptions)
		frame:setSkin(skin)
		frame:scale(globalScale, globalScale)
		frame.x, frame.y = x * globalScale, y * globalScale
		frame.alpha = 0
		comic:insert(frame)
		
		frame.animation = animation
		frame.loop = loop
		frame.time = time
		comic.frameTable[frameIndex] = frame
	end

	local okayConstructor = options.okayButton or {}

	local okayButtonOptions = {
		width = okayConstructor.width or SIZE_BUTTON.width,
		height = okayConstructor.height or SIZE_BUTTON.height,
		defaultFile = okayConstructor.defaultFile or OKAY_BUTTON_DEFAULT,
		overFile = okayConstructor.overFile or OKAY_BUTTON_OVER
	}
	
	local okayButton = extras.widget.newButton(okayButtonOptions, onOkayButtonRelease)
	okayButton.comic = comic
	okayButton.alpha = 0
	okayButton:scale(globalScale * 0.75, globalScale * 0.75)
	okayButton.x = comic.frameTable[comic.frameNumber].x + OFFSET_BUTTON * globalScale + globalScale * (okayConstructor.x or 0)
	okayButton.y = comic.frameTable[comic.frameNumber].y + globalScale * (okayConstructor.y or 0)
	comic:insert(okayButton)
	
	local retryConstructor = options.retryButton or {}
	
	local retryButtonOptions = {
		width = retryConstructor.width or SIZE_BUTTON.width,
		height = retryConstructor.height or SIZE_BUTTON.height,
		defaultFile = retryConstructor.defaultFile or REPLAY_BUTTON_DEFAULT,
		overFile = retryConstructor.overFile or REPLAY_BUTTON_OVER
	}
	
	local retryButton = extras.widget.newButton(retryButtonOptions, onRetryButtonRelease)
	retryButton.comic = comic
	retryButton.alpha = 0
	retryButton:scale(globalScale * 0.75, globalScale * 0.75)
	retryButton.x = comic.frameTable[comic.frameNumber].x - OFFSET_BUTTON * globalScale + globalScale * (retryConstructor.x or 0)
	retryButton.y = comic.frameTable[comic.frameNumber].y + globalScale * (retryConstructor.y or 0)
	comic:insert(retryButton)
		
	comic.play = play
	comic.onComplete = onComplete
	comic.nextVignette = nextVignette
	comic.okayButton = okayButton
	comic.retryButton = retryButton
	comic.canBeTapped = true
	comic.setButtonsEnabled = setButtonsEnabled
	
	comic:addEventListener("tap", tappedComic)
	comic:addEventListener("finalize", finalizeComic)
	
	return comic
end

return comics