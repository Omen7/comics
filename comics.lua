------------------------------------------- Comic engine.
local modulePath = ...
local requirePath = modulePath.path or ""
local requireFolder = string.gsub(requirePath, "%.", "/")
local localization = require("localization")
local animation = require("animation")
local voiceover = require("voiceover")
local extras = require("extras") 
local screen = require("screen")
local spine = require("spine")
local sound = require("sound")

local comics = {}
------------------------------------------- Variables

------------------------------------------- Caches
local displayRemove = display.remove
local display = display
------------------------------------------- Constants
local GLOBAL_SCALE = screen.height / 768

local OFFSET_BUTTON = 44
local TEXTBOX_OFFSET_X = 20
local TIME_FRAME_DEFAULT = 2000
local MAX_QUESTION_IMAGE_REPEATS = 5
local DEFAULT_PROGRESS_BAR_HEIGHT = 632
local DEFAULT_PROGRESS_BAR_WIDTH = 40

local COLOR_FADE_RECT = {0, 0.85}
local SIZE_BUTTON = {width = 102, height = 114}
local DEFAULT_QUESTION_POSITION = {x = 0, y = -250, offsetX = 0, offsetY = 5}
local DEFAULT_ANSWER_SCALE = 0.90
local DEFAULT_ANSWER_POSITIONS = {
	{x = -250, y = 270, offsetX = 0, offsetY = 0},
	{x = 0, y = 270, offsetX = 0, offsetY = 0},
	{x = 250, y = 270, offsetX = 0, offsetY = 0}
}

local FONT_NAME = "VAGRounded"

local DEFAULT_PROGRESS_BAR = {
	BODY = requireFolder.."images/counter.png",
	FULL = requireFolder.."images/counter_full.png",
}

local QUESTION_DEFAULT = requireFolder.."images/questionbox.png"
local QUESTION_BOX_DEFAULT = requireFolder.."images/question.png"

local SOUND_BUTTON_DEFAULT = requireFolder.."images/sound.png"
local SOUND_BUTTON_OVER = requireFolder.."images/sound2.png"

local ANSWER_BUTTON_DEFAULT = requireFolder.."images/answer.png"
local ANSWER_BUTTON_OVER = requireFolder.."images/answer2.png"

local OKAY_BUTTON_DEFAULT = requireFolder.."images/continue.png"
local OKAY_BUTTON_OVER = requireFolder.."images/continue2.png"

local REPLAY_BUTTON_DEFAULT = requireFolder.."images/replay.png"
local REPLAY_BUTTON_OVER = requireFolder.."images/replay2.png"
------------------------------------------- Local functions
local function onComicComplete(comic)
	if comic.onComplete and type(comic.onComplete) == "function" then
		comic.onComplete({target = comic})
	end
	
	if not comic.isInteractive then 
		displayRemove(comic) 
	end
end

local function removeSelf(self)
	if self then
		displayRemove(self)
	end
end

local function finalizeComic(event)
	local comic = event.target
	transition.cancel(comic)
	
	if not comic.isInteractive then 
		transition.cancel(comic.okayButton)
	end
	if comic.comicTimer then 
		timer.cancel(comic.comicTimer)
		comic.comicTimer = nil
	end
	if comic.replayTimer then
		timer.cancel(comic.replayTimer)
		comic.replayTimer = nil
	end
	if comic.interactivityTimer then
		timer.cancel(comic.interactivityTimer)
		comic.interactivityTimer = nil
	end
	if comic.nextInteractionTimer then
		timer.cancel(comic.nextInteractionTimer)
		comic.nextInteractionTimer = nil
	end
	voiceover.stop()
end

local function playNextVignette(event)
	local comic = event.source.comic
	if comic.canShowNextFrame then
		comic:nextVignette()
	end
end

local function logEducationalSession()
	-- This function will send a table with the results of the evaluation wherever it needs to be sent. It'll either return a table or log a mixpanel event. Table name is resultTable. 
end

local function setSkin(self, skin)
	local comic = self
	
	for frameIndex = 1, #comic.frameTable do
		local frame = comic.frameTable[frameIndex]
		frame:setSkin(skin)
	end
end

