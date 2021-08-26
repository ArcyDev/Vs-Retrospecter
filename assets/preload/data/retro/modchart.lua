function start(song)
	activate = false
end

function update(elapsed)
	local currentBeat = (songPos / 1000) * (bpm / 60)
	hudX = getHudX()
	hudY = getHudY()

	if sway then
		camHudAngle = 2 * math.sin(currentBeat * 0.56)
	end

	if shakenote then
		for i = 0, 3 do
			setActorX(_G["defaultStrum" .. i .. "X"] + 5 * math.sin((currentBeat * 10 + i * 0.25) * math.pi), i)
			setActorY(_G["defaultStrum" .. i .. "Y"] + 5 * math.cos((currentBeat * 10 + i * 0.25) * math.pi) + 10, i)
		end
	end

	if shakenote2 then
		for i = 0, 3 do
			setActorX(_G["defaultStrum" .. i .. "X"] + 1.5 * math.sin((currentBeat * 10 + i * 0.25) * math.pi), i)
			setActorY(_G["defaultStrum" .. i .. "Y"] + 1.5 * math.cos((currentBeat * 10 + i * 0.25) * math.pi) + 10, i)
		end
	end
end

function beatHit(beat)
end

function stepHit(step)
	-- Separate these by ranges instead of on certain steps
	-- This is so that when steps are missed from lag, the effect still goes through

	-- fix for placement desync due to possible lag
	if (step == 641) or (step >= 768 and step < 896) or (step >= 1154 and step < 1408) then
		for i = 0, 7 do
			setActorX(_G["defaultStrum" .. i .. "X"], i)
			setActorY(_G["defaultStrum" .. i .. "Y"], i)
		end
	end

	-- Sway hud timing
	if not sway and (step >= 768 and step < 1152) then
		sway = true
	elseif sway and (step >= 1152) then
		sway = false
		camHudAngle = 0
	end

	-- ending effect timing
	if not shakenote and (step >= 1408 and step < 1416) or (step >= 1536 and step < 1540) then
		shakenote = true
		shakenote2 = false
	elseif shakenote and (step >= 1416 and step < 1536) then
		shakenote2 = true
		shakenote = false
	elseif (shakenote) and not (shakenote2) and (step >= 1540) then
		shakenote2 = false
		shakenote = false
	end

	if (step == 1408) then
		for i = 4, 7 do
			tweenFadeOut(i, 0, 5)
		end
	end

	if (step >= 1540) and not activate then
		activate = true

		setActorVelocityX(-20, 0)
		setActorVelocityY(-100, 0)

		setActorVelocityX(-30, 1)
		setActorVelocityY(-220, 1)

		setActorVelocityX(50, 2)
		setActorVelocityY(-70, 2)

		setActorVelocityX(10, 3)
		setActorVelocityY(-200, 3)
		for i = 0, 3 do
			setActorAccelerationY(300, i)
		end
	end

	-- 2nd beat split effect
	if (step >= 1 and step % 16 == 8 and step < 256) or (step >= 513 and step % 16 == 8 and step < 640) then
		setActorX(getActorX(0) - 50, 0)
		setActorX(getActorX(1) - 25, 1)
		setActorX(getActorX(2) + 25, 2)
		setActorX(getActorX(3) + 50, 3)
		tweenPos(0, getActorX(0) + 50, getActorY(0), 0.2)
		tweenPos(1, getActorX(1) + 25, getActorY(1), 0.2)
		tweenPos(2, getActorX(2) - 25, getActorY(2), 0.2)
		tweenPos(3, getActorX(3) - 50, getActorY(3), 0.2)

		setActorX(getActorX(4) - 50, 4)
		setActorX(getActorX(5) - 25, 5)
		setActorX(getActorX(6) + 25, 6)
		setActorX(getActorX(7) + 50, 7)
		tweenPos(4, getActorX(4) + 50, getActorY(4), 0.2)
		tweenPos(5, getActorX(5) + 25, getActorY(6), 0.2)
		tweenPos(6, getActorX(6) - 25, getActorY(5), 0.2)
		tweenPos(7, getActorX(7) - 50, getActorY(7), 0.2)
		setCamZoom(0.8)
	end

	-- spin transitions
	if step == 256 then
		for i = 0, 7 do
			tweenPosXAngle(i, _G["defaultStrum" .. i .. "X"], getActorAngle(i) + 360, 0.2, "setDefault")
		end
	end

	if step == 512 then
		for i = 0, 7 do
			tweenPosXAngle(i, _G["defaultStrum" .. i .. "X"], getActorAngle(i) + 360, 0.2, "setDefault")
		end
	end

	if step == 1152 then
		for i = 0, 7 do
			tweenPosXAngle(i, _G["defaultStrum" .. i .. "X"], getActorAngle(i) + 360, 0.2, "setDefault")
			tweenPosYAngle(i, _G["defaultStrum" .. i .. "Y"], 0, 0.2, "setDefault")
		end
	end

	-- jumpy arrows
	if (step >= 894 and step < 1152) then
		if step == 894 then
			setActorAccelerationY(60, 0)
			setActorAccelerationY(60, 4)
		end
		if step == 896 then
			setActorAccelerationY(60, 1)
			setActorAccelerationY(60, 5)
		end
		if step == 898 then
			setActorAccelerationY(60, 2)
			setActorAccelerationY(60, 6)
		end
		if step == 900 then
			setActorAccelerationY(60, 3)
			setActorAccelerationY(60, 7)
		end
		for i = 0, 7 do
			if getActorY(i) >= _G["defaultStrum" .. i .. "Y"] + 60 then
				setActorY(_G["defaultStrum" .. i .. "Y"] + 60, i)
				setActorVelocityY(-60, i)
			end
		end
	elseif (step >= 1154 and step < 1408) then
		for i = 0, 7 do
			setActorAccelerationX(0, i)
			setActorAccelerationY(0, i)
			setActorVelocityX(0, i)
			setActorVelocityY(0, i)
		end
	end

	-- retro arrow movement
	if step == 648 then
		setActorX(getActorX(0) + 12.5, 0)
		setActorX(getActorX(1) + 25, 1)
		setActorX(getActorX(2) + 50, 2)
		setActorX(getActorX(3) + 100, 3)
		tweenPos(0, getActorX(0) - 12.5, getActorY(0), 0.09)
		tweenPos(1, getActorX(1) - 25, getActorY(1), 0.09)
		tweenPos(2, getActorX(2) - 50, getActorY(2), 0.09)
		tweenPos(3, getActorX(3) - 100, getActorY(3), 0.09)
	end

	if step == 651 then
		setActorX(getActorX(0) + 12.5, 0)
		setActorX(getActorX(1) + 25, 1)
		setActorX(getActorX(2) + 50, 2)
		setActorX(getActorX(3) + 100, 3)
		tweenPos(0, getActorX(0) - 12.5, getActorY(0), 0.09)
		tweenPos(1, getActorX(1) - 25, getActorY(1), 0.09)
		tweenPos(2, getActorX(2) - 50, getActorY(2), 0.09)
		tweenPos(3, getActorX(3) - 100, getActorY(3), 0.09)
	end

	if step == 654 then
		setActorX(getActorX(0) + 12.5, 0)
		setActorX(getActorX(1) + 25, 1)
		setActorX(getActorX(2) + 50, 2)
		setActorX(getActorX(3) + 100, 3)
		tweenPos(0, getActorX(0) - 12.5, getActorY(0), 0.09)
		tweenPos(1, getActorX(1) - 25, getActorY(1), 0.09)
		tweenPos(2, getActorX(2) - 50, getActorY(2), 0.09)
		tweenPos(3, getActorX(3) - 100, getActorY(3), 0.09)
	end

	if step == 664 then
		setActorX(getActorX(0) + 12.5, 0)
		setActorX(getActorX(1) + 25, 1)
		setActorX(getActorX(2) + 50, 2)
		setActorX(getActorX(3) + 100, 3)
		tweenPos(0, getActorX(0) - 12.5, getActorY(0), 0.09)
		tweenPos(1, getActorX(1) - 25, getActorY(1), 0.09)
		tweenPos(2, getActorX(2) - 50, getActorY(2), 0.09)
		tweenPos(3, getActorX(3) - 100, getActorY(3), 0.09)
	end

	if step == 667 then
		setActorY(getActorY(0) - 50, 0)
		setActorY(getActorY(1) + 50, 1)
		setActorY(getActorY(2) - 50, 2)
		setActorY(getActorY(3) + 50, 3)
		tweenPos(0, getActorX(0), getActorY(0) + 50, 0.09)
		tweenPos(1, getActorX(1), getActorY(1) - 50, 0.09)
		tweenPos(2, getActorX(2), getActorY(2) + 50, 0.09)
		tweenPos(3, getActorX(3), getActorY(3) - 50, 0.09)
	end

	if step == 670 then
		setActorX(getActorX(0) + 12.5, 0)
		setActorX(getActorX(1) + 25, 1)
		setActorX(getActorX(2) + 50, 2)
		setActorX(getActorX(3) + 100, 3)
		tweenPos(0, getActorX(0) - 12.5, getActorY(0), 0.09)
		tweenPos(1, getActorX(1) - 25, getActorY(1), 0.09)
		tweenPos(2, getActorX(2) - 50, getActorY(2), 0.09)
		tweenPos(3, getActorX(3) - 100, getActorY(3), 0.09)
	end

	if step == 680 then
		setActorX(getActorX(0) + 12.5, 0)
		setActorX(getActorX(1) + 25, 1)
		setActorX(getActorX(2) + 50, 2)
		setActorX(getActorX(3) + 100, 3)
		tweenPos(0, getActorX(0) - 12.5, getActorY(0), 0.09)
		tweenPos(1, getActorX(1) - 25, getActorY(1), 0.09)
		tweenPos(2, getActorX(2) - 50, getActorY(2), 0.09)
		tweenPos(3, getActorX(3) - 100, getActorY(3), 0.09)
	end

	if step == 683 then
		setActorX(getActorX(0) + 12.5, 0)
		setActorX(getActorX(1) + 25, 1)
		setActorX(getActorX(2) + 50, 2)
		setActorX(getActorX(3) + 100, 3)
		tweenPos(0, getActorX(0) - 12.5, getActorY(0), 0.09)
		tweenPos(1, getActorX(1) - 25, getActorY(1), 0.09)
		tweenPos(2, getActorX(2) - 50, getActorY(2), 0.09)
		tweenPos(3, getActorX(3) - 100, getActorY(3), 0.09)
	end

	if step == 686 then
		setActorX(getActorX(0) + 12.5, 0)
		setActorX(getActorX(1) + 25, 1)
		setActorX(getActorX(2) + 50, 2)
		setActorX(getActorX(3) + 100, 3)
		tweenPos(0, getActorX(0) - 12.5, getActorY(0), 0.09)
		tweenPos(1, getActorX(1) - 25, getActorY(1), 0.09)
		tweenPos(2, getActorX(2) - 50, getActorY(2), 0.09)
		tweenPos(3, getActorX(3) - 100, getActorY(3), 0.09)
	end

	if step == 696 then
		setActorX(getActorX(0) + 12.5, 0)
		setActorX(getActorX(1) + 25, 1)
		setActorX(getActorX(2) + 50, 2)
		setActorX(getActorX(3) + 100, 3)
		tweenPos(0, getActorX(0) - 12.5, getActorY(0), 0.09)
		tweenPos(1, getActorX(1) - 25, getActorY(1), 0.09)
		tweenPos(2, getActorX(2) - 50, getActorY(2), 0.09)
		tweenPos(3, getActorX(3) - 100, getActorY(3), 0.09)
	end

	if step == 698 then
		setActorY(getActorY(0) - 50, 0)
		setActorY(getActorY(1) + 50, 1)
		setActorY(getActorY(2) - 50, 2)
		setActorY(getActorY(3) + 50, 3)
		tweenPos(0, getActorX(0), getActorY(0) + 50, 0.09)
		tweenPos(1, getActorX(1), getActorY(1) - 50, 0.09)
		tweenPos(2, getActorX(2), getActorY(2) + 50, 0.09)
		tweenPos(3, getActorX(3), getActorY(3) - 50, 0.09)
	end

	if step == 700 then
		setActorX(getActorX(0) - 12.5, 0)
		setActorX(getActorX(1) - 25, 1)
		setActorX(getActorX(2) - 50, 2)
		setActorX(getActorX(3) - 100, 3)
		tweenPos(0, getActorX(0) + 12.5, getActorY(0), 0.09)
		tweenPos(1, getActorX(1) + 25, getActorY(1), 0.09)
		tweenPos(2, getActorX(2) + 50, getActorY(2), 0.09)
		tweenPos(3, getActorX(3) + 100, getActorY(3), 0.09)
	end

	if step == 702 then
		setActorY(getActorY(0) + 50, 0)
		setActorY(getActorY(1) - 50, 1)
		setActorY(getActorY(2) + 50, 2)
		setActorY(getActorY(3) - 50, 3)
		tweenPos(0, getActorX(0), getActorY(0) - 50, 0.09)
		tweenPos(1, getActorX(1), getActorY(1) + 50, 0.09)
		tweenPos(2, getActorX(2), getActorY(2) - 50, 0.09)
		tweenPos(3, getActorX(3), getActorY(3) + 50, 0.09)
	end

	-- bf arrow movement
	if step == 712 then
		setActorX(getActorX(4) + 12.5, 4)
		setActorX(getActorX(5) + 25, 5)
		setActorX(getActorX(6) + 50, 6)
		setActorX(getActorX(7) + 100, 7)
		tweenPos(4, getActorX(4) - 12.5, getActorY(4), 0.09)
		tweenPos(5, getActorX(5) - 25, getActorY(5), 0.09)
		tweenPos(6, getActorX(6) - 50, getActorY(6), 0.09)
		tweenPos(7, getActorX(7) - 100, getActorY(7), 0.09)
	end

	if step == 715 then
		setActorX(getActorX(4) + 12.5, 4)
		setActorX(getActorX(5) + 25, 5)
		setActorX(getActorX(6) + 50, 6)
		setActorX(getActorX(7) + 100, 7)
		tweenPos(4, getActorX(4) - 12.5, getActorY(4), 0.09)
		tweenPos(5, getActorX(5) - 25, getActorY(5), 0.09)
		tweenPos(6, getActorX(6) - 50, getActorY(6), 0.09)
		tweenPos(7, getActorX(7) - 100, getActorY(7), 0.09)
	end

	if step == 718 then
		setActorX(getActorX(4) + 12.5, 4)
		setActorX(getActorX(5) + 25, 5)
		setActorX(getActorX(6) + 50, 6)
		setActorX(getActorX(7) + 100, 7)
		tweenPos(4, getActorX(4) - 12.5, getActorY(4), 0.09)
		tweenPos(5, getActorX(5) - 25, getActorY(5), 0.09)
		tweenPos(6, getActorX(6) - 50, getActorY(6), 0.09)
		tweenPos(7, getActorX(7) - 100, getActorY(7), 0.09)
	end

	if step == 728 then
		setActorX(getActorX(4) + 12.5, 4)
		setActorX(getActorX(5) + 25, 5)
		setActorX(getActorX(6) + 50, 6)
		setActorX(getActorX(7) + 100, 7)
		tweenPos(4, getActorX(4) - 12.5, getActorY(4), 0.09)
		tweenPos(5, getActorX(5) - 25, getActorY(5), 0.09)
		tweenPos(6, getActorX(6) - 50, getActorY(6), 0.09)
		tweenPos(7, getActorX(7) - 100, getActorY(7), 0.09)
	end

	if step == 731 then
		setActorY(getActorY(4) - 50, 4)
		setActorY(getActorY(5) + 50, 5)
		setActorY(getActorY(6) - 50, 6)
		setActorY(getActorY(7) + 50, 7)
		tweenPos(4, getActorX(4), getActorY(4) + 50, 0.09)
		tweenPos(5, getActorX(5), getActorY(5) - 50, 0.09)
		tweenPos(6, getActorX(6), getActorY(6) + 50, 0.09)
		tweenPos(7, getActorX(7), getActorY(7) - 50, 0.09)
	end

	if step == 734 then
		setActorX(getActorX(4) + 12.5, 4)
		setActorX(getActorX(5) + 25, 5)
		setActorX(getActorX(6) + 50, 6)
		setActorX(getActorX(7) + 100, 7)
		tweenPos(4, getActorX(4) - 12.5, getActorY(4), 0.09)
		tweenPos(5, getActorX(5) - 25, getActorY(5), 0.09)
		tweenPos(6, getActorX(6) - 50, getActorY(6), 0.09)
		tweenPos(7, getActorX(7) - 100, getActorY(7), 0.09)
	end

	if step == 744 then
		setActorX(getActorX(4) + 12.5, 4)
		setActorX(getActorX(5) + 25, 5)
		setActorX(getActorX(6) + 50, 6)
		setActorX(getActorX(7) + 100, 7)
		tweenPos(4, getActorX(4) - 12.5, getActorY(4), 0.09)
		tweenPos(5, getActorX(5) - 25, getActorY(5), 0.09)
		tweenPos(6, getActorX(6) - 50, getActorY(6), 0.09)
		tweenPos(7, getActorX(7) - 100, getActorY(7), 0.09)
	end

	if step == 747 then
		setActorX(getActorX(4) + 12.5, 4)
		setActorX(getActorX(5) + 25, 5)
		setActorX(getActorX(6) + 50, 6)
		setActorX(getActorX(7) + 100, 7)
		tweenPos(4, getActorX(4) - 12.5, getActorY(4), 0.09)
		tweenPos(5, getActorX(5) - 25, getActorY(5), 0.09)
		tweenPos(6, getActorX(6) - 50, getActorY(6), 0.09)
		tweenPos(7, getActorX(7) - 100, getActorY(7), 0.09)
	end

	if step == 750 then
		setActorX(getActorX(4) + 12.5, 4)
		setActorX(getActorX(5) + 25, 5)
		setActorX(getActorX(6) + 50, 6)
		setActorX(getActorX(7) + 100, 7)
		tweenPos(4, getActorX(4) - 12.5, getActorY(4), 0.09)
		tweenPos(5, getActorX(5) - 25, getActorY(5), 0.09)
		tweenPos(6, getActorX(6) - 50, getActorY(6), 0.09)
		tweenPos(7, getActorX(7) - 100, getActorY(7), 0.09)
	end

	if step == 760 then
		setActorY(getActorY(4) - 50, 4)
		setActorY(getActorY(5) + 50, 5)
		setActorY(getActorY(6) - 50, 6)
		setActorY(getActorY(7) + 50, 7)
		tweenPos(4, getActorX(4), getActorY(4) + 50, 0.09)
		tweenPos(5, getActorX(5), getActorY(5) - 50, 0.09)
		tweenPos(6, getActorX(6), getActorY(6) + 50, 0.09)
		tweenPos(7, getActorX(7), getActorY(7) - 50, 0.09)
	end

	if step == 762 then
		setActorX(getActorX(4) - 12.5, 4)
		setActorX(getActorX(5) - 25, 5)
		setActorX(getActorX(6) - 50, 6)
		setActorX(getActorX(7) - 100, 7)
		tweenPos(4, getActorX(4) + 12.5, getActorY(4), 0.09)
		tweenPos(5, getActorX(5) + 25, getActorY(5), 0.09)
		tweenPos(6, getActorX(6) + 50, getActorY(6), 0.09)
		tweenPos(7, getActorX(7) + 100, getActorY(7), 0.09)
	end

	if step == 764 then
		setActorY(getActorY(4) + 50, 4)
		setActorY(getActorY(5) - 50, 5)
		setActorY(getActorY(6) + 50, 6)
		setActorY(getActorY(7) - 50, 7)
		tweenPos(4, getActorX(4), getActorY(4) - 50, 0.09)
		tweenPos(5, getActorX(5), getActorY(5) + 50, 0.09)
		tweenPos(6, getActorX(6), getActorY(6) - 50, 0.09)
		tweenPos(7, getActorX(7), getActorY(7) + 50, 0.09)
	end

	if step == 766 then
		setActorX(getActorX(4) + 12.5, 4)
		setActorX(getActorX(5) + 25, 5)
		setActorX(getActorX(6) + 50, 6)
		setActorX(getActorX(7) + 100, 7)
		tweenPos(4, getActorX(4) - 12.5, getActorY(4), 0.09)
		tweenPos(5, getActorX(5) - 25, getActorY(5), 0.09)
		tweenPos(6, getActorX(6) - 50, getActorY(6), 0.09)
		tweenPos(7, getActorX(7) - 100, getActorY(7), 0.09)
	end
end
