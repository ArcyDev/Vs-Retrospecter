function laugh(id)
	if (laughState == 0) then
		laughState = 1
		tweenAngle(0, 25, 0.1)
		tweenAngle(3, -25, 0.1)
		--tweenPos(0, _G['defaultStrum0X'] + 40, _G['defaultStrum0Y'] + 40, 0.1)
		tweenPos(1, _G['defaultStrum1X'], _G['defaultStrum1Y'] + 25, 0.1)
		tweenPos(2, _G['defaultStrum2X'], _G['defaultStrum2Y'] + 25, 0.1, 'laugh')
		--tweenPos(3, _G['defaultStrum3X'] - 40, _G['defaultStrum3Y'] + 40, 0.1)
	elseif (laughState == 1) then
		laughState = 2
		tweenPos(0, _G['defaultStrum0X'], _G['defaultStrum0Y'] + 5, 0.05)
		tweenPos(1, _G['defaultStrum1X'], _G['defaultStrum1Y'] + 30, 0.05)
		tweenPos(2, _G['defaultStrum2X'], _G['defaultStrum2Y'] + 30, 0.05)
		tweenPos(3, _G['defaultStrum3X'], _G['defaultStrum3Y'] + 5, 0.05, 'laugh')
	elseif (laughState == 2) then
		laughState = 3
		tweenPos(0, _G['defaultStrum0X'], _G['defaultStrum0Y'], 0.05)
		tweenPos(1, _G['defaultStrum1X'], _G['defaultStrum1Y'] + 25, 0.05)
		tweenPos(2, _G['defaultStrum2X'], _G['defaultStrum2Y'] + 25, 0.05)
		tweenPos(3, _G['defaultStrum3X'], _G['defaultStrum3Y'], 0.05, 'laugh')
	elseif (laughState == 3) then
		laughState = 4
		tweenPos(0, _G['defaultStrum0X'], _G['defaultStrum0Y'] + 5, 0.05)
		tweenPos(1, _G['defaultStrum1X'], _G['defaultStrum1Y'] + 30, 0.05)
		tweenPos(2, _G['defaultStrum2X'], _G['defaultStrum2Y'] + 30, 0.05)
		tweenPos(3, _G['defaultStrum3X'], _G['defaultStrum3Y'] + 5, 0.05, 'laugh')
	elseif (laughState == 4) then
		laughState = 5
		tweenPos(0, _G['defaultStrum0X'], _G['defaultStrum0Y'], 0.05)
		tweenPos(1, _G['defaultStrum1X'], _G['defaultStrum1Y'] + 25, 0.05)
		tweenPos(2, _G['defaultStrum2X'], _G['defaultStrum2Y'] + 25, 0.05)
		tweenPos(3, _G['defaultStrum3X'], _G['defaultStrum3Y'], 0.05, 'laugh')
	elseif (laughState == 5) then
		laughState = 6
		tweenPos(0, _G['defaultStrum0X'], _G['defaultStrum0Y'] + 5, 0.05)
		tweenPos(1, _G['defaultStrum1X'], _G['defaultStrum1Y'] + 30, 0.05)
		tweenPos(2, _G['defaultStrum2X'], _G['defaultStrum2Y'] + 30, 0.05)
		tweenPos(3, _G['defaultStrum3X'], _G['defaultStrum3Y'] + 5, 0.05, 'laugh')
	elseif (laughState == 6) then
		laughState = 7
		tweenPos(0, _G['defaultStrum0X'], _G['defaultStrum0Y'], 0.05)
		tweenPos(1, _G['defaultStrum1X'], _G['defaultStrum1Y'] + 25, 0.05)
		tweenPos(2, _G['defaultStrum2X'], _G['defaultStrum2Y'] + 25, 0.05)
		tweenPos(3, _G['defaultStrum3X'], _G['defaultStrum3Y'], 0.05, 'laugh')
	elseif (laughState == 7) then
		laughState = 8
		tweenPos(0, _G['defaultStrum0X'], _G['defaultStrum0Y'] + 5, 0.05)
		tweenPos(1, _G['defaultStrum1X'], _G['defaultStrum1Y'] + 30, 0.05)
		tweenPos(2, _G['defaultStrum2X'], _G['defaultStrum2Y'] + 30, 0.05)
		tweenPos(3, _G['defaultStrum3X'], _G['defaultStrum3Y'] + 5, 0.05, 'laugh')
	elseif (laughState == 8) then
		laughState = 0
		tweenPos(0, _G['defaultStrum0X'], _G['defaultStrum0Y'], 0.05)
		tweenPos(1, _G['defaultStrum1X'], _G['defaultStrum1Y'] + 25, 0.05)
		tweenPos(2, _G['defaultStrum2X'], _G['defaultStrum2Y'] + 25, 0.05)
		tweenPos(3, _G['defaultStrum3X'], _G['defaultStrum3Y'], 0.05)
	end
end

function reset()
	for i = 0,3 do
		tweenAngle(i, 0, 0.1)
		tweenPos(i, _G['defaultStrum'..i..'X'], _G['defaultStrum'..i..'Y'], 0.1)
	end
end

function start (song)
	for i=0,7 do
		setActorAlpha(0, i)
	end

	laughState = 0
	actorScale = 0.7
	closeInDistance = 0
	middlePoint = ((_G['defaultStrum7X'] - _G['defaultStrum0X']) / 2) - 150
end

