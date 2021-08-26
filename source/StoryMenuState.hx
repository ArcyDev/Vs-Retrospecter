package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;
#if windows
import Discord.DiscordClient;
#end


class StoryMenuState extends MusicBeatState
{
	var weekData:Array<Dynamic> = [
		['Satisfracture', 'Spectral'],
		['Retro', 'Spectral'],
		['Retro', 'Spectral'],
		['Retro', 'Spectral'],
		['Retro', 'Spectral'],
		['Retro', 'Spectral'],
		['Retro', 'Spectral']
	];

	var altWeekData:Array<Dynamic> = [['Satisfracture', 'Spectral']];

	public static var weekUnlocked:Array<Bool> = [true, false, false, false, false, false, false];

	var weekCharacters:Array<String> = [
		'retro',
		'sakuromaMenu',
		'izzurius',
		'insatian',
		'hivemine',
		'atrocean',
		'dozirc'
	];

	var weekNames:Array<String> = ["wrath_title", "LUST", "PRIDE", "GLUTTONY", "GREED", "ENVY", "SLOTH"];

	var weekThemes:Array<String> = [
		"Menu_Wrath",
		"Menu_Lust",
		"Menu_Pride",
		"Menu_Gluttony",
		"Menu_Greed",
		"Menu_Envy",
		"Menu_Sloth"
	];

	var introThemes:Array<String> = [
		"Intro_Wrath",
		"Intro_Lust",
		"Intro_Pride",
		"Intro_Gluttony",
		"Intro_Greed",
		"Intro_Envy",
		"Intro_Sloth"
	];

	public static var modeUnlocked:Array<Bool> = [true, false, false, false];

	var modeNames:Array<String> = ["standard", "nofail", "freestyle", "randomized"];

	public static var characterUnlocked:Array<Bool> = [true, false, false];

	var bfCharacterNames:Array<String> = ["bf", "bf-retro", "bf-ace"];

	public static var girlfriendUnlocked:Array<Bool> = [true, false];

	var gfCharacterNames:Array<String> = ["gf", "sakuroma"];

	var weekColors:Array<FlxColor> = [
		0xFF18d8e5,
		0xFFff2a60,
		0xFFffffff,
		0xFFfe2544,
		0xFFd204ff,
		0xFF05fec4,
		0xFFd2914a
	];

	var bgColors:Array<FlxColor> = [
		0xFF00BBBB,
		FlxColor.PINK,
		0xFF1c1c1c,
		0xFF870000,
		0xFF5400a8,
		0xFF131735,
		0xFF94420f
	];

	var logoFileNames:Array<String> = [
		'VsRetrospecterLogo',
		'ComingSoonLogo',
		'ComingSoonLogo',
		'ComingSoonLogo',
		'ComingSoonLogo',
		'ComingSoonLogo',
		'ComingSoonLogo'
	];

	var bgFileNames:Array<String> = [
		'wrath_symbol',
		'lust_symbol',
		'pride_symbol',
		'gluttony_symbol',
		'greed_symbol',
		'envy_symbol',
		'sloth_symbol'
	];

	public static var unlockedSongs:Array<String> = [];
	public static var unlockedModes:Array<String> = [];
	public static var unlockedChars:Array<String> = [];


	var scoreText:FlxText;
	var txtWeekTitle:FlxText;
	var controlsConfirmText:FlxText;
	var controlsBackText:FlxText;

	var curWeek:Int = 0;
	var curMode:Int = 0;
	var curDifficulty:Int = 1;
	var curCharacter:Int = 0;
	var curGf:Int = 0;

	var weekSongs:FlxTypedGroup<FlxSound>;
	var grpWeekBGs:FlxTypedGroup<FlxTypedGroup<FlxSprite>>;
	var grpWeekText:FlxTypedGroup<FlxSprite>;
	var grpWeekTitles:FlxTypedGroup<FlxSprite>;
	var grpWeekCharacters:FlxTypedGroup<Character>;
	var bfCharacters:FlxTypedGroup<Character>;
	var gfIcons:FlxTypedGroup<HealthIcon>;

	var weekTitleOriginalScales:Array<FlxPoint>;

	// var difficultySelectors:FlxGroup;
	var bg:FlxSprite;
	// var bfCharacter:Character;
	var blackCover:FlxSprite;
	var sprMode:FlxSprite;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	function unlockWeeks():Array<Bool>
	{
		var weeks:Array<Bool> = [];

		weeks.push(true);

		for(i in 0...FlxG.save.data.weekUnlocked)
			{
				weeks.push(true);
			}
		return weeks;
	}

	// Stuff for displaying unlocks
	var fadeBG:FlxSprite;
	var unlockSprites:FlxTypedGroup<FlxSprite>;
	var unlockDescription:FlxText;
	var uniqueUnlockText:String;
	var badge:FlxSprite;

	// Secrets
	var charInputs:String;
	var cheatCode1:String = "MOMMYMOTHYMILKIES";
	var cheatCode2:String = "DRYOCAMPARUBICUNDATHEROSYMAPLEMOTHISASMALLNORTHAMERICANMOTHINTHEFAMILYSATURNIIDAEALSOKNOWNASTHEGREATSILKMOTHSITWASFIRSTDESCRIBEDBYJOHANCHRISTIANFABRICIUSIN1793THESPECIESISKNOWNFORITSWOOLYBODYANDPINKANDYELLOWCOLORATIONWHICHVARIESFROMCREAMORWHITETOBRIGHTPINKORYELLOWMALESHAVEBUSHIERANTENNAETHANFEMALESWHICHALLOWTHEMTOSENSEFEMALEPHEROMONESFORMATING";

	override function create()
	{
		//weekUnlocked = unlockWeeks();

		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Story Mode Menu", null);
		#end

		// Set up the modes
		for (i in 0...modeUnlocked.length)
		{
			if (!modeUnlocked[i])
			{
				modeNames[i] = null; // Set it to null to resemble it not being unlocked
			}
		}

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (TitleState.introMusic == null || !TitleState.introMusic.playing)
		{
			if (FlxG.sound.music != null && FlxG.sound.music.playing)
			{
				var songTime = FlxG.sound.music.time;
				FlxG.sound.playMusic(Paths.music(weekThemes[0]), 0.75);
				FlxG.sound.music.time = songTime;
				Conductor.changeBPM(102);
			}
			else
			{
				FlxG.sound.playMusic(Paths.music(weekThemes[0]), 0.75);
				Conductor.changeBPM(102);
			}
		}

		Conductor.changeBPM(102);

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, FlxG.height + 40, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 800, 0, "", 46);
		txtWeekTitle.text = "Select Mode";
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.screenCenter(X);
		txtWeekTitle.alpha = 0.7;