local function displayNextInteraction(self)
	self.currentQuestion = self.currentQuestion + 1
	
	if self.currentQuestion <= #self.questionsTable then
		self:displayQuestion()
		self:displayAnswers()
	else
		logEducationalSession()
		self.comic.canShowNextFrame = true
		if self.outroAnimation then 
			self:setAnimation(self.outroAnimation) 
		end
		self.comic.comicTimer = timer.performWithDelay(1000, playNextVignette)
		self.comic.comicTimer.comic = self.comic
	end
end

local function playSound(delay, soundID)
	if soundID then
		timer.performWithDelay(delay, function() 
			sound.play(soundID) 
		end)
	end
end

local function playVO(self)
	local voButton = self.target or self
	voiceover.setUrl("http://yogomepacks.com/vo/")
	
	if voButton.voID then 
		voiceover.stop()
		voiceover.play({voButton.voID}, nil, localization.getLanguage())
	end
end

local function removeProgressBar(self)
	local progressBarContainer = self
	if progressBarContainer.height == DEFAULT_PROGRESS_BAR_HEIGHT then
		transition.to(progressBarContainer.progressBarGroup, {time = 500, alpha = 0, onComplete = removeSelf})
	end
end

local function addProgressToBar(self)
	local progressBarContainer = self
	local stepHeight = DEFAULT_PROGRESS_BAR_HEIGHT / progressBarContainer.stepAmount
	
	transition.to(progressBarContainer, {time = 500, height = progressBarContainer.height + stepHeight, onComplete = removeProgressBar})
end

local function createProgressBar(self)
	local frame = self
	local stepAmount = #frame.questionsTable
	
	local progressBarGroup = display.newGroup()
	progressBarGroup:scale(GLOBAL_SCALE, GLOBAL_SCALE)
	progressBarGroup.x = -400 * GLOBAL_SCALE
	progressBarGroup.y = 0
	progressBarGroup.alpha = 0
	frame.comic:insert(progressBarGroup)

	local progressBarBody = display.newImage(DEFAULT_PROGRESS_BAR.BODY)
	progressBarGroup:insert(progressBarBody)
	
	local progressBarContainer = display.newContainer(DEFAULT_PROGRESS_BAR_WIDTH, 0)
	progressBarContainer:translate(0, 158)
	progressBarGroup:insert(progressBarContainer)
	
	local progressBarFull = display.newImage(DEFAULT_PROGRESS_BAR.FULL)
	progressBarFull.anchorY = 1
	progressBarContainer:insert(progressBarFull)
	
	progressBarContainer.progressBarGroup = progressBarGroup
	progressBarContainer.addProgressToBar = addProgressToBar
	progressBarContainer.stepAmount = stepAmount
	
	frame.progressBarContainer = progressBarContainer
	
	transition.to(progressBarGroup, {delay = 800, time = 500, alpha = 1})
end

