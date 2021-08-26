import flixel.FlxG;
import flixel.input.gamepad.FlxGamepad;
import openfl.Lib;

class KadeEngineData
{
    public static function initSave()
    {
        //if (FlxG.save.data.weekUnlocked == null)
		//	FlxG.save.data.weekUnlocked = 1;

		if (FlxG.save.data.downscroll == null)
			FlxG.save.data.downscroll = false;

		if (FlxG.save.data.antialiasing == null)
			FlxG.save.data.antialiasing = true;

		if (FlxG.save.data.missSounds == null)
			FlxG.save.data.missSounds = true;

		if (FlxG.save.data.accuracyDisplay == null)
			FlxG.save.data.accuracyDisplay = true;

		if (FlxG.save.data.offset == null)
			FlxG.save.data.offset = 0;

		if (FlxG.save.data.songPosition == null)
			FlxG.save.data.songPosition = false;

		if (FlxG.save.data.fps == null)
			FlxG.save.data.fps = false;

		if (FlxG.save.data.changedHit == null)
		{
			FlxG.save.data.changedHitX = -1;
			FlxG.save.data.changedHitY = -1;
			FlxG.save.data.changedHit = false;
		}

		if (FlxG.save.data.fpsRain == null)
			FlxG.save.data.fpsRain = false;

		if (FlxG.save.data.fpsCap == null)
			FlxG.save.data.fpsCap = 120;

		if (FlxG.save.data.fpsCap > 285 || FlxG.save.data.fpsCap < 60)
			FlxG.save.data.fpsCap = 120; // baby proof so you can't hard lock ur copy of kade engine

		if (FlxG.save.data.scrollSpeed == null)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.npsDisplay == null)
			FlxG.save.data.npsDisplay = false;

		if (FlxG.save.data.frames == null)
			FlxG.save.data.frames = 10;

		if (FlxG.save.data.accuracyMod == null)
			FlxG.save.data.accuracyMod = 1;

		if (FlxG.save.data.watermark == null)
			FlxG.save.data.watermark = true;

		if (FlxG.save.data.ghost == null)
			FlxG.save.data.ghost = true;

		if (FlxG.save.data.background == null)
			FlxG.save.data.background = 2;

		if (FlxG.save.data.modChart == null)
			FlxG.save.data.modChart = true;

		if (FlxG.save.data.stepMania == null)
			FlxG.save.data.stepMania = false;

		if (FlxG.save.data.flashing == null)
			FlxG.save.data.flashing = true;

		if (FlxG.save.data.motion == null)
			FlxG.save.data.motion = true;

		if (FlxG.save.data.chrom == null)
			FlxG.save.data.chrom = true;

		if (FlxG.save.data.ghostTrails == null)
			FlxG.save.data.ghostTrails = true;

		if (FlxG.save.data.particles == null)
			FlxG.save.data.particles = true;

		if (FlxG.save.data.screenShake == null)
			FlxG.save.data.screenShake = true;

		if (FlxG.save.data.windowShake == null)
			FlxG.save.data.windowShake = true;

		if (FlxG.save.data.resetButton == null)
			FlxG.save.data.resetButton = false;

		if (FlxG.save.data.InstantRespawn == null)
			FlxG.save.data.InstantRespawn = false;

		if (FlxG.save.data.botplay == null)
			FlxG.save.data.botplay = false;

		if (FlxG.save.data.cpuStrums == null)
			FlxG.save.data.cpuStrums = true;

		if (FlxG.save.data.strumline == null)
			FlxG.save.data.strumline = false;

		if (FlxG.save.data.customStrumLine == null)
			FlxG.save.data.customStrumLine = true;

		if (FlxG.save.data.camzoom == null)
			FlxG.save.data.camzoom = true;

		if (FlxG.save.data.scoreScreen == null)
			FlxG.save.data.scoreScreen = true;

		if (FlxG.save.data.inputShow == null)
			FlxG.save.data.inputShow = false;

		if (FlxG.save.data.optimize == null)
			FlxG.save.data.optimize = false;

		if (FlxG.save.data.cacheImages == null)
			FlxG.save.data.cacheImages = true;

		if (FlxG.save.data.cacheCutscenes == null)
			FlxG.save.data.cacheCutscenes = true;

		if (FlxG.save.data.editor == null)
			FlxG.save.data.editor = true;

		if (FlxG.save.data.zoom == null)
			FlxG.save.data.zoom = 1;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		KeyBinds.gamepad = gamepad != null;

		// Data for Retro mod
		// Load unlocked mode data
		if (FlxG.save.data.modeUnlocked != null)
		{
			for (i in 0...StoryMenuState.modeUnlocked.length)
			{
				// (Arcy) Fail-safe for data not being the same length
				if (FlxG.save.data.modeUnlocked[i] != null)
					StoryMenuState.modeUnlocked[i] = FlxG.save.data.modeUnlocked[i];
			}
		}

		// Load unlocked character data
		if (FlxG.save.data.characterUnlocked != null)
		{
			for (i in 0...StoryMenuState.characterUnlocked.length)
			{
				// (Arcy) Fail-safe for data not being the same length
				if (FlxG.save.data.characterUnlocked[i] != null)
					StoryMenuState.characterUnlocked[i] = FlxG.save.data.characterUnlocked[i];
			}
		}

		// Load unlocked girlfriend data
		if (FlxG.save.data.girlfriendUnlocked != null)
		{
			for (i in 0...StoryMenuState.girlfriendUnlocked.length)
			{
				// (Arcy) Fail-safe for data not being the same length
				if (FlxG.save.data.girlfriendUnlocked[i] != null)
					StoryMenuState.girlfriendUnlocked[i] = FlxG.save.data.girlfriendUnlocked[i];
			}
		}

		// Load unlocked song data
		if (FlxG.save.data.songUnlocked != null)
		{
			for (i in 0...FreeplayState.songUnlocked.length)
			{
				// (Arcy) Fail-safe for data not being the same length
				if (FlxG.save.data.songUnlocked[i] != null)
					FreeplayState.songUnlocked[i] = FlxG.save.data.songUnlocked[i];
			}
		}

		// Load visible song data
		if (FlxG.save.data.songVisible != null)
		{
			for (i in 0...FreeplayState.songVisible.length)
			{
				// (Arcy) Fail-safe for data not being the same length
				if (FlxG.save.data.songVisible[i] != null)
					FreeplayState.songVisible[i] = FlxG.save.data.songVisible[i];
			}
		}

		Conductor.recalculateTimings();
		PlayerSettings.player1.controls.loadKeyBinds();
		KeyBinds.keyCheck();

		Main.watermarks = FlxG.save.data.watermark;

		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
	}
}