		controlsConfirmText = new FlxText(1090, FlxG.height + 30, 0, "ENTER - Confirm", 18);
		controlsConfirmText.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, RIGHT);

		controlsBackText = new FlxText(1150, FlxG.height + 55, 0, "ESC - Back", 18);
		controlsBackText.setFormat("VCR OSD Mono", 20, FlxColor.WHITE, RIGHT);

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		bg = new FlxSprite(0, 0);
		bg.makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
		bg.color = bgColors[0];

		// Add scrolling backgrounds
		grpWeekBGs = new FlxTypedGroup<FlxTypedGroup<FlxSprite>>();

		for (i in 0...bgFileNames.length)
		{
			if (bgFileNames[i] != '')
			{
				var symbols:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
				// 6 columns across
				for (j in 0...6)
				{
					// 8 rows down
					for (k in 0...8)
					{
						var weekBG:FlxSprite = new FlxSprite(((k % 2 == 1) ? -300 : -150) + (j * 300),
							-150 + (k * 150)).loadGraphic(Paths.image('storymenu/' + bgFileNames[i], 'preload'));
						weekBG.antialiasing = FlxG.save.data.antialiasing;
						weekBG.alpha = 0;
						symbols.add(weekBG);
					}
				}

				grpWeekBGs.add(symbols);
			}
			else
			{
				grpWeekBGs.add(new FlxTypedGroup<FlxSprite>());
			}
		}

		if (grpWeekBGs.members[0].length > 0)
		{
			for (i in 0...grpWeekBGs.members[0].length)
			{
				grpWeekBGs.members[0].members[i].alpha = 1;
			}
		}

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);
		grpWeekTitles = new FlxTypedGroup<FlxSprite>();
		grpWeekText = new FlxTypedGroup<FlxSprite>();

		// var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		// add(blackBarThingie);

		// Add each sin character
		grpWeekCharacters = new FlxTypedGroup<Character>();
		weekTitleOriginalScales = new Array<FlxPoint>();

		for (i in 0...weekNames.length)
		{
			if (weekNames[i].endsWith('title'))
			{
				var weekThing:FlxSprite = new FlxSprite(0, 400).loadGraphic(Paths.image('storymenu/' + weekNames[i]));

				weekThing.setGraphicSize(271, 144);
				weekThing.updateHitbox();

				weekThing.screenCenter(X);

				weekThing.antialiasing = FlxG.save.data.antialiasing;
				weekThing.visible = false;

				grpWeekTitles.add(weekThing);
				weekTitleOriginalScales.push(new FlxPoint(weekThing.scale.x, weekThing.scale.y));
			}
			else
			{
				var weekThing:FlxText = new FlxText(-50, 425, 0, weekNames[i], 28);
				weekThing.color = weekColors[i];
				weekThing.screenCenter(X);
				weekThing.visible = false;

				grpWeekTitles.add(weekThing);
				weekTitleOriginalScales.push(new FlxPoint(weekThing.scale.x, weekThing.scale.y));
			}
		}

		for (i in 0...logoFileNames.length)
		{
			if (logoFileNames[i] == 'ComingSoonLogo')
			{
				var weekThing:FlxSprite = new FlxSprite(FlxG.width * 0.7, -275).loadGraphic(Paths.image(logoFileNames[i], 'preload'));
				weekThing.scale.set(0.125, 0.125);
				weekThing.screenCenter(X);
				weekThing.antialiasing = FlxG.save.data.antialiasing;
				weekThing.visible = false;
				grpWeekText.add(weekThing);
			}
			else
			{
				var weekThing:FlxSprite = new FlxSprite(FlxG.width * 0.7, 215).loadGraphic(Paths.image(logoFileNames[i], 'preload'));
				weekThing.scale.set(0.25, 0.25);
				// weekThing.y += ((weekThing.height + 20) * i);
				// weekThing.targetY = i;
				grpWeekText.add(weekThing);

				weekThing.screenCenter(X);
				weekThing.antialiasing = FlxG.save.data.antialiasing;
				// weekThing.updateHitbox();
				weekThing.visible = false;
			}
		}

		bfCharacters = new FlxTypedGroup<Character>();

		// Make a separate character for each bf instead of having to reload the assets every time it switches
		for (i in 0...bfCharacterNames.length)
		{
			var bfChar:Character = new Character(FlxG.width + 200, 250, bfCharacterNames[i], true);
			bfChar.scale.set(0.5, 0.5);
			bfChar.x -= bfChar.width / 2;
			bfChar.visible = false;
			bfCharacters.add(bfChar);
		}

		// Hard coding *clap*
		if (girlfriendUnlocked[1])
		{
			gfIcons = new FlxTypedGroup<HealthIcon>();

			for (i in 0...gfCharacterNames.length)
			{
				var gfIcon:HealthIcon = new HealthIcon(gfCharacterNames[i], true);
				gfIcon.scale.set(0.75, 0.75);
				gfIcon.setPosition(FlxG.width + 200, 535);
				gfIcon.visible = false;
				gfIcons.add(gfIcon);
			}

			gfIcons.members[0].visible = true;
		}

		bfCharacters.members[0].visible = true;

		// Show only the first week
		grpWeekTitles.members[0].visible = true;
		grpWeekText.members[0].visible = true;

		// Create the characters
		// In a very poor way
		var sinChar0:Character = new Character(425, -20, weekCharacters[0]);
		sinChar0.scale.set(0.9, 0.9);
		grpWeekCharacters.add(sinChar0);
		var sinChar1:Character = new Character(825, -25, weekCharacters[1]);
		sinChar1.scale.set(0.5, 0.5);
		grpWeekCharacters.add(sinChar1);
		for (i in 2...6)
		{
			var sinChar:Character = new Character(1450, -25, weekCharacters[i]);
			sinChar.scale.set(0.5, 0.5);
			grpWeekCharacters.add(sinChar);
		}
		var sinChar6:Character = new Character(-25, -25, weekCharacters[6]);
		sinChar6.scale.set(0.5, 0.5);
		grpWeekCharacters.add(sinChar6);

		// Make other characters just the silhouette
		for (i in 1...grpWeekCharacters.members.length)
		{
			grpWeekCharacters.members[i].color = FlxColor.BLACK;
		}

		// difficultySelectors = new FlxGroup();
		// add(difficultySelectors);

		leftArrow = new FlxSprite(300, 200);
		// leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.scale.set(0.5, 0.5);
		leftArrow.animation.play('idle');
		// difficultySelectors.add(leftArrow);

		// Game mode text
		sprMode = new FlxText(FlxG.width + 200, 100, 0, "", 50);
		sprMode.frames = ui_tex;
		sprMode.animation.addByPrefix('standard', 'STANDARD');
		sprMode.animation.addByPrefix('nofail', 'NO FAIL');
		sprMode.animation.addByPrefix('nofaillock', 'no fail lock');
		sprMode.animation.addByPrefix('freestyle', 'FREESTYLE');
		sprMode.animation.addByPrefix('freestylelock', 'freestyle lock');
		sprMode.animation.addByPrefix('randomized', 'RANDOMIZED');
		sprMode.animation.addByPrefix('randomizedlock', 'randomized lock');
		sprMode.animation.play('standard');

		// Difficulty stuff
		sprDifficulty = new FlxSprite(sprMode.x, 225);
		sprDifficulty.frames = ui_tex;
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.addByPrefix('hell', 'HELL');
		sprDifficulty.animation.play('easy');
		changeDifficulty();

		rightArrow = new FlxSprite(825, 200);
		// rightArrow = new FlxSprite(sprDifficultyX + grpWeekText.members[0].x + 50, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.scale.set(0.5, 0.5);
		rightArrow.animation.play('idle');
		// difficultySelectors.add(rightArrow);

		// Oh bf bb
		// bfCharacter = new Character(sprDifficulty.x, 250, 'bf', true);
		// bfCharacter.x -= bfCharacter.width / 2;
		// bfCharacter.setCharacter(bfCharacterNames[0]);

		fadeBG = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height);
		fadeBG.color = FlxColor.BLACK;
		fadeBG.alpha = 0.9;
		fadeBG.visible = false;

		unlockSprites = new FlxTypedGroup<FlxSprite>();

		unlockDescription = new FlxText(FlxG.width / 2, 600);
		unlockDescription.setFormat("VCR OSD Mono", 32, FlxColor.WHITE);
		unlockDescription.screenCenter(X);
		unlockDescription.visible = false;

		charInputs = "";

		add(bg);
		add(grpWeekBGs);
		add(grpWeekCharacters);
		add(sprMode);
		add(sprDifficulty);
		// add(bfCharacter);
		add(bfCharacters);
		add(gfIcons);

		blackCover = new FlxSprite(0, 400);
		blackCover.makeGraphic(FlxG.width, FlxG.height - 400, FlxColor.BLACK);
		add(blackCover);

		// Cheap, lazy way to check if Ectospasm was beaten
		if (Highscore.getScore('Ectospasm', 3) > 0)
		{
			badge = new FlxSprite(1150, 575);
			if (FlxG.save.data.cacheImages)
			{
				badge.frames = FileCache.instance.fromSparrow('shared_badge', 'Badge');
			}
			else
			{
				badge.frames = Paths.getSparrowAtlas('Badge','shared');
			}
			badge.animation.addByPrefix('shine', 'Badge Shine', 24);
			badge.animation.play('shine');
			add(badge);
		}

		add(grpWeekTitles);
		add(grpWeekText);
		add(leftArrow);
		add(rightArrow);

		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);
		add(controlsConfirmText);
		add(controlsBackText);

		// Unlock stuff covers over everything
		add(fadeBG);
		add(unlockSprites);
		add(unlockDescription);

		updateText();

		// Music themes for each week
		weekSongs = new FlxTypedGroup<FlxSound>();
		for (i in 0...weekThemes.length)
		{
			var music:FlxSound = new FlxSound().loadEmbedded(Paths.music(weekThemes[i]), true, true);
			weekSongs.add(music);
			FlxG.sound.list.add(music);
		}

		displayUnlocks();

		super.create();
	}

	override function update(elapsed:Float)
	{
		// Workaround to avoid sound stutter issue with time lost during loading
		if ((TitleState.introMusic == null || !TitleState.introMusic.playing) && FlxG.sound.music.playing && !movedBack)
		{
			weekSongs.members[curWeek].play(false, FlxG.sound.music.time % weekSongs.members[curWeek].length);
			weekSongs.members[curWeek].volume = 0.75;

			if (MainMenuState.songName != weekThemes[curWeek])
			{
				MainMenuState.songName = weekThemes[curWeek];

				weekSongs.members[curWeek].fadeIn(0.5, 0, 0.75);
				FlxG.sound.music.fadeOut(0.5, 0, function(twn:FlxTween)
				{
					FlxG.sound.music.pause();
				});
			}
			else
			{
				FlxG.sound.music.pause();
			}
		}

		// Kept track for animations on beat
		if (TitleState.introMusic != null && TitleState.introMusic.playing)
		{
			Conductor.songPosition = TitleState.introMusic.time;
		}
		else
		{
			Conductor.songPosition = weekSongs.members[curWeek].time;
		}

		// Workaround for missing a beat animation on song loop
		if (Conductor.songPosition == 0)
		{
			beatHit();
		}

		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		scoreText.text = "WEEK SCORE:" + lerpScore;

		// Cheat code for Fuzzy Feeling
		checkCodeInput();

		// Bogos Bumpin?
		if (weekNames[curWeek].endsWith('title') && grpWeekTitles.members[curWeek].scale.x > weekTitleOriginalScales[curWeek].x)
		{
			grpWeekTitles.members[curWeek].scale.x -= 0.5 * elapsed * weekTitleOriginalScales[curWeek].x;
			grpWeekTitles.members[curWeek].scale.y -= 0.5 * elapsed * weekTitleOriginalScales[curWeek].y;
		}
		if (logoFileNames[curWeek] == 'ComingSoonLogo' && grpWeekText.members[curWeek].scale.x > 0.125)
		{
			grpWeekText.members[curWeek].scale.x -= 0.25 * elapsed;
			grpWeekText.members[curWeek].scale.y -= 0.25 * elapsed;
		}
		else if (grpWeekText.members[curWeek].scale.x > 0.25)
		{
			grpWeekText.members[curWeek].scale.x -= 0.25 * elapsed;
			grpWeekText.members[curWeek].scale.y -= 0.25 * elapsed;
		}

		// Pan the background
		// Oh FUCK I have to do each one because the transitions show both NOOOOOO
		if (FlxG.save.data.motion)
		{
			for (i in 0...grpWeekBGs.length)
			{
				if (grpWeekBGs.members[i].length > 0)
				{
					for (j in 0...grpWeekBGs.members[i].length)
					{
						grpWeekBGs.members[i].members[j].x -= 100 * elapsed;
						grpWeekBGs.members[i].members[j].y += 100 * elapsed;

						// Reset position when end of the image is reached
						if (grpWeekBGs.members[i].members[j].x <= -300)
						{
							grpWeekBGs.members[i].members[j].x = 1500;
						}
						if (grpWeekBGs.members[i].members[j].y >= 1050)
						{
							grpWeekBGs.members[i].members[j].y = -150;
						}
					}
				}
			}
		}

		// Moved these to the create function and control inputs for optimization
		// txtWeekTitle.text = weekNames[curWeek].toUpperCase();
		// txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 30);

		// FlxG.watch.addQuick('font', scoreText.font);

		// difficultySelectors.visible = weekUnlocked[curWeek];

		if (unlocking && !stopspamming)
		{
			if (controls.ACCEPT || controls.BACK)
			{
				stopspamming = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

				// Remove the unlock group
				if (unlockedSongs.length > 0)
				{
					unlockedSongs = [];
				}
				else if (unlockedModes.length > 0)
				{
					unlockedModes = [];
				}
				else if (unlockedChars.length > 0)
				{
					unlockedChars = [];
				}

				for (i in 0...unlockSprites.length)
				{
					FlxTween.tween(unlockSprites.members[i], {alpha: 0}, 0.5);
				}
				FlxTween.tween(unlockDescription, {alpha: 0}, 0.5, {
					onComplete: function(flx:FlxTween)
					{
						unlockSprites.clear();
						displayUnlocks();
					}
				});
			}
		}
		else if (!movedBack && !stopspamming)
		{
			// Moved the control animations outside since it's shared with all selections
			if (controls.RIGHT)
			{
				rightArrow.animation.play('press');
				rightArrow.offset.set(-20, -10);
			}
			else
			{
				rightArrow.animation.play('idle');
				rightArrow.offset.set(0, 0);
			}

			if (controls.LEFT)
			{
				leftArrow.animation.play('press');
				leftArrow.offset.set(-25, -10);
			}
			else
			{
				leftArrow.animation.play('idle');
				leftArrow.offset.set(0, 0);
			}

			if (!selectedWeek)
			{
				if (controls.ACCEPT)
				{
					selectWeek();
				}
				else if (controls.RIGHT_P)
				{
					changeWeek(1);
				}
				else if (controls.LEFT_P)
				{
					changeWeek(-1);
				}

				/*if (controls.UP_P)
					{
						changeWeek(-1);
					}

					if (controls.DOWN_P)
					{
						changeWeek(1);
				}*/
				else if (controls.BACK)
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					movedBack = true;

					// Keep the current theme going
					FlxG.sound.music.loadEmbedded(Paths.music(weekThemes[curWeek]), true, true);
					FlxG.sound.music.play(false, weekSongs.members[curWeek].time % weekSongs.members[curWeek].length);
					weekSongs.members[curWeek].stop();

					FlxG.switchState(new MainMenuState());
				}
				/*if (controls.RIGHT_P)
						changeDifficulty(1);
					if (controls.LEFT_P)
						changeDifficulty(-1); */
			}
			else if (selectedSettings)
			{
				if (controls.ACCEPT)
				{
					confirmWeek();
				}
				else if (controls.BACK)
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					selectedSettings = false;

					// Don't break shit >:(
					stopspamming = true;

					// Bring those arrows back
					FlxTween.tween(leftArrow, {alpha: 1}, 0.5, {ease: FlxEase.cubeOut});
					FlxTween.tween(rightArrow, {alpha: 1}, 0.5, {ease: FlxEase.cubeOut});

					// Down and up
					FlxTween.tween(txtWeekTitle, {y: 750}, 0.25, {
						ease: FlxEase.cubeOut,
						onComplete: function(flx:FlxTween)
						{
							if (!selectedMode)
								txtWeekTitle.text = "Select Mode";
							else if (!selectedDifficulty)
								txtWeekTitle.text = "Select Difficulty";
							else
								txtWeekTitle.text = "Select Character";

							FlxTween.tween(txtWeekTitle, {y: 675}, 0.25, {
								ease: FlxEase.cubeOut,
								onComplete: function(flx:FlxTween)
								{
									stopspamming = false;
								}
							});
						}
					});
				}
			}
			else if (!selectedMode)
			{
				if (controls.ACCEPT)
				{
					selectSettings();
				}
				else if (controls.RIGHT_P)
				{
					changeMode(1);
				}
				else if (controls.LEFT_P)
				{
					changeMode(-1);
				}
				else if (controls.DOWN_P)
				{
					selectMode();
				}
				else if (controls.BACK)
				{
					cancelStorySettings();
				}
			}
			else if (!selectedDifficulty)
			{
				if (controls.ACCEPT)
				{
					selectSettings();
				}
				else if (controls.RIGHT_P)
				{
					changeDifficulty(1);
				}
				else if (controls.LEFT_P)
				{
					changeDifficulty(-1);
				}
				else if (controls.DOWN_P)
				{
					selectDifficulty();
				}
				else if (controls.UP_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					selectedMode = false;

					// Don't break shit >:(
					stopspamming = true;
					txtWeekTitle.text = "Select Mode";
					txtWeekTitle.screenCenter(X);

					// Move the arrows back up
					FlxTween.tween(leftArrow, {x: 575, y: 90}, 0.15, {ease: FlxEase.cubeOut});
					FlxTween.tween(rightArrow, {x: 1110, y: 90}, 0.15, {
						ease: FlxEase.cubeOut,
						onComplete: function(flx:FlxTween)
						{
							stopspamming = false;
						}
					});
				}
				else if (controls.BACK)
				{
					cancelStorySettings();
				}
			}
			else if (!selectedCharacter)
			{
				if (controls.ACCEPT)
				{
					selectSettings();
				}
				else if (controls.RIGHT_P)
				{
					changeCharacter(1);
				}
				else if (controls.LEFT_P)
				{
					changeCharacter(-1);
				}
				else if (controls.DOWN_P && girlfriendUnlocked[1])
				{
					selectCharacter();
				}
				else if (controls.UP_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					selectedDifficulty = false;

					// Don't break shit >:(
					stopspamming = true;
					txtWeekTitle.text = "Select Difficulty";
					txtWeekTitle.screenCenter(X);

					// Move the arrows back up
					FlxTween.tween(leftArrow, {x: 640, y: 215}, 0.15, {ease: FlxEase.cubeOut});
					FlxTween.tween(rightArrow, {x: 1035, y: 215}, 0.15, {
						ease: FlxEase.cubeOut,
						onComplete: function(flx:FlxTween)
						{
							stopspamming = false;
						}
					});
				}
				else if (controls.BACK)
				{
					cancelStorySettings();
				}
			}
			else
			{
				if (controls.ACCEPT)
				{
					selectSettings();
				}
				else if (controls.RIGHT_P)
				{
					changeGirlfriend(1);
				}
				else if (controls.LEFT_P)
				{
					changeGirlfriend(-1);
				}
				else if (controls.UP_P)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					selectedCharacter = false;

					// Don't break shit >:(
					stopspamming = true;
					txtWeekTitle.text = "Select Character";
					txtWeekTitle.screenCenter(X);

					// Move the arrows back up
					FlxTween.tween(leftArrow, {x: 700, y: 415}, 0.15, {ease: FlxEase.cubeOut});
					FlxTween.tween(rightArrow, {x: 975, y: 415}, 0.15, {
						ease: FlxEase.cubeOut,
						onComplete: function(flx:FlxTween)
						{
							stopspamming = false;
						}
					});
				}
				else if (controls.BACK)
				{
					cancelStorySettings();
				}
			}
		}

		super.update(elapsed);
	}

	override function beatHit()
	{
		super.beatHit();

		// Characters dance on beat
		for (i in 0...grpWeekCharacters.length)
		{
			grpWeekCharacters.members[i].animation.play('idle', true);
		}

		// Same with bf
		if (bfCharacters.members[curCharacter].animation.name != 'hey')
		{
			bfCharacters.members[curCharacter].animation.play('idle', true);
		}

		// And the logos
		if (weekNames[curWeek].endsWith('title'))
		{
			var originalX = weekTitleOriginalScales[curWeek].x;
			var originalY = weekTitleOriginalScales[curWeek].y;

			FlxTween.tween(grpWeekTitles.members[curWeek], {'scale.x': originalX * 1.05, 'scale.y': originalY * 1.05}, 0.025);
		}

		if (logoFileNames[curWeek] == 'ComingSoonLogo')
		{
			FlxTween.tween(grpWeekText.members[curWeek], {'scale.x': 0.15, 'scale.y': 0.15}, 0.025);
		}
		else
		{
			FlxTween.tween(grpWeekText.members[curWeek], {'scale.x': 0.275, 'scale.y': 0.275}, 0.025);
		}

		// Let's do the badge too, why not
		if (badge != null && curBeat % 2 == 0)
		{
			badge.animation.play('shine', true);
		}
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var selectedMode:Bool = false;
	var selectedDifficulty:Bool = false;
	var selectedCharacter:Bool = false;
	var selectedSettings:Bool = false;
	var stopspamming:Bool = false;
	var unlocking:Bool = false;

	/// Old selectWeek function just in case I mess up

	/*function selectWeek()
		{
			if (weekUnlocked[curWeek])
			{
				if (stopspamming == false)
				{
					FlxG.sound.play(Paths.sound('confirmMenu'));

					grpWeekText.members[curWeek].startFlashing();
					grpWeekCharacters.members[1].animation.play('bfConfirm');
					stopspamming = true;
				}

			PlayState.storyPlaylist = weekData()[curWeek];
			PlayState.isStoryMode = true;
			selectedWeek = true;


			PlayState.storyDifficulty = curDifficulty;

			// adjusting the song name to be compatible
			var songFormat = StringTools.replace(PlayState.storyPlaylist[0], " ", "-");
			switch (songFormat) {
				case 'Dad-Battle': songFormat = 'Dadbattle';
				case 'Philly-Nice': songFormat = 'Philly';
			}

			var poop:String = Highscore.formatSong(songFormat, curDifficulty);
			PlayState.sicks = 0;
			PlayState.bads = 0;
			PlayState.shits = 0;
			PlayState.goods = 0;
			PlayState.campaignMisses = 0;
			PlayState.SONG = Song.loadFromJson(poop, PlayState.storyPlaylist[0]);
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
			});
		}
	}*/
	function selectWeek()
	{
		if (weekUnlocked[curWeek] && !stopspamming)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));

			// grpWeekText.members[curWeek].startFlashing();
			// grpWeekCharacters.members[1].animation.play('bfConfirm');
			stopspamming = true;

			// Make the arrows fade away
			FlxTween.tween(leftArrow, {alpha: 0}, 0.5, {ease: FlxEase.cubeOut});
			FlxTween.tween(rightArrow, {alpha: 0}, 0.5, {ease: FlxEase.cubeOut});

			var previousWeek:Int = curWeek - 1;
			if (previousWeek < 0)
			{
				previousWeek = weekData.length - 1;
			}
			var nextWeek:Int = curWeek + 1;
			if (nextWeek >= weekData.length)
			{
				nextWeek = 0;
			}

			// Move side characters off-screen
			FlxTween.tween(grpWeekCharacters.members[previousWeek], {x: -600}, 0.5, {ease: FlxEase.cubeOut});
			FlxTween.tween(grpWeekCharacters.members[nextWeek], {x: 1450}, 0.5, {
				ease: FlxEase.cubeOut,
				onComplete: function(flx:FlxTween)
				{
					// Move vs character to the left
					FlxTween.tween(grpWeekCharacters.members[curWeek], {x: 50}, 0.5, {ease: FlxEase.cubeOut});

					// Move the black rect cover down off-screen, along with the elements on it
					FlxTween.tween(blackCover, {y: 660}, 0.75, {
						ease: FlxEase.cubeOut,
						onComplete: function(flx:FlxTween)
						{
							// Move text back up
							txtWeekTitle.color = FlxColor.WHITE;
							txtWeekTitle.text = "Select Mode";
							FlxTween.tween(txtWeekTitle, {y: 675}, 0.5, {ease: FlxEase.cubeOut});
							// txtWeekTitle.Translate(0, -70);

							// Move score text up
							FlxTween.tween(scoreText, {y: 675}, 0.5, {ease: FlxEase.cubeOut});
							FlxTween.tween(controlsConfirmText, {y: 665}, 0.5, {ease: FlxEase.cubeOut});
							FlxTween.tween(controlsBackText, {y: 685}, 0.5, {ease: FlxEase.cubeOut});

							// Re-position arrows
							leftArrow.x = sprDifficulty.x - sprDifficulty.width + 70;
							leftArrow.y = sprMode.y - 10;
							rightArrow.x = sprDifficulty.x + sprDifficulty.width - 40;
							rightArrow.y = sprMode.y - 10;
							leftArrow.alpha = 1;
							rightArrow.alpha = 1;

							// Move the difficulty over on-screen
							FlxTween.tween(sprMode, {x: 725}, 0.5, {ease: FlxEase.cubeOut});
							FlxTween.tween(leftArrow, {x: 575}, 0.5, {ease: FlxEase.cubeOut});
							FlxTween.tween(rightArrow, {x: 1110}, 0.5, {ease: FlxEase.cubeOut});
							FlxTween.tween(sprDifficulty, {x: 850}, 0.75, {ease: FlxEase.cubeOut});
							FlxTween.tween(bfCharacters.members[curCharacter], {x: 725}, 1, {
								ease: FlxEase.cubeOut,
								onComplete: function(flx:FlxTween)
								{
									// Good enough
									stopspamming = false;
								}
							});
							if (girlfriendUnlocked[1])
							{
								FlxTween.tween(gfIcons.members[curGf], {x: 860}, 1.25, {ease: FlxEase.cubeOut});
							}
						}
					});
					FlxTween.tween(grpWeekTitles.members[curWeek], {y: 790}, 0.75, {ease: FlxEase.cubeOut});
					FlxTween.tween(grpWeekText.members[curWeek], {y: 890}, 0.75, {ease: FlxEase.cubeOut});
					if (badge != null)
					{
						FlxTween.tween(badge, {y: 1320}, 0.75, {ease: FlxEase.cubeOut});
					}
				}
			});

			selectedWeek = true;
		}
	}

	function selectMode()
	{
		if (selectedWeek && !stopspamming)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));

			stopspamming = true;
			txtWeekTitle.text = "Select Difficulty";
			txtWeekTitle.screenCenter(X);

			// Move arrows down to next section
			FlxTween.tween(leftArrow, {x: 640, y: 215}, 0.15, {ease: FlxEase.cubeOut});
			FlxTween.tween(rightArrow, {x: 1035, y: 215}, 0.15, {
				ease: FlxEase.cubeOut,
				onComplete: function(flx:FlxTween)
				{
					stopspamming = false;
				}
			});

			selectedMode = true;
		}
	}

	function selectDifficulty()
	{
		if (selectedMode && !stopspamming)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));

			stopspamming = true;
			txtWeekTitle.text = "Select Character";
			txtWeekTitle.screenCenter(X);

			// Move arrows down to next section
			FlxTween.tween(leftArrow, {x: 700, y: 415}, 0.15, {ease: FlxEase.cubeOut});
			FlxTween.tween(rightArrow, {x: 975, y: 415}, 0.15, {
				ease: FlxEase.cubeOut,
				onComplete: function(flx:FlxTween)
				{
					stopspamming = false;
				}
			});

			selectedDifficulty = true;
		}
	}

	function selectCharacter()
	{
		if (selectedDifficulty && !stopspamming)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));

			stopspamming = true;
			txtWeekTitle.text = "Select Girlfriend";
			txtWeekTitle.screenCenter(X);

			// Move arrows down to next section
			FlxTween.tween(leftArrow, {x: 730, y: 575}, 0.15, {ease: FlxEase.cubeOut});
			FlxTween.tween(rightArrow, {x: 950, y: 575}, 0.15, {
				ease: FlxEase.cubeOut,
				onComplete: function(flx:FlxTween)
				{
					stopspamming = false;
				}
			});

			selectedCharacter = true;
		}
	}

	function selectSettings()
	{
		if (characterUnlocked[curCharacter] && modeUnlocked[curMode] && !stopspamming)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));

			// Make the arrows fade away
			FlxTween.tween(leftArrow, {alpha: 0}, 0.5, {ease: FlxEase.cubeOut});
			FlxTween.tween(rightArrow, {alpha: 0}, 0.5, {ease: FlxEase.cubeOut});

			// Down and up
			FlxTween.tween(txtWeekTitle, {y: 750}, 0.25, {
				ease: FlxEase.cubeOut,
				onComplete: function(flx:FlxTween)
				{
					txtWeekTitle.text = "Ready to Battle?";
					txtWeekTitle.screenCenter(X);
					FlxTween.tween(txtWeekTitle, {y: 675}, 0.25, {
						ease: FlxEase.cubeOut,
						onComplete: function(flx:FlxTween)
						{
							stopspamming = false;
						}
					});
				}
			});

			selectedSettings = true;
		}
	}

	function confirmWeek()
	{
		// (Arcy) Can't play with locked settings
		if (!characterUnlocked[curCharacter] || !modeUnlocked[curMode])
			return;

		FlxG.sound.play(Paths.sound('confirmMenu'));
		stopspamming = true;

		if (curDifficulty < 2)
		{
			PlayState.storyPlaylist = weekData[curWeek];
		}
		else
		{
			PlayState.storyPlaylist = altWeekData[curWeek];
		}
		PlayState.firstTry = true;
		PlayState.isStoryMode = true;
		PlayState.storyMode = curMode;
		PlayState.bfCharacter = bfCharacterNames[curCharacter];
		PlayState.gfCharacter = gfCharacterNames[curGf];

		var diffic = "";

		switch (curDifficulty)
		{
			case 0:
				diffic = '-easy';
			case 2:
				diffic = '-hard';
			case 3:
				diffic = '-hell';
		}

		// Show bf being ready
		bfCharacters.members[curCharacter].animation.play("hey");

		PlayState.storyDifficulty = curDifficulty;

		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
		PlayState.storyWeek = curWeek;
		PlayState.campaignScore = 0;
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			LoadingState.loadAndSwitchState(new PlayState(), true);
		});
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		// Again, don't break things
		stopspamming = true;

		// Make text (actually an image) invisible
		grpWeekTitles.members[curWeek].visible = false;
		grpWeekText.members[curWeek].visible = false;

		// Make current character a silhouette
		FlxTween.color(grpWeekCharacters.members[curWeek], 1, grpWeekCharacters.members[curWeek].color, FlxColor.BLACK, {ease: FlxEase.cubeOut});

		// I wanna throw up
		if (grpWeekBGs.members[curWeek].length > 0)
		{
			for (i in 0...grpWeekBGs.members[curWeek].length)
			{
				FlxTween.tween(grpWeekBGs.members[curWeek].members[i], {alpha: 0}, 0.25);
			}
		}

		var oldWeek:Int = curWeek;

		curWeek += change;

		if (curWeek >= weekData.length)
		{
			curWeek = 0;
		}
		if (curWeek < 0)
		{
			curWeek = weekData.length - 1;
		}

		// Hard coded badge stuff
		if (badge != null)
		{
			if (curWeek == 0)
			{
				badge.visible = true;
			}
			else
			{
				badge.visible = false;
			}
		}

		// And now make new character visible
		FlxTween.color(grpWeekCharacters.members[curWeek], 1, grpWeekCharacters.members[curWeek].color, FlxColor.WHITE, {ease: FlxEase.cubeOut});

		// Make scrolling bg visible
		if (grpWeekBGs.members[curWeek].length > 0)
		{
			for (i in 0...grpWeekBGs.members[curWeek].length)
			{
				FlxTween.tween(grpWeekBGs.members[curWeek].members[i], {alpha: 1}, 0.25);
			}
		}

		// Change background color
		FlxTween.color(bg, 1, bg.color, bgColors[curWeek], {ease: FlxEase.cubeOut});

		/*var bullShit:Int = 0;

			for (item in grpWeekText.members)
			{
				item.targetY = bullShit - curWeek;
				if (item.targetY == Std.int(0) && weekUnlocked[curWeek])
					item.alpha = 1;
				else
					item.alpha = 0.6;
				bullShit++;
		}*/

		FlxG.sound.play(Paths.sound('scrollMenu'));

		// Move characters
		if (change > 0) // Left
		{
			var previous2Weeks:Int = curWeek - 2;
			if (previous2Weeks < 0)
			{
				previous2Weeks = weekData.length + previous2Weeks;
			}
			var previousWeek:Int = curWeek - 1;
			if (previousWeek < 0)
			{
				previousWeek = weekData.length - 1;
			}
			var nextWeek:Int = curWeek + 1;
			if (nextWeek >= weekData.length)
			{
				nextWeek = 0;
			}

			FlxTween.tween(grpWeekCharacters.members[previous2Weeks], {x: -600}, 0.5, {ease: FlxEase.cubeOut});
			FlxTween.tween(grpWeekCharacters.members[previousWeek], {
				x: -25,
				y: -25,
				'scale.x': 0.5,
				'scale.y': 0.5
			}, 0.5, {ease: FlxEase.cubeOut});
			FlxTween.tween(grpWeekCharacters.members[curWeek], {
				x: 425,
				y: -20,
				'scale.x': 0.9,
				'scale.y': 0.9
			}, 0.5, {
				ease: FlxEase.cubeOut,
				onComplete: function(flx:FlxTween)
				{
					stopspamming = false;
				}
			});
			grpWeekCharacters.members[nextWeek].x = 1450;
			FlxTween.tween(grpWeekCharacters.members[nextWeek], {x: 825}, 0.5, {ease: FlxEase.cubeOut});
		}
		else // Right
		{
			var previousWeek:Int = curWeek - 1;
			if (previousWeek < 0)
			{
				previousWeek = weekData.length - 1;
			}
			var nextWeek:Int = curWeek + 1;
			if (nextWeek >= weekData.length)
			{
				nextWeek = 0;
			}
			var next2Weeks:Int = curWeek + 2;
			if (next2Weeks >= weekData.length)
			{
				next2Weeks = next2Weeks - weekData.length;
			}

			grpWeekCharacters.members[previousWeek].x = -600;
			FlxTween.tween(grpWeekCharacters.members[previousWeek], {x: -25}, 0.5, {ease: FlxEase.cubeOut});
			FlxTween.tween(grpWeekCharacters.members[curWeek], {
				x: 425,
				y: -20,
				'scale.x': 0.9,
				'scale.y': 0.9
			}, 0.5, {
				ease: FlxEase.cubeOut,
				onComplete: function(flx:FlxTween)
				{
					stopspamming = false;
				}
			});
			FlxTween.tween(grpWeekCharacters.members[nextWeek], {
				x: 825,
				y: -25,
				'scale.x': 0.5,
				'scale.y': 0.5
			}, 0.5, {ease: FlxEase.cubeOut});
			FlxTween.tween(grpWeekCharacters.members[next2Weeks], {x: 1450}, 0.5, {ease: FlxEase.cubeOut});
		}

		updateTheme(oldWeek);
		updateText();
	}

	function changeMode(change:Int = 0):Void
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));

		curMode += change;

		if (curMode < 0)
		{
			curMode = modeNames.length - 1;
		}
		if (curMode >= modeNames.length)
		{
			curMode = 0;
		}

		switch (curMode)
		{
			case 0:
				sprMode.animation.play('standard');
				sprMode.offset.x = 0;
				sprMode.offset.y = 0;
				sprMode.scale.x = 1;
			case 1:
				sprMode.offset.x = -50;
				sprMode.scale.x = 1;
				if (!modeUnlocked[1])
				{
					sprMode.animation.play('nofaillock');
					sprMode.offset.y = 40;
				}
				else
				{
					sprMode.animation.play('nofail');
					sprMode.offset.y = 0;
				}
			case 2:
				sprMode.offset.x = 17.5;
				sprMode.scale.x = 0.9;
				if (!modeUnlocked[2])
				{
					sprMode.animation.play('freestylelock');
					sprMode.offset.y = 45;
				}
				else
				{
					sprMode.animation.play('freestyle');
					sprMode.offset.y = 0;
				}
			case 3:
				sprMode.offset.x = 20;
				sprMode.scale.x = 0.8;
				if (!modeUnlocked[3])
				{
					sprMode.animation.play('randomizedlock');
					sprMode.offset.y = 45;
				}
				else
				{
					sprMode.animation.play('randomized');
					sprMode.offset.y = 0;
				}
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));

		curDifficulty += change;

		if (curDifficulty < 0)
		{
			curDifficulty = 3;
		}
		if (curDifficulty > 3)
		{
			curDifficulty = 0;
		}

		sprDifficulty.offset.x = 0;

		switch (curDifficulty)
		{
			case 0:
				sprDifficulty.animation.play('easy');
				sprDifficulty.offset.x = 20;
			case 1:
				sprDifficulty.animation.play('normal');
				sprDifficulty.offset.x = 70;
			case 2:
				sprDifficulty.animation.play('hard');
				sprDifficulty.offset.x = 20;
			case 3:
				sprDifficulty.animation.play('hell');
				sprDifficulty.offset.x = 20;
		}

		// (tsg - 6/7/21) TODO: see if its possible to get bf anim from here, and allow the shiver anim to play when hell is selected.
		// trace(bfCharacter.animation.curAnim);

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		// sprDifficulty.y = leftArrow.y - 15;
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end

		FlxTween.tween(sprDifficulty, {alpha: 1}, 0.07);
	}

	function changeCharacter(change:Int = 0):Void
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));

		bfCharacters.members[curCharacter].visible = false;
		var oldPos = bfCharacters.members[curCharacter].x;

		curCharacter += change;

		// Wrapping selection
		if (curCharacter < 0)
		{
			curCharacter = characterUnlocked.length - 1;
		}
		if (curCharacter >= characterUnlocked.length)
		{
			curCharacter = 0;
		}

		// Third time's a charm?
		bfCharacters.members[curCharacter].x = oldPos;
		bfCharacters.members[curCharacter].visible = true;
		// bfCharacter.changeMenuCharacter(bfCharacterNames[curCharacter]);
		// bfCharacter.setCharacter(bfCharacterNames[curCharacter]);

		// Show silhouette if locked
		if (characterUnlocked[curCharacter])
		{
			bfCharacters.members[curCharacter].color = FlxColor.WHITE;
		}
		else
		{
			bfCharacters.members[curCharacter].color = FlxColor.BLACK;
		}
	}

	function changeGirlfriend(change:Int = 0):Void
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));

		gfIcons.members[curGf].visible = false;
		var oldPos = gfIcons.members[curGf].x;

		curGf += change;

		// Wrapping selection
		if (curGf < 0)
		{
			curGf = gfIcons.length - 1;
		}
		if (curGf >= gfIcons.length)
		{
			curGf = 0;
		}

		// Third time's a charm?
		gfIcons.members[curGf].x = oldPos;
		gfIcons.members[curGf].visible = true;
		// bfCharacter.changeMenuCharacter(bfCharacterNames[curCharacter]);
		// bfCharacter.setCharacter(bfCharacterNames[curCharacter]);

		// Show silhouette if locked
		// Don't need too ayy
		/*if (characterUnlocked[curCharacter])
		{
			bfCharacters.members[curCharacter].color = FlxColor.WHITE;
		}
		else
		{
			bfCharacters.members[curCharacter].color = FlxColor.BLACK;
		}*/
	}

	function updateTheme(lastWeek:Int)
	{
		if (TitleState.introMusic != null && TitleState.introMusic.playing)
		{
			// Play the week's associated intro
			var songTime = TitleState.introMusic.time;
			TitleState.introMusic.loadEmbedded(Paths.music(introThemes[curWeek]));
			TitleState.introMusic.play(false, songTime);
			TitleState.introMusic.onComplete = null;
			TitleState.introMusic.onComplete = function()
			{
				MainMenuState.songName = weekThemes[curWeek];
				FlxG.sound.music.loadEmbedded(Paths.music(weekThemes[curWeek]));
				FlxG.sound.music.volume = TitleState.introMusic.volume; // Shit workaround I guess
				FlxG.sound.music.play(true);
				TitleState.introMusic.destroy();
				TitleState.introMusic = null;
			}
			TitleState.introMusic.volume = 0.75;
		}
		else
		{
			// Play the week's associated theme
			MainMenuState.songName = weekThemes[curWeek];
			weekSongs.members[curWeek].play(false, weekSongs.members[lastWeek].time % weekSongs.members[curWeek].length);
			weekSongs.members[curWeek].fadeIn(0.25, 0, 0.75);
			weekSongs.members[lastWeek].fadeOut(0.25, 0);
		}
	}

	function updateText()
	{
		grpWeekTitles.members[curWeek].visible = true;
		grpWeekText.members[curWeek].visible = true;

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end
	}

	/**
	 * Function used to move everything back to the main state of the story menu.
	 */
	function cancelStorySettings()
	{
		FlxG.sound.play(Paths.sound('cancelMenu'));
		selectedWeek = false;
		selectedMode = false;
		selectedDifficulty = false;

		// Don't break shit >:(
		stopspamming = true;

		var previousWeek:Int = curWeek - 1;
		if (previousWeek < 0)
		{
			previousWeek = weekData.length - 1;
		}
		var nextWeek:Int = curWeek + 1;
		if (nextWeek >= weekData.length)
		{
			nextWeek = 0;
		}

		// Move description text off
		FlxTween.tween(txtWeekTitle, {y: 750}, 0.5, {
			ease: FlxEase.cubeOut,
			onComplete: function(flx:FlxTween)
			{
				// Move the black rect cover back up, along with the elements on it
				FlxTween.tween(grpWeekCharacters.members[curWeek], {x: 425}, 0.5, {ease: FlxEase.cubeOut});
				FlxTween.tween(blackCover, {y: 400}, 0.75, {
					ease: FlxEase.cubeOut,
					onComplete: function(flx:FlxTween)
					{
						// Move vs character back and other characters on-screen
						FlxTween.tween(grpWeekCharacters.members[previousWeek], {x: -25}, 0.5, {ease: FlxEase.cubeOut});
						FlxTween.tween(grpWeekCharacters.members[nextWeek], {x: 825}, 0.5, {ease: FlxEase.cubeOut});

						// And bring the arrows back
						leftArrow.alpha = 0;
						rightArrow.alpha = 0;
						leftArrow.x = 300;
						leftArrow.y = 200;
						rightArrow.x = 825;
						rightArrow.y = 200;

						FlxTween.tween(leftArrow, {alpha: 1}, 0.5, {ease: FlxEase.cubeOut});
						FlxTween.tween(rightArrow, {alpha: 1}, 0.5, {
							ease: FlxEase.cubeOut,
							onComplete: function(flx:FlxTween)
							{
								stopspamming = false;
							}
						});
					}
				});
				FlxTween.tween(grpWeekTitles.members[curWeek], {y: 400}, 0.75, {ease: FlxEase.cubeOut});
				FlxTween.tween(grpWeekText.members[curWeek], {y: 215}, 0.75, {ease: FlxEase.cubeOut});
				if (badge != null)
				{
					FlxTween.tween(badge, {y: 575}, 0.75, {ease: FlxEase.cubeOut});
				}
			}
		});

		// Move score text off
		FlxTween.tween(scoreText, {y: 750}, 0.5, {ease: FlxEase.cubeOut});
		FlxTween.tween(controlsConfirmText, {y: 740}, 0.5, {ease: FlxEase.cubeOut});
		FlxTween.tween(controlsBackText, {y: 760}, 0.5, {ease: FlxEase.cubeOut});

		// Move the difficulty and bf back off-screen
		if (girlfriendUnlocked[1])
		{
			FlxTween.tween(gfIcons.members[curGf], {x: 1585}, 0.5, {ease: FlxEase.cubeOut});
		}
		FlxTween.tween(bfCharacters.members[curCharacter], {x: 1450}, 0.5, {ease: FlxEase.cubeOut});
		FlxTween.tween(sprDifficulty, {x: 1575}, 0.5, {ease: FlxEase.cubeOut});
		FlxTween.tween(sprMode, {x: 1450}, 0.5, {ease: FlxEase.cubeOut});
		FlxTween.tween(leftArrow, {x: 1325}, 0.5, {ease: FlxEase.cubeOut});
		FlxTween.tween(rightArrow, {x: 1850}, 0.5, {ease: FlxEase.cubeOut});
	}

	/**
	 * Goes through the justUnlocked array and displays all of it in a little neat UI.
	 */
	function displayUnlocks()
	{
		unlocking = true;

		// Nothing left to unlock
		if (unlockedSongs.length == 0 && unlockedModes.length == 0 && unlockedChars.length == 0)
		{
			FlxTween.tween(fadeBG, {alpha: 0}, 0.5);
			for (i in 0...unlockSprites.length)
			{
				FlxTween.tween(unlockSprites.members[i], {alpha: 0}, 0.5);
			}
			FlxTween.tween(unlockDescription, {alpha: 0}, 0.5, {
				onComplete: function(flx:FlxTween)
				{
					fadeBG.visible = false;
					unlockSprites.visible = false;
					unlockDescription.visible = false;

					unlocking = false;
					stopspamming = false;
				}
			});
			return;
		}

		if (unlockedSongs.length > 0)
		{
			for (i in 0...unlockedSongs.length)
			{
				var unlockSprite = new Alphabet(0, 0, unlockedSongs[i], true, false, true);
				unlockSprite.screenCenter();
				if (unlockedSongs.length % 2 == 1)
				{
					unlockSprite.y += (i - (unlockedSongs.length - 1) / 2) * 100;
				}
				else
				{
					unlockSprite.y += 50 + ((i - (unlockedSongs.length / 2)) * 100);
				}
				unlockSprite.alpha = 0;
				unlockSprites.add(unlockSprite);

				if (unlockSprite.alpha == 0)
				{
					FlxTween.tween(unlockSprite, {alpha: 1}, 0.5);
				}
			}

			if (uniqueUnlockText != null)
			{
				unlockDescription.text = uniqueUnlockText;
			}
			else
			{
				unlockDescription.text = "New song" + (unlockedSongs.length == 1 ? '' : 's') + " unlocked in Freeplay!";
			}
			unlockDescription.screenCenter(X);

			if (unlockDescription.alpha == 0)
			{
				FlxTween.tween(unlockDescription, {alpha: 1}, 0.5);
			}

			fadeBG.visible = true;
			unlockDescription.visible = true;
			unlockSprites.visible = true;
			stopspamming = false;
			return;
		}
		else if (unlockedModes.length > 0)
		{
			for (i in 0...unlockedModes.length)
			{
				var unlockSprite = new FlxSprite();
				switch(unlockedModes[i])
				{
					// Modes
					case 'nofail':
						var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
						unlockSprite.frames = ui_tex;
						unlockSprite.animation.addByPrefix('nofail', 'NO FAIL');
						unlockSprite.animation.play('nofail');
						unlockSprite.offset.x = 75;
					case 'freestyle':
						var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
						unlockSprite = new FlxSprite(0, 0);
						unlockSprite.frames = ui_tex;
						unlockSprite.animation.addByPrefix('freestyle', 'FREESTYLE');
						unlockSprite.animation.play('freestyle');
						unlockSprite.offset.x = 150;
					case 'randomized':
						var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
						unlockSprite = new FlxSprite(0, 0);
						unlockSprite.frames = ui_tex;
						unlockSprite.animation.addByPrefix('randomized', 'RANDOMIZED');
						unlockSprite.animation.play('randomized');
						unlockSprite.offset.x = 175;
				}

				unlockSprite.screenCenter();
				unlockSprite.alpha = 0;
				if (unlockedModes.length % 2 == 1)
				{
					unlockSprite.y += (i - (unlockedModes.length - 1) / 2) * 150;
				}
				else
				{
					unlockSprite.y += 75 + ((i - (unlockedModes.length / 2)) * 150);
				}
				unlockSprites.add(unlockSprite);

				if (unlockSprite.alpha == 0)
				{
					FlxTween.tween(unlockSprite, {alpha: 1}, 0.5);
				}
			}

			unlockDescription.text = "New mode" + (unlockedModes.length == 1 ? '' : 's') + " unlocked!";
			unlockDescription.screenCenter(X);

			if (unlockDescription.alpha == 0)
			{
				FlxTween.tween(unlockDescription, {alpha: 1}, 0.5);
			}

			fadeBG.visible = true;
			unlockDescription.visible = true;
			unlockSprites.visible = true;
			stopspamming = false;
			return;
		}
		else
		{
			for (i in 0...unlockedChars.length)
			{
				var unlockSprite = new FlxSprite();
				switch(unlockedChars[i])
				{
					// Characters
					case 'bf-retro':
						unlockSprite = new Character(0, 0, 'bf-retro', true);
						unlockSprite.scale.set(0.5, 0.5);
						var tex = Paths.getSparrowAtlas('characters/RetroBF', 'shared');
						unlockSprite.frames = tex;
						unlockSprite.animation.addByPrefix('idle', 'BF idle dance', 24, true); // Make it looped
						unlockSprite.animation.play('idle');
					case 'bf-ace':
						unlockSprite = new Character(0, 0, 'bf-ace', true);
						var tex = Paths.getSparrowAtlas('characters/AceBF', 'shared');
						unlockSprite.scale.set(0.5, 0.5);
						unlockSprite.frames = tex;
						unlockSprite.animation.addByPrefix('idle', 'BF idle dance', 24, true); // Make it looped
						unlockSprite.animation.play('idle');
				}

				unlockSprite.screenCenter();
				unlockSprite.alpha = 0;
				if (unlockedChars.length % 2 == 1)
				{
					unlockSprite.x += (i - (unlockedChars.length - 1) / 2) * 350;
				}
				else
				{
					unlockSprite.x += 175 + ((i - (unlockedChars.length / 2)) * 350);
				}
				unlockSprites.add(unlockSprite);

				if (unlockSprite.alpha == 0)
				{
					FlxTween.tween(unlockSprite, {alpha: 1}, 0.5);
				}
			}

			unlockDescription.text = "New character" + (unlockedChars.length == 1 ? '' : 's') + " unlocked!";
			unlockDescription.screenCenter(X);

			if (unlockDescription.alpha == 0)
			{
				FlxTween.tween(unlockDescription, {alpha: 1}, 0.5);
			}

			fadeBG.visible = true;
			unlockDescription.visible = true;
			unlockSprites.visible = true;
			stopspamming = false;
			return;
		}
	}

	/**
	 * Deciphers the last pressed keys to see if a secret code was typed out.
	 */
	function checkCodeInput()
	{
		if (FlxG.keys.justPressed.ANY && !FreeplayState.songUnlocked[4])
		{
			if (FlxG.keys.justPressed.A)
			{
				charInputs += 'A';
			}
			else if (FlxG.keys.justPressed.B)
			{
				charInputs += 'B';
			}
			else if (FlxG.keys.justPressed.C)
			{
				charInputs += 'C';
			}
			else if (FlxG.keys.justPressed.D)
			{
				charInputs += 'D';
			}
			else if (FlxG.keys.justPressed.E)
			{
				charInputs += 'E';
			}
			else if (FlxG.keys.justPressed.F)
			{
				charInputs += 'F';
			}
			else if (FlxG.keys.justPressed.G)
			{
				charInputs += 'G';
			}
			else if (FlxG.keys.justPressed.H)
			{
				charInputs += 'H';
			}
			else if (FlxG.keys.justPressed.I)
			{
				charInputs += 'I';
			}
			else if (FlxG.keys.justPressed.J)
			{
				charInputs += 'J';
			}
			else if (FlxG.keys.justPressed.K)
			{
				charInputs += 'K';
			}
			else if (FlxG.keys.justPressed.L)
			{
				charInputs += 'L';
			}
			else if (FlxG.keys.justPressed.M)
			{
				charInputs += 'M';
			}
			else if (FlxG.keys.justPressed.N)
			{
				charInputs += 'N';
			}
			else if (FlxG.keys.justPressed.O)
			{
				charInputs += 'O';
			}
			else if (FlxG.keys.justPressed.P)
			{
				charInputs += 'P';
			}
			else if (FlxG.keys.justPressed.Q)
			{
				charInputs += 'Q';
			}
			else if (FlxG.keys.justPressed.R)
			{
				charInputs += 'R';
			}
			else if (FlxG.keys.justPressed.S)
			{
				charInputs += 'S';
			}
			else if (FlxG.keys.justPressed.T)
			{
				charInputs += 'T';
			}
			else if (FlxG.keys.justPressed.U)
			{
				charInputs += 'U';
			}
			else if (FlxG.keys.justPressed.V)
			{
				charInputs += 'V';
			}
			else if (FlxG.keys.justPressed.W)
			{
				charInputs += 'W';
			}
			else if (FlxG.keys.justPressed.X)
			{
				charInputs += 'X';
			}
			else if (FlxG.keys.justPressed.Y)
			{
				charInputs += 'Y';
			}
			else if (FlxG.keys.justPressed.Z)
			{
				charInputs += 'Z';
			}
			else if (FlxG.keys.justPressed.ZERO)
			{
				charInputs += '0';
			}
			else if (FlxG.keys.justPressed.ONE)
			{
				charInputs += '1';
			}
			else if (FlxG.keys.justPressed.TWO)
			{
				charInputs += '2';
			}
			else if (FlxG.keys.justPressed.THREE)
			{
				charInputs += '3';
			}
			else if (FlxG.keys.justPressed.FOUR)
			{
				charInputs += '4';
			}
			else if (FlxG.keys.justPressed.FIVE)
			{
				charInputs += '5';
			}
			else if (FlxG.keys.justPressed.SIX)
			{
				charInputs += '6';
			}
			else if (FlxG.keys.justPressed.SEVEN)
			{
				charInputs += '7';
			}
			else if (FlxG.keys.justPressed.EIGHT)
			{
				charInputs += '8';
			}
			else if (FlxG.keys.justPressed.NINE)
			{
				charInputs += '9';
			}

			if (cheatCode1.startsWith(charInputs) || cheatCode2.startsWith(charInputs))
			{
				if (charInputs == cheatCode1)
				{
					uniqueUnlockText = "You've unlocked the secret song in Freeplay. Good job cheater!";
					FlxTween.tween(fadeBG, {alpha: 0.9}, 0.5);

					FreeplayState.songUnlocked[4] = true;
					FlxG.save.data.songUnlocked = FreeplayState.songUnlocked;
					FlxG.save.flush();

					unlockedSongs.push("Fuzzy Feeling");
					displayUnlocks();
				}
				//else if (charInputs.endsWith('K'))
				else if (charInputs == cheatCode2)
				{
					uniqueUnlockText = "You could've just typed 'mommymothymilkies' instead.";
					FlxTween.tween(fadeBG, {alpha: 0.9}, 0.5);

					FreeplayState.songUnlocked[4] = true;
					FlxG.save.data.songUnlocked = FreeplayState.songUnlocked;
					FlxG.save.flush();

					unlockedSongs.push("Fuzzy Feeling");
					displayUnlocks();
				}
			}
			else
			{
				if (charInputs.length >= 5)
					FlxG.sound.play(Paths.sound('RON', 'shared'));

				charInputs = '';
			}
		}
	}
}
