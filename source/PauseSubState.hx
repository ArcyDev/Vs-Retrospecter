package;

import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.Lib;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Change Difficulty', 'Exit to menu'];
	var difficulties:Array<String> = ['Easy', 'Normal', 'Hard', 'Hell'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var perSongOffset:FlxText;
	var songPath:String;

	var offsetChanged:Bool = false;
	var startOffset:Float = PlayState.songOffset;
	var difficultyMenu:Bool = false;

	// (Carbon) For controllers only!
	var confirmButtonEnabled = true;

	public function new(x:Float, y:Float)
	{
		super();

		if(FlxG.gamepads.lastActive != null) {
			confirmButtonEnabled = false;
			
			new FlxTimer().start(0.5, (timer:FlxTimer) -> {
				confirmButtonEnabled = true;
			});
		}

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('Snackrifice'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyFromInt(PlayState.storyDifficulty).toUpperCase();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var levelMode:FlxText = new FlxText(20, 15 + 64, 0, "", 32);
		levelMode.text += CoolUtil.modeString();
		levelMode.scrollFactor.set();
		levelMode.setFormat(Paths.font('vcr.ttf'), 32);
		levelMode.updateHitbox();
		add(levelMode);

		levelMode.alpha = 0;
		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		levelMode.x = FlxG.width - (levelMode.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(levelMode, {alpha: 1, y: levelMode.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);
		perSongOffset = new FlxText(5, FlxG.height - 18, 0, "Additive Offset (Left, Right): " + PlayState.songOffset + " - Description - " + 'Adds value to global offset, per song.', 12);
		perSongOffset.scrollFactor.set();
		perSongOffset.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		#if cpp
			add(perSongOffset);
		#end

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		// pre lowercasing the song name (update)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		songPath = 'assets/data/' + songLowercase + '/';

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.7)
		{
			pauseMusic.volume += 0.01 * elapsed;
		}
		else if (pauseMusic.volume > 0.7)
		{
			pauseMusic.volume = 0.7;
		}

		super.update(elapsed);

		#if sys
		if (PlayState.isSM && !PlayState.isStoryMode)
			songPath = PlayState.pathToSm;
		#end

		if (controls.UP_P)
		{
			changeSelection(-1);

		}
		else if (controls.DOWN_P)
		{
			changeSelection(1);
		}
		else if (controls.LEFT_P)
		{
			changeOffset(-1);
		}
		else if (controls.RIGHT_P)
		{
			changeOffset(1);
		}

		if (controls.ACCEPT && !FlxG.keys.pressed.ALT && confirmButtonEnabled)
		{
			if (difficultyMenu)
			{
				if (PlayState.SONG.song == "Ectospasm")
				{
					PlayState.SONG = Song.loadFromJson(Highscore.formatSong(StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase(), 3), PlayState.SONG.song);
					PlayState.storyDifficulty = 3;
				}
				else
				{
					PlayState.SONG = Song.loadFromJson(Highscore.formatSong(StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase(), curSelected), PlayState.SONG.song);
					PlayState.storyDifficulty = curSelected;
				}
				FlxG.resetState();
			}
			else
			{
				switch (menuItems[curSelected])
				{
					case "Resume":
						close();
					case "Restart Song":
						PlayState.startTime = 0;
						FlxG.resetState();
					case "Change Difficulty":
						switchMenu();
					case "Exit to menu":
						PlayState.startTime = 0;
						if(PlayState.loadRep)
						{
							FlxG.save.data.botplay = false;
							FlxG.save.data.scrollSpeed = 1;
							FlxG.save.data.downscroll = false;
						}
						PlayState.loadRep = false;
						#if windows
						if (PlayState.luaModchart != null)
						{
							PlayState.luaModchart.die();
							PlayState.luaModchart = null;
						}
						#end
						if (FlxG.save.data.fpsCap > 290)
							(cast (Lib.current.getChildAt(0), Main)).setFPSCap(290);

						if (PlayState.isStoryMode)
							FlxG.switchState(new StoryMenuState());
						else
							FlxG.switchState(new FreeplayState());
				}
			}
		}

		if (controls.BACK)
		{
			// Go back to pause options
			if (difficultyMenu)
			{
				switchMenu();
			}
			// Resume the game
			else if (!offsetChanged)
			{
				close();
			}
		}

		if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
		{
			curSelected = menuItems.length - 1;
		}
		if (curSelected >= menuItems.length)
		{
			curSelected = 0;
		}

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}

	function switchMenu()
	{
		// Bring it back to the first in the index and toggle the flag
		curSelected = 0;
		difficultyMenu = !difficultyMenu;

		// Rename the settings
		if (difficultyMenu)
		{
			if (PlayState.SONG.song == "Ectospasm")
				menuItems = ['Hell'];
			else
				menuItems = ['Easy', 'Normal', 'Hard', 'Hell'];
		}
		else
		{
			if (offsetChanged)
			{
				menuItems = ['Restart Song', 'Change Difficulty', 'Exit to menu'];
			}
			else
			{
				menuItems = ['Resume', 'Restart Song', 'Change Difficulty', 'Exit to menu'];
			}
		}

		// Clear and recreate the objects
		grpMenuShit.clear();
		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		// Update positions
		changeSelection();
	}

	function changeOffset(amount:Int)
	{
		var oldOffset = PlayState.songOffset;
		PlayState.songOffset += amount;
		sys.FileSystem.rename(songPath + oldOffset + '.offset', songPath + PlayState.songOffset + '.offset');
		perSongOffset.text = "Additive Offset (Left, Right): " + PlayState.songOffset + " - Description - " + 'Adds value to global offset, per song.';

		// Prevent loop from happening every single time the offset changes
		if(!offsetChanged)
		{
			if (!difficultyMenu)
			{
				grpMenuShit.clear();

				menuItems = ['Restart Song', 'Change Difficulty', 'Exit to menu'];

				for (i in 0...menuItems.length)
				{
					var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
					songText.isMenuItem = true;
					songText.targetY = i;
					grpMenuShit.add(songText);
				}

				changeSelection();

				cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
			}
			offsetChanged = true;
		}
		else if (PlayState.songOffset == startOffset)
		{
			if (!difficultyMenu)
			{
				grpMenuShit.clear();

				menuItems = ['Resume', 'Restart Song', 'Change Difficulty', 'Exit to menu'];

				for (i in 0...menuItems.length)
				{
					var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
					songText.isMenuItem = true;
					songText.targetY = i;
					grpMenuShit.add(songText);
				}

				changeSelection();

				cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
				offsetChanged = true;
			}

			offsetChanged = false;
		}
	}
}