local function validateAnswer(self)
	local answer = self.target
	local frame = answer.frame
	
	frame.resultTable[#frame.resultTable + 1] = answer.isCorrect
	frame.voButton:setEnabled(false)
	frame.progressBarContainer:addProgressToBar()
	
	answer.isSelected = true
	voiceover.stop()
	
	if frame.comic.soundAnswerID then
		sound.play(frame.comic.soundAnswerID)
	end
	
	for buttonIndex = 1, #frame.buttonTable do
		local button = frame.buttonTable[buttonIndex]
		button:setEnabled(false)
		
		if not button.isSelected then
			transition.to(button.answerBox, {time = 800, xScale = 0.001, yScale = 0.001, transition = easing.inBack, onComplete = removeSelf})
		else
			transition.to(button.answerBox, {delay = 1000, time = 800, xScale = 0.001, yScale = 0.001, transition = easing.inBack, onComplete = removeSelf})
			transition.to(frame.questionGroup, {delay = 1000, time = 800, xScale = 0.001, yScale = 0.001, transition = easing.inBack, onComplete = removeSelf})
			frame.comic.nextInteractionTimer = timer.performWithDelay(3000, function() 
				frame:displayNextInteraction() 
			end)
		end
	end
	
	playSound(500, frame.comic.soundAnimationID)
	playSound(1500, frame.comic.soundAnimationID)
end

local function displayAnswers(self)
	local frame = self
	local buttonTable = {}	
	local answersTable = frame.answersTable[frame.currentQuestion]
	local positionTable = extras.table.shuffle(answersTable)
	local defaultPositionTable = extras.table.deepcopy(DEFAULT_ANSWER_POSITIONS)
	defaultPositionTable = extras.table.shuffle(defaultPositionTable)
	
	local answersGroup = display.newGroup()
	frame.comic:insert(answersGroup)
		
	for answerIndex = 1, #answersTable do
		local answerData = answersTable[answerIndex]
		local positionData = positionTable[answerIndex]
		
		local answerBox = display.newGroup()
		answerBox.x = (positionData.x or defaultPositionTable[answerIndex].x) * GLOBAL_SCALE
		answerBox.y = (positionData.y or defaultPositionTable[answerIndex].y) * GLOBAL_SCALE
		answersGroup:insert(answerBox)
		
		local pathDir = answerData.defaultPath and frame.comic.baseDir or nil
		
		local answerButtonOptions = {
			defaultFile = answerData.defaultPath or ANSWER_BUTTON_DEFAULT,
			overFile = answerData.overPath or ANSWER_BUTTON_OVER,
			baseDir = pathDir
		}
	
		local answerButton = extras.widget.newButton(answerButtonOptions, validateAnswer)
		answerButton.frame = frame
		answerBox:insert(answerButton)
				
		buttonTable[answerIndex] = answerButton
		buttonTable[answerIndex].isCorrect = answerData.isCorrect
		buttonTable[answerIndex].isSelected = false
		buttonTable[answerIndex].answerBox = answerBox
			
		if answerData.text then
			local textOptions = {
				text = answerData.text,
				x = answerData.offsetX or DEFAULT_ANSWER_POSITIONS[answerIndex].offsetX + answerButton.x,
				y = answerData.offsetY or DEFAULT_ANSWER_POSITIONS[answerIndex].offsetY + answerButton.y,
				width = answerButton.contentWidth - TEXTBOX_OFFSET_X,
				font = FONT_NAME,   
				fontSize = answerData.fontSize,
				align = "center"
			}
		
			local textColor = answerData.fontColor or {0}
			local text = display.newText(textOptions)
			text:setFillColor(unpack(textColor))
			answerBox:insert(text)
		end
		
		local answerScale = answerData.scale or DEFAULT_ANSWER_SCALE
		answerBox.xScale, answerBox.yScale = 0.001, 0.001
		transition.to(answerBox, {delay = 1500, time = 800, xScale = answerScale * GLOBAL_SCALE, yScale = answerScale * GLOBAL_SCALE, transition = easing.outBack})
	end
	
	playSound(1750, frame.comic.soundAnimationID)
	
	frame.buttonTable = buttonTable
end

local function formatText(questionData, questionGroup, textBox)
	local textOptions = {
		text = questionData.text,     
		x = questionData.offsetX or DEFAULT_QUESTION_POSITION.offsetX + textBox.x,
		y = questionData.offsetY or DEFAULT_QUESTION_POSITION.offsetY + textBox.y,
		width = textBox.contentWidth - TEXTBOX_OFFSET_X,
		font = FONT_NAME,   
		fontSize = questionData.fontSize,
		align = "center"
	}
	
	local textColor = questionData.fontColor or {1}
	local text = display.newText(textOptions)
	text:setFillColor(unpack(textColor))
	questionGroup:insert(text)
end

local function formatOperation(questionData, questionGroup)
	local textGroup = display.newGroup()
	questionGroup:insert(textGroup)
	
	local firstEquationText = display.newText(questionData.operation, 0, 0, FONT_NAME, questionData.fontSize)
	textGroup:insert(firstEquationText) 
	
	local equationQuestionSquare = display.newImage(QUESTION_BOX_DEFAULT)
	equationQuestionSquare.x, equationQuestionSquare.y = firstEquationText.contentWidth * 0.5 + 40, 3
	textGroup:insert(equationQuestionSquare) 
	
	textGroup.x = textGroup.x - 40
end

local function formatImageSequence(frame, questionData, questionGroup, textBox)
	local rowSpacing = questionData.repeatAmount <= MAX_QUESTION_IMAGE_REPEATS and questionData.repeatAmount or MAX_QUESTION_IMAGE_REPEATS
	local spacingX = textBox.contentWidth / (rowSpacing + 1)
	
	for imageIndex = 1, questionData.repeatAmount do
		local image = display.newImage(questionData.imagePath, frame.comic.baseDir)
		
		local newWidth = (image.contentWidth * textBox.contentHeight * 0.85) / image.contentHeight
		local newHeight = (image.contentHeight * newWidth) / image.contentWidth
		
		local maxColumns = (textBox.contentWidth * 0.85) / newWidth
			
		if questionData.repeatAmount > MAX_QUESTION_IMAGE_REPEATS then
			newWidth = newWidth * 0.50
			newHeight = newHeight * 0.50
		elseif questionData.repeatAmount > maxColumns then
			if questionData.repeatAmount < MAX_QUESTION_IMAGE_REPEATS then
				newWidth, newHeight = newWidth * 0.85, newHeight * 0.85
			else
				newWidth, newHeight = newWidth * 0.70, newHeight * 0.70
			end
		end
		
		image.width = newWidth
		image.height = newHeight
		
		image.x = imageIndex <= MAX_QUESTION_IMAGE_REPEATS and (textBox.x - textBox.contentWidth * 0.5) + (imageIndex * spacingX) or (textBox.x - textBox.contentWidth * 0.5) + ((imageIndex - MAX_QUESTION_IMAGE_REPEATS) * spacingX)
		image.y = questionData.repeatAmount <= MAX_QUESTION_IMAGE_REPEATS and textBox.y or imageIndex <= MAX_QUESTION_IMAGE_REPEATS and textBox.y - textBox.contentHeight * 0.21 or textBox.y + textBox.contentHeight * 0.21
		questionGroup:insert(image)
	end
end

local function formatSplit(questionData, questionGroup)
	local textGroup = display.newGroup()
	questionGroup:insert(textGroup)
	
	local firstEquationText = display.newText(questionData.firstText, 0, 0, FONT_NAME, questionData.fontSize)
	textGroup:insert(firstEquationText) 
	
	local equationQuestionSquare = display.newImage(QUESTION_BOX_DEFAULT)
	equationQuestionSquare.x, equationQuestionSquare.y = firstEquationText.contentWidth * 0.5 + 40, 3
	textGroup:insert(equationQuestionSquare) 
	
	local secondEquationText = display.newText(questionData.secondText, equationQuestionSquare.x + equationQuestionSquare.contentWidth * 0.5 + 10, 0, FONT_NAME, questionData.fontSize)
	secondEquationText.anchorX = 0
	textGroup:insert(secondEquationText)
	
	textGroup.x = textGroup.x - secondEquationText.contentWidth * 0.5 - 45
end

local function formatImage(frame, questionData, questionGroup)
	local image = display.newImage(questionData.imagePath, frame.comic.baseDir)
	image:scale(GLOBAL_SCALE, GLOBAL_SCALE)
	questionGroup:insert(image)
end

local function formatQuestion(frame, questionData, questionGroup, textBox)
	if questionData.text then
		formatText(questionData, questionGroup, textBox)
	elseif questionData.operation then
		formatOperation(questionData, questionGroup)
	elseif questionData.repeatAmount then
		formatImageSequence(frame, questionData, questionGroup, textBox)
	elseif questionData.firstText and questionData.secondText then
		formatSplit(questionData, questionGroup)
	elseif questionData.imagePath and not questionData.repeatAmount then
		formatImage(frame, questionData, questionGroup)
	end
end

local function displayQuestion(self)
	local frame = self
	local questionsTable = frame.questionsTable
	local questionData = questionsTable[frame.currentQuestion]
	
	local questionGroup = display.newGroup()
	questionGroup.x = (questionData.x or DEFAULT_QUESTION_POSITION.x) * GLOBAL_SCALE
	questionGroup.y = (questionData.y or DEFAULT_QUESTION_POSITION.y) * GLOBAL_SCALE
	frame.comic:insert(questionGroup)
	
	local textBox = display.newImage(QUESTION_DEFAULT)
	questionGroup:insert(textBox)
	
	formatQuestion(frame, questionData, questionGroup, textBox)
	
	local voButtonOptions = {
		defaultFile = SOUND_BUTTON_DEFAULT,
		overFile = SOUND_BUTTON_OVER
	}
	
	local voButton = extras.widget.newButton(voButtonOptions, playVO)
	voButton.voID = questionData.voID
	voButton:scale(0.70, 0.70)
	voButton.x = textBox.x + textBox.contentWidth * 0.5 + 90
	voButton.y = 0
	voButton.playVO = playVO
	questionGroup:insert(voButton)
	
	questionGroup.xScale, questionGroup.yScale = 0.001, 0.001
	transition.to(questionGroup, {time = 800, xScale = GLOBAL_SCALE, yScale = GLOBAL_SCALE, transition = easing.outBack, onComplete = function() voButton:playVO() end})
	playSound(500, frame.comic.soundAnimationID)

	frame.questionGroup = questionGroup
	frame.voButton = voButton
end

local function getInteractiveData(self)
	local frame = self
	
	if frame.interactivity then		
		local questionsTable = {}
		local answersTable = {}
		local resultTable = {}
		
		frame.comic.canBeTapped = false
		frame.comic.canShowNextFrame = false
		
		for tableIndex = 1, #frame.interactivity do
			local set = frame.interactivity[tableIndex]
			questionsTable[tableIndex] = set.question
			answersTable[tableIndex] = set.answers
		end
				
		frame.questionsTable = questionsTable
		frame.answersTable = answersTable
		frame.resultTable = resultTable
		
		frame.displayQuestion = displayQuestion
		frame.displayAnswers = displayAnswers
		frame.displayNextInteraction = displayNextInteraction
		frame.createProgressBar = createProgressBar
		
		frame.comic.interactivityTimer = timer.performWithDelay(frame.interactivity.delay, function() 
			frame:displayQuestion()
			frame:displayAnswers()
			frame:createProgressBar()
		end)	
	end
end

local function nextVignette(self)
	local comic = self
	
	if comic.comicTimer then 
		timer.cancel(comic.comicTimer)
		comic.comicTimer = nil
	end
	
	if comic.currentFrame <= comic.frameNumber then
		local frame = comic.frameTable[comic.currentFrame]
		transition.to(frame, {time = 500, alpha = 1, onComplete = getInteractiveData})	
		frame:setAnimation(frame.animation, {loop = frame.loop}) 
		comic.currentFrame = comic.currentFrame + 1
		comic.comicTimer = timer.performWithDelay(frame.time, playNextVignette)
		comic.comicTimer.comic = comic
	else
		if not comic.isInteractive then 
			comic:setButtonsEnabled(true) 
		else
			transition.to(comic, {delay = comic.onCompleteDelay, time = 500, alpha = 1, onComplete = onComicComplete}) -- This deletes the comic.
		end
		comic.canBeTapped = false
	end
end

local function play(self)
	local comic = self
	if not comic.isInteractive then 
		comic.canBeTapped = true 
	end
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
	if comic.soundButtonTapID then
		sound.play(comic.soundButtonTapID)
	end
	for frameIndex = 1, #comic.frameTable do
		local frame = comic.frameTable[frameIndex]
		transition.cancel(frame)
		transition.to(frame, {time = 250, alpha = 0})
	end
	comic.currentFrame = 1
	comic.replayTimer = timer.performWithDelay(500, replayComic)
	comic.replayTimer.comic = comic
end

local function onOkayButtonRelease(event)
	local okayButton = event.target
	local comic = okayButton.comic
	comic:setButtonsEnabled(false)
	if comic.soundButtonTapID then
		sound.play(comic.soundButtonTapID)
	end
	transition.to(comic, {delay = comic.onCompleteDelay, time = 500, alpha = 0, onComplete = onComicComplete})
end

local function tappedComic(event)
	local comic = event.target
	if comic.canBeTapped then
		if comic.soundTapID then
			sound.play(comic.soundTapID)
		end
		comic:nextVignette()
	end
end

local function bounceAnimation(self)
	transition.to(self, {time = 750, xScale = self.xScale + 0.10, yScale = self.yScale + 0.10, transition = easing.outQuad, onComplete = function()
        transition.to(self, {time = 750, xScale = self.xScale - 0.10, yScale = self.yScale - 0.10, transition = easing.outQuad, onComplete = function()
            bounceAnimation(self)
        end})
    end})
end

local function setButtonsEnabled(self, value)
	local comic = self
	local alpha = value and 1 or 0
	transition.to(comic.okayButton, {time = 500, alpha = alpha})
	transition.to(comic.retryButton, {time = 500, alpha = alpha})
	comic.okayButton:setEnabled(value)
	comic.retryButton:setEnabled(value)
end
------------------------------------------- Module functions
function comics.new(options, onComplete)
	options = options or {}
	local baseDir = options.baseDir or system.ResourceDirectory
	
	if not (type(options) == "table") then
		error("Error. First parameter on comics.new() should be a table.", 2)
	end
		
	local comic = display.newGroup()
	comic.isInteractive = options.isInteractive or false
	comic.soundButtonTapID = options.soundButtonTapID or nil
	comic.soundAnimationID = options.soundAnimationID or nil
	comic.soundAnswerID = options.soundAnswerID or nil
	comic.soundTapID = options.soundTapID or nil
	comic.onCompleteDelay = options.onCompleteDelay or 0
	comic.frameNumber = #options.frames
	comic.canShowNextFrame = true
	comic.anchorChildren = true
	comic.baseDir = baseDir
	comic.frameTable = {}
	comic.currentFrame = 1
	
	if comic.frameNumber < 1 then
		error("Error. Parameter 'frames' must receive at least one frame.", 2)
	end
	
	local fadeRect = display.newRect(0, 0, screen.width2, screen.height2)
	fadeRect:setFillColor(unpack(COLOR_FADE_RECT))
	comic:insert(fadeRect)
	
	for frameIndex = 1, comic.frameNumber do
		local frameData = options.frames[frameIndex]
		
		local animationEvents = frameData.animationEvents or {[frameData.animation] = {}}
		local interactivity = frameData.interactivity or nil
		local animationSpeed = options.animationSpeed or 10
		local animationState = frameData.animation
		local outroAnimation = frameData.outroAnimation or nil
		local particlePath = options.particlePath or nil
		local spinePath = frameData.spine
		local useAtlas = frameData.useAtlas
		local loop = frameData.loop or false
		local time = frameData.time or TIME_FRAME_DEFAULT
		local x = frameData.x or 0
		local y = frameData.y or 0
		local skin = options.skin
		
		local spineOptions = {
			baseDir = baseDir,
			animationSpeed = animationSpeed,
			animationEvents = animationEvents,
			particlePath = particlePath,
			useAtlas = useAtlas,
			forceUpdate = true
		}
		
		local frame = animation.newSpine(spinePath, spineOptions)
		frame:setSkin(skin)
		frame:scale(GLOBAL_SCALE, GLOBAL_SCALE)
		frame.x, frame.y = x * GLOBAL_SCALE, y * GLOBAL_SCALE
		frame.alpha = 0
		comic:insert(frame)
		
		frame.animation = animationState
		frame.loop = loop
		frame.time = time
		
		frame.interactivity = interactivity
		frame.outroAnimation = outroAnimation
		frame.currentQuestion = 1
		frame.comic = comic

		comic.frameTable[frameIndex] = frame
	end

	if not comic.isInteractive then
		comic.canBeTapped = true
		
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
		okayButton:scale(GLOBAL_SCALE * 0.75, GLOBAL_SCALE * 0.75)
		okayButton.x = comic.frameTable[comic.frameNumber].x + OFFSET_BUTTON * GLOBAL_SCALE + GLOBAL_SCALE * (okayConstructor.x or 0)
		okayButton.y = comic.frameTable[comic.frameNumber].y + GLOBAL_SCALE * (okayConstructor.y or 0)
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
		retryButton:scale(GLOBAL_SCALE * 0.75, GLOBAL_SCALE * 0.75)
		retryButton.x = comic.frameTable[comic.frameNumber].x - OFFSET_BUTTON * GLOBAL_SCALE + GLOBAL_SCALE * (retryConstructor.x or 0)
		retryButton.y = comic.frameTable[comic.frameNumber].y + GLOBAL_SCALE * (retryConstructor.y or 0)
		comic:insert(retryButton)
		
		comic.okayButton = okayButton
		comic.retryButton = retryButton
		comic.setButtonsEnabled = setButtonsEnabled
		
		comic.okayButton.animation = bounceAnimation(comic.okayButton)
	else
		comic.canBeTapped = false
	end

	comic.play = play
	comic.onComplete = onComplete
	comic.nextVignette = nextVignette
	comic.setSkin = setSkin

	comic:addEventListener("tap", tappedComic)
	comic:addEventListener("finalize", finalizeComic)
	
	return comic
end

return comics