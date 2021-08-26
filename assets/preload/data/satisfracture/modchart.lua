function start (song)
end

function update (elapsed)

	local currentBeat = (songPos / 1000)*(bpm/60)
	hudX = getHudX()
    hudY = getHudY()
	
    if sway then
        camHudAngle = 5 * math.sin(currentBeat * 0.504)
    end
	
    if quickdraw then
		for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 32 * math.sin((currentBeat + i*2) * math.pi), i)
			setActorY(_G['defaultStrum'..i..'Y'], i)
		end
    end

    if quickdraw2 then
		for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'], i)
			setActorY(_G['defaultStrum'..i..'Y'] + 16 * math.sin((currentBeat + i*2) * math.pi), i)
		end
    end
	
    if quickdraw3 then
		for i=0,3 do
			setActorX(_G['defaultStrum'..i..'X'] + 32 * math.sin((currentBeat + i*2) * math.pi) + 700, i)
			setActorY(_G['defaultStrum'..i..'Y'], i)
		end
		for i=4,7 do
			setActorX(_G['defaultStrum'..i..'X'] + 32 * math.sin((currentBeat + i*2) * math.pi) - 550, i)
			setActorY(_G['defaultStrum'..i..'Y'], i)
		end
    end
	
    if quickdraw4 then
		for i=0,3 do
			setActorX(_G['defaultStrum'..i..'X'] + 700, i)
			setActorY(_G['defaultStrum'..i..'Y'], i)
		end
		for i=4,7 do
			setActorX(_G['defaultStrum'..i..'X'] - 550, i)
			setActorY(_G['defaultStrum'..i..'Y'] + 16 * math.sin((currentBeat + i) * math.pi), i)
		end
    end

	if crisscross then
		for i=0,3 do
			setActorX(_G['defaultStrum'..i..'X'] + 300 * math.sin(currentBeat * 0.503) + 350, i)
		end
		for i=4,7 do
			setActorX(_G['defaultStrum'..i..'X'] - 300 * math.sin(currentBeat * 0.503) - 275, i)
		end
	end
	
	if crisscross2 then
		for i=0,3 do
			setActorX(_G['defaultStrum'..i..'X'] + 300 * math.sin(currentBeat * 0.504) + 350, i)
			setActorY(_G['defaultStrum'..i..'Y'] + 16 * math.cos((currentBeat + i*5) * math.pi), i)
		end
		for i=4,7 do
			setActorX(_G['defaultStrum'..i..'X'] - 300 * math.sin(currentBeat * 0.504) - 275, i)
			setActorY(_G['defaultStrum'..i..'Y'] + 16 * math.cos((currentBeat + i*5) * math.pi), i)
		end
	end
	
    if speedy then
		for i=0,7 do
			setActorY(_G['defaultStrum'..i..'Y'] + 16 * math.cos(currentBeat + i), i)
		end
    end
end

function beatHit (beat)
end

function stepHit (step)

	-- Separate these by ranges instead of on certain steps
	-- This is so that when steps are missed from lag, the effect still goes through
	
	-- fix for placement desync due to possible lag
	if (step >= 578 and step < 600) or (step >= 706 and step < 760) and (step >= 840 and step < 896) or (step >= 1030 and step < 1144) then
        for i=0,7 do
			setActorX(_G['defaultStrum'..i..'X'],i)
			setActorAngle(0, i)
        end
	end
	
	
	-- "ENOUGH"
	if step == 176 then
		for i=0,3 do
			tweenFadeOut(i, 0, 0.4)
		end
	end
	if step == 188 then
		showOnlyStrums = true
	end
	if step == 192 then
		for i=0,7 do
			tweenFadeIn(i, 1, 0.01)
			showOnlyStrums = false
		end
	end
	
	-- Fade Out note timing	
	if step == 1120 then
		for i=0,3 do
			tweenFadeOut(i, 0, 1)
		end
	end
	if step == 1146 then
		tweenFadeOut(5, 0, 0.2)
	end
	if step == 1148 then
		tweenFadeOut(6, 0, 0.2)
	end
	if step == 1150 then
		tweenFadeOut(7, 0, 0.2)
	end
	if step == 1152 then
		tweenFadeOut(4, 0, 3)
		tweenPosXAngle(4, 600, 0, 2, 'setDefault')
	end


	-- Sway hud timing
	if not sway and (step >= 192 and step < 320) or (step >= 448 and step < 576) or (step >= 832 and step < 1024) then
		sway = true
	elseif sway and (step >= 320 and step < 448) or (step >= 576 and step < 832) or (step >= 1024) then
		sway = false
		camHudAngle = 0
	end
	
	
	-- Quickdraw note timing
	if not quickdraw and (step >= 320 and step < 448) then
		quickdraw = true
	elseif quickdraw and (step >= 448) then
		quickdraw = false
	end
	
	if not quickdraw2 and (step >= 448 and step < 576) then
		quickdraw2 = true
	elseif quickdraw2 and (step >= 576) then
		quickdraw2 = false
	end
	
	if not quickdraw3 and (step >= 960 and step < 992) then
		quickdraw3 = true
	elseif quickdraw3 and (step >= 992) then
		quickdraw3 = false
	end
	
	if not quickdraw4 and (step >= 992 and step < 1024) then
		quickdraw4 = true
	elseif quickdraw4 and (step >= 1024)  then
		quickdraw4 = false
	end
	
	
	--Criss-Cross note timing
	if (step >= 640 and step < 704) or (step >= 832 and step < 960) then
		for i=0,3 do
			tweenFadeOut(i, 0.3, 0.4)
		end
	end
	if (step >= 704 and step < 832) or (step >= 960 and step < 1024) then
		for i=0,3 do
			tweenFadeIn(i, 1, 0.4)
		end
	end
	
	if not crisscross and (step >= 640 and step < 704) then
		crisscross = true
	elseif crisscross and (step >= 704 and step < 832) then
		crisscross = false
	end
	if not crisscross2 and (step >= 832 and step < 960) then
		crisscross2 = true
	elseif crisscross2 and (step >= 960) then
		crisscross2 = false
	end

	
	
	-- Speedy note timing
	if not speedy and (step >= 768 and step < 832) then
		speedy = true
	elseif speedy and (step >= 832) then
		speedy = false
	end
	
	-- spin transitions
	if (step == 576) or (step == 704) or (step == 1024) then
		for i=0,7 do
			tweenPosXAngle(i, _G['defaultStrum'..i..'X'], getActorAngle(i) + 360, 0.2, 'setDefault')
			setActorY(_G['defaultStrum'..i..'Y'] + 10, i)
		end
	end
end