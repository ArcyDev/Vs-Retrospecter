/**
	TSG here, this dialogue system was lifted from my Small Things engine mod, with the Small Things specific shit commented out.
	If you have any issues with the dialogue system at all, feel free to DM me.
**/

package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curMood:String = '';
	var curCharacter:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;
	var skipText:FlxText;

	public var finishThing:Void->Void;

	var portraitRight:FlxSprite;
	var secondPortrait:FlxSprite;

	var bgFade:FlxSprite;

	var music:FlxSound;

	// Dialogue shake
	var amplitudeX:Float;
	var amplitudeY:Float;
	var textShake:Bool = false;

	public function new(song:String, character:String, difficulty:Int, gf:String, talkingRight:Bool = false)
	{
		super();

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'retro':
				if (PlayState.isStoryMode) {
					music = new FlxSound().loadEmbedded(Paths.music('dialogue_1', 'wrath'), true, true);
					music.volume = 0;
					music.fadeIn(1, 0, 0.2);
					FlxG.sound.list.add(music);
				}
			case 'spectral':
				if (PlayState.isStoryMode) {
					music = new FlxSound().loadEmbedded(Paths.music('dialogue_2', 'wrath'), true, true);
					music.volume = 0;
					music.fadeIn(1, 0, 0.2);
					FlxG.sound.list.add(music);
				}
			case 'satisfracture':
				if (PlayState.isStoryMode) {
					music = new FlxSound().loadEmbedded(Paths.music('dialogue_1', 'wrath'), true, true);
					music.volume = 0;
					music.fadeIn(1, 0, 0.2);
					FlxG.sound.list.add(music);
				}
			case 'ectospasm':
				if (PlayState.isStoryMode) {
					music = new FlxSound().loadEmbedded(Paths.music('dialogue_2', 'wrath'), true, true);
					music.volume = 0;
					music.fadeIn(1, 0, 0.2);
					FlxG.sound.list.add(music);
				}
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.83, function(tmr:FlxTimer)
		{
			bgFade.alpha += (1 / 5) * 0.7;
			if (bgFade.alpha > 0.7)
			{
				bgFade.alpha = 0.7;
			}
		}, 5);

		box = new FlxSprite(-20, 45);

		var hasDialog = false;
		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'retro':
				hasDialog = true;

			case 'spectral':
				hasDialog = true;

			case 'satisfracture':
				hasDialog = true;

			case 'ectospasm':
				hasDialog = true;

			case 'fuzzy feeling':
				hasDialog = true;
		}

		box.frames = Paths.getSparrowAtlas('speech_bubble_talking');
		box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
		box.animation.addByPrefix('normal', 'Speech Bubble Normal Open', 24, false);
		box.setGraphicSize(Std.int(box.width * 1 * 0.9));
		box.y = (FlxG.height - box.height) + 80;

		this.dialogueList = getDialogue(song, character, difficulty, gf);

		if (!hasDialog)
			return;

		portraitRight = new FlxSprite(0, 40);
		add(portraitRight);
		portraitRight.visible = false;
		secondPortrait = new FlxSprite(0, 40);
		add(secondPortrait);
		secondPortrait.visible = false;

		box.animation.play('normalOpen');
		box.updateHitbox();
		add(box);

		box.screenCenter(X);
		// portraitLeft.screenCenter(X);

		swagDialogue = new FlxTypeText(200, 500, Std.int(FlxG.width * 0.7), "", 32);
		swagDialogue.setFormat(Paths.font('vcr.ttf'), 40, FlxColor.BLACK, LEFT);
		dropText = new FlxText(202, 502, Std.int(FlxG.width * 0.7), "", 32);
		dropText.setFormat(Paths.font('vcr.ttf'), 40, FlxColor.BLACK, LEFT);

		skipText = new FlxText(1120, (FlxG.height * 0.9) + 50, 0, "Press Esc to skip");
		skipText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		add(dropText);
		add(swagDialogue);
		add(skipText);

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		dropText.text = swagDialogue.text;

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		// Dialogue shake
		if (textShake)
		{
			swagDialogue.x = 240 + (amplitudeX * Math.sin(FlxG.random.float(0, 2 * Math.PI)));
			dropText.x = 242 + (amplitudeX * Math.sin(FlxG.random.float(0, 2 * Math.PI)));
			swagDialogue.y = 500 + (amplitudeY * Math.sin(FlxG.random.float(0, 2 * Math.PI)));
			dropText.y = 502 + (amplitudeY * Math.sin(FlxG.random.float(0, 2 * Math.PI)));
			// timeElapsed += elapsed;
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		// Skip dialogue
		if (PlayerSettings.player1.controls.BACK && dialogueStarted && !isEnding)
		{
			isEnding = true;

			if (music != null && music.playing)
				music.fadeOut(1.2, 0);

			new FlxTimer().start(0.2, function(tmr:FlxTimer)
			{
				box.alpha -= 1 / 5;
				bgFade.alpha -= 1 / 5 * 0.7;
				portraitRight.visible = false;
				secondPortrait.visible = false;
				swagDialogue.alpha -= 1 / 5;
				dropText.alpha = swagDialogue.alpha;
				skipText.alpha -= 1 / 5;
			}, 5);

			new FlxTimer().start(1.2, function(tmr:FlxTimer)
			{
				finishThing();
				kill();
			});
		}
		else if (PlayerSettings.player1.controls.ACCEPT && dialogueStarted == true)
		{
			updateDialogue();
		}
		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function updateDialogue(playSound:Bool = true):Void
	{
		remove(dialogue);

		// (Arcy) Stop making sounds!!!
		if (playSound && !isEnding)
		{
			FlxG.sound.play(Paths.sound('clickText'), 0.4);
		}

		if (dialogueList[1] == null && dialogueList[0] != null)
		{
			if (!isEnding)
			{
				isEnding = true;

				switch (PlayState.SONG.song.toLowerCase())
				{
					case 'retro':
						music.fadeOut(2.2, 0);
					case 'satisfracture':
						music.fadeOut(2.2, 0);
					case 'spectral':
						music.fadeOut(2.2, 0);
				}

				new FlxTimer().start(0.2, function(tmr:FlxTimer)
				{
					box.alpha -= 1 / 5;
					bgFade.alpha -= 1 / 5 * 0.7;
					portraitRight.visible = false;
					secondPortrait.visible = false;
					swagDialogue.alpha -= 1 / 5;
					dropText.alpha = swagDialogue.alpha;
					skipText.alpha -= 1 / 5;
				}, 5);

				new FlxTimer().start(1.2, function(tmr:FlxTimer)
				{
					finishThing();
					kill();
				});
			}
		}
		else
		{
			dialogueList.remove(dialogueList[0]);

			portraitRight.visible = false;
			secondPortrait.visible = false;

			startDialogue();
		}
	}

	function startDialogue():Void
	{
		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		// swagDialogue.text = ;
		swagDialogue.resetText(dialogueList[0]);
		dropText.text = '';
		swagDialogue.start(0.04, true);

		switch (curCharacter)
		{
			/*
			case 'bf':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('bfText'), 0.6)];
				swagDialogue.color = FlxColor.fromRGB(80, 165, 235);
				portraitLeft.visible = false;
				if (!portraitRight.visible)
				{
					portraitRight.frames = Paths.getSparrowAtlas('portraits', 'shared');
					portraitRight.animation.addByPrefix('enter', 'bf portrait', 24, false);
					portraitRight.setGraphicSize(Std.int(portraitRight.width * 1 * 0.75));
					portraitRight.antialiasing = true;
					portraitRight.updateHitbox();
					portraitRight.scrollFactor.set();
					// portraitRight.screenCenter(X);

					portraitRight.x = (box.x + box.width) - (portraitRight.width) - 60;
					portraitRight.y = box.y - 168;

					portraitRight.visible = true;
					portraitRight.animation.play('enter');
				}
			*/
			case 'bf':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('bfText'), 0.6)];
				swagDialogue.color = FlxColor.fromRGB(80, 165, 235);
				if (!portraitRight.visible)
				{
					switch (PlayState.bfCharacter)
					{
						case 'bf-retro':
							portraitRight.frames = Paths.getSparrowAtlas('characters/portraits/RetroBF');
							portraitRight.animation.addByPrefix('enter', 'retrobf portrait', 24, false);

						case 'bf-ace':
							portraitRight.frames = Paths.getSparrowAtlas('characters/portraits/AceBF');
							portraitRight.animation.addByPrefix('enter', 'portrait', 24, false);

						default:
							portraitRight.frames = Paths.getSparrowAtlas('characters/portraits/Boyfriend');
							portraitRight.animation.addByPrefix('enter', curMood, 24, false);
					}

					portraitRight.setGraphicSize(Std.int(portraitRight.width * 1 * 0.75));
					portraitRight.antialiasing = FlxG.save.data.antialiasing;
					portraitRight.updateHitbox();
					portraitRight.scrollFactor.set();
					// portraitRight.screenCenter(X);

					portraitRight.x = (box.x + box.width) - (portraitRight.width) - 60;

					switch (PlayState.bfCharacter)
					{
						case 'bf-retro':
							portraitRight.y = box.y - 175;

						case 'bf-ace':
							portraitRight.y = box.y - 150;

						default:
							portraitRight.y = box.y - 200;
					}

					portraitRight.visible = true;
					portraitRight.animation.play('enter');
				}
			case 'bf-og':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('bfText'), 0.6)];
				swagDialogue.color = FlxColor.fromRGB(80, 165, 235);
				if (!portraitRight.visible)
				{
					portraitRight.frames = Paths.getSparrowAtlas('characters/portraits/Boyfriend');
					portraitRight.animation.addByPrefix('enter', curMood, 24, false);
					portraitRight.setGraphicSize(Std.int(portraitRight.width * 1 * 0.75));
					portraitRight.antialiasing = FlxG.save.data.antialiasing;
					portraitRight.updateHitbox();
					portraitRight.scrollFactor.set();
					// portraitRight.screenCenter(X);

					portraitRight.x = (box.x + box.width) - (portraitRight.width) - 60;
					portraitRight.y = box.y - 200;

					portraitRight.visible = true;
					portraitRight.animation.play('enter');
				}
			case 'gf':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('bfText'), 0.6)];
				swagDialogue.color = 0xFF0c0a16;
				if (!portraitRight.visible)
				{
					portraitRight.frames = Paths.getSparrowAtlas('characters/portraits/Girlfriend');
					portraitRight.animation.addByPrefix('enter', curMood, 24, false);
					portraitRight.setGraphicSize(Std.int(portraitRight.width * 1 * 0.75));
					portraitRight.antialiasing = FlxG.save.data.antialiasing;
					portraitRight.updateHitbox();
					portraitRight.scrollFactor.set();
					// portraitRight.screenCenter(X);

					portraitRight.x = (box.x + box.width) - (portraitRight.width) - 60;
					portraitRight.y = box.y - 225;

					portraitRight.visible = true;
					portraitRight.animation.play('enter');
				}
			case 'retro':
				if (curMood == 'Angry')
				{
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('retroAngryVoice'), 0.6)];
				}
				else
				{
					swagDialogue.sounds = [FlxG.sound.load(Paths.sound('retroText'), 0.6)];
				}
				swagDialogue.color = FlxColor.fromRGB(42, 136, 164);
				if (!portraitRight.visible)
				{
					portraitRight.frames = Paths.getSparrowAtlas('characters/portraits/RetroSpecter');
					portraitRight.animation.addByPrefix('enter', curMood, 24, false);
					portraitRight.setGraphicSize(Std.int(portraitRight.width * 1 * 0.75));
					portraitRight.antialiasing = FlxG.save.data.antialiasing;
					portraitRight.updateHitbox();
					portraitRight.scrollFactor.set();
					// portraitRight.screenCenter(X);

					portraitRight.x = box.x + 64;
					portraitRight.y = box.y - 248;

					portraitRight.visible = true;
					portraitRight.animation.play('enter');
				}

			case 'sakuroma':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('sakuromaText'), 0.6)];
				swagDialogue.color = FlxColor.fromRGB(247, 124, 216);

				if (!portraitRight.visible)
				{
					portraitRight.frames = Paths.getSparrowAtlas('characters/portraits/Sakuroma');
					portraitRight.animation.addByPrefix('enter', curMood, 24, false);
					portraitRight.setGraphicSize(Std.int(portraitRight.width * 1 * 0.75));
					portraitRight.antialiasing = FlxG.save.data.antialiasing;
					portraitRight.updateHitbox();
					portraitRight.scrollFactor.set();
					// portraitRight.screenCenter(X);

					portraitRight.x = box.x + 64;
					portraitRight.y = box.y - 248;

					portraitRight.visible = true;
					portraitRight.animation.play('enter');
				}
			case 'sakuromas':
				swagDialogue.sounds = [FlxG.sound.load(Paths.sound('sakuromaText'), 0.6)];
				swagDialogue.color = FlxColor.fromRGB(247, 124, 216);

				if (!portraitRight.visible)
				{
					portraitRight.frames = Paths.getSparrowAtlas('characters/portraits/Sakuroma');
					portraitRight.animation.addByPrefix('enter', curMood, 24, false);
					portraitRight.setGraphicSize(Std.int(portraitRight.width * 1 * 0.75));
					portraitRight.antialiasing = FlxG.save.data.antialiasing;
					portraitRight.updateHitbox();
					portraitRight.scrollFactor.set();
					// portraitRight.screenCenter(X);

					portraitRight.x = box.x + 64;
					portraitRight.y = box.y - 248;

					portraitRight.visible = true;
					portraitRight.animation.play('enter');
				}
				if(!secondPortrait.visible)
				{
					secondPortrait.frames = Paths.getSparrowAtlas('characters/portraits/Sakuroma');
					secondPortrait.animation.addByPrefix('enter', curMood, 24, false);
					secondPortrait.setGraphicSize(Std.int(secondPortrait.width * 1 * 0.75));
					secondPortrait.antialiasing = FlxG.save.data.antialiasing;
					secondPortrait.updateHitbox();
					secondPortrait.scrollFactor.set();
					// portraitRight.screenCenter(X);

					secondPortrait.x = box.x + portraitRight.width + 64;
					secondPortrait.y = box.y - 248;

					secondPortrait.visible = true;
					secondPortrait.animation.play('enter');
				}
				// command: set font
			case 'setFont':
				// split arguments
				var splitArgs:Array<String> = dialogueList[0].split("|");

				// set the current dialogue font
				swagDialogue.setFormat(Paths.font(splitArgs[0]), Std.parseInt(splitArgs[1]), FlxColor.BLACK, LEFT);
				dropText.setFormat(Paths.font(splitArgs[0]), Std.parseInt(splitArgs[1]), FlxColor.BLACK, LEFT);

				// move the dialogue script ahead one line WITHOUT PLAYING THE ENTER SOUND
				updateDialogue(false);
				// command: start text shake
			case 'startTextShake':
				// split arguments
				var splitArgs:Array<String> = dialogueList[0].split("|");

				// set the frequency and amplitude of the waves
				amplitudeX = Std.parseFloat(splitArgs[0]);
				amplitudeY = Std.parseFloat(splitArgs[1]);

				// Enable shake
				textShake = true;

				// move the dialogue script ahead one line WITHOUT PLAYING THE ENTER SOUND
				updateDialogue(false);
				// command: stop text shake
			case 'stopTextShake':
				// Disable shake
				textShake = false;

			case 'setVoice':
				// NOT WORKING FOR SOME REASON
				var splitArgs:Array<String> = dialogueList[0].split("|");

				swagDialogue.sounds = [FlxG.sound.load(Paths.sound(splitArgs[0]), 0.6)];

				updateDialogue(false);

		}
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		if ((curCharacter == 'bf' && (PlayState.bfCharacter == 'bf')) || curCharacter == 'retro'|| curCharacter == 'bf-og' || curCharacter == 'sakuroma' || curCharacter == 'gf' || curCharacter == 'sakuromas')
		{
			curMood = splitName[2];
			dialogueList[0] = dialogueList[0].substr(splitName[1].length + splitName[2].length + 3).trim();
		}
		else
		{
			dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
		}
		dialogueList[0] = dialogueList[0].replace('[Happy]',':D').replace('[Frown]',':(').replace('[Sad]','D:').replace('[Cat]',':3');
	}

	/**
	*	Load the dialogue for the specified context.
	* @param	song			The song to retrieve dialogue for
	* @param	character		The currently played Boyfriend
	* @param	difficulty		The song difficulty
	* @param	difficulty		The current Girlfriend
	* @return	The dialogue read from the appropriate file, or null if no dialogue could be found.
	*/
	function getDialogue(song:String, character:String, difficulty:Int, gf:String):Array<String>
	{
		// Dialogue files are located within the song-name folder.
		// File names are of the name dialogue-character-[difficulty]
		// If no difficulty is specified, it will be the default for any
		// difficulty without a specific file

		var difficultyName:String;

		switch(difficulty)
		{
			case 0:
				difficultyName = "easy";

			case 1:
				difficultyName = "normal";

			case 2:
				difficultyName = "hard";

			case 3:
				difficultyName = "hell";

			default:
				difficultyName = "INVLAID";
		}

		var basePath = 'data/${song.toLowerCase().replace(' ', '-')}/dialogue-${character}';
		var difficultyVariant = '${basePath}-${difficultyName}';
		var gfVariant = '${basePath}${gf.replace('gf', '')}';

		var loadedDialogue:Array<String> = null;

		loadedDialogue = CoolUtil.coolTextFile(Paths.txt(gfVariant, 'preload'));

		if(loadedDialogue == null)
		{
			loadedDialogue = CoolUtil.coolTextFile(Paths.txt(difficultyVariant, 'preload'));

			if (loadedDialogue == null)
			{
				loadedDialogue = CoolUtil.coolTextFile(Paths.txt(basePath, 'preload'));
			}
		}

		return loadedDialogue;
	}
}