function update (elapsed)
	if (p1fly) then
		for i=0,3 do
			setActorX(_G['defaultStrum'..i..'X'] + 50 * math.sin((songPos / 1000) * math.pi), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 30 * math.sin((songPos / 1000) * 2 * math.pi), i)
		end
	end

	if (p2fly) then
		for i=4,7 do
			setActorY(_G['defaultStrum'..i..'Y'] + -30 * math.sin((songPos / 1000) * 2 * math.pi), i)
		end
	end

	if (flyTogether) then
		for i=0,3 do
			setActorX(middlePoint + (i * 125) + (250 * math.sin((songPos / 1000) * math.pi)), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 50 * math.sin((songPos / 1000) * 2 * math.pi), i)
		end
		for i=4,7 do
			setActorX(middlePoint + ((i - 4) * 125) + (250 * math.sin((-songPos / 1000) * math.pi)), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 30 * math.sin((-songPos / 1000) * 2 * math.pi), i)
		end
	end

	-- Pulse effect
	if (p2HalfPulse or p2Pulse or p2FastPulse) then
		if (actorScale > 0.7) then
			actorScale = actorScale - elapsed
		end
		for i=0,3 do
			setActorScale(actorScale, i)
		end
	end

	if (p1HalfPulse or p1Pulse or p1FastPulse) then
		if (actorScale > 0.7) then
			actorScale = actorScale - elapsed
		end
		for i=4,7 do
			setActorScale(actorScale, i)
		end
	end

	-- Close in effect
	if (closeIn) then
		closeInDistance = closeInDistance + (2.75 * elapsed)
		for i=0,3 do
			setActorX(_G['defaultStrum'..i..'X'] + closeInDistance, i)
		end
		for i=4,7 do
			setActorX(_G['defaultStrum'..i..'X'] - closeInDistance, i)
		end
	end
end

function beatHit (beat)
	-- Effect checks
	if (beat >= 16 and beat < 20 and getActorAlpha(0) == 0) then
		tweenFadeIn(0, 1, 1)
		tweenFadeIn(7, 1, 1)
	elseif (beat >= 20 and beat < 24 and getActorAlpha(1) == 0) then
		tweenFadeIn(1, 1, 1)
		tweenFadeIn(6, 1, 1)
	elseif (beat >= 24 and beat < 28 and getActorAlpha(2) == 0) then
		tweenFadeIn(2, 1, 1)
		tweenFadeIn(5, 1, 1)
	elseif (beat >= 28 and beat < 32 and getActorAlpha(3) == 0) then
		tweenFadeIn(3, 1, 1)
		tweenFadeIn(4, 1, 1)
	elseif (beat == 62) then -- Can't really prevent missing this. This sucks
		laugh(-1)
	elseif (beat >= 64 and beat < 128 and not p1fly) then
		reset()
		p1fly = true
	elseif (beat >= 192 and beat < 254 and not closeIn) then
		closeIn = true
		p2fly = true
	elseif (beat >= 224 and beat < 254 and not p1FastPulse) then
		p1Pulse = false
		p2Pulse = false
		p1FastPulse = true
		p2FastPulse = true
	elseif (beat >= 254 and beat < 256 and closeIn) then
		laugh(-1)
		closeIn = false
		p1fly = false
		p2fly = false
		p1FastPulse = false
		p2FastPulse = false
	elseif (beat >= 256 and beat < 288 and not flyTogether) then
		flyTogether = true
		p1Pulse = true
		p2Pulse = true
	elseif (beat >= 288 and flyTogether) then
		flyTogether = false
		for i=0,7 do
			tweenPos(i, middlePoint + ((i % 4) * 125), _G['defaultStrum'..i..'Y'], 2)
		end
	end

	-- Pulse checks
	if (beat >= 64 and not p2HalfPulse and not p2Pulse) then
		p2HalfPulse = true
	elseif (beat >= 128 and not p2Pulse) then
		p2HalfPulse = false
		p2Pulse = true
	end

	if (beat >= 128 and not p1HalfPulse and not p1Pulse) then
		p1HalfPulse = true
	elseif (beat >= 192 and not p1Pulse) then
		p1HalfPulse = false
		p1Pulse = true
	end

	-- Pulsing effect
	if (p2HalfPulse and beat % 2 == 0) then
		actorScale = 0.85
		for i=0,3 do
			setActorScale(0.85, i)
		end
	elseif (p2Pulse) then
		actorScale = 0.85
		for i=0,3 do
			setActorScale(0.85, i)
		end
	end

	if (p1HalfPulse and beat % 2 == 0) then
		actorScale = 0.85
		for i=4,7 do
			setActorScale(0.85, i)
		end
	elseif (p1Pulse) then
		actorScale = 0.85
		for i=4,7 do
			setActorScale(0.85, i)
		end
	end
end

function stepHit (step)
	if (curStep == 1022) then
		reset()
		for i=0,3 do
			tweenPosXAngle(i, middlePoint + (i * 125), 360, 0.25)
		end
		for i=4, 7 do
			tweenPosXAngle(i, middlePoint + ((i - 4) * 125), -360, 0.25)
		end
	end

	-- Pulsing effect
	if (p2FastPulse and curStep % 2 == 0) then
		actorScale = 0.85
		for i=0,3 do
			setActorScale(0.85, i)
		end
	end

	if (p1FastPulse and curStep % 2 == 0) then
		actorScale = 0.85
		for i=4,7 do
			setActorScale(0.85, i)
		end
	end
end