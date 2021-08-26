package;


import ChromaticAberrationShader;
import Note.NoteType;
import Replay.Ana;
import Replay.Analysis;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.text.FlxTypeText;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.events.KeyboardEvent;
import openfl.media.Sound;
import openfl.ui.Keyboard;

using StringTools;
#if sys
import smTools.SMFile;
import sys.io.File;
#end
#if cpp
//import webm.WebmPlayer;
#end
#if windows
import Discord.DiscordClient;
#end
#if windows
import sys.FileSystem;
#end


class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	/*
	 * Mode that modifies how the gameplay is for the current week.
	 *
	 * @param	0				Base game mode. Nothing special added.
	 * @param	1				No fail mode. Player cannot die.
	 * @param	2				Freestyle mode. Any note direction is legal on beat.
	 * @param	3				Randomized mode. Note directions are randomly generated on beat.
	 */
	public static var storyMode:Int = 0;

	/*
	 * The name for the character to replace bf. Used for the character selection in the Story Menu.
	 */
	public static var bfCharacter:String = 'bf';
	public static var gfCharacter:String = 'gf';

	public static var songPosBG:FlxSprite;
	public static var songPosBar:FlxBar;

	public static var rep:Replay;
	public static var loadRep:Bool = false;
	public static var inResults:Bool = false;

	var songLength:Float = 0;
	var kadeEngineWatermark:FlxText;

	#if windows
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	private var vocals:FlxSound;

	public static var isSM:Bool = false;
	#if sys
	public static var sm:SMFile;
	public static var pathToSm:String;
	#end

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	public var notes:FlxTypedGroup<Note>;

	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public static var strumLineNotes:FlxTypedGroup<FlxSprite> = null;
	public static var playerStrums:FlxTypedGroup<FlxSprite> = null;
	public static var cpuStrums:FlxTypedGroup<FlxSprite> = null;

	private var camZooming:Bool = true;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;

	public var health:Float = 1; // making public because sethealth doesnt work without it

	private var combo:Int = 0;

	public static var misses:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var campaignSicks:Int = 0;
	public static var campaignGoods:Int = 0;
	public static var campaignBads:Int = 0;
	public static var campaignShits:Int = 0;

	public var accuracy:Float = 0.00;

	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var healthBarOrigin:FlxPoint;
	private var songPositionBar:Float = 0;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var iconP1:HealthIcon; // making these public again because i may be stupid
	public var iconP2:HealthIcon; // what could go wrong?
	public var camHUD:FlxCamera;
	public var camSustains:FlxCamera;
	public var camNotes:FlxCamera;

	private var camGame:FlxCamera;
	public var cannotDie = false;

	var notesHitArray:Array<Date> = [];
	var idleToBeat:Bool = true; // change if bf and dad would idle to the beat of the song
	var idleBeat:Int = 4; // how frequently bf and dad would play their idle animation(1 - every beat, 2 - every 2 beats and so on)

	// (tsg - 7/24/21) small things lyric system port
	// (Arcy - 8/3/21) Redoing this because we don't need lyrics for multiple songs
	var enoughTxt:FlxText;
	var enoughTxtOrigin:FlxPoint;

	// (tsg - 7/24/21) - small things lyric system port
	#if debug
	var conductorPosTxt:FlxText;
	#end

	var poisonSound:FlxSound;
	var spectreSound:FlxSound;
	var sakuLaugh:FlxSound;
	var sakuNote:FlxSound;
	var bfBeepWake:FlxSound;
	var wrathIntroSnap:FlxSound;

	var songName:FlxText;

	var talking:Bool = true;

	public var songScore:Int = 0;

	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;
	var replayTxt:FlxText;

	// Special effects
	var spriteTrail:FlxTypedGroup<FlxSprite>;
	var windowOrigin:FlxPoint;
	var chrom:ChromaticAberrationShader;

	// Retro-specific variables
	// Poison health drain mechanic
	var healthDrainPoison:Float = 0.025;
	var poisonStacks:Int = 0;

	var poisonIcon:FlxSprite;
	var poisonTxt:FlxText;
	var poisonNoteHits:Array<FlxTypedGroup<FlxSprite>> = [null, null, null, null];

	// Spectre note mechanic
	var noteFadeTime:Float = 0.025;
	var noteOpacity:Float = 0.5;
	var spectreHit:Bool = false;
	var enemySpectreHit:Bool = false;

	var spectreNoteHits:Array<FlxTypedGroup<FlxSprite>> = [null, null, null, null];
	var enemySpectreNoteHit:FlxSprite;

	// Cutscene stuff
	var cutsceneSprite:Character;
	var endCutsceneSprites:FlxTypedGroup<FlxSprite>;
	var endCutsceneAnimation:CompoundSprite;
	var characterLogo:FlxSprite;
	var ending:Bool = false;

	// (tsg - 6/26/21) this is a variable specifically so we can access it later
	var sakuBop:FlxSprite;
	var vortex:FlxSprite;
	var bgFlash:FlxSprite;
	var flames:FlxSprite;
	var flameChange:FlxSprite;
	var groundGreen:FlxSprite;
	var rocks:FlxSprite;
	var rocksGreen:FlxSprite;
	var gem1Green:FlxSprite;
	var gem2Green:FlxSprite;
	var crack:FlxSprite; // Crack object used to set when animations play
	var crystals:FlxTypedGroup<FlxSprite>; // Stores a list of crystal objects to modify
	var cave:FlxSprite; // Round rock thingy on the right side for runes animation
	var cave2:FlxSprite; // Round rock thingy on the left side for runes animation

	// Data used for initial positioning and resetting after moving effects
	public var crystalPos:Array<FlxPoint> = [
		new FlxPoint(1600, 200),
		new FlxPoint(1200, -100),
		new FlxPoint(1400, -500),
		new FlxPoint(800, -150),
		new FlxPoint(-900, 0),
		new FlxPoint(550, -200),
		new FlxPoint(-300, -300),
		new FlxPoint(100, -200)
	];
	// X travel speed during fancy Spectral effect
	// Y Offset on the sin wave to make each crystal float at different patterns
	public var crystalFloatData:Array<FlxPoint> = [
		new FlxPoint(1500, 1),
		new FlxPoint(2000, 0),
		new FlxPoint(1000, 2),
		new FlxPoint(2500, 1.5),
		new FlxPoint(3000, 4),
		new FlxPoint(1000, 3),
		new FlxPoint(2500, 6),
		new FlxPoint(2000, 2.5)
	];

	var particles:FlxTypedGroup<FlxEmitter>; // Particle emitters for fire sparks. Changes to hearts if Saku Note is hit
	var spectralBGEmitter:FlxEmitter; // Particle emitter for the lines in the moving effect
	var spectralDarkScreen:FlxSprite; // Screen of a black box to make the background darker

	// Cutscene variables
	public static var firstTry:Bool = true; // Used to skip cutscenes/dialogue when retrying in story mode
	var transforming:Bool = false;
	var slammed:Bool = false;
	var roared:Bool = false;
	var debris:Int = 0;
	var onFire:Bool = false;
	var exploded:Bool = false;
	var shakeIntensity:Float = 0.01;

	// Spectral death dialogue
	public static var deaths:Int = 0;
	public static var shownHint:Bool = false;
	public static var speechBubble:FlxSprite;
	public static var retroPortrait:FlxSprite;
	public static var hintText:FlxTypeText;
	public static var hintDropText:FlxText;
	public static var trueEctospasm:Bool = false; // Used to take account of the bonus chart for Ectospasm

	var sakuUnlocked:Bool = false;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	var inCutscene:Bool = false;
	var usedTimeTravel:Bool = false;

	// Per song additive offset
	public static var songOffset:Float = 0;

	// BotPlay text
	private var botPlayState:FlxText;
	// Replay shit
	private var saveNotes:Array<Dynamic> = [];
	private var saveJudge:Array<String> = [];
	private var replayAna:Analysis = new Analysis(); // replay analysis

	public static var highestCombo:Int = 0;

	private var executeModchart = false;

	// Animation common suffixes
	private var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	//private var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];

	public static var startTime = 0.0;
	var missTime = 0.0; // Track time past last miss for setting voices volume on Optimized

	// API stuff

	public function addObject(object:FlxBasic)
	{
		add(object);
	}

	public function removeObject(object:FlxBasic)
	{
		remove(object);
	}

	override public function create()
	{
		FlxG.mouse.visible = false;
		instance = this;

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(800);

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
		}

		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;

		misses = 0;

		highestCombo = 0;
		inResults = false;

		PlayStateChangeables.useDownscroll = FlxG.save.data.downscroll;
		PlayStateChangeables.safeFrames = FlxG.save.data.frames;
		PlayStateChangeables.scrollSpeed = FlxG.save.data.scrollSpeed;
		PlayStateChangeables.botPlay = FlxG.save.data.botplay;
		PlayStateChangeables.Optimize = FlxG.save.data.optimize;
		PlayStateChangeables.zoom = FlxG.save.data.zoom;

		#if windows
		if (SONG.song == 'True Ectospasm')
		{
			executeModchart = FileSystem.exists(Paths.lua("ectospasm/modchart-truehell"));
		}
		else
		{
			// pre lowercasing the song name (create)
			var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
			executeModchart = FileSystem.exists(Paths.lua(songLowercase + "/modchart"));
			if (isSM)
				executeModchart = FileSystem.exists(pathToSm + "/modchart.lua");
		}

		if (executeModchart && (!FlxG.save.data.modChart || PlayStateChangeables.Optimize))
		{
			executeModchart = false;
		}
		//if (executeModchart)
			//PlayStateChangeables.Optimize = false;
		#end
		#if !cpp
		executeModchart = false; // FORCE disable for non cpp targets
		#end

		// (Arcy) Workaround for using a special modchart for True Ectospasm
		if (SONG.song == 'True Ectospasm')
		{
			SONG.song = 'Ectospasm';
			trueEctospasm = true;
		}
		else
			trueEctospasm = false;

		#if windows
		// Making difficulty text for Discord Rich Presence.
		storyDifficultyText = CoolUtil.difficultyFromInt(storyDifficulty);

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Vs. Retrospecter";
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camSustains = new FlxCamera();
		camSustains.bgColor.alpha = 0;
		camNotes = new FlxCamera();
		camNotes.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camSustains);
		FlxG.cameras.add(camNotes);

		camHUD.zoom = PlayStateChangeables.zoom;

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		//if (SONG == null)
		//	SONG = Song.loadFromJson('tutorial', 'tutorial');

		// Set bf character
		SONG.player1 = bfCharacter;
		// and special gf character
		if (gfCharacter == 'sakuroma')
		{
			SONG.gfVersion = 'gf-saku';
		}

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		if (SONG.eventObjects == null)
		{
			SONG.eventObjects = [new Song.Event("Init BPM",0,SONG.bpm,"BPM Change")];
		}


		TimingStruct.clearTimings();

		var convertedStuff:Array<Song.Event> = [];

		var currentIndex = 0;
		for (i in SONG.eventObjects)
		{
			var name = Reflect.field(i,"name");
			var type = Reflect.field(i,"type");
			var pos = Reflect.field(i,"position");
			var value = Reflect.field(i,"value");

			if (type == "BPM Change")
			{
                var beat:Float = pos;

                var endBeat:Float = Math.POSITIVE_INFINITY;

                TimingStruct.addTiming(beat,value,endBeat, 0); // offset in this case = start time since we don't have a offset

                if (currentIndex != 0)
                {
                    var data = TimingStruct.AllTimings[currentIndex - 1];
                    data.endBeat = beat;
                    data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
					TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
                }

				currentIndex++;
			}
			convertedStuff.push(new Song.Event(name,pos,value,type));
		}

		SONG.eventObjects = convertedStuff;

		// defaults if no stage was found in chart
		var stageCheck:String = 'stage';

		if (SONG.stage != null)
		{
			stageCheck = SONG.stage;
		}

		if (!PlayStateChangeables.Optimize)
		{
			switch (stageCheck)
			{
				case 'wrath':
				{
					defaultCamZoom = 0.9;
					curStage = 'wrath';

					if (SONG.song == 'Spectral' || SONG.song == 'Ectospasm')
					{
						// Load poison sound for Spectral and Ectospasm
						poisonSound = new FlxSound().loadEmbedded(Paths.sound('acid', 'shared'));
						FlxG.sound.list.add(poisonSound);

						if (SONG.song == 'Ectospasm')
						{
							// Load spectre hit sound for Ectospasm
							spectreSound = new FlxSound().loadEmbedded(Paths.sound('SpectreArrow', 'shared'));
							FlxG.sound.list.add(spectreSound);

							// Load secret Saku laugh sound for Ectospasm
							sakuLaugh = new FlxSound().loadEmbedded(Paths.sound('sakulaff', 'shared'));
							sakuNote = new FlxSound().loadEmbedded(Paths.sound('sakuNote', 'shared'));
							FlxG.sound.list.add(sakuLaugh);
							FlxG.sound.list.add(sakuNote);
						}
					}

					if (FlxG.save.data.background > 0)
					{
						var wrathBgScale:Float = .72;
						var wrathXAdjust:Float = 0;
						var wrathYAdjust:Float = -128;

						// wrath_sky
						var sky:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('wrath_sky', 'wrath'));
						sky.antialiasing = FlxG.save.data.antialiasing;
						sky.screenCenter();
						//sky.scale.x = 0.85;
						//sky.scale.y = 0.85;
						sky.scrollFactor.set(0.5, 0.5);
						sky.active = false;
						sky.x += wrathXAdjust;
						sky.y += wrathYAdjust + 250;
						add(sky);

						if (FlxG.save.data.background > 1 && (SONG.song == 'Spectral' || SONG.song == 'Ectospasm'))
						{
							// wrath_vortex
							vortex = new FlxSprite(0, 0);
							if (FlxG.save.data.cacheImages)
							{
								vortex.frames = FileCache.instance.fromSparrow('wrath_vortex', 'Vortex');
							}
							else
							{
								vortex.frames = Paths.getSparrowAtlas('Vortex','wrath');
							}
							vortex.antialiasing = FlxG.save.data.antialiasing;
							vortex.animation.addByPrefix('speeen', 'Vortex', 24);
							vortex.scrollFactor.set(0.5, 0.5);
							//vortex.scale.set(0.5, 0.5);
							vortex.x -= 100;
							vortex.y -= 750;
							if (isStoryMode && firstTry)
								vortex.alpha = 0.0000000001;
							vortex.animation.play('speeen');
							add(vortex);
						}

						// wrath_gates
						var gates:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('wrath_gates', 'wrath'));
						gates.antialiasing = FlxG.save.data.antialiasing;
						gates.screenCenter();
						//gates.scale.x = 0.85;
						//gates.scale.y = 0.85;
						gates.scrollFactor.set(0.55, 0.55);
						gates.active = false;
						gates.x += wrathXAdjust;
						gates.y += wrathYAdjust - 150;
						add(gates);

						// wrath_backrocks
						var backrocks:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('wrath_backrocks', 'wrath'));
						backrocks.antialiasing = FlxG.save.data.antialiasing;
						backrocks.screenCenter();
						//backrocks.scale.x = wrathBgScale;
						//backrocks.scale.y = wrathBgScale;
						backrocks.scrollFactor.set(0.6, 0.6);
						backrocks.active = false;
						backrocks.x += wrathXAdjust;
						backrocks.y += wrathYAdjust;
						add(backrocks);

						// wrath_gems
						var gem1:FlxSprite = new FlxSprite(0, 0);
						if (FlxG.save.data.cacheImages)
						{
							gem1.frames = FileCache.instance.fromSparrow('wrath_gem1', 'gem1');
						}
						else
						{
							gem1.frames = Paths.getSparrowAtlas('gem1','wrath');
						}
						gem1.animation.addByPrefix('green', 'green', 0, false);
						gem1.antialiasing = FlxG.save.data.antialiasing;
						gem1.screenCenter();
						//gem1.scale.x = wrathBgScale;
						//gem1.scale.y = wrathBgScale;
						gem1.scrollFactor.set(0.6, 0.6);
						gem1.active = false;
						gem1.x += wrathXAdjust + 200; // gem adjustment
						gem1.y += wrathYAdjust + 150; // more gem adjustment
						gem1.animation.play('green');
						add(gem1);

						if (FlxG.save.data.flashing && (SONG.song == 'Spectral' || SONG.song == 'Ectospasm'))
						{
							gem1Green = new FlxSprite(0, 0);
							if (FlxG.save.data.cacheImages)
							{
								gem1Green.frames = FileCache.instance.fromSparrow('wrath_gem1', 'gem1');
							}
							else
							{
								gem1Green.frames = Paths.getSparrowAtlas('gem1','wrath');
							}
							gem1Green.animation.addByPrefix('cyan', 'cyan', 0, false);
							gem1Green.antialiasing = FlxG.save.data.antialiasing;
							gem1Green.screenCenter();
							//gem1Green.scale.x = wrathBgScale;
							//gem1Green.scale.y = wrathBgScale;
							gem1Green.scrollFactor.set(0.6, 0.6);
							gem1Green.active = false;
							gem1Green.x += wrathXAdjust + 200; // gem adjustment
							gem1Green.y += wrathYAdjust + 150; // more gem adjustment
							gem1Green.alpha = 0;
							gem1Green.animation.play('cyan');
							add(gem1Green);
						}

						var gem2:FlxSprite = new FlxSprite(0, 0);
						if (FlxG.save.data.cacheImages)
						{
							gem2.frames = FileCache.instance.fromSparrow('wrath_gem2', 'gem2');
						}
						else
						{
							gem2.frames = Paths.getSparrowAtlas('gem2','wrath');
						}
						gem2.animation.addByPrefix('green', 'green', 0, false);
						gem2.antialiasing = FlxG.save.data.antialiasing;
						gem2.screenCenter();
						//gem2.scale.x = wrathBgScale;
						//gem2.scale.y = wrathBgScale;
						gem2.scrollFactor.set(0.7, 0.7);
						gem2.active = false;
						gem2.x += wrathXAdjust + 200; // gem adjustment
						gem2.y += wrathYAdjust + 150; // more gem adjustment
						gem2.animation.play('green');
						add(gem2);

						if (FlxG.save.data.flashing && (SONG.song == 'Spectral' || SONG.song == 'Ectospasm'))
						{
							gem2Green = new FlxSprite(0, 0);
							if (FlxG.save.data.cacheImages)
							{
								gem2Green.frames = FileCache.instance.fromSparrow('wrath_gem2', 'gem2');
							}
							else
							{
								gem2Green.frames = Paths.getSparrowAtlas('gem2','wrath');
							}
							gem2Green.animation.addByPrefix('cyan', 'cyan', 0, false);
							gem2Green.antialiasing = FlxG.save.data.antialiasing;
							gem2Green.screenCenter();
							//gem2Green.scale.x = wrathBgScale;
							//gem2Green.scale.y = wrathBgScale;
							gem2Green.scrollFactor.set(0.7, 0.7);
							gem2Green.active = false;
							gem2Green.x += wrathXAdjust + 200; // gem adjustment
							gem2Green.y += wrathYAdjust + 150; // more gem adjustment
							gem2Green.alpha = 0;
							gem2Green.animation.play('cyan');
							add(gem2Green);
						}

						if (SONG.song == 'Spectral' || SONG.song == 'Ectospasm')
						{
							// Darken the background
							spectralDarkScreen = new FlxSprite(-1000, -1500).makeGraphic(4000, 3000, FlxColor.BLACK);
							spectralDarkScreen.active = false;
							spectralDarkScreen.alpha = 0;
							add(spectralDarkScreen);

							if (FlxG.save.data.particles && FlxG.save.data.motion)
							{
								// Particles to make it look fast
								spectralBGEmitter = new FlxEmitter(3500, -1000);
								spectralBGEmitter.launchMode = FlxEmitterMode.SQUARE;
								spectralBGEmitter.velocity.set(-2500, -0, -5000, 0);
								spectralBGEmitter.height = 3000;
								spectralBGEmitter.makeParticles(50, 5, FlxColor.WHITE, 500);
								add(spectralBGEmitter);
							}

							if (FlxG.save.data.background > 1)
							{
								// wrath_flames
								flames = new FlxSprite(0, 0);
								if (FlxG.save.data.cacheImages)
								{
									flames.frames = FileCache.instance.fromSparrow('wrath_flames', 'flames_colorchange');
								}
								else
								{
									flames.frames = Paths.getSparrowAtlas('flames_colorchange','wrath');
								}
								flames.antialiasing = FlxG.save.data.antialiasing;
								flames.animation.addByPrefix('greenFlame', 'Symbol 1 Instanz 1', 24);
								flames.screenCenter();
								flames.scale.x = 1.6;
								flames.scale.y = 1.5;
								flames.scrollFactor.set(0.7, 0.7);
								flames.x += wrathXAdjust - 250;
								if (isStoryMode && firstTry)
								{
									//flames.visible = false;
									flames.y += wrathYAdjust + 1200;
									flames.alpha = 0.0000000001;
								}
								else
									flames.y += wrathYAdjust + 200;
								flames.animation.play('greenFlame');
								add(flames);

								// wrath_flames color change
								if (FlxG.save.data.flashing)
								{
									flameChange = new FlxSprite(0, 0);
									if (FlxG.save.data.cacheImages)
									{
										flameChange.frames = FileCache.instance.fromSparrow('wrath_flames', 'flames_colorchange');
									}
									else
									{
										flameChange.frames = Paths.getSparrowAtlas('flames_colorchange','wrath');
									}
									flameChange.antialiasing = FlxG.save.data.antialiasing;
									flameChange.animation.addByPrefix('blueFlame', 'Symbol 2 Instanz 1', 24);
									flameChange.screenCenter();
									flameChange.scale.x = 1.6;
									flameChange.scale.y = 1.5;
									flameChange.scrollFactor.set(0.7, 0.7);
									flameChange.x += wrathXAdjust - 250;
									flameChange.y += wrathYAdjust + 200;
									flameChange.alpha = 0.0000000001;
									flameChange.animation.play('blueFlame');
									add(flameChange);
								}
							}

							// SakuBop
							if ((SONG.song == 'Spectral' || SONG.song == 'Ectospasm') && gfCharacter != 'sakuroma')
							{
								sakuBop = new FlxSprite(0, 0);
								if (FlxG.save.data.cacheImages)
								{
									sakuBop.frames = FileCache.instance.fromSparrow('wrath_saku', 'SakuBop');
								}
								else
								{
									sakuBop.frames = Paths.getSparrowAtlas('SakuBop','wrath');
								}
								sakuBop.antialiasing = FlxG.save.data.antialiasing;
								sakuBop.animation.addByPrefix('bop', 'SakuBop', 24, false);
								sakuBop.screenCenter();
								//sakuBop.scale.x *= .5;
								//sakuBop.scale.y *= .5;
								sakuBop.x += 690;
								sakuBop.y += -70;
								if (SONG.song == 'Spectral')
									sakuBop.alpha = 0;
								sakuBop.scrollFactor.set(0.8, 0.8);
								add(sakuBop);
							}
						}

						// wrath_cave
						if (!isStoryMode && FlxG.save.data.background == 1 && (SONG.song == 'Spectral' || SONG.song == 'Ectospasm'))
							cave = new FlxSprite(0, 0).loadGraphic(Paths.image('wrath_runes', 'wrath'));
						else
							cave = new FlxSprite(0, 0).loadGraphic(Paths.image('wrath_cave', 'wrath'));
						if (FlxG.save.data.background > 1 && (SONG.song == 'Spectral' || SONG.song == 'Ectospasm'))
						{
							if (FlxG.save.data.cacheImages)
							{
								cave.frames = FileCache.instance.fromSparrow('wrath_runes','runes_glow');
							}
							else
							{
								cave.frames = Paths.getSparrowAtlas('runes_glow','wrath');
							}
							cave.animation.addByPrefix('glow', 'Glow', 24, false);
							cave.animation.addByPrefix('cave', 'Cave', 24, false);

							if (isStoryMode && firstTry)
								cave.animation.play('cave');
							else
								cave.animation.play('glow');
						}
						cave.antialiasing = FlxG.save.data.antialiasing;
						cave.screenCenter();
						//cave.scale.x = wrathBgScale - 0.1775;
						//cave.scale.y = wrathBgScale - 0.1775;
						cave.scrollFactor.set(0.8, 0.8);
						cave.x += wrathXAdjust - 317;
						cave.y += wrathYAdjust + 81;
						cave.flipX = true;
						add(cave);

						if (!isStoryMode && FlxG.save.data.background == 1 && (SONG.song == 'Spectral' || SONG.song == 'Ectospasm'))
							cave2 = new FlxSprite(0, 0).loadGraphic(Paths.image('wrath_runes2', 'wrath'));
						else
						{
							cave2 = new FlxSprite(0, 0).loadGraphic(Paths.image('wrath_cave', 'wrath'));
							cave2.scale.set(1.24558452481, 1.24558452481);
						}
						if (FlxG.save.data.background > 1 && (SONG.song == 'Spectral' || SONG.song == 'Ectospasm'))
						{
							if (FlxG.save.data.cacheImages)
							{
								cave2.frames = FileCache.instance.fromSparrow('wrath_runes2','runes_glow2');
								cave2.scale.set(1, 1);
							}
							else
							{
								cave2.frames = Paths.getSparrowAtlas('runes_glow2','wrath');
								cave2.scale.set(1, 1);
							}
							cave2.animation.addByPrefix('glow', 'Glow', 24, false);
							cave2.animation.addByPrefix('cave', 'Cave', 24, false);

							if (isStoryMode && firstTry)
								cave2.animation.play('cave');
							else
								cave2.animation.play('glow');
						}
						cave2.antialiasing = FlxG.save.data.antialiasing;
						cave2.screenCenter();
						//cave2.scale.x = wrathBgScale - 0.075;
						//cave2.scale.y = wrathBgScale - 0.075;
						cave2.scrollFactor.set(0.8, 0.8);
						cave2.x += wrathXAdjust + 162;
						cave2.y += wrathYAdjust + 25;
						add(cave2);

						if (FlxG.save.data.flashing && isStoryMode && (SONG.song == 'Spectral'))
						{
							bgFlash = new FlxSprite(-1250, -100).makeGraphic(3000, 1000);
							bgFlash.active = false;
							bgFlash.visible = false;
							add(bgFlash);
						}

						// Spectral background effect
						if (FlxG.save.data.background > 1 && (SONG.song == 'Spectral' || SONG.song == 'Ectospasm'))
						{
							// wrath_animated_crystals
							crystals = new FlxTypedGroup<FlxSprite>();

							for (i in 0...8)
							{
								var crystal:FlxSprite = new FlxSprite(0, 0);
								if (isStoryMode && firstTry)
									crystal.setPosition(crystalPos[i].x, crystalPos[i].y + 1500);
								else
									crystal.setPosition(crystalPos[i].x, crystalPos[i].y);
								if (FlxG.save.data.cacheImages)
								{
									crystal.frames = FileCache.instance.fromSparrow('wrath_crystals', 'Crystals');
								}
								else
								{
									crystal.frames = Paths.getSparrowAtlas('Crystals','wrath');
								}
								crystal.antialiasing = FlxG.save.data.antialiasing;
								crystal.animation.addByPrefix('idle', 'Crystal' + i, 24);
								crystal.scrollFactor.set(0.9, 0.9);
								crystal.animation.play('idle');
								crystals.add(crystal);
							}

							if (isStoryMode && firstTry)
								crystals.visible = false;
							add(crystals);
						}

						// wrath_ground
						var ground:FlxSprite = new FlxSprite(0, 0);
						if (FlxG.save.data.cacheImages)
						{
							ground.frames = FileCache.instance.fromSparrow('wrath_ground', 'ground');
						}
						else
						{
							ground.frames = Paths.getSparrowAtlas('ground','wrath');
						}
						ground.animation.addByPrefix('green', 'green', 0, false);
						ground.antialiasing = FlxG.save.data.antialiasing;
						ground.screenCenter();
						//ground.scale.x = wrathBgScale;
						//ground.scale.y = wrathBgScale;
						ground.scrollFactor.set(1, 1);
						ground.active = false;
						ground.x += wrathXAdjust;
						ground.y += wrathYAdjust;
						ground.animation.play('green');
						add(ground);

						if (SONG.song == 'Spectral' || SONG.song == 'Ectospasm')
						{
							if (FlxG.save.data.flashing)
							{
								// wrath_ground
								groundGreen = new FlxSprite(0, 0);
								if (FlxG.save.data.cacheImages)
								{
									groundGreen.frames = FileCache.instance.fromSparrow('wrath_ground', 'ground');
								}
								else
								{
									groundGreen.frames = Paths.getSparrowAtlas('ground','wrath');
								}
								groundGreen.animation.addByPrefix('cyan', 'cyan', 0, false);
								groundGreen.antialiasing = FlxG.save.data.antialiasing;
								groundGreen.screenCenter();
								//groundGreen.scale.x = wrathBgScale;
								//groundGreen.scale.y = wrathBgScale;
								groundGreen.scrollFactor.set(1, 1);
								groundGreen.active = false;
								groundGreen.x += wrathXAdjust;
								groundGreen.y += wrathYAdjust;
								groundGreen.alpha = 0;
								groundGreen.animation.play('cyan');
								add(groundGreen);
							}

							// wrath_crack
							crack = new FlxSprite(0, 0);
							if (FlxG.save.data.cacheImages)
							{
								crack.frames = FileCache.instance.fromSparrow('wrath_crack', 'HellCrack');
							}
							else
							{
								crack.frames = Paths.getSparrowAtlas('HellCrack','wrath');
							}
							crack.antialiasing = FlxG.save.data.antialiasing;
							crack.animation.addByPrefix('appear', 'HellcrackAppear', 24, false);
							crack.animation.addByPrefix('bop', 'HellcrackBop', 24, false);
							crack.screenCenter();
							//crack.scale.x = .7;
							//crack.scale.y = .7;
							crack.x += 70;
							crack.y += 365;
							crack.scrollFactor.set(1, 1);
						}

						// wrath_rocks
						rocks = new FlxSprite(0, 0);
						if (FlxG.save.data.cacheImages)
						{
							rocks.frames = FileCache.instance.fromSparrow('wrath_frontRocks', 'frontRocks');
						}
						else
						{
							rocks.frames = Paths.getSparrowAtlas('frontRocks','wrath');
						}
						rocks.animation.addByPrefix('green', 'green', 0, false);
						rocks.antialiasing = FlxG.save.data.antialiasing;
						rocks.screenCenter();
						//rocks.scale.x = wrathBgScale;
						//rocks.scale.y = wrathBgScale;
						rocks.scrollFactor.set(1.1, 1.1);
						rocks.active = false;
						rocks.x += wrathXAdjust + 25;
						rocks.y += wrathYAdjust + 175; // rock adjustment
						rocks.animation.play('green');
						add(rocks);

						if (FlxG.save.data.flashing && (SONG.song == 'Spectral' || SONG.song == 'Ectospasm'))
						{
							// wrath_rocks
							rocksGreen = new FlxSprite(0, 0);
							if (FlxG.save.data.cacheImages)
							{
								rocksGreen.frames = FileCache.instance.fromSparrow('wrath_frontRocks', 'frontRocks');
							}
							else
							{
								rocksGreen.frames = Paths.getSparrowAtlas('frontRocks','wrath');
							}
							rocksGreen.animation.addByPrefix('cyan', 'cyan', 0, false);
							rocksGreen.antialiasing = FlxG.save.data.antialiasing;
							rocksGreen.screenCenter();
							//rocksGreen.scale.x = wrathBgScale;
							//rocksGreen.scale.y = wrathBgScale;
							rocksGreen.scrollFactor.set(1.1, 1.1);
							rocksGreen.active = false;
							rocksGreen.x += wrathXAdjust + 25;
							rocksGreen.y += wrathYAdjust + 175; // rock adjustment
							rocksGreen.alpha = 0;
							rocksGreen.animation.play('cyan');
							add(rocksGreen);
						}
					}

					// (tsg) per song adjustments
					if (SONG.song == "Retro" || SONG.song == 'Satisfracture' || SONG.song == "Fuzzy Feeling")
					{
						defaultCamZoom -= 0.215;
					}

					if (SONG.song == "Spectral" || SONG.song == 'Ectospasm')
					{
						// defaultCamZoom -= 0.3;
						defaultCamZoom -= 0.215;

						// Move the rocks to accomodate the sides of the screen
						if (!(isStoryMode && firstTry))
						{
							if (FlxG.save.data.background > 0)
							{
								rocks.scale.x += .1;
								rocks.scale.y += .1;
								if (rocksGreen != null)
								{
									rocksGreen.scale.x += .1;
									rocksGreen.scale.y += .1;
								}
							}

							defaultCamZoom = 0.525;
						}
					}

					switch(SONG.player1) {
						case "bf":
							SONG.player1 = "bf-wrath";

						case "bf-retro":
							SONG.player1 = "bf-retro-wrath";

						case "bf-ace":
							SONG.player1 = "bf-ace-wrath";
					}

					if (SONG.gfVersion == "gf")
						SONG.gfVersion = "gf-wrath";

					if (SONG.player2 == "retro")
						SONG.player2 = "retro-wrath";

					if (SONG.player2 == "retro2")
						SONG.player2 = "retro2-wrath";
				}
				default:
					{
						// Shouldn't ever happen and might crash the game
						defaultCamZoom = 0.9;
						curStage = 'stage';
						var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
						bg.antialiasing = FlxG.save.data.antialiasing;
						bg.scrollFactor.set(0.9, 0.9);
						bg.active = false;
						add(bg);

						var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
						stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
						stageFront.updateHitbox();
						stageFront.antialiasing = FlxG.save.data.antialiasing;
						stageFront.scrollFactor.set(0.9, 0.9);
						stageFront.active = false;
						add(stageFront);

						var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
						stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
						stageCurtains.updateHitbox();
						stageCurtains.antialiasing = FlxG.save.data.antialiasing;
						stageCurtains.scrollFactor.set(1.3, 1.3);
						stageCurtains.active = false;

						add(stageCurtains);
					}
			}
		}
		// Things that still need to be in optimized
		else
		{
			if (SONG.song == 'Spectral' || SONG.song == 'Ectospasm')
			{
				// Load poison sound for Spectral and Ectospasm
				poisonSound = new FlxSound().loadEmbedded(Paths.sound('acid', 'shared'));
				FlxG.sound.list.add(poisonSound);

				if (SONG.song == 'Ectospasm')
				{
					// Load spectre hit sound for Ectospasm
					spectreSound = new FlxSound().loadEmbedded(Paths.sound('SpectreArrow', 'shared'));
					FlxG.sound.list.add(spectreSound);

					// Load secret Saku laugh sound for Ectospasm
					sakuLaugh = new FlxSound().loadEmbedded(Paths.sound('sakulaff', 'shared'));
					sakuNote = new FlxSound().loadEmbedded(Paths.sound('sakuNote', 'shared'));
					FlxG.sound.list.add(sakuLaugh);
					FlxG.sound.list.add(sakuNote);
				}
			}
		}

		// defaults if no gf was found in chart
		var gfCheck:String = SONG.gfVersion;

		var curGf:String = '';
		switch (gfCheck)
		{
			case 'gf-wrath':
				curGf = 'gf-wrath';
			case 'gf-saku':
				curGf = 'gf-saku';
			default:
				curGf = 'gf-wrath';
		}

		gf = new Character(400, 130, curGf);
		gf.scrollFactor.set(1, 1);

		dad = new Character(100, 100, SONG.player2);
		dad.animation.stop(); // For some reason, the dad's animation goes through cutscenes

		// Chromatic aberration on specific songs
		if (FlxG.save.data.chrom && (SONG.song == 'Spectral' || SONG.song == 'Ectospasm'))
		{
			dad.chromEnabled = true;
		}

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		if(curStage == 'wrath') {
			// (tsg) stage adjust stuff
			boyfriend.x += 200;
			gf.y += 25;

			// (tsg - 6/18/21) move camera just a little bit up to account for the slightly bigger retro sprite
			if (SONG.song == "Retro")
			{
				camPos.y -= 64;
			}

			// (tsg - 6/18/21) manually adjust the dad x position for new retro sprites
			if (dad.curCharacter == "retro-wrath")
			{
				dad.y += -50;
				dad.x -= 20;
			}

			// (tsg) adjust the player2 position only if its a retro2 character
			else if (dad.curCharacter == "retro2-wrath")
			{
				dad.x -= 534;
				dad.y -= 128;
			}
			else if (dad.curCharacter == 'sakuroma')
			{
				dad.x -= 300;
				dad.y -= 250;
			}

			// (Arcy) Scooch gf over a little
			if (gf.curCharacter == "gf-wrath")
			{
				gf.x -= 150;
				gf.y += 25;
			}
			else if (gf.curCharacter == 'gf-saku')
			{
				gf.x -= 40;
				gf.y -= 70;
			}
		}

		if (!PlayStateChangeables.Optimize)
		{
			add(gf);

			// Crack goes in front of gf but behind Retro
			if (crack != null)
			{
				add(crack);
			}

			if (FlxG.save.data.ghostTrails)
			{
				spriteTrail = new FlxTypedGroup<FlxSprite>();
				add(spriteTrail);
			}

			add(dad);

			if (isStoryMode)
			{
				if (firstTry && (SONG.song == 'Retro' || SONG.song == 'Satisfracture'))
				{
					dad.visible = false;
					cutsceneSprite = new Character(dad.x, dad.y, 'retro-intro');
					cutsceneSprite.scale.set(.95, .95);
					cutsceneSprite.x -= 22;
					add(cutsceneSprite);
				}
				else if (SONG.song == 'Spectral')
				{
					cutsceneSprite = new Character(dad.x, dad.y, 'retro-tf');

					if (firstTry)
					{
						dad.visible = false;
						add(cutsceneSprite);

						characterLogo = new FlxSprite(0, 200);
						if (FlxG.save.data.cacheImages)
						{
							characterLogo.frames = FileCache.instance.fromSparrow('shared_beserkerRetroLogo', 'BeserkerRetroLogo');
						}
						else
						{
							characterLogo.frames = Paths.getSparrowAtlas('BeserkerRetroLogo','shared');
						}
						characterLogo.animation.addByPrefix('logo', 'BERSERKER-RETRO Instanz 1', 24, false);
						characterLogo.scale.set(0.75, 0.75);
						characterLogo.screenCenter(X);
						characterLogo.alpha = 0;
						characterLogo.cameras = [camHUD];
						add(characterLogo);
					}

					endCutsceneSprites = new FlxTypedGroup<FlxSprite>();

					if (!FlxG.save.data.cacheCutscenes)
					{
						// Bunch of sprites for end cutscene
						for(i in 1...9)
						{
							var endSprite:Character = new Character(cutsceneSprite.x, cutsceneSprite.y, 'retro-end' + i);
							endSprite.alpha = 0.0000000001;
							endCutsceneSprites.add(endSprite);
						}
					}
					else
					{
						for(ecSprite in FileCache.instance.wrathEndCutsceneSprites.members) {
							var processedSprite = cast(ecSprite, FlxSprite);
							endCutsceneSprites.add(processedSprite);
						}

						// (Arcy) Cutscene sprites need to be remade because they become invalidated?
						// (Arcy) Probably because of some garbage collection?
						FileCache.instance.constructCutscenes();
					}

					add(endCutsceneSprites);
				}
			}

			add(boyfriend);

			// Special overlay for the wrath stage
			if (SONG.stage == 'wrath')
			{
				// wrath_overlay
				var overlay:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('wrath_overlay', 'wrath'));
				overlay.antialiasing = FlxG.save.data.antialiasing;
				overlay.blend = BlendMode.SCREEN;
				overlay.screenCenter();
				//overlay.scale.x = .72;
				//overlay.scale.y = .72;
				overlay.scrollFactor.set(0.6, 0.6);
				overlay.active = false;
				overlay.y += -128;
				add(overlay);
			}

			// Special effects stuff
			if (FlxG.save.data.windowShake)
			{
				windowOrigin = new FlxPoint(Application.current.window.x, Application.current.window.y);
				Application.current.window.onMove.add(function(x:Float, y:Float):Void
				{
					windowOrigin = new FlxPoint(x, y);
				});
			}

		}

		if (loadRep)
		{
			// FlxG.watch.addQuick('Queued',inputsQueued);

			PlayStateChangeables.useDownscroll = rep.replay.isDownscroll;
			PlayStateChangeables.safeFrames = rep.replay.sf;
			PlayStateChangeables.botPlay = true;
		}

		var doof:DialogueBox = null;
		if (isStoryMode && firstTry && ((SONG.song != 'Retro' && SONG.song != 'Satisfracture') || PlayStateChangeables.Optimize))
		{
			doof = new DialogueBox(SONG.song, bfCharacter, storyDifficulty, curGf);
			doof.scrollFactor.set();
			// doof.x += 70;
			// doof.y = FlxG.height * 0.5;
		}
		else if (SONG.song == 'Fuzzy Feeling')
		{
			doof = new DialogueBox(SONG.song, bfCharacter, storyDifficulty, curGf);
			doof.scrollFactor.set();
			doof.finishThing = startCountdown;
		}

		GhostSprite.initialize();

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (PlayStateChangeables.useDownscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();

		if (SONG.song == 'Spectral' || SONG.song == 'Ectospasm')
		{
			for (i in 0...4)
			{
				poisonNoteHits[i] = new FlxTypedGroup<FlxSprite>();

				if (SONG.song == 'Ectospasm')
				{
					spectreNoteHits[i] = new FlxTypedGroup<FlxSprite>();
					add(spectreNoteHits[i]);

					if (i == 0)
					{
						enemySpectreNoteHit = new FlxSprite();
						add(enemySpectreNoteHit);
					}
				}

				add(poisonNoteHits[i]);
			}
		}

		generateStaticArrows(0);
		generateStaticArrows(1);

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		/*if (FlxG.save.data.songPosition) // I dont wanna talk about this code :(
		{
			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (FlxG.save.data.downscroll)
			{
				songPosBG.y = FlxG.height * 0.9 + 45;
			}
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, 90000);
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - 20, songPosBG.y, 0, SONG.song, 16);
			if (FlxG.save.data.downscroll)
			{
				songName.y -= 3;
			}
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);
			songName.cameras = [camHUD];
		}*/

		if (curSong == 'Spectral' || curSong == 'Ectospasm')
		{
			healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('HealthBar_Placeholder_Red')); // Haha lazy coding
		}
		else
		{
			healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		}
		if (FlxG.save.data.downscroll)
		{
			healthBarBG.y = 50;
		}
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		if (curSong != 'Spectral' && curSong != 'Ectospasm')
		{
			add(healthBarBG);
		}

		if (curSong == 'Spectral' || curSong == 'Ectospasm')
		{
			healthBar = new FlxBar(healthBarBG.x, healthBarBG.y, RIGHT_TO_LEFT, Std.int(healthBarBG.width), Std.int(healthBarBG.height), this, 'health', 0, 2);
		}
		else
		{
			healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
				'health', 0, 2);
		}
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		if (curSong == 'Spectral' || curSong == 'Ectospasm')
		{
			healthBar.y -= 15;
			healthBar.createImageEmptyBar(Paths.image('HealthBar_Placeholder_Red'), FlxColor.WHITE);
			healthBar.createImageFilledBar(Paths.image('HealthBar_Placeholder_Green'), FlxColor.WHITE);
			healthBarOrigin = healthBar.getPosition();
		}
		// healthBar
		add(healthBar);

		// Add Kade Engine watermark
		kadeEngineWatermark = new FlxText(4, healthBarBG.y
			+ 50, 0,
			(trueEctospasm ? 'True Ectospasm' : SONG.song)
			+ " "
			+ (storyDifficulty == 3 ? "Hell" : storyDifficulty == 2 ? "Hard" : storyDifficulty == 1 ? "Normal" : "Easy")
			+ " "
			+ (storyMode == 3 ? "Randomized" : storyMode == 2 ? "Freestyle" : storyMode == 1 ? "No Fail" : "Standard")
			+ (Main.watermarks ? " - KE " + MainMenuState.kadeEngineVer : ""),
			16);
		kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		add(kadeEngineWatermark);

		if (PlayStateChangeables.useDownscroll)
			kadeEngineWatermark.y = FlxG.height * 0.9 + 45;

		scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + 50, 0, "", 20);

		scoreTxt.screenCenter(X);

		scoreTxt.scrollFactor.set();

		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		add(scoreTxt);

		replayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0, "REPLAY",
			20);
		replayTxt.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		replayTxt.borderSize = 4;
		replayTxt.borderQuality = 2;
		replayTxt.scrollFactor.set();
		if (loadRep)
		{
			add(replayTxt);
		}
		// Literally copy-paste of the above, fu
		botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0,
			"BOTPLAY", 20);
		botPlayState.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botPlayState.scrollFactor.set();
		botPlayState.borderSize = 4;
		botPlayState.borderQuality = 2;
		if (PlayStateChangeables.botPlay && !loadRep)
			add(botPlayState);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);

		// (tsg - 7/24/21) small things lyric system port
		/*lyricTxt = new FlxText(healthBar.x, healthBar.y, 320, "[PLACEHOLDER]", 28);
		lyricTxt.setFormat(Paths.font("vcr.ttf"), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		lyricTxt.scrollFactor.set();

		lyricSpeakerIcon = new HealthIcon();
		lyricSpeakerIcon.scale.x = 0.85;
		lyricSpeakerIcon.scale.y = 0.85;
		lyricSpeakerIcon.visible = false;

		add(lyricSpeakerIcon);
		add(lyricTxt);

		// by default have this off
		lyricTxt.text = "";*/

		// (tsg - 7/24/21) - small things lyric system port
		#if debug
		conductorPosTxt = new FlxText(10, 10, "", 20);
		conductorPosTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		conductorPosTxt.scrollFactor.set();

		add(conductorPosTxt);
		#end

		if (curSong == 'Spectral' || curSong == 'Ectospasm')
		{
			var kamOffset = bfCharacter == 'bf-ace' && !FlxG.save.data.downscroll ? -10 : 0;

			poisonIcon = new FlxSprite(iconP1.x + 75,
				healthBar.y + (FlxG.save.data.downscroll ? 25 : -75) + kamOffset).loadGraphic(Paths.image('Health_Splat', 'shared'));
			poisonIcon.scale.set(0.2, 0.2);
			poisonTxt = new FlxText(iconP1.x + 115, poisonIcon.y + 20, '0', 20);
			poisonTxt.color = FlxColor.BLACK;

			// Chromatic Aberration effect
			if (FlxG.save.data.chrom)
			{
				chrom = new ChromaticAberrationShader();
				iconP1.shader = chrom;
				iconP2.shader = chrom;
				healthBar.shader = chrom;
				poisonIcon.shader = chrom;

				chrom.rOffset.value = [0, 0];
				chrom.gOffset.value = [0, 0];
				chrom.bOffset.value = [0, 0];
			}
		}

		add(poisonIcon);
		add(iconP1);
		add(iconP2);
		add(poisonTxt);

		if (curSong == 'Spectral' || curSong == 'Ectospasm')
		{
			iconP1.y += 15;
			iconP2.y += 15;
		}

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		//lyricTxt.cameras = [camHUD]; // (tsg - 7/24/21) small things lyric system port
		//lyricSpeakerIcon.cameras = [camHUD]; // (tsg - 7/24/21) small things lyric system port

		// (tsg - 7/24/21) - small things lyric system port
		#if debug
		conductorPosTxt.cameras = [camHUD];
		#end

		if (SONG.song == 'Spectral' || SONG.song == 'Ectospasm')
		{
			poisonIcon.cameras = [camHUD];
			poisonTxt.cameras = [camHUD];

			for (i in 0...4)
			{
				poisonNoteHits[i].cameras = [camHUD];

				if (SONG.song == 'Ectospasm')
				{
					spectreNoteHits[i].cameras = [camHUD];
					enemySpectreNoteHit.cameras = [camHUD];
				}
			}
		}
		scoreTxt.cameras = [camHUD];
		if (doof != null)
		{
			doof.cameras = [camHUD];
		}
		if (FlxG.save.data.songPosition)
		{
			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
		}
		kadeEngineWatermark.cameras = [camHUD];
		if (loadRep)
		{
			replayTxt.cameras = [camHUD];
		}

		startingSong = true;

		if (isStoryMode)
		{
			switch (StringTools.replace(curSong, " ", "-").toLowerCase())
			{
				case 'retro':
					healthBar.visible = false;
					healthBarBG.visible = false;
					iconP1.visible = false;
					iconP2.visible = false;
					scoreTxt.visible = false;
					introCutscene();
				case 'satisfracture':
					if (PlayStateChangeables.Optimize)
					{
						if (doof != null)
						{
							healthBar.visible = false;
							healthBarBG.visible = false;
							iconP1.visible = false;
							iconP2.visible = false;
							scoreTxt.visible = false;

							startDialogue(doof);
							doof.finishThing = function()
							{
								healthBar.visible = true;
								healthBarBG.visible = true;
								iconP1.visible = true;
								iconP2.visible = true;
								scoreTxt.visible = true;
								startCountdown();
							};
						}
						else
						{
							startCountdown();
						}
					}
					else if (firstTry)
					{
						healthBar.visible = false;
						healthBarBG.visible = false;
						iconP1.visible = false;
						iconP2.visible = false;
						scoreTxt.visible = false;

						introCutscene();
					}
					else
					{
						startCountdown();
					}
				case 'spectral':
					if (doof != null)
					{
						healthBar.visible = false;
						healthBarBG.visible = false;
						iconP1.visible = false;
						iconP2.visible = false;
						scoreTxt.visible = false;
						poisonIcon.visible = false;
						poisonTxt.visible = false;

						startDialogue(doof);

						if (PlayStateChangeables.Optimize)
						{
							doof.finishThing = function()
							{
								healthBar.visible = true;
								healthBarBG.visible = true;
								iconP1.visible = true;
								iconP2.visible = true;
								scoreTxt.visible = true;
								poisonIcon.visible = true;
								poisonTxt.visible = true;
								startCountdown();
							};
						}
						else
						{
							doof.finishThing = transformCutscene;
						}
					}
					else
					{
						startCountdown();
					}
				default:
					startCountdown();
			}
		}
		else if (curSong == 'Fuzzy Feeling')
		{
			startDialogue(doof);
		}
		else
		{
			startCountdown();
		}

		if (!loadRep)
		{
			rep = new Replay("na");
		}

		// Game over hint stuff
		retroPortrait = new FlxSprite(20, 100);
		retroPortrait.frames = Paths.getSparrowAtlas('characters/portraits/RetroSpecter', 'shared');
		retroPortrait.animation.addByPrefix('Enraged', 'Enraged', 24, false);
		retroPortrait.scale.set(0.66, 0.66);

		speechBubble = new FlxSprite(25, 400);
		speechBubble.frames = Paths.getSparrowAtlas('speech_bubble_talking', 'shared');
		speechBubble.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
		speechBubble.scale.set(0.9, 0.9);

		hintText = new FlxTypeText(150, 560, 1050, "", 32);
		hintText.setFormat(Paths.font('aApiNyala.ttf'), 50, FlxColor.fromRGB(42, 136, 164), LEFT);
		hintText.sounds = [FlxG.sound.load(Paths.sound('retroAngryVoice'), 0.6)];

		hintDropText = new FlxText(153, 562, 1050, "", 32);
		hintDropText.setFormat(Paths.font('aApiNyala.ttf'), 50, FlxColor.fromRGB(42, 136, 164), LEFT);
		hintDropText.color = FlxColor.BLACK;

		retroPortrait.cameras = [camHUD];
		speechBubble.cameras = [camHUD];
		hintText.cameras = [camHUD];
		hintDropText.cameras = [camHUD];

		updateHealthGraphics();

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);

		// (Arcy) Doesn't work because sound resumes when focusing back in for some reason even when paused
		//FlxG.stage.window.onFocusOut.add(focusOut);
		//FlxG.stage.window.onFocusIn.add(focusIn);

		super.create();
	}

	function startDialogue(?dialogueBox:DialogueBox):Void
	{
		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			if (dialogueBox != null)
			{
				inCutscene = true;
				add(dialogueBox);
			}
			else
			{
				startCountdown();
			}
		});
	}

	var startTimer:FlxTimer;

	#if windows
	public static var luaModchart:ModchartState = null;
	#end

	function startCountdown():Void
	{
		inCutscene = false;

		appearStaticArrows();
		//generateStaticArrows(0);
		//generateStaticArrows(1);

		if (startTime != 0)
		{
			var toBeRemoved = [];
			for(i in 0...unspawnNotes.length)
			{
				var dunceNote:Note = unspawnNotes[i];

				if (dunceNote.strumTime - startTime <= 0)
					toBeRemoved.push(dunceNote);
				else if (dunceNote.strumTime - startTime < 3500)
				{
					notes.add(dunceNote);

					if (dunceNote.mustPress)
						dunceNote.y = (playerStrums.members[Math.floor(Math.abs(dunceNote.noteData))].y
							+ 0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
								2)) - dunceNote.noteYOff;
					else
						dunceNote.y = (strumLineNotes.members[Math.floor(Math.abs(dunceNote.noteData))].y
							+ 0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
								2)) - dunceNote.noteYOff;
					toBeRemoved.push(dunceNote);
				}
			}

			for(i in toBeRemoved)
				unspawnNotes.remove(i);
		}

		#if windows
		// pre lowercasing the song name (startCountdown)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();

		if (executeModchart)
		{
			luaModchart = ModchartState.createModchartState();
			luaModchart.executeState('start', [songLowercase]);
		}
		#end

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.playAnim('idle');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
				}
			}

			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;

	var keys = [false, false, false, false];

	private function releaseInput(evt:KeyboardEvent):Void // handles releases
	{
		@:privateAccess
		var key = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(evt.keyCode));

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;

		switch (evt.keyCode) // arrow keys
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}

		if (data == -1)
			return;

		keys[data] = false;
	}

	public var closestNotes:Array<Note> = [];


	private function handleInput(evt:KeyboardEvent):Void
	{ // this actually handles press inputs

		if (PlayStateChangeables.botPlay || loadRep || paused)
			return;

		// first convert it from openfl to a flixel key code
		// then use FlxKey to get the key's name based off of the FlxKey dictionary
		// this makes it work for special characters

		@:privateAccess
		var key = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(evt.keyCode));

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;

		switch (evt.keyCode) // arrow keys
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}
		if (data == -1)
		{
			return;
		}
		if (keys[data])
		{
			return;
		}

		keys[data] = true;

		var ana = new Ana(Conductor.songPosition, null, false, "miss", data);

		var dataNotes = [];
		for(i in closestNotes)
			if (!(curSong == 'Satisfracture' && curStep >= 187 && curStep <= 192) &&
				(i.noteData == data || storyMode == 2))
				dataNotes.push(i);

		if (dataNotes.length != 0)
		{
			var coolNote = null;

			for (i in dataNotes)
				if (!i.isSustainNote)
				{
					if (storyMode == 2 && i.noteType == NoteType.Poison && i.noteData == data)
					{
						coolNote = i;
						break;
					}
					else if (!(storyMode == 2 && i.noteType == NoteType.Poison))
					{
						coolNote = i;
						break;
					}
				}

			if (coolNote == null) // Note is null, which means it's probably a sustain note. Update will handle this (HOPEFULLY???)
			{
				return;
			}

			if (dataNotes.length > 1) // stacked notes or really close ones
			{
				for (i in 0...dataNotes.length)
				{
					if (i == 0) // skip the first note
						continue;

					var note = dataNotes[i];

					if (!note.isSustainNote && (note.strumTime - coolNote.strumTime) < 2)
					{
						// just fuckin remove it since it's a stacked note and shouldn't be there
						note.kill();
						notes.remove(note, true);
						note.destroy();
					}
				}
			}

			goodNoteHit(coolNote);
			var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
			ana.hit = true;
			ana.hitJudge = Ratings.CalculateRating(noteDiff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));
			ana.nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
		}
		else if (!FlxG.save.data.ghost && songStarted)
		{
			noteMiss(data, null);
			ana.hit = false;
			ana.hitJudge = "shit";
			ana.nearestNote = [];
			health -= 0.15;
			updateHealthGraphics();
		}
	}

	var songStarted = false;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;

		// Particle effects for Spectral
		if (FlxG.save.data.particles && (curSong == 'Spectral' || curSong == 'Ectospasm'))
		{
			particles = new FlxTypedGroup<FlxEmitter>();

			for (i in 0...6)
			{
				var emitter:FlxEmitter = new FlxEmitter(-1000, 1500);
				emitter.launchMode = FlxEmitterMode.SQUARE;
				emitter.velocity.set(-50, -150, 50, -750, -100, 0, 100, -100);
				emitter.scale.set(0.75, 0.75, 3, 3, 0.75, 0.75, 1.5, 1.5);
				emitter.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
				emitter.width = 3500;
				emitter.alpha.set(1, 1, 0, 0);
				emitter.lifespan.set(3, 5);
				emitter.loadParticles(Paths.image('Particles/Particle' + i, 'shared'), 500, 16, true);

				emitter.start(false, FlxG.random.float(0.1, 0.2), 100000);
				particles.add(emitter);
			}

			add(particles);
		}

		#if windows
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		FlxG.sound.music.time = startTime;
		vocals.time = startTime;
		Conductor.songPosition = startTime;
		startTime = 0;

		FlxG.sound.music.play();
		vocals.play();

		for(i in 0...unspawnNotes.length)
			if (unspawnNotes[i].strumTime < startTime)
				unspawnNotes.remove(unspawnNotes[i]);
	}

	public function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		#if sys
		if (SONG.needsVoices && !isSM)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();
		#else
		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();
		#end

		FlxG.sound.list.add(vocals);

		if (!paused)
		{
			#if sys
			if (!isStoryMode && isSM)
			{
				var bytes = File.getBytes(pathToSm + "/" + sm.header.MUSIC);
				var sound = new Sound();
				sound.loadCompressedDataFromByteArray(bytes.getData(), bytes.length);
				FlxG.sound.music.loadEmbedded(sound, false);
				//FlxG.sound.playMusic(sound);
			}
			else
				FlxG.sound.music.loadEmbedded(Paths.inst(PlayState.SONG.song), false);
				//FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
			#else
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
			#end
		}

		if (!(isStoryMode && curSong == "Spectral"))
		{
			FlxG.sound.music.onComplete = endSong;
		}
		//FlxG.sound.music.pause();

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		if (FlxG.save.data.songPosition)
		{
			remove(songPosBG);
			remove(songPosBar);
			remove(songName);

			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x
				+ 4, songPosBG.y
				+ 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength
				- 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - (SONG.song.length * 5), songPosBG.y, 0, SONG.song, 16);
			if (PlayStateChangeables.useDownscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
		}


		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		// Per song offset check
		#if windows
		// pre lowercasing the song name (generateSong)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();

		var songPath = 'assets/data/' + songLowercase + '/';

		#if sys
		if (isSM && !isStoryMode)
			songPath = pathToSm;
		#end

		for (file in sys.FileSystem.readDirectory(songPath))
		{
			var path = haxe.io.Path.join([songPath, file]);
			if (!sys.FileSystem.isDirectory(path))
			{
				if (path.endsWith('.offset'))
				{
					songOffset = Std.parseFloat(file.substring(0, file.indexOf('.off')));
					break;
				}
				else
				{
					sys.io.File.saveContent(songPath + songOffset + '.offset', '');
				}
			}
		}
		#end

		for (section in noteData)
		{
			// var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset + songOffset;
				if (daStrumTime < 0)
				{
					daStrumTime = 0;
				}
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				if (!gottaHitNote && PlayStateChangeables.Optimize)
					continue;

				var oldNote:Note;
				if (unspawnNotes.length > 0)
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				}
				else
				{
					oldNote = null;
				}

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, gottaHitNote, NoteType.createByIndex(songNotes[3]));

				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				if (susLength > 0)
					swagNote.isParent = true;

				var type = 0;

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData,
						oldNote, true, gottaHitNote);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					// sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}

					sustainNote.parent = swagNote;
					swagNote.children.push(sustainNote);
					sustainNote.spotInLine = type;
					type++;
				}

				// swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			}
			// daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		// Randomized mode always changes the note directions
		if (storyMode == 3)
		{
			// Variables needed for any double/triple/quad notes
			var prevStrumTime:Float = -1;
			var validNotes:Array<Bool> = [true, true, true, true];
			var noteID:Int = 0;

			var newNote:Note;
			var index:Int;
			var groupedNotes:FlxTypedGroup<Note>;
			groupedNotes = new FlxTypedGroup<Note>();

			for (note in unspawnNotes)
			{
				// Skip Retro's notes
				if (!note.mustPress)
					continue;

				if (note.strumTime - prevStrumTime < 0.000000001)
				{
					groupedNotes.add(note);
				}
				else
				{
					// Set sustain notes first
					for (i in 0...groupedNotes.length)
					{
						if (groupedNotes.members[i].isSustainNote)
						{
							newNote = groupedNotes.members[i]; // Unchanged from normal chart
							index = unspawnNotes.indexOf(newNote); // Store index for replacing later
							newNote.changeNoteDirection(newNote.prevNote.noteData); // Set the new direction
							validNotes[newNote.prevNote.noteData] = false; // Eliminate this direction as a choice
							unspawnNotes[index] = newNote; // Replace the note
						}
					}

					// Then randomized presses
					for (i in 0...groupedNotes.length)
					{
						if (!groupedNotes.members[i].isSustainNote)
						{
							newNote = groupedNotes.members[i]; // Unchanged from normal chart
							index = unspawnNotes.indexOf(newNote); // Store index for replacing later
							noteID = CoolUtil.getRandomNoteData(validNotes); // Random direction
							validNotes[noteID] = false; // Eliminate this direction as a choice
							newNote.changeNoteDirection(noteID); // Change the direction
							unspawnNotes[index] = newNote; // Replace the note
						}
					}

					// Now start the cycle again
					validNotes = [true, true, true, true];
					groupedNotes.clear();
					groupedNotes.add(note);
				}

				// And record last strum time for multi-notes
				prevStrumTime = note.strumTime;
			}
		}

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			// defaults if no noteStyle was found in chart
			var noteTypeCheck:String = 'normal';

			if (PlayStateChangeables.Optimize && player == 0)
				continue;

			noteTypeCheck = SONG.noteStyle;

			switch (noteTypeCheck)
			{
				case 'normal':
					// Sorry for being lazy and not making this its own special section
					if ((SONG.song == 'Spectral' || SONG.song == 'Ectospasm') && player == 0)
					{
						if (FlxG.save.data.cacheImages)
						{
							babyArrow.frames = FileCache.instance.fromSparrow('shared_notesRetro2', 'NOTE_assets_retro');
						}
						else
						{
							babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets_retro');
						}
					}
					else
					{
						if (FlxG.save.data.cacheImages)
						{
							if (FlxG.save.data.customStrumLine || player == 0)
							{
								babyArrow.frames = FileCache.instance.fromSparrow('shared_notesRetro', 'NOTE_assets_retrobf');
							}
							else
							{
								babyArrow.frames = FileCache.instance.fromSparrow('shared_notesDefault', 'NOTE_assets');
							}
						}
						else
						{
							if (FlxG.save.data.customStrumLine || player == 0)
							{
								babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets_retrobf');
							}
							else
							{
								babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
							}
						}
					}

					// These aren't needed right?
					/*babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');*/

					babyArrow.antialiasing = FlxG.save.data.antialiasing;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}

				default:
					// Sorry for being lazy and not making this its own special section
					if ((SONG.song == 'Spectral' || SONG.song == 'Ectospasm') && player == 0)
					{
						if (FlxG.save.data.cacheImages)
						{
							babyArrow.frames = FileCache.instance.fromSparrow('shared_notesRetro2', 'NOTE_assets_retro');
						}
						else
						{
							babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets_retro');
						}
					}
					else
					{
						if (FlxG.save.data.cacheImages)
						{
							if (FlxG.save.data.customStrumLine || player == 0)
							{
								babyArrow.frames = FileCache.instance.fromSparrow('shared_notesRetro', 'NOTE_assets_retrobf');
							}
							else
							{
								babyArrow.frames = FileCache.instance.fromSparrow('shared_notesDefault', 'NOTE_assets');
							}
						}
						else
						{
							if (FlxG.save.data.customStrumLine || player == 0)
							{
								babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets_retrobf');
							}
							else
							{
								babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
							}
						}
					}

					// These aren't needed right?
					/*for (j in 0...4)
					{
						babyArrow.animation.addByPrefix(dataColor[j], 'arrow' + dataSuffix[j]);
					}*/

					var lowerDir:String = dataSuffix[i].toLowerCase();

					babyArrow.animation.addByPrefix('static', 'arrow' + dataSuffix[i]);
					babyArrow.animation.addByPrefix('pressed', lowerDir + ' press', 24, false);
					babyArrow.animation.addByPrefix('confirm', lowerDir + ' confirm', 24, false);

					babyArrow.x += Note.swagWidth * i;

					babyArrow.antialiasing = FlxG.save.data.antialiasing;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.alpha = 0;
			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				//babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;
			babyArrow.animation.play('static');
			// babyArrow.x += 50;
			babyArrow.x += 50 + ((FlxG.width / 2) * player);

			switch (player)
			{
				case 0:
					cpuStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			// Add poison animation notes
			if (player == 1 && (SONG.song == 'Spectral' || SONG.song == 'Ectospasm'))
			{
				for (j in 0...5)
				{
					var poisonAnim:FlxSprite = new FlxSprite(babyArrow.x, 0);
					if (FlxG.save.data.cacheImages)
					{
						poisonAnim.frames = FileCache.instance.fromSparrow('shared_notesPoisonHit', 'PoisonArrowHit');
					}
					else
					{
						poisonAnim.frames = Paths.getSparrowAtlas('PoisonArrowHit','shared');
					}

					switch (i)
					{
						case 0:
							poisonAnim.animation.addByPrefix('break', 'Poison Arrow Hit Left', 24, false);
						case 1:
							poisonAnim.animation.addByPrefix('break', 'Poison Arrow Hit Down', 24, false);
						case 2:
							poisonAnim.animation.addByPrefix('break', 'Poison Arrow Hit Up', 24, false);
						case 3:
							poisonAnim.animation.addByPrefix('break', 'Poison Arrow Hit Right', 24, false);
					}

					poisonAnim.antialiasing = FlxG.save.data.antialiasing;
					poisonAnim.setGraphicSize(Std.int(poisonAnim.width * 0.7));
					poisonAnim.visible = false;
					poisonNoteHits[i].add(poisonAnim);

					if (SONG.song == 'Ectospasm')
					{
						var spectreAnim:FlxSprite = new FlxSprite(babyArrow.x, 0);
						if (FlxG.save.data.cacheImages)
						{
							spectreAnim.frames = FileCache.instance.fromSparrow('shared_spectreNoteHitUpscroll', 'SpectreHit');
						}
						else
						{
							spectreAnim.frames = Paths.getSparrowAtlas('SpectreHit','shared');
						}

						switch (i)
						{
							case 0:
								spectreAnim.animation.addByPrefix('break', 'SpectreHit left', 24, false);
							case 1:
								spectreAnim.animation.addByPrefix('break', 'SpectreHit down', 24, false);
							case 2:
								spectreAnim.animation.addByPrefix('break', 'SpectreHit up', 24, false);
							case 3:
								spectreAnim.animation.addByPrefix('break', 'SpectreHit right', 24, false);
						}

						spectreAnim.antialiasing = FlxG.save.data.antialiasing;
						spectreAnim.setGraphicSize(Std.int(spectreAnim.width * 0.7));
						spectreAnim.visible = false;
						spectreNoteHits[i].add(spectreAnim);
					}
				}
			}
			else if (player == 0 && SONG.song == 'Ectospasm' && i == 0)
			{
				enemySpectreNoteHit.setPosition(babyArrow.x, 0);
				if (FlxG.save.data.cacheImages)
				{
					enemySpectreNoteHit.frames = FileCache.instance.fromSparrow('shared_spectreNoteHitUpscroll', 'SpectreHit');
				}
				else
				{
					enemySpectreNoteHit.frames = Paths.getSparrowAtlas('SpectreHit','shared');
				}

				enemySpectreNoteHit.animation.addByPrefix('break', 'SpectreHit left', 24, false);

				enemySpectreNoteHit.antialiasing = FlxG.save.data.antialiasing;
				enemySpectreNoteHit.setGraphicSize(Std.int(enemySpectreNoteHit.width * 0.7));
				enemySpectreNoteHit.visible = false;
			}

			if (PlayStateChangeables.Optimize)
				babyArrow.x -= 275;

			cpuStrums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets(); // CPU arrows start out slightly off-center
			});

			strumLineNotes.add(babyArrow);
		}
	}

	private function appearStaticArrows():Void
	{
		strumLineNotes.forEach(function(babyArrow:FlxSprite)
		{
			if (isStoryMode)
				babyArrow.alpha = 1;
		});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			FlxG.cameras.list[FlxG.cameras.list.length - 1].angle = 0;
			camHUD.zoom = 1;

			#if windows
			DiscordClient.changePresence("PAUSED on "
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"Acc: "
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			#end
			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			paused = false;
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
			{
				startTimer.active = true;
			}

			#if windows
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText + " " + SONG.song + " (" + storyDifficultyText + ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: " + HelperFunctions.truncateFloat(accuracy, 2) + "% | Score: " + songScore
					+ " | Misses: " + misses, iconRPC, true,
					songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy),
					iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		if (paused)
			return;

		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();

		#if windows
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var nps:Int = 0;
	var maxNPS:Int = 0;

	public var updateFrame = 0;

	var iconOffset:Int = 26;

	override public function update(elapsed:Float)
	{
		// (Arcy) Commenting these out for now because we don't use any events
		// (Arcy) I'm not deleting it because we might use it for songs in the future
		/*if (updateFrame == 4)
		{
			TimingStruct.clearTimings();

				var currentIndex = 0;
				for (i in SONG.eventObjects)
				{
					if (i.type == "BPM Change")
					{
						var beat:Float = i.position;

						var endBeat:Float = Math.POSITIVE_INFINITY;

						TimingStruct.addTiming(beat,i.value,endBeat, 0); // offset in this case = start time since we don't have a offset

						if (currentIndex != 0)
						{
							var data = TimingStruct.AllTimings[currentIndex - 1];
							data.endBeat = beat;
							data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
							TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
						}

						currentIndex++;
					}
				}
				updateFrame++;
		}
		else if (updateFrame < 5)
		{
			updateFrame++;
		}

		var timingSeg = TimingStruct.getTimingAtTimestamp(Conductor.songPosition);

		if (timingSeg != null)
		{

			var timingSegBpm = timingSeg.bpm;

			if (timingSegBpm != Conductor.bpm)
			{
				Conductor.changeBPM(timingSegBpm, false);
			}

		}

		var newScroll = PlayStateChangeables.scrollSpeed;

		if (SONG.eventObjects != null)
		{
			for(i in SONG.eventObjects)
			{
				switch(i.type)
				{
					case "Scroll Speed Change":
						if (i.position < curDecimalBeat)
							newScroll = i.value;
				}
			}
		}

		PlayStateChangeables.scrollSpeed = newScroll;*/

		// (Arcy) Fail-safe for whoever is crazy enough to plug in a controller mid-song
		KeyBinds.gamepad = FlxG.gamepads.lastActive != null;

		if (PlayStateChangeables.botPlay && FlxG.keys.justPressed.ONE)
		{
			camHUD.visible = !camHUD.visible;
		}

		#if windows
		if (executeModchart && luaModchart != null && songStarted && !ending)
		{
			luaModchart.setVar('songPos', Conductor.songPosition);
			luaModchart.setVar('hudZoom', camHUD.zoom);
			luaModchart.setVar('curBeat', HelperFunctions.truncateFloat(curDecimalBeat,3));
			luaModchart.setVar('cameraZoom', FlxG.camera.zoom);
			luaModchart.executeState('update', [elapsed]);

			/*for (i in 0...strumLineNotes.length) {
				var member = strumLineNotes.members[i];
				member.x = luaModchart.getVar("strum" + i + "X", "float");
				member.y = luaModchart.getVar("strum" + i + "Y", "float");
				member.angle = luaModchart.getVar("strum" + i + "Angle", "float");
			}*/

			FlxG.camera.angle = luaModchart.getVar('cameraAngle', 'float');
			camHUD.angle = luaModchart.getVar('camHudAngle', 'float');

			if (luaModchart.getVar("showOnlyStrums", 'bool'))
			{
				healthBarBG.visible = false;
				kadeEngineWatermark.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
			}
			else
			{
				healthBarBG.visible = true;
				kadeEngineWatermark.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
			}

			// STOP CREATING MORE MEMORY WHEN IT ISN'T NEEDED
			// var p1 = luaModchart.getVar("strumLine1Visible",'bool');
			// var p2 = luaModchart.getVar("strumLine2Visible",'bool');

			for (i in 0...4)
			{
				strumLineNotes.members[i].visible = luaModchart.getVar("strumLine1Visible", 'bool');
				if (i <= playerStrums.length)
				{
					playerStrums.members[i].visible = luaModchart.getVar("strumLine2Visible", 'bool');
				}
			}

			camNotes.zoom = camHUD.zoom;
			camNotes.x = camHUD.x;
			camNotes.y = camHUD.y;
			camNotes.angle = camHUD.angle;
			camSustains.zoom = camHUD.zoom;
			camSustains.x = camHUD.x;
			camSustains.y = camHUD.y;
			camSustains.angle = camHUD.angle;
		}
		#end

		// reverse iterate to remove oldest notes first and not invalidate the iteration
		// stop iteration as soon as a note is not removed
		// all notes should be kept in the correct order and this is optimal, safe to do every frame/update
		{
			var balls = notesHitArray.length - 1;
			while (balls >= 0)
			{
				var cock:Date = notesHitArray[balls];
				if (cock != null && cock.getTime() + 1000 < Date.now().getTime())
				{
					notesHitArray.remove(cock);
				}
				else
				{
					break;
				}

				balls--;
			}
			nps = notesHitArray.length;
			if (nps > maxNPS)
			{
				maxNPS = nps;
			}
		}

		super.update(elapsed);

		// (tsg - 7/24/21) - small things lyric system port
		#if debug
		conductorPosTxt.text = "Conductor Pos (only shows in debug so dont scream at me): " + Conductor.songPosition;
		#end

		if (!FlxG.save.data.accuracyDisplay)
		{
			scoreTxt.text = "Score: " + songScore;
		}
		else
		{
			scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS, accuracy);
		}

		scoreTxt.screenCenter(X);

		if (controls.PAUSE && startedCountdown && canPause && !cannotDie)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			cannotDie = true;
			#if windows
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
			FlxG.switchState(new ChartingState());
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if windows
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));
		if (poisonIcon != null)
		{
			poisonIcon.setGraphicSize(Std.int(FlxMath.lerp(100, poisonIcon.width, 0.5)));
			poisonTxt.setGraphicSize(Std.int(FlxMath.lerp(20, poisonTxt.width, 0.5)));
			poisonIcon.updateHitbox();
			poisonTxt.updateHitbox();
		}

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		// iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		// iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		// (tsg - 7/24/21) small things lyric system port
		/*lyricTxt.x = (healthBar.getMidpoint().x - 100) - 70;
		lyricTxt.y = (FlxG.save.data.downscroll ? healthBar.getMidpoint().y + 175 : healthBar.getMidpoint().y - 175);

		lyricSpeakerIcon.x = lyricTxt.x + (lyricTxt.width / 2) - 64;
		lyricSpeakerIcon.y = lyricTxt.y - 112;

		var lyricFailMargin:Int = 120;

		if (hasLyrics == true)
		{
			for (i in lyrics)
			{
				if (FlxMath.inBounds(Conductor.songPosition, i.start, i.start + lyricFailMargin))
				{
					lyricTxt.text = i.lyric;
					lyricSpeakerIcon.animation.play(i.speaker);
					lyricSpeakerIcon.visible = true;
				}

				if (FlxMath.inBounds(Conductor.songPosition, i.end, i.end + lyricFailMargin))
				{
					lyricTxt.text = "";
					lyricSpeakerIcon.visible = false;
				}
			}
		}*/

		if (curSong == 'Satisfracture' && curStep >= 188 && curStep < 192 && enoughTxt != null)
		{
			enoughTxt.setPosition(FlxG.random.float(-15, 15) + enoughTxtOrigin.x, FlxG.random.float(-15, 15) + enoughTxtOrigin.y);
		}

		if (curSong == 'Spectral' || curSong == 'Ectospasm')
		{
			// Spectral Start cutscene
			if (transforming && !ending)
			{
				if (defaultCamZoom < 0.9
					&& cutsceneSprite.animation.curAnim.curFrame >= 0
					&& cutsceneSprite.animation.curAnim.curFrame < 24)
				{
					defaultCamZoom += 0.5 * elapsed;
				}
				else if (defaultCamZoom > 0.9
					&& cutsceneSprite.animation.curAnim.curFrame >= 0
					&& cutsceneSprite.animation.curAnim.curFrame < 24)
				{
					defaultCamZoom = 0.9;
				}
				else if (defaultCamZoom > 0.685
					&& cutsceneSprite.animation.curAnim.curFrame >= 43
					&& cutsceneSprite.animation.curAnim.curFrame < 72)
				{
					defaultCamZoom -= 0.5 * elapsed;
				}
				else if (defaultCamZoom < 0.685
					&& cutsceneSprite.animation.curAnim.curFrame >= 43
					&& cutsceneSprite.animation.curAnim.curFrame < 72)
				{
					defaultCamZoom = 0.685;
				}
				else if (cutsceneSprite.animation.curAnim.curFrame >= 77 && cutsceneSprite.animation.curAnim.curFrame < 105)
				{
					camFollow.setPosition(cutsceneSprite.getMidpoint().x + 150, cutsceneSprite.getMidpoint().y - 275);

					if (defaultCamZoom > 0.5)
					{
						defaultCamZoom -= 0.33 * elapsed;
					}
					else if (defaultCamZoom < 0.525)
					{
						defaultCamZoom = 0.525;
					}

					if (FlxG.save.data.screenShake)
					{
						camera.shake(0.025, 0.35);
					}
					if (FlxG.save.data.windowShake)
					{
						Application.current.window.x += (FlxG.random.int(0, 1) == 0 ? -1 : 1) * 3;
						Application.current.window.y += (FlxG.random.int(0, 1) == 0 ? -1 : 1) * 3;
					}

					if (FlxG.save.data.background > 1 && flames.alpha == 0.0000000001)
					{
						FlxTween.tween(flames, {y: flames.y - 1000, alpha: 1}, 0.5, {ease: FlxEase.cubeOut});
					}

					if (!roared)
					{
						roared = true;
						FlxG.sound.play(Paths.sound('roar'));
					}
				}

				if (FlxG.save.data.background > 0)
				{
					if (rocks.scale.x == 1
						&& cutsceneSprite.animation.curAnim.curFrame >= 43
						&& cutsceneSprite.animation.curAnim.curFrame < 72)
					{
						rocks.scale.x += .1;
						rocks.scale.y += .1;
						if (rocksGreen != null)
						{
							rocksGreen.scale.x += .1;
							rocksGreen.scale.y += .1;
						}
					}
				}

				if (cutsceneSprite.animation.curAnim.curFrame >= 58 && !slammed)
				{
					slammed = true;
					if (FlxG.save.data.screenShake)
					{
						camera.shake(0.075, 0.5);
					}
					if (FlxG.save.data.windowShake)
					{
						Application.current.window.y += 100;
					}

					FlxG.sound.play(Paths.sound('Fist slam'));

					if (FlxG.save.data.background > 0)
					{
						if (FlxG.save.data.background == 1)
						{
							cave.loadGraphic(Paths.image('wrath_runes', 'wrath'));
							cave.screenCenter();
							//cave.scale.x = .5425;
							//cave.scale.y = .5425;
							cave.scrollFactor.set(0.8, 0.8);
							cave.x += -317;
							cave.y += -47;

							cave2.loadGraphic(Paths.image('wrath_runes2', 'wrath'));
							cave2.scale.set(1, 1);
							cave2.screenCenter();
							//cave2.scale.x = .645;
							//cave2.scale.y = .645;
							cave2.scrollFactor.set(0.8, 0.8);
							cave2.x += 160;
							cave2.y += -103;
						}

						crack.animation.play('appear');

						if (FlxG.save.data.background > 1)
						{
							cave.animation.play('glow', true);
							cave2.animation.play('glow', true);

							if (FlxG.save.data.flashing)
							{
								bgFlash.visible = true;
								FlxTween.tween(bgFlash, {alpha: 0}, 1);
							}
							FlxTween.tween(vortex, {alpha: 1}, 0.15);

							crystals.visible = true;
							for (i in 0...crystals.length)
							{
								FlxTween.tween(crystals.members[i], {y: crystals.members[i].y - 1500}, FlxG.random.float(0.5, 2.5));
							}
						}
					}

					if (characterLogo.animation.curAnim == null)
					{
						characterLogo.animation.play('logo');
						characterLogo.alpha = 1;
					}
				}
			}
			// Spectral End cutscene
			else if (transforming && ending && !PlayStateChangeables.Optimize)
			{
				// Check if slam has occurred yet past animation frame 12 on the first sprite animation
				if (!slammed &&
						(endCutsceneAnimation.currentAnimationIndex > 0 ||
							(endCutsceneAnimation.currentAnimationIndex == 0 && endCutsceneAnimation.currentAnimatingSprite.animation.curAnim.curFrame >= 29)))
				{
					slammed = true;

					if (FlxG.save.data.screenShake)
					{
						camera.shake(0.05, 0.5);
					}
					if (FlxG.save.data.windowShake)
					{
						Application.current.window.y += 50;
					}

					FlxG.sound.play(Paths.sound('AngySlam'));
				}
				else if (slammed && debris == 0)
				{
					debris++;
					FlxG.sound.play(Paths.sound('Debris1'));
				}

				// Check if fire has occurred yet past second sprite animation
				if (!onFire &&
						endCutsceneAnimation.currentAnimationIndex >= 1)
				{
					onFire = true;
					FlxG.sound.play(Paths.sound('fire'));
				}

				// Check if explosion has occurred yet past animation frame 6 on the third sprite animation
				if (!exploded &&
						(endCutsceneAnimation.currentAnimationIndex > 3 ||
							(endCutsceneAnimation.currentAnimationIndex == 3 && endCutsceneAnimation.currentAnimatingSprite.animation.curAnim.curFrame >= 6)))
				{
					exploded = true;
					FlxG.sound.play(Paths.sound('FireBoom'));
				}
				else if (exploded && debris == 1)
				{
					debris++;
					FlxG.sound.play(Paths.sound('Debris2'));
					FlxG.sound.play(Paths.sound('FireRoar'));
				}

				// Final screen shake until cut out
				if (FlxG.save.data.screenShake && endCutsceneAnimation.currentAnimationIndex >= 5)
				{
					shakeIntensity += elapsed * 0.025;
					camera.shake(shakeIntensity, 0.1);
				}
			}

			// Health bar shake
			if (health <= 0.01)
			{
				healthBar.setPosition(FlxG.random.float(-5, 5) + healthBarOrigin.x, FlxG.random.float(-5, 5) + healthBarOrigin.y);
				iconP1.setPosition(healthBar.x + (healthBar.width * (1 - (health / 2)) - iconOffset), healthBar.y - 60);
				iconP2.setPosition(healthBar.x + (healthBar.width * (1 - (health / 2)) - (150 - iconOffset)), healthBar.y - 60);
				poisonIcon.setPosition(iconP1.x + 75, healthBar.y + (FlxG.save.data.downscroll ? 25 : -75) + (bfCharacter == 'bf-ace' && !FlxG.save.data.downscroll ? -10 : 0));
				poisonTxt.setPosition(iconP1.x + 115, poisonIcon.y + 20);
			}
			else if (healthBar.x != healthBarOrigin.x || healthBar.y != healthBarOrigin.y)
			{
				healthBar.setPosition(healthBarOrigin.x, healthBarOrigin.y);
				iconP1.setPosition(healthBar.x + (healthBar.width * (1 - (health / 2)) - iconOffset), healthBar.y - 60);
				iconP2.setPosition(healthBar.x + (healthBar.width * (1 - (health / 2)) - (150 - iconOffset)), healthBar.y - 60);
				poisonIcon.setPosition(iconP1.x + 75, healthBar.y + (FlxG.save.data.downscroll ? 25 : -75) + (bfCharacter == 'bf-ace' && !FlxG.save.data.downscroll ? -10 : 0));
				poisonTxt.setPosition(iconP1.x + 115, poisonIcon.y + 20);
			}

			// Window shake stuff
			if (!PlayStateChangeables.Optimize)
			{
				if (FlxG.save.data.windowShake
					&& (Application.current.window.x != windowOrigin.x || Application.current.window.y != windowOrigin.y))
				{
					if (Application.current.window.x < windowOrigin.x)
					{
						Application.current.window.x++;
					}
					else
					{
						Application.current.window.x--;
					}
					if (Application.current.window.y < windowOrigin.y)
					{
						Application.current.window.y++;
					}
					else
					{
						Application.current.window.y--;
					}
				}

				// Crystal floating movement
				if (!inCutscene && FlxG.save.data.background > 1)
				{
					for (i in 0...crystals.length)
					{
						crystals.members[i].y += 50 * Math.sin((Conductor.songPosition / 1000) + crystalFloatData[i].y) * elapsed;

						// Fancy moving effect during hardcore part of the song
						if (FlxG.save.data.motion && curStep >= 1536 /*&& curStep < 1857*/)
						{
							crystals.members[i].x -= crystalFloatData[i].x * elapsed;

							// Wrap around the screen
							if (crystals.members[i].x <= -1000)
							{
								crystals.members[i].x = 2500;
							}
						}
						// Set position back
						/*else if (curStep >= 1857 && crystals.members[i].x != crystalPos[i].x)
							crystals.members[i].x = crystalPos[i].x; */
					}
				}

				// Chromatic Aberration effect
				if (FlxG.save.data.chrom)
				{
					if (chrom.rOffset.value[1] > 0)
					{
						chrom.rOffset.value[1] -= 0.01 * elapsed;
					}
					else if (chrom.rOffset.value[1] < 0)
					{
						chrom.rOffset.value[1] = 0;
					}

					if (chrom.gOffset.value[0] < 0)
					{
						chrom.gOffset.value[0] += 0.01 * elapsed;
					}
					else if (chrom.gOffset.value[0] > 0)
					{
						chrom.gOffset.value[0] = 0;
					}

					if (chrom.gOffset.value[1] < 0)
					{
						chrom.gOffset.value[1] += 0.01 * elapsed;
					}
					else if (chrom.gOffset.value[1] > 0)
					{
						chrom.gOffset.value[1] = 0;
					}

					if (chrom.bOffset.value[0] > 0)
					{
						chrom.bOffset.value[0] -= 0.01 * elapsed;
					}
					else if (chrom.bOffset.value[0] < 0)
					{
						chrom.bOffset.value[0] = 0;
					}

					if (chrom.bOffset.value[1] < 0)
					{
						chrom.bOffset.value[1] += 0.01 * elapsed;
					}
					else if (chrom.bOffset.value[1] > 0)
					{
						chrom.bOffset.value[1] = 0;
					}
				}
			}

			/// Retro Poison Mechanic
			// Drain health, but don't kill player
			if (health > 0.01)
			{
				if (healthDrainPoison * poisonStacks * elapsed > health)
				{
					health = 0.01;
				}
				else
				{
					health -= healthDrainPoison * poisonStacks * elapsed; // Gotta make it fair with different framerates :)
				}

				updateHealthGraphics();
			}

			// Spectre Mechanic
			if (curSong == 'Ectospasm')
			{
				if (!spectreHit)
				{
					if (noteFadeTime * elapsed > noteOpacity)
					{
						noteOpacity = 0;
					}
					else
					{
						noteOpacity -= noteFadeTime * elapsed;
					}
				}
				else
				{
					if (noteOpacity > 1)
					{
						noteOpacity = 1;
						spectreHit = false;
					}
					else
					{
						noteOpacity += elapsed;
					}
				}
			}
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;

				if (Conductor.songPosition >= 0)
				{
					startSong();
				}
			}
		}
		else if (!ending)
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;
			/*@:privateAccess
				{
					FlxG.sound.music._channel.
			}*/
			songPositionBar = Conductor.songPosition;

			if (!paused)
			{
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !ending && !inCutscene)
		{
			closestNotes = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
					closestNotes.push(daNote);
			}); // Collect notes that can be hit

			closestNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

			#if windows
			if (luaModchart != null)
			{
				luaModchart.setVar("mustHit", PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}
			#end

			if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				var offsetX = 0;
				var offsetY = 0;
				#if windows
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				if (camZooming)
				{
					if (dad.curCharacter == 'retro2-wrath')
					{
						camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 300 + offsetY);
					}
					else
					{
						camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);
					}
				}
				#if windows
				if (luaModchart != null)
				{
					luaModchart.executeState('playerTwoTurn', []);
				}
				#end
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);
			}
			else if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				var offsetX = 0;
				var offsetY = 0;
				#if windows
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				if (camZooming)
				{
					if (dad.curCharacter == 'retro2-wrath')
					{
						camFollow.setPosition(boyfriend.getMidpoint().x - 100 + offsetX, boyfriend.getMidpoint().y - 200 + offsetY);
					}
					else
					{
						camFollow.setPosition(boyfriend.getMidpoint().x - 100 + offsetX, boyfriend.getMidpoint().y - 100 + offsetY);
					}
				}

				#if windows
				if (luaModchart != null)
				{
					luaModchart.executeState('playerOneTurn', []);
				}
				#end
			}
		}

		if (camZooming)
		{
			if (FlxG.save.data.zoom < 0.8)
				FlxG.save.data.zoom = 0.8;

			if (FlxG.save.data.zoom > 1.2)
				FlxG.save.data.zoom = 1.2;

			if (!executeModchart)
			{
				FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
				camHUD.zoom = FlxMath.lerp(FlxG.save.data.zoom, camHUD.zoom, 0.95);

				camNotes.zoom = camHUD.zoom;
				camSustains.zoom = camHUD.zoom;
			}
			else
			{
				FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
				camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);

				camNotes.zoom = camHUD.zoom;
				camSustains.zoom = camHUD.zoom;
			}
		}

		if (health <= 0 && !cannotDie)
		{
			if (storyMode == 1)
			{
				health = 0.01; // Don't kill
			}
			else if (!usedTimeTravel)
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;
				/// Retro poison mechanic
				// Reset poison stacks on death
				poisonStacks = 0;

				camHUD.angle = 0;
				camHUD.zoom = 1;

				vocals.stop();
				FlxG.sound.music.stop();

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if windows
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("GAME OVER -- "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC);
				#end

				// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
			else
			{
				health = 1;
			}

		}
		if (!inCutscene && FlxG.save.data.resetButton)
		{
			if (FlxG.keys.justPressed.R)
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				camHUD.angle = 0;
				camHUD.zoom = 1;

				vocals.stop();
				FlxG.sound.music.stop();

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if windows
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("GAME OVER -- "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC);
				#end

				// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
		}

		if (unspawnNotes[0] != null && generatedMusic)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);
				if (executeModchart)
				{
					dunceNote.cameras = [camHUD];
					// I don't know if this affects anything but it seems like it doesn't?
					/*if (!dunceNote.isSustainNote)
						dunceNote.cameras = [camNotes];
					else
						dunceNote.cameras = [camSustains];*/
				}
				else
				{
					dunceNote.cameras = [camHUD];
				}
				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic && !inCutscene)
		{
			var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];

			notes.forEachAlive(function(daNote:Note)
			{
				// instead of doing stupid y > FlxG.height
				// we be men and actually calculate the time :)
				if (daNote.tooLate)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				if (!daNote.modifiedByLua)
				{
					if (PlayStateChangeables.useDownscroll)
					{
						if (daNote.mustPress)
						{
							// Change opacity in Ectospasm
							if (curSong == 'Ectospasm' && daNote.noteType != NoteType.Spectre)
							{
								daNote.alpha = noteOpacity;
							}

							// Special effect for Satisfracture song
							if (!(curSong == 'Satisfracture' && curStep >= 187 && curStep <= 192))
							{
								daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
									+ 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
										2)) - daNote.noteYOff;
							}
						}
						else
						{
							if (curSong == 'Ectospasm' && !enemySpectreHit)
							{
								daNote.alpha = noteOpacity;
							}
							else if (daNote.alpha == noteOpacity)
							{
								FlxTween.tween(daNote, {alpha: 1}, 0.5);
							}

							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								+ 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)) - daNote.noteYOff;
						}

						// Spectre note offset
						if (daNote.noteType == NoteType.Spectre)
						{
							daNote.y -= daNote.height / 2;
						}

						if (daNote.isSustainNote)
						{
							// Remember = minus makes notes go up, plus makes them go down
							if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
								daNote.y += daNote.prevNote.height;
							else
								daNote.y += daNote.height / 2;

							// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
							if (!PlayStateChangeables.botPlay)
							{
								if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit || holdArray[Math.floor(Math.abs(daNote.noteData))] && !daNote.tooLate)
									&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth / 2))
								{
									// Clip to strumline
									var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
									swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
										+ Note.swagWidth / 2
										- daNote.y) / daNote.scale.y;
									swagRect.y = daNote.frameHeight - swagRect.height;

									daNote.clipRect = swagRect;
								}
							}
							else
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
								swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
							}
						}
					}
					else
					{
						if (daNote.mustPress)
						{
							// Change opacity in Ectospasm
							if (daNote.noteType != NoteType.Spectre)
							{
								daNote.alpha = noteOpacity;
							}

							// Special effect for Satisfracture song
							if (!(curSong == 'Satisfracture' && curStep >= 187 && curStep <= 192))
							{
								daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
									- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
										2)) + daNote.noteYOff;
							}
						}

						else
						{
							if (curSong == 'Ectospasm' && !enemySpectreHit)
							{
								daNote.alpha = noteOpacity;
							}
							else
							{
								FlxTween.tween(daNote, {alpha: 1}, 0.5);
							}

							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2)) + daNote.noteYOff;
						}
						if (daNote.isSustainNote)
						{
							daNote.y -= daNote.height / 2;

							if (!PlayStateChangeables.botPlay)
							{
								if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit || holdArray[Math.floor(Math.abs(daNote.noteData))] && !daNote.tooLate)
									&& daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
								{
									// Clip to strumline
									var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
									swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
										+ Note.swagWidth / 2
										- daNote.y) / daNote.scale.y;
									swagRect.height -= swagRect.y;

									daNote.clipRect = swagRect;
								}
							}
							else
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

					if (curSong == 'Spectral' || curSong == 'Ectospasm')
					{
						// (Arcy) Shake the screen and window whenever Retro sings
						if (FlxG.save.data.screenShake)
						{
							camera.shake(0.015, 0.05);
						}
						if (FlxG.save.data.windowShake)
						{
							Application.current.window.x += (FlxG.random.int(0, 1) == 0 ? -1 : 1) * (curSong == 'Spectral' ? 3 : 5);
							Application.current.window.y += (FlxG.random.int(0, 1) == 0 ? -1 : 1) * (curSong == 'Spectral' ? 3 : 5);
						}

						// (Arcy) We're gonna make the sprite trails ourselves
						if (FlxG.save.data.ghostTrails && !daNote.isSustainNote)
						{
							var trail:GhostSprite = GhostSprite.createGhostSprite(dad, 0.25, 0.33);
							spriteTrail.add(trail);
						}
					}

					// Accessing the animation name directly to play it
					if (!daNote.isParent && daNote.parent != null)
					{
						if (daNote.spotInLine != daNote.parent.children.length - 1)
						{
							//var singData:Int = Std.int(Math.abs(daNote.noteData));
							//dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);

							switch (Math.abs(daNote.noteData))
							{
								case 2:
									{
										if (daNote.isSustainNote && dad.animation.name == 'idle')
										{
											dad.playAnim('singUP' + altAnim);
										}
									}
								case 3:
									{
										if (daNote.isSustainNote && dad.animation.name == 'idle')
										{
											dad.playAnim('singRIGHT' + altAnim);
										}

										if ((curSong == 'Spectral' || curSong == 'Ectospasm') && gf.curCharacter == 'gf-wrath' && gf.animation.name.startsWith('dance'))
										{
											gf.playAnim('hair' + gf.animation.name.substr(5), true, false, gf.animation.frameIndex);
										}
									}
								case 1:
									{
										if (daNote.isSustainNote && dad.animation.name == 'idle')
										{
											dad.playAnim('singDOWN' + altAnim);
										}
									}
								case 0:
									{
										if (daNote.isSustainNote && dad.animation.name == 'idle')
										{
											dad.playAnim('singLEFT' + altAnim);
										}
									}
							}

							if (FlxG.save.data.cpuStrums)
							{
								cpuStrums.forEach(function(spr:FlxSprite)
								{
									if (Math.abs(daNote.noteData) == spr.ID)
									{
										spr.animation.play('confirm', true);
									}
									if (spr.animation.curAnim.name == 'confirm')
									{
										spr.centerOffsets();
										spr.offset.x -= 13;
										spr.offset.y -= 13;
									}
									else
										spr.centerOffsets();
								});
							}

							#if windows
							if (luaModchart != null)
								luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
							#end

							dad.holdTimer = 0;

							if (SONG.needsVoices)
								vocals.volume = 1;
						}
					}
					else
					{
						var singData:Int = Std.int(Math.abs(daNote.noteData));
						dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);

						// Make it so Retro's notes remain visible afterwards
						if (curSong == 'Ectospasm' && daNote.noteType == NoteType.Spectre)
						{
							spectreSound.play(true);
							enemySpectreHit = true;

							enemySpectreNoteHit.x = daNote.x - daNote.width - 9;
							enemySpectreNoteHit.y = daNote.y - (daNote.height / 2) - 20;
							enemySpectreNoteHit.angle = daNote.angle;
							enemySpectreNoteHit.animation.play('break', true);
							enemySpectreNoteHit.visible = true;
							enemySpectreNoteHit.animation.finishCallback = function(str:String)
							{
								enemySpectreNoteHit.visible = false;
							};
						}

						if (FlxG.save.data.cpuStrums)
						{
							cpuStrums.forEach(function(spr:FlxSprite)
							{
								if (Math.abs(daNote.noteData) == spr.ID)
								{
									spr.animation.play('confirm', true);
								}
								if (spr.animation.curAnim.name == 'confirm')
								{
									spr.centerOffsets();
									spr.offset.x -= 13;
									spr.offset.y -= 13;
								}
								else
									spr.centerOffsets();
							});
						}

						#if windows
						if (luaModchart != null)
							luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
						#end

						dad.holdTimer = 0;

						if (SONG.needsVoices)
							vocals.volume = 1;
					}
					daNote.active = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				if (daNote.mustPress && !daNote.modifiedByLua)
				{
					daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x + daNote.noteXOffset;
					if (!daNote.isSustainNote)
						daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
					if (daNote.sustainActive && curSong != 'Ectospasm')
						daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
				}
				else if (!daNote.wasGoodHit && !daNote.modifiedByLua)
				{
					daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x + daNote.noteXOffset;
					if (!daNote.isSustainNote)
						daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
					if (daNote.sustainActive && curSong != 'Ectospasm') // Override alpha
						daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
					daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
				}

				if (daNote.isSustainNote)
				{
					daNote.x += daNote.width / 2 + 20;
				}

				// trace(daNote.y);
				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if (daNote.isSustainNote && daNote.wasGoodHit && Conductor.songPosition >= daNote.strumTime)
				{
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
				else if ((daNote.mustPress && daNote.tooLate && !PlayStateChangeables.useDownscroll || daNote.mustPress && daNote.tooLate
					&& PlayStateChangeables.useDownscroll)
					&& daNote.mustPress)
				{
					// Prevent note miss for cool effect for cool song
					if (!(curSong == 'Satisfracture' && curStep >= 187 && curStep <= 192))
					{
						if (daNote.isSustainNote && daNote.wasGoodHit)
							{
								daNote.kill();
								notes.remove(daNote, true);
							}
							// Don't punish player for "fake notes"
							else if (!(curSong == 'Satisfracture' && curStep > 192 && curStep <= 220) && daNote.noteType == NoteType.Normal)
							{
								if (loadRep && daNote.isSustainNote)
								{
									// im tired and lazy this sucks I know i'm dumb
									if (findByTime(daNote.strumTime) != null)
										totalNotesHit += 1;
									else
									{
										if (!daNote.isSustainNote)
										{
											health -= 0.10;
											updateHealthGraphics();
											vocals.volume = 0;
										}
										if (!daNote.isSustainNote)
											noteMiss(daNote.noteData, daNote);
										if (daNote.isParent)
										{
											health -= 0.15; // give a health punishment for failing a LN
											updateHealthGraphics();
											for (i in daNote.children)
											{
												i.alpha = 0.3;
												i.sustainActive = false;
											}
										}
										else
										{
											if (!daNote.wasGoodHit
												&& daNote.isSustainNote
												&& daNote.sustainActive
												&& daNote.spotInLine != daNote.parent.children.length)
											{
												health -= 0.15; // give a health punishment for failing a LN
												updateHealthGraphics();
												for (i in daNote.parent.children)
												{
													i.alpha = 0.3;
													i.sustainActive = false;
												}
												if (daNote.parent.wasGoodHit)
													misses++;
												updateAccuracy();
											}
										}
									}
								}
								else
								{
									if (!daNote.isSustainNote)
									{
										health -= 0.10;
										updateHealthGraphics();
										vocals.volume = 0;
									}
									if (!daNote.isSustainNote)
										noteMiss(daNote.noteData, daNote);

									if (daNote.isParent)
									{
										health -= 0.15; // give a health punishment for failing a LN
										updateHealthGraphics();
										for (i in daNote.children)
										{
											i.alpha = 0.3;
											i.sustainActive = false;
										}
									}
									else
									{
										if (!daNote.wasGoodHit
											&& daNote.isSustainNote
											&& daNote.sustainActive
											&& daNote.spotInLine != daNote.parent.children.length)
										{
											health -= 0.20; // give a health punishment for failing a LN
											updateHealthGraphics();
											for (i in daNote.parent.children)
											{
												i.alpha = 0.3;
												i.sustainActive = false;
											}
											if (daNote.parent.wasGoodHit)
												misses++;
											updateAccuracy();
										}
									}
								}
							}

							missTime = 0; // Reset time since last miss
							daNote.visible = false;
							daNote.kill();
							notes.remove(daNote, true);
						}
					}
			});
		}

		if (FlxG.save.data.cpuStrums)
		{
			cpuStrums.forEach(function(spr:FlxSprite)
			{
				if (spr.animation.finished)
				{
					spr.animation.play('static');
					spr.centerOffsets();
				}
			});
			if (PlayStateChangeables.botPlay)
			{
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (spr.animation.finished)
					{
						spr.animation.play('static');
						spr.centerOffsets();
					}
				});
			}
		}

		if (!inCutscene && songStarted)
			keyShit();

		// Special case for optimized mode
		if (vocals.volume == 0 && PlayStateChangeables.Optimize)
		{
			missTime += elapsed;
			if (missTime > 1)
				vocals.volume = 1;
		}
	}

	function endSong():Void
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);

		if (!loadRep)
			rep.SaveReplay(saveNotes, saveJudge, replayAna);
		else
		{
			PlayStateChangeables.botPlay = false;
			PlayStateChangeables.scrollSpeed = 1;
			PlayStateChangeables.useDownscroll = false;
		}

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);

		#if windows
		if (luaModchart != null)
		{
			luaModchart.die();
			luaModchart = null;
		}
		#end

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		FlxG.sound.music.pause();
		vocals.pause();

		if (SONG.validScore)
		{
			// adjusting the highscore song name to be compatible
			// would read original scores if we didn't change packages
			var songHighscore = StringTools.replace(PlayState.SONG.song, " ", "-");

			#if !switch
			Highscore.saveScore(songHighscore, Math.round(songScore), storyDifficulty);
			Highscore.saveCombo(songHighscore, Ratings.GenerateLetterRank(accuracy), storyDifficulty);
			#end
		}

		if (!PlayStateChangeables.botPlay)
		{
			if (sakuUnlocked && !FreeplayState.songUnlocked[4])
			{
				// Don't do this hard coding either
				FreeplayState.songUnlocked[4] = true;

				FlxG.save.data.songUnlocked = FreeplayState.songUnlocked;

				FlxG.save.flush();

				FreeplayState.justUnlocked.push("saku-secret");
			}
			else if (curSong == 'Ectospasm')
			{
				FreeplayState.songVisible[4] = true;
				FlxG.save.data.songVisible = FreeplayState.songVisible;
				FlxG.save.flush();
			}
		}

		if (isStoryMode)
		{
			campaignScore += Math.round(songScore);
			campaignMisses += misses;
			campaignSicks += sicks;
			campaignGoods += goods;
			campaignBads += bads;
			campaignShits += shits;

			storyPlaylist.remove(storyPlaylist[0]);

			// Song unlocks for Freeplay
			var initSonglist = CoolUtil.coolTextFile(Paths.txt('data/freeplaySonglist'));
			// Absolutely horrible way to do this. Store this in a Singleton later on
			for (i in 0...initSonglist.length)
			{
				if (initSonglist[i].split(':')[0].toLowerCase() == SONG.song.toLowerCase())
				{
					FreeplayState.songUnlocked[i] = true;
					break;
				}
			}

			FlxG.save.data.songUnlocked = FreeplayState.songUnlocked;

			if (!PlayStateChangeables.botPlay)
			{
				// (Arcy) No Fail mode and Freestyle mode unlocks
				if (!StoryMenuState.modeUnlocked[1])
				{
					StoryMenuState.modeUnlocked[1] = true;
					FlxG.save.data.modeUnlocked = StoryMenuState.modeUnlocked;

					StoryMenuState.unlockedModes.push('nofail');
				}
				if (!StoryMenuState.modeUnlocked[2])
				{
					StoryMenuState.modeUnlocked[2] = true;
					FlxG.save.data.modeUnlocked = StoryMenuState.modeUnlocked;

					StoryMenuState.unlockedModes.push('freestyle');
				}

				FlxG.save.flush();
			}

			if (storyPlaylist.length <= 0)
			{
				if (!PlayStateChangeables.botPlay)
				{
					// (Arcy) Randomized mode unlocks
					if (!StoryMenuState.modeUnlocked[3])
					{
						StoryMenuState.modeUnlocked[3] = true;
						FlxG.save.data.modeUnlocked = StoryMenuState.modeUnlocked;
						StoryMenuState.unlockedModes.push('randomized');
					}
					// (Arcy) Song unlock
					if (!FreeplayState.songUnlocked[3])
					{
						FreeplayState.songUnlocked[3] = true;
						FlxG.save.data.songUnlocked = FreeplayState.songUnlocked;
						StoryMenuState.unlockedSongs.push('Ectospasm');
					}
					// (Arcy) Retro bf character unlock
					// (Carbon) Ace bf character unlock
					if (storyWeek == 0 && (!StoryMenuState.characterUnlocked[1] || !StoryMenuState.characterUnlocked[2]))
					{
						StoryMenuState.characterUnlocked[1] = true; // Retro
						StoryMenuState.characterUnlocked[2] = true; // Ace
						FlxG.save.data.characterUnlocked = StoryMenuState.characterUnlocked;
						StoryMenuState.unlockedChars.push('bf-retro');
						StoryMenuState.unlockedChars.push('bf-ace');
					}
					if (SONG.validScore)
					{
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
					}
				}
				else
				{
					FreeplayState.songVisible[3] = true;
					FlxG.save.data.songVisible = FreeplayState.songVisible;
					FlxG.save.flush();
				}

				FlxG.save.flush();

				if (FlxG.save.data.scoreScreen)
				{
					openSubState(new ResultsScreen());
					new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							inResults = true;
						});
				}
				else
				{
					FlxG.switchState(new StoryMenuState());
				}
			}
			else
			{
				firstTry = true;
				FlxTween.tween(camHUD, {alpha: 0}, 1, {
					onComplete: function(flx:FlxTween)
					{
						var poop:String = Highscore.formatSong(storyPlaylist[0].toLowerCase().replace(' ','-'), storyDifficulty);

						FlxTransitionableState.skipNextTransIn = true;
						FlxTransitionableState.skipNextTransOut = true;
						prevCamFollow = camFollow;

						PlayState.SONG = Song.loadFromJson(poop, PlayState.storyPlaylist[0]);
						FlxG.sound.music.stop();

						LoadingState.loadAndSwitchState(new PlayState());
					}
				});
			}
		}
		else
		{
			paused = true;

			FlxG.sound.music.stop();
			vocals.stop();

			if (!StoryMenuState.girlfriendUnlocked[1] && curSong == "Fuzzy Feeling")
			{
				StoryMenuState.girlfriendUnlocked[1] = true;

				FlxG.save.data.girlfriendUnlocked = StoryMenuState.girlfriendUnlocked;
				FlxG.save.flush();
				FreeplayState.justUnlocked.push('gf-saku');
			}

			if (curSong == "Fuzzy Feeling")
			{
				var doof:DialogueBox = new DialogueBox('end-saku', bfCharacter, storyDifficulty, gf.curCharacter);
				doof.cameras = [camHUD];
				doof.finishThing = function()
				{
					if (FlxG.save.data.scoreScreen)
					{
						openSubState(new ResultsScreen());
						new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								inResults = true;
							});
					}
					else
					{
						FlxG.switchState(new FreeplayState());
					}
				};

				startDialogue(doof);
			}
			else if (FlxG.save.data.scoreScreen)
			{
				openSubState(new ResultsScreen());
				new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						inResults = true;
					});
			}
			else
			{
				FlxG.switchState(new FreeplayState());
			}
		}
	}

	var timeShown = 0;
	var currentTimingShown:FlxText = null;

	private function popUpScore(daNote:Note):Void
	{
		var noteDiff:Float = -(daNote.strumTime - Conductor.songPosition);
		var wife:Float = EtternaFunctions.wife3(-noteDiff, Conductor.timeScale);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;
		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		coolText.y -= 350;
		coolText.cameras = [camHUD];

		var rating:FlxSprite = new FlxSprite();
		var score:Float = 350;

		if (FlxG.save.data.accuracyMod == 1)
			totalNotesHit += wife;

		var daRating = daNote.rating;

		switch (daRating)
		{
			case 'shit':
				score = -300;
				combo = 0;
				misses++;
				health -= 0.15;
				ss = false;
				shits++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit -= 1;
			case 'bad':
				daRating = 'bad';
				score = 0;
				health -= 0.08;
				ss = false;
				bads++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 0.50;
			case 'good':
				daRating = 'good';
				score = 200;
				ss = false;
				goods++;
				if (health < 2)
					health += 0.04;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 0.75;
			case 'sick':
				if (health < 2)
					health += 0.08;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 1;
				sicks++;
		}

		updateHealthGraphics();

		// trace('Wife accuracy loss: ' + wife + ' | Rating: ' + daRating + ' | Score: ' + score + ' | Weight: ' + (1 - wife));

		songScore += Math.round(score);
		songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
			*/

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		//rating.screenCenter();
		rating.y = healthBar.y + (PlayStateChangeables.useDownscroll ? 0 : -100);
		rating.x = healthBar.x - 250;

		if (FlxG.save.data.changedHit)
		{
			rating.x = FlxG.save.data.changedHitX;
			rating.y = FlxG.save.data.changedHitY;
		}
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var msTiming = HelperFunctions.truncateFloat(noteDiff, 3);
		if (PlayStateChangeables.botPlay && !loadRep)
			msTiming = 0;

		if (loadRep)
			msTiming = HelperFunctions.truncateFloat(findByTime(daNote.strumTime)[3], 3);

		if (currentTimingShown != null)
		{
			remove(currentTimingShown);
		}

		currentTimingShown = new FlxText(0, 0, 0, "0ms");
		timeShown = 0;
		switch (daRating)
		{
			case 'shit' | 'bad':
				currentTimingShown.color = FlxColor.RED;
			case 'good':
				currentTimingShown.color = FlxColor.GREEN;
			case 'sick':
				currentTimingShown.color = FlxColor.CYAN;
		}
		currentTimingShown.borderStyle = OUTLINE;
		currentTimingShown.borderSize = 1;
		currentTimingShown.borderColor = FlxColor.BLACK;
		currentTimingShown.text = msTiming + "ms";
		currentTimingShown.size = 20;

		if (currentTimingShown.alpha != 1)
		{
			currentTimingShown.alpha = 1;
		}

		if (!PlayStateChangeables.botPlay || loadRep)
			add(currentTimingShown);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = rating.x;
		comboSpr.y = rating.y + 100;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		currentTimingShown.screenCenter();
		currentTimingShown.x = comboSpr.x + 100;
		currentTimingShown.y = rating.y + 100;
		currentTimingShown.acceleration.y = 600;
		currentTimingShown.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		currentTimingShown.velocity.x += comboSpr.velocity.x;
		if (!PlayStateChangeables.botPlay || loadRep)
		{
			add(rating);
		}

		rating.setGraphicSize(Std.int(rating.width * 0.7));
		rating.antialiasing = FlxG.save.data.antialiasing;
		comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
		comboSpr.antialiasing = FlxG.save.data.antialiasing;

		currentTimingShown.updateHitbox();
		comboSpr.updateHitbox();
		rating.updateHitbox();

		currentTimingShown.cameras = [camHUD];
		comboSpr.cameras = [camHUD];
		rating.cameras = [camHUD];

		var seperatedScore:Array<Int> = [];

		var comboSplit:Array<String> = (combo + "").split('');

		if (combo > highestCombo)
			highestCombo = combo;

		// make sure we have 3 digits to display (looks weird otherwise lol)
		if (comboSplit.length == 1)
		{
			seperatedScore.push(0);
			seperatedScore.push(0);
		}
		else if (comboSplit.length == 2)
		{
			seperatedScore.push(0);
		}

		for (i in 0...comboSplit.length)
		{
			var str:String = comboSplit[i];
			seperatedScore.push(Std.parseInt(str));
		}

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = rating.x + (43 * daLoop) - 50;
			numScore.y = rating.y + 100;
			numScore.cameras = [camHUD];

			numScore.antialiasing = FlxG.save.data.antialiasing;
			numScore.setGraphicSize(Std.int(numScore.width * 0.5));

			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001,
			onUpdate: function(tween:FlxTween)
			{
				if (currentTimingShown != null)
					currentTimingShown.alpha -= 0.02;
				timeShown++;
			}
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();
				if (currentTimingShown != null && timeShown >= 20)
				{
					remove(currentTimingShown);
					currentTimingShown = null;
				}
				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});
	}

	// THIS FUNCTION JUST FUCKS WIT HELD NOTES AND BOTPLAY/REPLAY (also gamepad shit)

	private function keyShit():Void // I've invested in emma stocks
	{
		// control arrays, order L D R U
		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
		var releaseArray:Array<Bool> = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];
		var keynameArray:Array<String> = ['left', 'down', 'up', 'right'];
		#if windows
		if (luaModchart != null)
		{
			for (i in 0...pressArray.length) {
				if (pressArray[i] == true) {
				luaModchart.executeState('keyPressed', [keynameArray[i]]);
				}
			};

			for (i in 0...releaseArray.length) {
				if (releaseArray[i] == true) {
				luaModchart.executeState('keyReleased', [keynameArray[i]]);
				}
			};

		};
		#end

		// Prevent player input if botplay is on
		if (PlayStateChangeables.botPlay)
		{
			holdArray = [false, false, false, false];
			pressArray = [false, false, false, false];
			releaseArray = [false, false, false, false];
		}

		var anas:Array<Ana> = [null, null, null, null];

		for (i in 0...pressArray.length)
			if (pressArray[i])
				anas[i] = new Ana(Conductor.songPosition, null, false, "miss", i);

		// HOLDS, check for sustain notes
		if (holdArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && (holdArray[daNote.noteData] || storyMode == 2) && daNote.sustainActive)
				{
					goodNoteHit(daNote);
				}
			});
		}

		if ((KeyBinds.gamepad && !FlxG.keys.justPressed.ANY))
		{
			// PRESSES, check for note hits
			if (pressArray.contains(true) && generatedMusic)
			{
				boyfriend.holdTimer = 0;

				var possibleNotes:Array<Note> = []; // notes that can be hit
				var directionList:Array<Int> = []; // directions that can be hit
				var dumbNotes:Array<Note> = []; // notes to kill later

				notes.forEachAlive(function(daNote:Note)
				{
					if (!(curSong == 'Satisfracture' && curStep >= 187 && curStep <= 192) &&
						daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
					{
						if (directionList.contains(daNote.noteData))
						{
							for (coolNote in possibleNotes)
							{
								if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
								{ // if it's the same note twice at < 10ms distance, just delete it
									// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
									dumbNotes.push(daNote);
									break;
								}
								else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
								{ // if daNote is earlier than existing note (coolNote), replace
									possibleNotes.remove(coolNote);
									possibleNotes.push(daNote);
									break;
								}
							}
						}
						else
						{
							possibleNotes.push(daNote);
							directionList.push(daNote.noteData);
						}
					}
				});

				for (note in dumbNotes)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}

				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				var hit = [false,false,false,false];

				if (possibleNotes.length > 0)
				{
					var presses:Int = 0;
					if (storyMode == 2)
					{
						presses = pressArray.filter(function(press) return press).length;
					}

					if (!FlxG.save.data.ghost)
					{
						for (shit in 0...pressArray.length)
						{ // if a direction is hit that shouldn't be
							if (pressArray[shit] && !directionList.contains(shit))
								noteMiss(shit, null);
						}
					}
					for (coolNote in possibleNotes)
					{
						// More Freestyle exceptions
						if ((storyMode == 2 && presses > 0) ||
								(pressArray[coolNote.noteData] && !hit[coolNote.noteData]))
						{
							// Don't hit poison notes unless using the note for Freestyle
							if (coolNote.noteType == NoteType.Poison && !pressArray[coolNote.noteData])
								continue;

							hit[coolNote.noteData] = true;
							scoreTxt.color = FlxColor.WHITE;
							var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
							anas[pressArray.indexOf(true)].hit = true;
							anas[pressArray.indexOf(true)].hitJudge = Ratings.CalculateRating(noteDiff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));
							anas[pressArray.indexOf(true)].nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];

							// Track how many presses are done in Freestyle
							if (storyMode == 2)
							{
								presses--;
								pressArray[pressArray.indexOf(true)] = false;
							}

							goodNoteHit(coolNote);
						}
					}
				};

				if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss') && (boyfriend.animation.curAnim.curFrame >= 10 || boyfriend.animation.curAnim.finished))
						boyfriend.playAnim('idle');
				}
				else if (!FlxG.save.data.ghost)
				{
					for (shit in 0...pressArray.length)
						if (pressArray[shit])
							noteMiss(shit, null);
				}
			}

			if (!loadRep)
				for (i in anas)
					if (i != null)
						replayAna.anaArray.push(i); // put em all there
		}

		// No hitting "fake notes"
		if (!(curSong == 'Satisfracture' && curStep >= 187 && curStep <= 192))
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (PlayStateChangeables.useDownscroll && (daNote.y + daNote.noteYOff) > strumLine.y || !PlayStateChangeables.useDownscroll && (daNote.y + daNote.noteYOff) < strumLine.y)
				{
					// Force good note hit regardless if it's too late to hit it or not as a fail safe
					if (PlayStateChangeables.botPlay
							&& daNote.canBeHit
							&& daNote.mustPress
							&& daNote.noteType != NoteType.Poison
							&& daNote.noteType != NoteType.SakuNote
							|| PlayStateChangeables.botPlay
							&& daNote.tooLate
							&& daNote.mustPress
							&& daNote.noteType != NoteType.Poison
							&& daNote.noteType != NoteType.SakuNote)
					{
						if (loadRep)
						{
							var n = findByTime(daNote.strumTime);
							if (n != null)
							{
								goodNoteHit(daNote);
								boyfriend.holdTimer = daNote.sustainLength;
							}
						}
						else
						{
							goodNoteHit(daNote);
							boyfriend.holdTimer = daNote.sustainLength;
							if (FlxG.save.data.cpuStrums)
							{
								playerStrums.forEach(function(spr:FlxSprite)
								{
									if (Math.abs(daNote.noteData) == spr.ID)
									{
										spr.animation.play('confirm', true);
									}
									if (spr.animation.curAnim.name == 'confirm')
									{
										spr.centerOffsets();
										spr.offset.x -= 13;
										spr.offset.y -= 13;
									}
									else
										spr.centerOffsets();
								});
							}
						}
					}
				}
			});
		}

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss') && (boyfriend.animation.curAnim.curFrame >= 10 || boyfriend.animation.curAnim.finished))
				boyfriend.playAnim('idle');
		}

		if (!PlayStateChangeables.botPlay)
		{
			var dirPressed = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (dirPressed[spr.ID] && spr.animation.curAnim.name != 'confirm' && spr.animation.curAnim.name != 'pressed')
					spr.animation.play('pressed', false);
				if (!dirPressed[spr.ID])
					spr.animation.play('static', false);

				if (spr.animation.curAnim.name == 'confirm')
				{
					spr.centerOffsets();
					spr.offset.x -= 13;
					spr.offset.y -= 13;
				}
				else
					spr.centerOffsets();
			});
		}
	}

	public function findByTime(time:Float):Array<Dynamic>
	{
		for (i in rep.replay.songNotes)
		{
			if (i[0] == time)
				return i;
		}
		return null;
	}

	public function findByTimeIndex(time:Float):Int
	{
		for (i in 0...rep.replay.songNotes.length)
		{
			if (rep.replay.songNotes[i][0] == time)
				return i;
		}
		return -1;
	}

	public function focusOut()
	{
		if (paused)
			return;
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.pause();
			vocals.pause();
		}

		openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
	}

	public function focusIn()
	{
		// nada
	}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		if (!boyfriend.stunned)
		{
			//health -= 0.2;
			updateHealthGraphics();
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;
			misses++;

			if (daNote != null)
			{
				if (!loadRep)
				{
					saveNotes.push([
						daNote.strumTime,
						0,
						direction,
						166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166
					]);
					saveJudge.push("miss");
				}
			}
			else if (!loadRep)
			{
				saveNotes.push([
					Conductor.songPosition,
					0,
					direction,
					166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166
				]);
				saveJudge.push("miss");
			}

			// var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
			// var wife:Float = EtternaFunctions.wife3(noteDiff, FlxG.save.data.etternaMode ? 1 : 1.7);

			if (FlxG.save.data.accuracyMod == 1)
			{
				totalNotesHit -= 1;
			}

			if (daNote != null)
			{
				if (!daNote.isSustainNote)
					songScore -= 10;
			}
			else
				songScore -= 10;

			if(FlxG.save.data.missSounds)
				{
					FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
					// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
					// FlxG.log.add('played imss note');
				}

			// Hole switch statement replaced with a single line :)
			if (!PlayStateChangeables.Optimize)
				boyfriend.playAnim('sing' + dataSuffix[direction] + 'miss', true);

			#if windows
			if (luaModchart != null)
			{
				luaModchart.executeState('playerOneMiss', [direction, Conductor.songPosition]);
			}
			#end

			updateAccuracy();
		}
	}

	/*function badNoteCheck()
			{
				// just double pasting this shit cuz fuk u
				// REDO THIS SYSTEM!
				var upP = controls.UP_P;
				var rightP = controls.RIGHT_P;
				var downP = controls.DOWN_P;
				var leftP = controls.LEFT_P;

				if (leftP)
					noteMiss(0);
				if (upP)
					noteMiss(2);
				if (rightP)
					noteMiss(3);
				if (downP)
					noteMiss(1);
				updateAccuracy();
			}
	 */
	function updateAccuracy()
	{
		totalPlayed += 1;
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);
		accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
	}

	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
		{
			return possibleNotes.length + 1;
		}
		return possibleNotes.length;
	}

	function goodNoteHit(note:Note, resetMashViolation = true):Void
	{
		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		if (loadRep)
		{
			noteDiff = findByTime(note.strumTime)[3];
			note.rating = rep.replay.songJudgements[findByTimeIndex(note.strumTime)];
		}
		else
			note.rating = Ratings.CalculateRating(noteDiff);

		if (note.rating == "miss")
			return;

		// add newest note to front of notesHitArray
		// the oldest notes are at the end and are removed first
		if (!note.isSustainNote)
			notesHitArray.unshift(Date.now());

		if (!note.wasGoodHit)
		{
			if (note.noteType == NoteType.Normal)
			{
				if (!note.isSustainNote)
				{
					popUpScore(note);
					combo += 1;
				}
				else
				{
					totalNotesHit += 1;
				}

				if (!PlayStateChangeables.Optimize)
				{
					switch (note.noteData)
					{
						case 2:
							if (note.isSustainNote && boyfriend.animation.curAnim.name == 'idle')
							{
								boyfriend.playAnim('singUP');
							}
							else if (!note.isSustainNote)
							{
								boyfriend.playAnim('singUP', true);
							}
						case 3:
							if (note.isSustainNote && boyfriend.animation.curAnim.name == 'idle')
							{
								boyfriend.playAnim('singRIGHT');
							}
							else if (!note.isSustainNote)
							{
								boyfriend.playAnim('singRIGHT', true);
							}
						case 1:
							if (note.isSustainNote && boyfriend.animation.curAnim.name == 'idle')
							{
								boyfriend.playAnim('singDOWN');
							}
							else if (!note.isSustainNote)
							{
								boyfriend.playAnim('singDOWN', true);
							}
						case 0:
							if (note.isSustainNote && boyfriend.animation.curAnim.name == 'idle')
							{
								boyfriend.playAnim('singLEFT');
							}
							else if (!note.isSustainNote)
							{
								boyfriend.playAnim('singLEFT', true);
							}
					}
				}

				#if windows
				if (luaModchart != null)
				{
					luaModchart.executeState('playerOneSing', [note.noteData, Conductor.songPosition]);
				}
				#end

				vocals.volume = 1;

				updateAccuracy();
			}
			else if (note.noteType == NoteType.Poison)
			{
				poisonSound.play(true);
				poisonStacks++;
				poisonTxt.text = Std.string(poisonStacks);

				for (i in 0...poisonNoteHits[note.noteData].length)
				{
					if (!poisonNoteHits[note.noteData].members[i].visible)
					{
						poisonNoteHits[note.noteData].members[i].x = note.x - note.width - 5;
						poisonNoteHits[note.noteData].members[i].y = note.y - (note.height / 2) - 20;
						poisonNoteHits[note.noteData].members[i].angle = note.angle;
						poisonNoteHits[note.noteData].members[i].animation.play('break', true);
						poisonNoteHits[note.noteData].members[i].visible = true;
						poisonNoteHits[note.noteData].members[i].animation.finishCallback = function(str:String)
						{
							poisonNoteHits[note.noteData].members[i].visible = false;
						};

						break;
					}
				}
			}
			else if (note.noteType == NoteType.Spectre)
			{
				spectreSound.play(true);
				spectreHit = true;

				for (i in 0...spectreNoteHits[note.noteData].length)
				{
					if (!spectreNoteHits[note.noteData].members[i].visible)
					{
						spectreNoteHits[note.noteData].members[i].x = note.x - note.width - 9;
						spectreNoteHits[note.noteData].members[i].y = note.y - (note.height / 2) - 20;
						spectreNoteHits[note.noteData].members[i].angle = note.angle;
						spectreNoteHits[note.noteData].members[i].animation.play('break', true);
						spectreNoteHits[note.noteData].members[i].visible = true;
						spectreNoteHits[note.noteData].members[i].animation.finishCallback = function(str:String)
						{
							spectreNoteHits[note.noteData].members[i].visible = false;
						};

						break;
					}
				}

				updateAccuracy();
			}
			else if (note.noteType == NoteType.SakuNote)
			{
				sakuLaugh.play(true);
				sakuNote.play(true);
				sakuUnlocked = true;

				if (FlxG.save.data.particles)
				{
					for (i in 0...particles.length)
					{
						particles.members[i].emitting = false;

						var emitter:FlxEmitter = new FlxEmitter(-1000, 1500);
						emitter.launchMode = FlxEmitterMode.SQUARE;
						emitter.velocity.set(-50, -250, 50, -850, -100, 0, 100, -150);
						emitter.scale.set(2, 2, 5, 5, 0.75, 0.75, 1.5, 1.5);
						emitter.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
						emitter.width = 3500;
						emitter.alpha.set(1, 1, 0, 0);
						emitter.lifespan.set(3, 5);
						emitter.loadParticles(Paths.image('Particles/Heart' + i, 'shared'), 500, 16, true);

						emitter.start(false, FlxG.random.float(0.1, 0.2), 100000);
						particles.add(emitter);
					}
				}
			}

			if (!loadRep && note.mustPress)
			{
				var array = [note.strumTime, note.sustainLength, note.noteData, noteDiff];
				if (note.isSustainNote)
					array[1] = -1;
				saveNotes.push(array);
				saveJudge.push(note.rating);
			}

			if (!(PlayStateChangeables.botPlay && !FlxG.save.data.cpuStrums))
			{
				playerStrums.forEach(function(spr:FlxSprite)
				{
					// Freestyle mode don't care about no directions
					if (note.noteData == spr.ID || storyMode == 2)
					{
						spr.animation.play('confirm', true);
					}
				});
			}

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
			else
			{
				note.wasGoodHit = true;
			}
		}
	}

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		#if windows
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curStep', curStep);
			luaModchart.executeState('stepHit', [curStep]);
		}
		#end

		if (curSong == 'Satisfracture')
		{
			if (curStep >= 185 && curStep < 192 && camZooming)
			{
				if (!PlayStateChangeables.Optimize)
					FlxTween.tween(FlxG.camera, {zoom: 2.25}, 0.5);

				var offsetX = 0;
				var offsetY = 0;
				#if windows
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				camFollow.setPosition(dad.getMidpoint().x - 75 + offsetX, dad.getMidpoint().y - 300 + offsetY);
				camZooming = false; // Disable lerping back
			}

			if (!PlayStateChangeables.Optimize && curStep >= 186 && curStep < 192 && dad.animation.curAnim.name != 'enough')
			{
				dad.playAnim('enough', true);
			}

			if (curStep >= 188 && curStep < 192 && enoughTxt == null)
			{
				enoughTxt = new FlxText(0, 475, 0, "ENOUGH!", 100);
				enoughTxt.cameras = [camHUD];
				enoughTxt.screenCenter(X);
				enoughTxtOrigin = enoughTxt.getPosition();
				add(enoughTxt);
			}

			if (curStep >= 192 && !camZooming)
			{
				/*var dadPos:FlxPoint = new FlxPoint(dad.x, dad.y);
					remove(dad);
					dad = new Character(dad.x, dad.y, 'coco');
					add(dad); */
				if (FlxG.save.data.flashing)
				{
					FlxG.camera.flash(FlxColor.WHITE, 0.2);
				}
				if (FlxG.save.data.chrom)
				{
					dad.chromEnabled = true;
				}

				FlxG.camera.zoom = defaultCamZoom;
				camZooming = true;
				if (!PlayStateChangeables.Optimize)
					boyfriend.playAnim('singLEFTmiss', true);

				if (enoughTxt != null)
				{
					remove(enoughTxt);
				}
			}
		}
		else if (curSong == 'Spectral')
		{
			if (!PlayStateChangeables.Optimize && FlxG.save.data.background > 0)
			{
				if (sakuBop != null && sakuBop.alpha == 0 && curStep >= 1024)
				{
					FlxTween.tween(sakuBop, {alpha: 1}, 1);
				}

				if (curStep >= 1536 && spectralDarkScreen.alpha == 0)
				{
					FlxTween.tween(spectralDarkScreen, {alpha: 0.75}, 0.2);
				}

				if (FlxG.save.data.particles && FlxG.save.data.motion && curStep >= 1536 && !spectralBGEmitter.emitting)
				{
					spectralBGEmitter.start(false, 0.025, 10000);
				}

				if (FlxG.save.data.flashing)
				{
					if (curStep >= 383 && curStep % 8 == 0)
					{
						if (groundGreen.alpha == 0)
						{
							groundGreen.alpha = 1;
						}
						else
						{
							groundGreen.alpha = 0;
						}
						if (rocksGreen.alpha == 0)
						{
							rocksGreen.alpha = 1;
						}
						else
						{
							rocksGreen.alpha = 0;
						}
						if (gem1Green.alpha == 0)
						{
							gem1Green.alpha = 1;
						}
						else
						{
							gem1Green.alpha = 0;
						}
						if (gem2Green.alpha == 0)
						{
							gem2Green.alpha = 1;
						}
						else
						{
							gem2Green.alpha = 0;
						}

						if (FlxG.save.data.background > 1)
						{
							flameChange.alpha = 1;
							FlxTween.tween(flameChange, {alpha: 0}, 0.5);
						}
					}
				}
			}

			if (FlxG.save.data.flashing)
			{
				if (curStep == 640 || curStep == 1024 || curStep == 1536 || curStep == 1856)
				{
					FlxG.camera.flash(FlxColor.WHITE, 0.25);
				}
			}

			if (isStoryMode && curStep >= 1856 && dad.visible)
			{
				endCutscene();
			}
		}
		else if (curSong == 'Ectospasm')
		{
			if (!PlayStateChangeables.Optimize && FlxG.save.data.background > 0)
			{
				if (FlxG.save.data.flashing)
				{
					if (curStep >= 128 && curStep % 8 == 0)
					{
						if (groundGreen.alpha == 0)
						{
							groundGreen.alpha = 1;
						}
						else
						{
							groundGreen.alpha = 0;
						}
						if (rocksGreen.alpha == 0)
						{
							rocksGreen.alpha = 1;
						}
						else
						{
							rocksGreen.alpha = 0;
						}
						if (gem1Green.alpha == 0)
						{
							gem1Green.alpha = 1;
						}
						else
						{
							gem1Green.alpha = 0;
						}
						if (gem2Green.alpha == 0)
						{
							gem2Green.alpha = 1;
						}
						else
						{
							gem2Green.alpha = 0;
						}

						if (FlxG.save.data.background > 1)
						{
							flameChange.alpha = 1;
							FlxTween.tween(flameChange, {alpha: 0}, 0.5);
						}
					}
				}
			}
		}
		else if (curSong == 'Fuzzy Feeling')
		{
			if (((curStep >= 248 && curStep < 256) || (curStep >= 1016 && curStep < 1024)) && dad.animation.curAnim.name != 'laugh')
			{
				dad.playAnim('laugh', true);
			}
			else if (FlxG.save.data.particles && curStep >= 768 && particles == null)
			{
				particles = new FlxTypedGroup<FlxEmitter>();

				for (i in 0...6)
				{
					var emitter:FlxEmitter = new FlxEmitter(-1000, 1500);
					emitter.launchMode = FlxEmitterMode.SQUARE;
					emitter.velocity.set(-50, -250, 50, -850, -100, 0, 100, -150);
					emitter.scale.set(2, 2, 10, 10, 0.75, 0.75, 1.5, 1.5);
					emitter.drag.set(0, 0, 0, 0, 5, 5, 10, 10);
					emitter.width = 3500;
					emitter.alpha.set(1, 1, 0, 0);
					emitter.lifespan.set(3, 5);
					emitter.loadParticles(Paths.image('Particles/Heart' + i, 'shared'), 500, 16, true);

					emitter.start(false, FlxG.random.float(0.1, 0.2), 100000);
					particles.add(emitter);
				}

				add(particles);
			}
		}

		// yes this updates every step.
		// yes this is bad
		// but i'm doing it to update misses and accuracy
		#if windows
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"Acc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC, true,
			songLength
			- Conductor.songPosition);
		#end
	}

	override function beatHit()
	{
		super.beatHit();

		// (tsg - 6/26/21) make sakuroma bop
		// (Arcy - 626/21) Restart the animation and bop on every other beat to make it always consistent
		if (sakuBop != null && curBeat % 2 == 0)
		{
			sakuBop.animation.play('bop', true);
		}
		if (crack != null && curBeat % 2 == 0)
		{
			crack.animation.play('bop', true);
		}
		if (cave != null && cave.animation.getByName('glow') != null && FlxG.save.data.background > 1 && curBeat % 2 == 0)
		{
			cave.animation.play('glow', true);
		}
		if (cave2 != null && cave2.animation.getByName('glow') != null && FlxG.save.data.background > 1 && curBeat % 2 == 0)
		{
			cave2.animation.play('glow', true);
		}

		// Chromatic aberration effect at no health for Spectral/Ectospasm
		if (chrom != null && FlxG.save.data.chrom && health <= 0.01)
		{
			chrom.rOffset.value = [0, -0.005];
			chrom.gOffset.value = [-0.005, -0.005];
			chrom.bOffset.value = [0.005, -0.005];
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, (PlayStateChangeables.useDownscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
		}

		#if windows
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curBeat', curBeat);
			luaModchart.executeState('beatHit', [curBeat]);
		}
		#end

		if (FlxG.save.data.camzoom)
		{
			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));
		if (poisonIcon != null)
		{
			poisonIcon.setGraphicSize(Std.int(poisonIcon.width + 30));
			poisonTxt.setGraphicSize(Std.int(poisonTxt.width + 10));
			poisonIcon.updateHitbox();
			poisonTxt.updateHitbox();
		}

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (!PlayStateChangeables.Optimize)
		{
			if (SONG.notes[Math.floor(curStep / 16)] != null)
			{
				// Dad doesnt interupt his own notes
				if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
				{
					// (Arcy) We're gonna make the sprite trails ourselves
					if (FlxG.save.data.ghostTrails && (curSong == 'Spectral' || curSong == 'Ectospasm'))
					{
						var trail:GhostSprite = GhostSprite.createGhostSprite(dad, 0.25, 0.33);
						spriteTrail.add(trail);
					}
					dad.dance();
				}
			}

			if (curBeat % gfSpeed == 0)
			{
				gf.dance();

				// Synchronize bops on beat
				if (boyfriend.animation.name == "idle" && curBeat % 2 == 0)
				{
					boyfriend.playAnim('idle', true);
				}

				if (dad.animation.name == "idle" && curBeat % 2 == 0)
				{
					dad.playAnim('idle', true);
				}
			}

			if (!boyfriend.animation.curAnim.name.startsWith("sing") && (curBeat % idleBeat == 0 || !idleToBeat))
			{
				boyfriend.playAnim('idle', idleToBeat);
			}
		}
	}

	/**
	 * Calculates the position of the character icons on the health bar and updates the icons according to the current health.
	 */
	function updateHealthGraphics()
	{
		var percent:Float = 1 - (health / 2);

		iconP1.x = healthBar.x + (healthBar.width * percent - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * percent - (iconP2.width - iconOffset));

		if (poisonIcon != null)
		{
			poisonIcon.x = iconP1.x + 75;
			poisonTxt.x = iconP1.x + 115;
		}

		if (percent > .8)
		{
			iconP1.animation.curAnim.curFrame = 1;
		}
		else
		{
			iconP1.animation.curAnim.curFrame = 0;
		}

		if (percent >= .99)
		{
			iconP2.animation.curAnim.curFrame = 3;
		}
		else if (percent > .8)
		{
			iconP2.animation.curAnim.curFrame = 2;
		}
		else if (percent < .2)
		{
			iconP2.animation.curAnim.curFrame = 1;
		}
		else
		{
			iconP2.animation.curAnim.curFrame = 0;
		}
	}

	/**
	 * Retro. Open your eyes.
	 * Cutscene happens BEFORE dialogue
	 */
	function introCutscene()
	{
		camFollow.setPosition(800, 400);

		bfBeepWake = new FlxSound().loadEmbedded(Paths.sound("beep"));
		wrathIntroSnap = new FlxSound().loadEmbedded(Paths.sound("phase1intro"));

		new FlxTimer().start(1.6, function(tmr:FlxTimer)
		{
			bfBeepWake.play(true);
			wrathIntroSnap.play(true);
			boyfriend.playAnim("singUP");
			boyfriend.animation.finishCallback = function(str:String)
			{
				boyfriend.animation.finishCallback = null;
				boyfriend.playAnim("idle", true);
				boyfriend.animation.stop();
			};
		});

		//wrathIntroSnap.play(true);

		new FlxTimer().start(2.7, function(tmr:FlxTimer)
		{
			cutsceneSprite.playAnim('intro', true);
		});

		cutsceneSprite.animation.finishCallback = function(str:String)
		{
			var doof:DialogueBox = new DialogueBox(SONG.song.toLowerCase(), bfCharacter, storyDifficulty, gf.curCharacter);
			doof.cameras = [camHUD];
			doof.finishThing = function()
			{
				healthBar.visible = true;
				healthBarBG.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
				startCountdown();
			};
			dad.visible = true;
			remove(cutsceneSprite);
			startDialogue(doof);
		};
	}

	/**
	 * Does all the cool transformation and stage change stuff.
	 */
	function transformCutscene()
	{
		transforming = true;
		cutsceneSprite.playAnim('tf', true);
		FlxG.sound.play(Paths.sound('Growl'));
		FlxG.sound.play(Paths.sound('ground shake'));
		cutsceneSprite.animation.finishCallback = function(str:String)
		{
			FlxTween.tween(characterLogo, {alpha: 0}, 0.5, {ease: FlxEase.cubeInOut});

			transforming = false;

			healthBar.visible = true;
			healthBarBG.visible = true;
			iconP1.visible = true;
			iconP2.visible = true;
			scoreTxt.visible = true;
			poisonIcon.visible = true;
			poisonTxt.visible = true;
			defaultCamZoom = 0.525;

			dad.visible = true;
			remove(cutsceneSprite);
			startCountdown();
		}

		var offsetX = 0;
		var offsetY = 0;
		#if windows
		if (luaModchart != null)
		{
			offsetX = luaModchart.getVar("followXOffset", "float");
			offsetY = luaModchart.getVar("followYOffset", "float");
		}
		#end
		camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);
	}

	/**
	 * Recursive function to condense things. I know it's gross, I'm sorry.
	 * And finally we end off with a bang B)
	 */
	 function endCutscene()
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);

		inCutscene = true;
		transforming = true;
		ending = true;
		canPause = false;
		FlxG.camera.angle = 0;
		camHUD.angle = 0;

		// Re-use some cutscene variables
		slammed = false;
		roared = false;

		FlxG.sound.play(Paths.sound('AngyRoar'));

		// Get rid of any stray notes
		notes.forEach(function(daNote:Note)
		{
			daNote.kill();
			daNote.destroy();
		});
		notes.clear();

		if (!PlayStateChangeables.Optimize)
		{
			for (i in 0...4)
			{
				FlxTween.tween(playerStrums.members[i], {alpha: 0}, 0.5, {ease:FlxEase.cubeInOut});
				FlxTween.tween(cpuStrums.members[i], {alpha: 0}, 0.5, {ease:FlxEase.cubeInOut});
			}

			FlxTween.tween(healthBar, {alpha: 0}, 1, {ease:FlxEase.cubeInOut});
			FlxTween.tween(healthBarBG, {alpha: 0}, 1, {ease:FlxEase.cubeInOut});
			FlxTween.tween(iconP1, {alpha: 0}, 1, {ease:FlxEase.cubeInOut});
			FlxTween.tween(iconP2, {alpha: 0}, 1, {ease:FlxEase.cubeInOut});
			FlxTween.tween(scoreTxt, {alpha: 0}, 1, {ease:FlxEase.cubeInOut});
			FlxTween.tween(poisonIcon, {alpha: 0}, 1, {ease:FlxEase.cubeInOut});
			FlxTween.tween(poisonTxt, {alpha: 0}, 1, {ease:FlxEase.cubeInOut});

			camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 150);
			dad.visible = false;

			var endCutsceneSpritesProcessed:Array<FlxSprite> = new Array();
			var animOffsets:Array<FlxPoint> = [new FlxPoint(0, 0), new FlxPoint(254, -92), new FlxPoint(254, -92), new FlxPoint(89, -159), new FlxPoint(-175, -214), new FlxPoint(-334, -483), new FlxPoint(162, -184), new FlxPoint(162, -184)];

			var cutscenePos:FlxPoint = new FlxPoint(cutsceneSprite.x - 367, cutsceneSprite.y - 202);

			for(ecSprite in endCutsceneSprites.members)
			{
				var processedSprite = cast(ecSprite, FlxSprite);
				processedSprite.setPosition(cutscenePos.x, cutscenePos.y);

				endCutsceneSpritesProcessed.push(processedSprite);
			}

			endCutsceneAnimation = new CompoundSprite(endCutsceneSpritesProcessed, cutscenePos.x, cutscenePos.y, animOffsets);

			endCutsceneAnimation.animationEndCallback = (name:String) -> {
				transforming = false;

				if (FlxG.save.data.flashing)
				{
					camHUD.flash(FlxColor.WHITE, 1);
				}

				var blackBG:FlxSprite = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
				blackBG.cameras = [camHUD];
				add(blackBG);

				FlxG.sound.play(Paths.sound('Debris3'));

				new FlxTimer().start(2, function(flx:FlxTimer)
				{
					var continueLogo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('FUCKFCUKFCUFKCUFKCUFKCUFKCUFKCUF', 'shared'));
					continueLogo.cameras = [camHUD];
					continueLogo.scale.set(0.5, 0.5);
					continueLogo.screenCenter();
					continueLogo.alpha = 0;
					add(continueLogo);

					FlxG.sound.play(Paths.sound('FinalRoar'));

					FlxTween.tween(continueLogo, {alpha: 1}, 2.5, {onComplete: function(flx:FlxTween)
					{
						new FlxTimer().start(5, function(flx:FlxTimer)
						{
							endSong();
						});
					}});
				});
			};

			endCutsceneAnimation.playAll("end", true);
		}
		else
		{
			for (i in 0...4)
			{
				FlxTween.tween(playerStrums.members[i], {alpha: 0}, 0.5, {ease:FlxEase.cubeInOut});
			}

			new FlxTimer().start(2, function(flx:FlxTimer)
			{
				var continueLogo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('FUCKFCUKFCUFKCUFKCUFKCUFKCUFKCUF', 'shared'));
				continueLogo.cameras = [camHUD];
				continueLogo.scale.set(0.5, 0.5);
				continueLogo.screenCenter();
				continueLogo.alpha = 0;
				add(continueLogo);

				FlxG.sound.play(Paths.sound('FinalRoar'));

				FlxTween.tween(continueLogo, {alpha: 1}, 2.5, {onComplete: function(flx:FlxTween)
				{
					new FlxTimer().start(5, function(flx:FlxTimer)
					{
						endSong();
					});
				}});
			});
		}
	}
}

