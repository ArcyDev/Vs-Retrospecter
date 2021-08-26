package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.Exception;
import lime.app.Application;

#if sys
import smTools.SMFile;
import sys.FileSystem;
#end

#if sys
import sys.io.File;
#end

class LoadReplayState extends MusicBeatState
{
	var curSelected:Int = 0;

    var songs:Array<FreeplayState.SongMetadata> = [];

	var controlsStrings:Array<String> = [];
    var actualNames:Array<String> = [];

	private var grpControls:FlxTypedGroup<Alphabet>;
	var versionShit:FlxText;
	var poggerDetails:FlxText;
	override function create()
	{
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        #if sys
		controlsStrings = sys.FileSystem.readDirectory(Sys.getCwd() + "/assets/replays/");
        #end

        controlsStrings.sort(sortByDate);

        for(i in 0...controlsStrings.length)
        {
            var string:String = controlsStrings[i];
            actualNames[i] = string;
			var rep:Replay = Replay.LoadReplay(string);
            controlsStrings[i] = string.split("time")[0] + " " + CoolUtil.difficultyFromInt(rep.replay.songDiff).toUpperCase();
        }

        if (controlsStrings.length == 0)
            controlsStrings.push("No Replays...");

		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = FlxG.save.data.antialiasing;
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...controlsStrings.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, controlsStrings[i], true, false);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
			grpControls.add(controlLabel);
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}


		versionShit = new FlxText(5, FlxG.height - 34, 0, "Replay Loader (ESCAPE TO GO BACK)\nNOTICE!!!! Replays are in a beta stage, and they are probably not 100% correct. expect misses and other stuff that isn't there!\n", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);


		poggerDetails = new FlxText(5, 34, 0, "Replay Details - \nnone", 12);
		poggerDetails.scrollFactor.set();
		poggerDetails.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(poggerDetails);

		changeSelection(0);

		super.create();
	}

	function sortByDate(a:String, b:String) {
		var aTime = Std.parseFloat(a.split("time")[1])/1000;
		var bTime = Std.parseFloat(b.split("time")[1])/1000;

		return Std.int(bTime - aTime); // Newest first
	}

    public function getWeekNumbFromSong(songName:String):Int
    {
        var week:Int = 0;
        for (i in 0...songs.length)
        {
            var pog:FreeplayState.SongMetadata = songs[i];
            if (pog.songName == songName)
                week = pog.week;
        }
        return week;
    }

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
        {
            songs.push(new FreeplayState.SongMetadata(songName, weekNum, songCharacter));
        }

        public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
        {
            if (songCharacters == null)
                songCharacters = ['bf'];

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

			if (controls.BACK)
				FlxG.switchState(new OptionsMenu());
			if (controls.UP_P)
				changeSelection(-1);
			if (controls.DOWN_P)
				changeSelection(1);


			if (controls.ACCEPT && grpControls.members[curSelected].text != "No Replays...")
			{
                PlayState.rep = Replay.LoadReplay(actualNames[curSelected]);

                PlayState.loadRep = true;

				if (PlayState.rep.replay.replayGameVer == Replay.version)
				{

					// adjusting the song name to be compatible
					var songFormat = StringTools.replace(PlayState.rep.replay.songName, " ", "-");

					var poop = "";

					#if sys
					if (PlayState.rep.replay.sm)
						if (!FileSystem.exists(StringTools.replace(PlayState.rep.replay.chartPath,"converted.json","")))
						{
							Application.current.window.alert("The SM file in this replay does not exist!","SM Replays");
							return;
						}
					#end

					PlayState.isSM = PlayState.rep.replay.sm;
					#if sys
					if (PlayState.isSM)
						PlayState.pathToSm = StringTools.replace(PlayState.rep.replay.chartPath,"converted.json","");
					#end

					#if sys
					if (PlayState.isSM)
					{
						poop = File.getContent(PlayState.rep.replay.chartPath);
						try
							{
						PlayState.sm = SMFile.loadFile(PlayState.pathToSm + "/" + StringTools.replace(PlayState.rep.replay.songName," ", "_") + ".sm");
							}
							catch(e:Exception)
							{
								Application.current.window.alert("Make sure that the SM file is called " + PlayState.pathToSm + "/" + StringTools.replace(PlayState.rep.replay.songName," ", "_") + ".sm!\nAs I couldn't read it.","SM Replays");
								return;
							}
					}
					else
						poop = Highscore.formatSong(songFormat, PlayState.rep.replay.songDiff);
					#else
					poop = Highscore.formatSong(songFormat, PlayState.rep.replay.songDiff);
					#end

					try
					{
					if (PlayState.isSM)
						PlayState.SONG = Song.loadFromJsonRAW(poop);
					else
						PlayState.SONG = Song.loadFromJson(poop, PlayState.rep.replay.songName);
					}
					catch(e:Exception)
					{
						Application.current.window.alert("Failed to load the song! Does the JSON exist?","Replays");
						return;
					}
					PlayState.isStoryMode = false;
					PlayState.storyDifficulty = PlayState.rep.replay.songDiff;
					LoadingState.loadAndSwitchState(new PlayState());
				}
				else
				{
					PlayState.rep = null;
					PlayState.loadRep = false;
				}
			}
	}

	function changeSelection(change:Int = 0)
	{
		#if !switch
		// NGio.logEvent('Fresh');
		#end

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;

		var rep:Replay = Replay.LoadReplay(actualNames[curSelected]);

		poggerDetails.text = "Replay Details - \nDate Created: " + rep.replay.timestamp + "\nSong: " + rep.replay.songName + "\nReplay Version: " + rep.replay.replayGameVer + ' (' + (rep.replay.replayGameVer != Replay.version ? "OUTDATED not useable!" : "Latest") + ')\n';

		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpControls.members)
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
}
