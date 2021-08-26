package;
import Song.SwagSong;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import openfl.media.Sound;

using StringTools;
#if sys
import smTools.SMFile;
import sys.FileSystem;
import sys.io.File;
#end


#if windows
import Discord.DiscordClient;
#end


class FreeplayState extends MusicBeatState
{
	public static var songs:Array<SongMetadata> = [];
	public static var songUnlocked:Array<Bool> = [true, false, false, false, false];
	public static var songVisible:Array<Bool> = [true, false, true, false, false];

	// TODO: Make an UnlockManager to handle this.
	public static var justUnlocked:Array<String> = [];
	var unlocking:Bool = false;
	var stopSpamming:Bool = false;
	var fadeBG:FlxSprite;
	var unlockSprite:FlxSprite;
	var unlockDescription:FlxText;

	public static var curSelected:Int = 0;
	public static var curDifficulty:Int = 1;
	public static var curCharacter:Int = 0;
	public static var curGf:Int = 0;

	var scoreText:FlxText;
	var comboText:FlxText;
	var diffText:FlxText;
	var diffCalcText:FlxText;
	var previewtext:FlxText;
	var unlockText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var combo:String = '';

	var charText:FlxText;
	var charIcon:FlxSprite;
	var gfText:FlxText;
	var gfIcon:FlxSprite;

	private var grpSongs:FlxTypedGroup<Alphabet>;

	private var iconArray:Array<HealthIcon> = [];

	public static var songData:Map<String,Array<SwagSong>> = [];

	// Kade Engine doesn't accurately measure ratings for these songs
	private var difficultyRatings:Array<Dynamic> = [
		['4.3', '5.5', '6.21', '9.04'],
		['5.08', '6.66', '8.72', '10.77'],
		['6.66', '8.88', '10.31', '13.37'],
		['19.93'],
		['4.69', '5.69', '6.9', '9.6']
	];

	//public static var openedPreview:Bool = false;

	public static function loadDiff(diff:Int, format:String, name:String, array:Array<SwagSong>)
	{
		try
		{
			array.push(Song.loadFromJson(Highscore.formatSong(format, diff), name.toLowerCase()));
		}
		catch(ex)
		{
			// do nada
		}
	}

	override function create()
	{
		if (TitleState.introMusic != null && TitleState.introMusic.playing)
		{
			TitleState.introMusic.stop();
		}

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('data/freeplaySonglist'));

		//var diffList = "";

		songData = [];
		songs = [];

		for (i in 0...initSonglist.length)
		{
			var data:Array<String> = initSonglist[i].split(':');
			var meta = new SongMetadata(data[0], Std.parseInt(data[2]), data[1]);
			var format = StringTools.replace(meta.songName, " ", "-").toLowerCase();

			var diffs = [];
			var diffsThatExist = [];


			#if sys
			if (FileSystem.exists('assets/data/${format}/${format}-hell.json'))
				diffsThatExist.push("HELL");
			if (FileSystem.exists('assets/data/${format}/${format}-hard.json'))
				diffsThatExist.push("HARD");
			if (FileSystem.exists('assets/data/${format}/${format}-easy.json'))
				diffsThatExist.push("EASY");
			if (FileSystem.exists('assets/data/${format}/${format}.json'))
				diffsThatExist.push("NORMAL");

			if (diffsThatExist.length == 0)
			{
				Application.current.window.alert("No difficulties found for chart, skipping.",meta.songName + " Chart");
				continue;
			}
			#else
			diffsThatExist = ["EASY","NORMAL","HARD","HELL"];
			#end
			if (diffsThatExist.contains("EASY"))
				FreeplayState.loadDiff(0,format,meta.songName,diffs);
			if (diffsThatExist.contains("NORMAL"))
				FreeplayState.loadDiff(1,format,meta.songName,diffs);
			if (diffsThatExist.contains("HARD"))
				FreeplayState.loadDiff(2,format,meta.songName,diffs);
			if (diffsThatExist.contains("HELL"))
				FreeplayState.loadDiff(3,format,meta.songName,diffs);

			meta.diffs = diffsThatExist;

			FreeplayState.songData.set(meta.songName,diffs);

			if (songUnlocked[i])
				songs.push(meta);
			else if (songVisible[i])
			{
				meta.songCharacter = "lock";
				songs.push(meta);
			}

		}

