function start (song)
end

function update (elapsed)

	local currentBeat = (songPos / 1000)*(bpm/60)
	hudX = getHudX()
    hudY = getHudY()
	
    if sway then
        camHudAngle = 5 * math.sin(currentBeat / 2)
    end
	
    if swayfast then
        camHudAngle = 6 * math.sin(currentBeat * 2)
    end
	
    if swaynote then
		for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 64 * math.sin((currentBeat + i*2) * math.pi), i)
		end
    end

	if crisscross then
		for i=0,3 do
			setActorX(_G['defaultStrum'..i..'X'] + 300 * math.sin(currentBeat / 2) + 350, i)
		end
		for i=4,7 do
			setActorX(_G['defaultStrum'..i..'X'] - 300 * math.sin(currentBeat / 2) - 275, i)
		end
	end

	if crisscrossfast then
		for i=0,3 do
			setActorX(_G['defaultStrum'..i..'X'] + 300 * math.sin(currentBeat * 0.8) + 350, i)
		end
		for i=4,7 do
			setActorX(_G['defaultStrum'..i..'X'] - 300 * math.sin(currentBeat * 0.8) - 275, i)
		end
	end

	if crisscrossfinal then
		for i=0,3 do
			setActorX(_G['defaultStrum'..i..'X'] - 300 * math.sin(currentBeat * 1.2) + 350, i)
		end
		for i=4,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 300 * math.sin(currentBeat * 1.2) - 275, i)
		end
	end
end

function beatHit (beat)
end

function stepHit (step)

	-- Separate these by ranges instead of on certain steps
	-- This is so that when steps are missed from lag, the effect still goes through
	
	-- fix for placement desync due to possible lag
	if (step >= 900 and step < 1020) or (step >= 1670 and step < 1680) or (step >= 1956 and step < 2192) or (step >= 2550) then
        for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'],i)
			setActorAngle(0, i)
        end
	end


	-- Sway hud timing
	if not (swayfast or sway) and (step >= 256 and step < 512) or (step >= 1952 and step < 2208) then
		sway = true
	elseif swayfast or sway and (step >= 512 and step < 1048) or (step >= 2208) then
		sway = false
		camHudAngle = 0
	end
	if not (swayfast or sway) and (step >= 1280 and step < 1048) or (step >= 2208 and step < 2544) then
		swayfast = true
	elseif swayfast or sway and (step >= 1048 and step < 1952) or (step >= 2544) then
		swayfast = false
		camHudAngle = 0
	end

	
	
	-- sway note timing
	if not swaynote and (step >= 512 and step < 640) then
		swaynote = true
	elseif swaynote and (step >= 640) then
		swaynote = false
	end
	
	--Criss-Cross note timing
	if (step >= 640 and step < 896) or (step >= 1696 and step < 1952) then
		for i=0,3 do
			tweenFadeOut(i, 0.3, 0.4)
		end
	end
	if not crisscross and (step >= 640 and step < 896) or (step >= 1696 and step < 1952) then
		crisscross = true
	elseif crisscross and (step >= 896) or (step >= 1952) then
		crisscross = false
	end
	if (step >= 896 and step < 1400) or (step >= 1952 and step < 2200) then
		for i=0,3 do
			tweenFadeIn(i, 1, 0.4)
		end
	end
	
	if (step >= 1408 and step < 1664) then
		for i=0,3 do
			tweenFadeOut(i, 0.3, 0.4)
		end
	end
	if not crisscrossfast and (step >= 1408 and step < 1664) then
		crisscrossfast = true
	elseif crisscrossfast and (step >= 1664) then
		crisscrossfast = false
	end
	if (step >= 1664 and step < 1670) then
		for i=0,3 do
			tweenFadeIn(i, 1, 0.4)
		end
	end
	
	if (step >= 2208 and step < 2544) then
		for i=0,3 do
			tweenFadeOut(i, 0.3, 0.4)
		end
	end
	if not crisscrossfinal and (step >= 2208 and step < 2544) then
		crisscrossfinal = true
	elseif crisscrossfinal and (step >= 2544) then
		crisscrossfinal = false
	end
	if (step >= 2544) then
		for i=0,3 do
			tweenFadeIn(i, 1, 0.4)
		end
	end

	
	-- spin transitions
	if (step == 896) or (step == 1664) or (step == 1952) or (step == 2544) then
		for i=0,7 do
			tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i) + 360, 0.2, 'setDefault')
			setActorY(_G['defaultStrum'..i..'Y'] + 10, i)
		end
	end
end