// (Arcy) This can be optimized by object pooling, but I"m too lazy to set that up
// (Arcy) So do this for the full update future me please
class GhostSprite extends FlxSprite
{
	private static var poolSize = 5;
	private static var INVISIBLE_ALPHA  = 0.00000000001;

	private static var instanceReserve:FlxTypedGroup<GhostSprite>;
	private static var usedInstances:FlxTypedGroup<GhostSprite>;

	private var time:Float;
	private var curTime:Float;
	private var aVal:Float;

	public static function initialize() {
		if(instanceReserve != null && usedInstances != null) {
			GhostSprite.cleanPools();
		}

		instanceReserve = new FlxTypedGroup();
		usedInstances = new FlxTypedGroup();

		for(i in 0...poolSize) {
			instanceReserve.add(new GhostSprite());
		}
	}

	/**
	 * Creates a new sprite that copies the sprite and will fade into nothing and die. Forever.
	 *
	 * @param	Sprite			The sprite to make a copy of.
	 * @param	FadeTime		The time it takes for the sprite to fade completely to transparent.
	 * @param	AlphaStart		The starting value of the alpha for the sprite.
	 */
	public static function createGhostSprite(Sprite:FlxSprite, ?FadeTime:Float = 1, ?AlphaStart:Float = 1) {
		var spookyGhost:GhostSprite;

		if (instanceReserve.length != 0) {
			spookyGhost = instanceReserve.members[instanceReserve.length - 1];

			instanceReserve.remove(spookyGhost, true);

			trace(spookyGhost);
		} else {
			spookyGhost = new GhostSprite();

			poolSize++;
		}

		spookyGhost.frame = Sprite.frame;
		spookyGhost.offset = Sprite.offset;
		spookyGhost.scale = Sprite.scale;
		spookyGhost.width = Sprite.width;
		spookyGhost.frameWidth = Sprite.frameWidth;
		spookyGhost.height = Sprite.height;
		spookyGhost.frameHeight = Sprite.frameHeight;
		spookyGhost.setPosition(Sprite.getPosition().x, Sprite.getPosition().y);

		spookyGhost.updateHitbox();

		spookyGhost.time = FadeTime;
		spookyGhost.curTime = spookyGhost.time;
		spookyGhost.aVal = AlphaStart;

		usedInstances.add(spookyGhost);

		return spookyGhost;
	}

	public static function destroyGhostSprite(sprite:GhostSprite) {
		sprite.alpha = INVISIBLE_ALPHA;
		sprite.setPosition(0, 0);
		usedInstances.remove(sprite);
		instanceReserve.add(sprite);
	}

	private static function cleanPools() {
		for(i in usedInstances) {
			i.destroy();
		}

		for(i in instanceReserve) {
			i.destroy();
		}
	}

	override function update(elapsed:Float)
	{
		curTime -= elapsed;

		if (curTime <= 0)
		{
			destroyGhostSprite(this);
		}
		else
		{
			alpha = (curTime / time) * aVal;
		}
	}
}