		#if sys
		for(i in FileSystem.readDirectory("assets/sm/"))
		{
			if (FileSystem.isDirectory("assets/sm/" + i))
			{
				for (file in FileSystem.readDirectory("assets/sm/" + i))
				{
					if (file.contains(" "))
						FileSystem.rename("assets/sm/" + i + "/" + file,"assets/sm/" + i + "/" + file.replace(" ","_"));
					if (file.endsWith(".sm"))
					{
						var file:SMFile = SMFile.loadFile("assets/sm/" + i + "/" + file.replace(" ","_"));
						var data = file.convertToFNF("assets/sm/" + i + "/converted.json");
						var meta = new SongMetadata(file.header.TITLE, 0, "sm",file,"assets/sm/" + i);
						songs.push(meta);
						var song = Song.loadFromJsonRAW(data);
						songData.set(file.header.TITLE, [song,song,song]);
					}
				}
			}
		}
		#end

		//trace("\n" + diffList);

		/*
			if (FlxG.sound.music != null)
			{
				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
		 */

		 #if windows
		 // Updating Discord Rich Presence
		 DiscordClient.changePresence("In the Freeplay Menu", null);
		 #end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		persistentUpdate = true;

		// LOAD MUSIC

		// LOAD CHARACTERS

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		bg.antialiasing = FlxG.save.data.antialiasing;
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false, true);
			if (i == 4 && !songUnlocked[i])
				songText = new Alphabet(0, (70 * i) + 30, 'Secret', true, false, true);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		var bgHeight:Int = 105;
		if (StoryMenuState.girlfriendUnlocked[1] && StoryMenuState.characterUnlocked[1])
		{
			bgHeight = 210;
		}
		else if (StoryMenuState.girlfriendUnlocked[1] || StoryMenuState.characterUnlocked[1])
		{
			bgHeight = 160;
		}

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), bgHeight, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		diffCalcText = new FlxText(scoreText.x, scoreText.y + 66, 0, "", 24);
		diffCalcText.font = scoreText.font;
		add(diffCalcText);

		previewtext = new FlxText(scoreText.x, scoreText.y + 94, 0, "" + (KeyBinds.gamepad ? "X" : "SPACE") + " to preview", 24);
		previewtext.font = scoreText.font;
		//add(previewtext);

		comboText = new FlxText(diffText.x + 100, diffText.y, 0, "", 24);
		comboText.font = diffText.font;
		add(comboText);

		unlockText = new FlxText(diffText.x + 175, diffText.y, 0, "", 20);
		unlockText.font = scoreText.font;
		add(unlockText);

		// https://twitter.com/Saberspark/status/1423115380529278980?s=20
		// I'm so fucking tired man
		if (StoryMenuState.characterUnlocked[1])
		{
			charText = new FlxText(comboText.x - 30, comboText.y + 65, 0, "Tab to switch", 24);
			charText.font = comboText.font;
			add(charText);

			charIcon = new HealthIcon('bf', true);
			switch (curCharacter)
			{
				case 0:
					charIcon.animation.play('bf');
				case 1:
					charIcon.animation.play('bf-retro');
				case 2:
					charIcon.animation.play('bf-ace');
			}
			charIcon.setPosition(charText.x - 110, comboText.y + 10);
			charIcon.scale.set(0.5, 0.5);
			add(charIcon);
		}
		if (StoryMenuState.girlfriendUnlocked[1])
		{
			gfText = new FlxText(comboText.x - 30, comboText.y + 65, 0, "Ctrl to switch", 24);
			gfText.font = comboText.font;
			add(gfText);

			gfIcon = new HealthIcon('gf', true);
			switch (curGf)
			{
				case 0:
					gfIcon.animation.play('gf');
				case 1:
					gfIcon.animation.play('sakuroma');
			}
			gfIcon.setPosition(gfText.x - 110, comboText.y + 10);
			gfIcon.scale.set(0.5, 0.5);
			add(gfIcon);

			if (StoryMenuState.characterUnlocked[1])
			{
				gfText.y += 55;
				gfIcon.y += 50;
			}
		}

		add(scoreText);

		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/*
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */
		fadeBG = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height);
		fadeBG.color = FlxColor.BLACK;
		fadeBG.alpha = 0.9;
		fadeBG.visible = false;

		unlockSprite = new Character(0, 0, 'bf-retro', true);
		unlockSprite.scale.set(0.5, 0.5);
		unlockSprite.screenCenter();
		unlockSprite.visible = false;

		unlockDescription = new FlxText(FlxG.width / 2, 600);
		unlockDescription.setFormat("VCR OSD Mono", 32, FlxColor.WHITE);
		unlockDescription.screenCenter(X);
		unlockDescription.visible = false;

		add(fadeBG);
		add(unlockSprite);
		add(unlockDescription);

		displayUnlocks();

		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['dad'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (unlocking && !stopSpamming)
		{
			if (controls.ACCEPT || controls.BACK)
			{
				stopSpamming = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

				// Remove the current unlocked item
				justUnlocked.splice(0, 1);

				FlxTween.tween(unlockSprite, {alpha: 0}, 0.5);
				FlxTween.tween(unlockDescription, {alpha: 0}, 0.5, {onComplete: function(flx:FlxTween)
				{
					displayUnlocks();
				}});
			}

			return;
		}

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;
		comboText.text = combo + '\n';

		if (FlxG.sound.music.volume > 0.8)
		{
			FlxG.sound.music.volume -= 0.5 * FlxG.elapsed;
		}

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		//if (FlxG.keys.justPressed.SPACE && !openedPreview)
			//openSubState(new DiffOverview());

		if (controls.LEFT_P)
			changeDiff(-1);
		if (controls.RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}
		else if (FlxG.keys.justPressed.TAB)
			changeChar();
		else if (FlxG.keys.justPressed.CONTROL)
			changeGf();

		if (accepted)
		{
			switch(songs[curSelected].songName)
			{
				case 'Spectral':
					if (!songUnlocked[1])
						return;
				case 'Ectospasm':
					if (!songUnlocked[3])
						return;
				case 'Fuzzy-Feeling':
					if (!songUnlocked[4])
						return;
			}

			// adjusting the song name to be compatible
			var songFormat = StringTools.replace(songs[curSelected].songName, " ", "-");
			var hmm;
			try
			{
				if (songFormat == 'Ectospasm')
					hmm = songData.get(songs[curSelected].songName)[0];
				else
					hmm = songData.get(songs[curSelected].songName)[curDifficulty];
				if (hmm == null)
					return;
			}
			catch(ex)
			{
				return;
			}

			PlayState.SONG = hmm;
			PlayState.isStoryMode = false;
			PlayState.storyMode = 0;
			PlayState.bfCharacter = curCharacter == 0 ? 'bf' : curCharacter == 1 ? 'bf-retro' : 'bf-ace';
			PlayState.gfCharacter = curGf == 0 ? 'gf' : 'sakuroma';
			if (songFormat == 'Ectospasm')
				PlayState.storyDifficulty = 3;
			else
				PlayState.storyDifficulty = curDifficulty;
			#if sys
			if (songs[curSelected].songCharacter == "sm")
				{
					PlayState.isSM = true;
					PlayState.sm = songs[curSelected].sm;
					PlayState.pathToSm = songs[curSelected].path;
				}
			else
				PlayState.isSM = false;
			#else
			PlayState.isSM = false;
			#end
			LoadingState.loadAndSwitchState(new PlayState());
		}
	}

	function changeDiff(change:Int = 0)
	{
		if (songs[curSelected].songName == 'Ectospasm')
			return;

		if (!songs[curSelected].diffs.contains(CoolUtil.difficultyFromInt(curDifficulty + change)))
			return;

		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 3;
		if (curDifficulty > 3)
			curDifficulty = 0;


		// adjusting the highscore song name to be compatible (changeDiff)
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");

		#if !switch
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		#end
		if (songs[curSelected].songName == 'Ectospasm')
		{
			//diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[0])}';
			diffCalcText.text = 'RATING: ${difficultyRatings[curSelected][0])}';
			diffText.text = CoolUtil.difficultyFromInt(3).toUpperCase();
		}
		else
		{
			//diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[curDifficulty])}';
			diffCalcText.text = 'RATING: ${difficultyRatings[curSelected][curDifficulty])}';
			diffText.text = CoolUtil.difficultyFromInt(curDifficulty).toUpperCase();
		}
	}

	function changeChar()
	{
		if (!StoryMenuState.characterUnlocked[1])
			return;

		curCharacter++;

		if (curCharacter > 2)
			curCharacter = 0;

		switch (curCharacter)
		{
			case 0:
				charIcon.animation.play('bf');
			case 1:
				charIcon.animation.play('bf-retro');
			case 2:
				charIcon.animation.play('bf-ace');
		}
	}

	function changeGf()
	{
		if (!StoryMenuState.girlfriendUnlocked[1])
			return;

		curGf++;

		if (curGf > 1)
			curGf = 0;

		switch (curGf)
		{
			case 0:
				gfIcon.animation.play('gf');
			case 1:
				gfIcon.animation.play('sakuroma');
		}
	}

	function changeSelection(change:Int = 0)
	{
		#if !switch
		// NGio.logEvent('Fresh');
		#end

		// NGio.logEvent('Fresh');
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);



		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		/*if (songs[curSelected].diffs.length != 3)
		{
			switch(songs[curSelected].diffs[0])
			{
				case "Easy":
					curDifficulty = 0;
				case "Normal":
					curDifficulty = 1;
				case "Hard":
					curDifficulty = 2;
				case "Hell":
					curDifficulty = 3;
			}
		}*/

		// selector.y = (70 * curSelected) + 30;

		// adjusting the highscore song name to be compatible (changeSelection)
		// would read original scores if we didn't change packages
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");

		#if !switch
		if (songHighscore == 'Ectospasm')
			intendedScore = Highscore.getScore(songHighscore, 3);
		else
			intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		// lerpScore = 0;
		#end

		// Text showing how to unlock the song
		unlockText.text = "";
		switch(songs[curSelected].songName)
		{
			case 'Spectral':
				if (!songUnlocked[1])
				{
					FlxG.sound.music.pause();
					unlockText.text = "Beat Wrath Story";
				}
				else
				{
					FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
				}
			case 'Ectospasm':
				if (!songUnlocked[3])
				{
					FlxG.sound.music.pause();
					unlockText.text = "Beat Wrath Story";
				}
				else
				{
					FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
				}
			case 'Fuzzy-Feeling':
				if (!songUnlocked[4])
				{
					FlxG.sound.music.pause();
					unlockText.text = "Ectospasm Secret";
				}
				else
				{
					FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
				}
			default:
				FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		}

		if (songHighscore == "Ectospasm")
		{
			//diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[0])}';
			diffCalcText.text = 'RATING: ${difficultyRatings[curSelected][0])}';
			diffText.text = CoolUtil.difficultyFromInt(3).toUpperCase();
		}
		else
		{
			//diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[curDifficulty])}';
			diffCalcText.text = 'RATING: ${difficultyRatings[curSelected][curDifficulty])}';
			diffText.text = CoolUtil.difficultyFromInt(curDifficulty).toUpperCase();
		}

		#if PRELOAD_ALL
		if (songs[curSelected].songCharacter == "sm")
		{
			var data = songs[curSelected];
			var bytes = File.getBytes(data.path + "/" + data.sm.header.MUSIC);
			var sound = new Sound();
			sound.loadCompressedDataFromByteArray(bytes.getData(), bytes.length);
			FlxG.sound.playMusic(sound);
		}
		#end

		var hmm;
			try
			{
				if (songHighscore == "Ectospasm")
				{
					hmm = songData.get(songs[curSelected].songName)[3];
				}
				else
				{
					hmm = songData.get(songs[curSelected].songName)[curDifficulty];
				}

				if (hmm != null)
					Conductor.changeBPM(hmm.bpm);
			}
			catch(ex)
			{}

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
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

		if (songHighscore == 'Ectospasm')
			diffText.text = "HELL";
		else
		{
			switch (curDifficulty)
			{
				case 0:
					diffText.text = "EASY";
				case 1:
					diffText.text = 'NORMAL';
				case 2:
					diffText.text = "HARD";
				case 3:
					diffText.text = "HELL";
			}
		}
	}

	function displayUnlocks()
	{
		unlocking = true;

		// Nothing left to unlock
		if (justUnlocked.length == 0)
		{
			FlxTween.tween(fadeBG, {alpha: 0}, 0.5);
			FlxTween.tween(unlockSprite, {alpha: 0}, 0.5);
			FlxTween.tween(unlockDescription, {alpha: 0}, 0.5, {onComplete: function(flx:FlxTween)
			{
				fadeBG.visible = false;
				unlockSprite.visible = false;
				unlockDescription.visible = false;
				remove(fadeBG);
				remove(unlockSprite);
				remove(unlockDescription);

				unlocking = false;
				stopSpamming = false;
			}});
			return;
		}

		// Figure out what's being unlocked
		switch(justUnlocked[0])
		{
			// Songs
			case 'ectospasm':
				remove(unlockSprite);
				unlockSprite = new Alphabet(0, 0, 'Ectospasm', true, false, true);
				unlockSprite.screenCenter();
				add(unlockSprite);

				unlockDescription.text = "New song unlocked in Freeplay!";
				unlockDescription.screenCenter(X);
			case 'saku-secret':
				remove(unlockSprite);
				unlockSprite = new Alphabet(0, 0, 'Fuzzy Feeling', true, false, true);
				unlockSprite.screenCenter();
				add(unlockSprite);

				unlockDescription.text = "New song unlocked in Freeplay!";
				unlockDescription.screenCenter(X);
			// Gfs
			case 'gf-saku':
				remove(unlockSprite);
				unlockSprite = new Character(0, 0, 'gf-saku');
				unlockSprite.scale.set(0.5, 0.5);
				unlockSprite.screenCenter();
				unlockSprite.x -= 50;
				add(unlockSprite);

				unlockDescription.text = "A new girlfriend has appeared in story mode!";
				unlockDescription.screenCenter(X);
		}

		if (unlockSprite.alpha == 0)
			FlxTween.tween(unlockSprite, {alpha: 1}, 0.5);
		if (unlockDescription.alpha == 0)
			FlxTween.tween(unlockDescription, {alpha: 1}, 0.5);

		stopSpamming = false;
		fadeBG.visible = true;
		unlockSprite.visible = true;
		unlockDescription.visible = true;
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	#if sys
	public var sm:SMFile;
	public var path:String;
	#end
	public var songCharacter:String = "";

	public var diffs = [];

	#if sys
	public function new(song:String, week:Int, songCharacter:String, ?sm:SMFile = null, ?path:String = "")
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.sm = sm;
		this.path = path;
	}
	#else
	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
	#end
}
