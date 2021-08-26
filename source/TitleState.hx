package;

#if sys
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.effects.particles.FlxEmitter;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
import openfl.system.System;

using StringTools;
#if windows
import Discord.DiscordClient;
#end
#if cpp
#end


class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var textGroup:FlxGroup;

	var curWacky:Array<String> = [];

	override public function create():Void
	{
		#if polymod
		polymod.Polymod.init({modRoot: "mods", dirs: ['introMod']});
		#end

		#if sys
		if (!sys.FileSystem.exists(Sys.getCwd() + "/assets/replays"))
		{
			sys.FileSystem.createDirectory(Sys.getCwd() + "/assets/replays");
		}
		#end

		// (tsg) this is stupid, i don't know how i was given approval to do this, but here's the coconut
		if (sys.FileSystem.exists("assets/images/coconut.png") == false)
		{
			// (tsg) allow hell to break loose

			// (tsg) exit game
			System.exit(0);
		}

		#if windows
		DiscordClient.initialize();

		Application.current.onExit.add(function(exitCode)
		{
			DiscordClient.shutdown();
		});

		#end

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		super.create();

		// NGio.noLogin(APIStuff.API);

		//FlxG.save.bind('funkin', 'ninjamuffin99');

		if (FlxG.save.data.weekUnlocked != null)
		{
			// FIX LATER!!!
			// WEEK UNLOCK PROGRESSION!!
			// StoryMenuState.weekUnlocked = FlxG.save.data.weekUnlocked;

			if (StoryMenuState.weekUnlocked.length < 4)
				StoryMenuState.weekUnlocked.insert(0, true);

			// QUICK PATCH OOPS!
			if (!StoryMenuState.weekUnlocked[0])
				StoryMenuState.weekUnlocked[0] = true;
		}

		#if FREEPLAY
		FlxG.switchState(new FreeplayState());
		#elseif CHARTING
		FlxG.switchState(new ChartingState());
		#else
		if (!initialized)
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				startIntro();
			});
		else
			startIntro();
		#end
	}

	var logoBl:FlxSprite;
	var logoBg:FlxSprite;
	var part1:FlxSprite;
	var titleText:FlxSprite;

	public static var introMusic:FlxSound;

	function startIntro()
	{
		Conductor.changeBPM(102);
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		// bg.antialiasing = FlxG.save.data.antialiasing;
		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();
		add(bg);

		// Nuh uh Kade Engine
		/*if (Main.watermarks) {
			logoBl = new FlxSprite(-150, 1500);
			logoBl.frames = Paths.getSparrowAtlas('KadeEngineLogoBumpin');
		} else {
		logoBl = new FlxSprite(-150, -100);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		//}
		logoBl.antialiasing = FlxG.save.data.antialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.updateHitbox();*/
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		add(logoBl);
		logoBg = new FlxSprite().loadGraphic(Paths.image("titleScreenBg"));
		logoBg.antialiasing = FlxG.save.data.antialiasing;
		logoBg.screenCenter();
		add(logoBg);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = FlxG.save.data.antialiasing;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		add(titleText);

		// Particle effects copied from Spectral
		if (FlxG.save.data.particles)
		{
			for (i in 0...6)
			{
				var emitter:FlxEmitter = new FlxEmitter(0, 720);
				emitter.launchMode = FlxEmitterMode.SQUARE;
				emitter.velocity.set(-50, -150, 50, -750, -100, 0, 100, -100);
				emitter.scale.set(0.5, 0.5, 1, 1, 0.5, 0.5, 0.75, 0.75);
				emitter.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
				emitter.width = 1280;
				emitter.alpha.set(1, 1, 0, 0);
				emitter.lifespan.set(3, 5);
				emitter.loadParticles(Paths.image('Particles/Particle' + i, 'shared'), 500, 16, true);

				emitter.start(false, FlxG.random.float(0.1, 0.2), 100000);
				add(emitter);
			}
		}

		logoBl = new FlxSprite(-150, -4);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = FlxG.save.data.antialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.scale.set(0.625, 0.625); // Temporary change for part 1
		// logoBl.scale.x = 0.75;
		// logoBl.scale.y = 0.75;
		logoBl.screenCenter();
		// logoBl.y -= 64;
		logoBl.y -= 105;
		// logoBl.color = FlxColor.BLACK;
		add(logoBl);

		part1 = new FlxSprite(0, 0);
		part1.loadGraphic(Paths.image('Part_1', 'preload'));
		part1.antialiasing = FlxG.save.data.antialiasing;
		part1.scale.set(0.2, 0.2);
		part1.screenCenter();
		part1.y += 175;
		add(part1);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		FlxG.mouse.visible = false;

		if (initialized)
		{
			skipIntro();
		}
		else {
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			// Make it HUGE
			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-FlxG.width, -FlxG.height, FlxG.width * 3, FlxG.height * 3));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-FlxG.width, -FlxG.height, FlxG.width * 3, FlxG.height * 3));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();
			MainMenuState.songName = 'Intro_Wrath';
			introMusic = FlxG.sound.play(Paths.music('Intro_Wrath'), 0);
			introMusic.persist = true;
			FlxG.sound.music = new FlxSound();
			FlxG.sound.music.persist = true;
			FlxG.sound.music.loadEmbedded(Paths.music('Menu_Wrath'), true); // Preload the music

			introMusic.onComplete = function():Void
			{
				FlxG.sound.music.volume = introMusic.volume; // Shit workaround I guess
				FlxG.sound.music.play(true);
				MainMenuState.songName = 'Menu_Wrath';
				if (!skippedIntro)
				{
					skipIntro(); // Hits right when the intro ends
				}
				introMusic.destroy();
				introMusic = null;
			}

			introMusic.fadeIn(4, 0, 0.75);

			Conductor.changeBPM(102);
			initialized = true;
		}
		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('data/introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (introMusic != null && introMusic.playing)
			Conductor.songPosition = introMusic.time;
		else if (FlxG.sound.music != null)
		{
			Conductor.songPosition = FlxG.sound.music.time;

			// Workaround for missing a beat animation on song loop
			if (Conductor.songPosition == 0)
			{
				beatHit();
			}
		}
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		// Fake the beat animation
		if (logoBl != null && logoBl.scale.x > 0.625)
		{
			logoBl.scale.x -= 0.25 * elapsed;
			logoBl.scale.y -= 0.25 * elapsed;
		}
		if (part1 != null && part1.scale.x > 0.2)
		{
			part1.scale.x -= 0.25 * elapsed;
			part1.scale.y -= 0.25 * elapsed;
		}

		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		var pressedEnter:Bool = controls.ACCEPT;

		if (pressedEnter && !transitioning && skippedIntro)
		{
			if (FlxG.save.data.flashing)
			{
				titleText.animation.play('press');
				FlxG.camera.flash(FlxColor.WHITE, 1);
			}

			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			MainMenuState.firstStart = true;
			MainMenuState.finishedFunnyMove = false;

			// (tsg - 6/15/21) remove kade update check to not nag users for new updates that they won't be able to apply
			new FlxTimer().start(1.25, function(tmr:FlxTimer)
			{
				FlxG.switchState(new MainMenuState());
			});
			// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
		}

		if (pressedEnter && !skippedIntro && initialized)
		{
			skipIntro();
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		// logoBl.animation.play('bump', true);
		FlxTween.tween(logoBl, {'scale.x': 0.65, 'scale.y': 0.65}, 0.025);
		FlxTween.tween(part1, {'scale.x': 0.225, 'scale.y': 0.225}, 0.025);
		// logoBl.scale.set(0.65, 0.65);
		// part1.scale.set(0.225, 0.225);

		// Workaround for how the intro is handled
		if (initialized && !skippedIntro)
		{
			switch (curBeat)
			{
				case 1:
					createCoolText(['Retro Mod Team']);
				case 3:
					// (tsg - 7/5/21) i do this because of a rare bug where case 1 doesnt get hit
					deleteCoolText();
					createCoolText(['Retro Mod Team']);

					addMoreText('presents');
				case 4:
					deleteCoolText();
				case 5:
					createCoolText(['Based on a game by']);
				case 7:
					deleteCoolText();
					createCoolText([
						'Based on a game by',
						'ninjamuffin99',
						'phantomArcade',
						'kawaisprite',
						'evilsk8er'
					]);
				// addMoreText('Newgrounds');
				// ngSpr.visible = true;
				case 8:
					deleteCoolText();
				// ngSpr.visible = false;
				case 9:
					createCoolText([curWacky[0]]);
				case 11:
					addMoreText(curWacky[1]);
				case 12:
					deleteCoolText();
				case 13:
					addMoreText('Friday Night Funkin');
				case 14:
					addMoreText('VS');
				case 15:
					addMoreText('RetroSpecter');

				case 16:
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			if (FlxG.save.data.flashing)
			{
				FlxG.camera.flash(FlxColor.WHITE, 4);
			}
			remove(credGroup);

			/*FlxTween.tween(logoBl,{y: -100}, 1.4, {ease: FlxEase.expoInOut});

			logoBl.angle = -4;

			new FlxTimer().start(0.01, function(tmr:FlxTimer)
				{
					if(logoBl.angle == -4)
						FlxTween.angle(logoBl, logoBl.angle, 4, 4, {ease: FlxEase.quartInOut});
					if (logoBl.angle == 4)
						FlxTween.angle(logoBl, logoBl.angle, -4, 4, {ease: FlxEase.quartInOut});
				}, 0);*/

			skippedIntro = true;
		}
	}
}
