function start (song)
end

function update (elapsed)

	local currentBeat = (songPos / 1000)*(bpm/60)
	hudX = getHudX()
    hudY = getHudY()
	
	if shakehorizontal then
		setHudPosition(6 * math.sin((currentBeat * 10) * math.pi), 0)
		setCamPosition(6 * math.sin((currentBeat * 10) * math.pi),0)
	end
	
	if shakehorizontalweak then
		setHudPosition(3 * math.sin((currentBeat * 10) * math.pi),0)
		setCamPosition(3 * math.sin((currentBeat * 10) * math.pi),0)
	end

	if shakenotep1 then
		for i=0,3 do
			setActorX(_G['defaultStrum'..i..'X'] + 3 * math.sin((currentBeat * 10 + i*0.25) * math.pi), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 3 * math.cos((currentBeat * 10 + i*0.25) * math.pi) + 10, i)
		end
	end
	if shakenotep2 then
		for i=4,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 3 * math.sin((currentBeat * 10 + i*0.25) * math.pi), i)
			setActorY(_G['defaultStrum'..i..'Y'] + 3 * math.cos((currentBeat * 10 + i*0.25) * math.pi) + 10, i)
		end
	end
	
	if crazy then
		for i=0,3 do
			setActorX(_G['defaultStrum'..i..'X'] - 256 * math.sin(currentBeat / 5) + 275, i)
			setActorY(_G['defaultStrum'..i..'Y'] - 50 * math.cos(currentBeat) + 10,i)
		end
		for i=4,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 256 * math.sin(currentBeat / 5) - 275, i)
			setActorY(_G['defaultStrum'..i..'Y'] - 50 * math.cos(currentBeat) + 10,i)
		end
	end

	if shakehud then
		for i=0,7 do
			setHudPosition(20 * math.sin((currentBeat * 10) * math.pi), 20 * math.cos((currentBeat * 10) * math.pi))
			setCamPosition(-20 * math.sin((currentBeat * 10) * math.pi), -20 * math.cos((currentBeat * 10) * math.pi))
		end
	end
	
    if sway then
        camHudAngle = 3 * math.sin(currentBeat)
    end
	
end

function beatHit (beat)
end

function stepHit (step)

	-- Separate these by ranges instead of on certain steps
	-- This is so that when steps are missed from lag, the effect still goes through

	-- Shake hud timings
	if not shakeHud and ((step >= 128 and step < 132) or (step >= 1024 and step < 1028)) then
		shakeHud = true
	elseif shakeHud and ((step < 128) or (step >= 132 and step < 1024) or (step >= 1028)) then
		shakeHud = false
	end

	-- Shake note timings
	if (not shakenotep1 or not shakenotep2) and ((step >= 128 and step < 640) or (step >= 1024 and step < 1528)) then
		shakenotep1 = true
		shakenotep2 = true
	elseif (shakenotep1 or shakenotep2) and (step < 128) or (step >= 640 and step < 1024) or (step >= 1528) then
		shakenotep1 = false
		shakenotep2 = false
	end

	-- Shake horizontal timings
	if not shakeHorizontal and (step >= 640 and step < 768) then
		shakeHorizontal = true
	elseif shakeHorizontal and (step < 640 or step >= 768) then
		shakeHorizontal = false
	end

	-- Shake horizontal weak timings
	if not shakeHorizontalweak and (step >= 768 and step < 1024) then
		shakeHorizontalweak = true
	elseif shakeHorizontalweak and (step < 768 or step >= 1024) then
		shakeHorizontalweak = false
	end

	-- Sway timings
	if not sway and (step >= 1536 and step < 1856) then
		sway = true
	elseif sway and (step < 1536 or step >= 1856) then
		sway = false
	end

	-- Crazy timings
	if not crazy and (step >= 1536 and step < 1856) then
		crazy = true
	elseif crazy and (step < 1536 or step >= 1856) then
		crazy = false
	end

	-- Prevent notes from not being faded
	for i=0,3 do
		if step > 1528 and getActorAlpha(i) == 1 then
			setActorAlpha(0.1, i)
		end
	end

	-- Prevent reset not going off
	if camHudAngle ~= 0 and step > 1857 then
		resetButtonPositions()
	end

	if step == 132 then
		--shakehud = false
		setCamPosition(0,0)
		setHudPosition(0,0)
	end
	if step == 1028 then
		--shakehud = false
		setCamPosition(0,0)
		setHudPosition(0,0)
	end
	if step == 1528 then
		--shakenotep1 = false
		--shakenotep2 = false
		for i=0,3 do
			tweenFadeOut(i,0.1,0.6)
		end
	end	

	if step == 1857 then
		resetButtonPositions()
	end
end

function resetButtonPositions()
	for i=0,7 do
		setActorX(_G['defaultStrum'..i..'X'] + 3 * math.sin((i*0.25) * math.pi), i);
		setActorY(_G['defaultStrum'..i..'Y'] + 50, i);
	end

	-- Also reset camera
	camHudAngle = 0
end