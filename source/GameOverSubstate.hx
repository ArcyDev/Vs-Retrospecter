package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

	var allowRetry:Bool = true;
	var disableInput:Bool = false;
	var dialogueIndex:Int = 0;

	var ectospasmHintDialogue:Array<String> = ["Sorry about the poison notes. Do you want me to disable them?", "TOO BAD. THIS SONG IS HARD FOR A REASON. HAHAHA.", "THERE'S A NICE REWARD IN IT, IF YOU MAKE IT TO THE END...", "BUUUUT IF YOU WANNA TAKE THE COWARD'S WAY OUT, I'LL GIVE YOU A HINT.", "TYPE THE FIRST PARAGRAPH OF THE ROSY MAPLE MOTH'S WIKIPEDIA PAGE IN THE STORY MENU.", "NO SPACES OR PUNCTUATION. OTHERWISE, FIGHT ME LIKE A MAN!"];
	static var ectospasmInsultDialogue:Array<String> = [
		"ACID IS GREAT FOR YOUR SKIN COMPLEXION.",
		"THE OPTION'S STILL THERE TO TYPE UP THAT WIKI PAGE.",
		"NICE WHIFF. GET IT CUZ TOXINS. HAHA!",
		"ARE YOU STILL STREAMING THIS? GOD I HOPE SO.",
		"WHAT'S IT LIKE ALL THE WAY DOWN THERE?",
		"OOO RETRY NUMBER 7. MY FAVORITE NUMBER. LET'S MIX THINGS UP A BIT THIS TIME, SHALL WE?",
		"YOU'RE SUPPOSED TO MISS THE POISON NOTES. NOT HIT THEM.",
		"COME ON, GIRLFRIEND. LET'S GRAB SOME MCDEMON'S.",
		"ACE WAS NICE TO YOU. WHAT MADE YOU THINK I WOULD BE? HAHA.",
		"DON'T WORRY. THAT'LL WASH RIGHT OUT.",
		"HI MOM.",
		"YOU LOOK LIKE MY VARIOUS BODY FLUIDS. GROSS.",
		"AWW. YOU GOT IT ALL OVER MY STRETCHY PANTS :(",
		"WHY DO I EVEN WASTE MY TIME WITH YOU? HAHA.",
		"DO YOUR FINGERS HURT YET? CUZ MINE DON'T.",
		"IZZURIUS IS GONNA MAKE A NICE POTION OUT OF YOUR REMAINS.",
		"HAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHA!",
		"I HAVE A TATTOO ON MY BACK. Just thought you should know. TRIVIA.",
		"HOW MANY TIMES ARE YOU GONNA DIE ON PURPOSE JUST TO SEE THESE LINES?",
		"OH YOU'LL DEFINITELY GET IT NEXT TRY. TRUST ME. HAHA.",
		"I'D LIKE TO SEE ATROCEAN DO BETTER THAN THIS.",
		"I'LL CALL INSATIAN OVER TO PICK UP AND DEVOUR YOUR BONES.",
		"4 BALLS. THAT'S CALLED A DOUBLE TEABAG.",
		"IF YOU CAN'T EVEN BEAT THIS PHASE, THEN GOOD LUCK IN PART 2.",
		"STOP RAGING. YOUR MOMMY'S GONNA HEAR YOU.",
		"HAVE YOU EVEN GOTTEN HALFWAY THROUGH THE SONG YET? HAHA.",
		"DID YOU LIKE THE THORNS REFERENCE? I did...",
		"YOU WANT TO SEE MOTH BOOBA, DON'T YOU? TRY HARDER.",
		"I DREAD TO THINK WHAT SAKUROMA IS GONNA DO WITH YOU NOW.",
		"HIVEMINE'S GONNA SELL YOUR REMAINS FOR A PRETTY PENNY.",
		"YOU ARE SO SMALL. IS FUNNY TO ME.",
		"HAHA. WHAT A MISERABLE, LITTLE PILE.",
		"SKILL ISSUE.",
		"SUCKS TO SUCK. HAHAHAHA!",
		"CRY ABOUT IT. OH WAIT, YOU CAN'T!",
		"I'M HONESTLY SURPRISED YOU'VE FAILED THIS MUCH.",
		"JUST GIVE UP ALREADY, FOR BOTH OF OUR SAKE'S.",
		"LIFE IS GREAT. I GET TO JUST WATCH YOU SUFFER OVER AND OVER AGAIN.",
		"AWW, WHAT'S WRONG? BABY'S HANDS HURT?",
		"*crys* WHY. ARE YOU SO BAD.",
		"I HAVEN'T EVEN RUN OUT OF THINGS TO SAY YET. I CAN GO ALL DAY.",
		"YOUR TEARS ARE DELCIOUS, AND TASTE LIKE MY POISON.",
		"JUST GET GOOD ALREADY. MOST PEOPLE HAVE BEATEN THIS SONG BY NOW.",
		"I'M HONESTLY GETTING BORED AT THIS POINT.",
		"WHAT MAKES YOU THINK YOU CAN BEAT PART TWO'S BONUS SONG IF YOU CAN'T BEAT THIS ONE?",
		"JUST GO COMPLAIN ABOUT THIS PART ON GAMEBANANA ALREADY.",
		"MIND IF I TAKE A BREAK FROM INSULTING YOU TO TELL YOU A STORY?",
		"SO LIKE, LIFE IS GOOD AND ALL, BUT I'M HAVING SOME SELF-DOUBT ISSUES.",
		"BEING THE GATEKEEPER AND ALL IS A LOT OF RESPONSIBILITY.",
		"AND I KNOW I HAVE A BIT OF A TEMPER. HAHA.",
		"BUT I JUST WANT PEOPLE TO LIKE ME, YOU KNOW?",
		"I WANT TO FEEL VALIDATED.",
		"I WANT TO FEEL LIKE I MATTER IN THIS WORLD.",
		"BUT IT'S HARD TO FEEL IMPORTANT WHEN SO MANY OTHER PEOPLE EXIST...",
		"AND DO YOUR JOB BETTER THAN YOU.",
		"I JUST HOPE I DO A GOOD ENOUGH JOB TO MAKE PEOPLE HAPPY.",
		"THANKS FOR LETTING ME VENT, BOYFRIEND. BACK TO INSULTING YOU.",
		"YOU'RE FAT.",
		"YOUR MOM'S FAT.",
		"I'm fat :(",
		"I'M LEGIT RUNNING OUT OF THINGS TO SAY.",
		"I HOPE YOU GUYS LIKED THE MOD.",
		"PLEASE GO SUPPORT EVERYONE WHO WORKED ON IT IN THE CREDITS.",
		"rawr :3",
		"PLEASE JUST GO TYPE IN THE CHEAT CODE ALREADY.",
		"YOU'RE JUST DYING ON PURPOSE TO READ ALL THESE, AREN'T YOU?",
		"YAWN. I'M GETTING BORED.",
		"DID YOU KNOW I HAVE 2 DICKS?",
		"I ALSO LEAK ACID FROM MY HORNS.",
		"HOW ARE YOU GONNA HANDLE THE OTHER 6 SINS IF YOU CAN'T HANDLE ME?",
		"AND THE 7 HOLY VIRTUES.",
		"AND THE 4 HORSEMEN OF THE APOCALYPSE.",
		"JUST KIDDING. WE'LL PROBABLY BE BURNT OUT AFTER VS SAKUROMA.",
		"I'M HONESTLY JUST TYPING ANYTHING AT THIS POINT.",
		"100 LINES WAS A MISTAKE.",
		"PLEASE END MY MISERY.",
		"HERE, HAVE SOME FANSERVICE.",
		"*I take my shirt off* ;0",
		"OH WOW. IT IS HOT IN HERE. MAN I AM SWEATING.",
		"WINKY FACE",
		"OKAY THAT'S ENOUGH.",
		"RUNNING OUT OF LINES TO SAY...",
		"YOU SMELL.",
		"YOU'RE DUMB.",
		"MY VOICE HURTS FROM ALL THIS YELLING AT YOU.",
		"THE SHORTER CODE IS 'MOMMYMOTHYMILKIES' PLEASE JUST LEAVE ME ALONE.",
		"UGHHHHHHHHHHHHHH",
		"YOU SUCK.",
		"I GUESS I'LL USE THIS TIME TO EDUCATE YOU ABOUT THE OTHER SINS.",
		"SAKUROMA IS LUST. SHE'S A MOTH. SHE'S CUTE, BUT ANNOYING.",
		"IZZURIUS IS PRIDE. HE'S A PLAGUE CROW. HE MADE MY CLOTHES.",
		"THAT'S WHY MY PANTS DON'T TEAR. HE MADE THEM. THEY'RE STRETCHY.",
		"INSATIAN IS GLUTTONY. I DON'T KNOW MUCH ABOUT HER HONESTLY. SHE'S WEIRD.",
		"HIVEMINE IS GREED. SHE'S INTERESTING, BUT SHE KEEPS TRYING TO STEAL MY CRYSTALS.",
		"ATROCEAN IS ENVY. HE'S JUST A STRAIGHT UP DICK. I HATE HIM.",
		"DOZIRC IS SLOTH. HE'S A PRETTY COOL DUDE HONESTLY. VERY LAID BACK.",
		"ALRIGHT I'M NEARING THE 100 QUOTES I WAS CONTRACTUALLY OBLIGATED TO DO.",
		"IT'S BEEN FUN, BOYFRIEND. I ENJOYED MAULING YOU OVER AND OVER AGAIN.",
		"LET'S DO THIS AGAIN SOMETIME, OKAY?",
		"FAREWELL. SEE YOU IN PART 2.",
		"I WILL NOW REPEAT EVERYTHING I JUST SAID."
	];

	var deathInitialSfx:FlxSound;
	var deathLoopSfx:FlxSound;

	var isOnLoop = false;
	var stageSuffix:String = "";

	private var wrathDeathLoopSpriteOffset = new FlxPoint(0, 0);

	public function new(x:Float, y:Float)
	{
		var daBf:String = '';
		switch (PlayState.SONG.player1)
		{
			case 'bf-retro':
				daBf = 'bf-retro';
			case 'bf-retro-wrath':
				daBf = 'bf-retro-wrath';
			case 'bf-ace':
				daBf = 'bf-ace';
			case 'bf-ace-wrath':
				daBf = 'bf-ace-wrath';
			case 'bf-wrath':
				if (PlayState.SONG.song == 'Spectral' || PlayState.SONG.song == 'Ectospasm')
					daBf = 'bf-wrath-death';
				else
					daBf = 'bf';
			default:
				// Special case for optimized mode
				if (PlayState.SONG.song == 'Spectral' || PlayState.SONG.song == 'Ectospasm')
					daBf = 'bf-wrath-death';
				else
					daBf = 'bf';
		}

		super();
		Conductor.songPosition = 0;
		PlayState.firstTry = false;

		bf = new Boyfriend(x, y, daBf);
		add(bf);

		// Is offset for some reason
		if (daBf == 'bf-wrath-death')
			camFollow = new FlxObject(bf.getGraphicMidpoint().x - 350, bf.getGraphicMidpoint().y - 50, 1, 1);
		else
			camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		if(daBf == 'bf-wrath-death') {
			deathInitialSfx = new FlxSound().loadEmbedded(Paths.sound("deathSfxInitial"));
			deathLoopSfx = new FlxSound().loadEmbedded(Paths.sound("bfDeathLoop"), true);
			FlxG.sound.list.add(deathInitialSfx);
			FlxG.sound.list.add(deathLoopSfx);

			deathInitialSfx.play();

			new FlxTimer().start(deathInitialSfx.length / 1000, (tmr:FlxTimer) -> {
				deathLoopSfx.play(true);
			});
		}

		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));


		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');
		if (daBf == 'bf-wrath-death')
		{
			bf.animation.finishCallback = function(str:String)
			{
				bf.animation.finishCallback = null;
				isOnLoop = true;
				startVibin = true;
				// This gets called before update
				FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
				remove(bf);
				bf = new Boyfriend(x + wrathDeathLoopSpriteOffset.x, y + wrathDeathLoopSpriteOffset.y, 'bf-wrath-death2');
				bf.playAnim('deathLoop');
				add(bf);

				if (PlayState.SONG.song == 'Ectospasm' && (PlayState.deaths >= 1 || PlayState.shownHint))
				{
					add(PlayState.retroPortrait);
					add(PlayState.speechBubble);
					add(PlayState.hintDropText);
					add(PlayState.hintText);

					PlayState.retroPortrait.animation.play('Enraged');
					FlxTween.tween(PlayState.retroPortrait, {alpha: 1}, 0.1);
					PlayState.speechBubble.animation.play('normalOpen');
					PlayState.speechBubble.animation.finishCallback = function(anim:String):Void
					{
						if (PlayState.deaths >= 1 && !PlayState.shownHint)
						{
							PlayState.hintText.resetText(ectospasmHintDialogue[dialogueIndex]);
						}
						else
						{
							PlayState.hintText.resetText(ectospasmInsultDialogue[PlayState.deaths]);
						}
						PlayState.hintText.start(0.04, true);
						PlayState.hintText.completeCallback = function()
						{
							disableInput = false;
						}
					}
				}
			};
		}
		else if (PlayState.SONG.song == 'Ectospasm' && (daBf == 'bf-retro-wrath' || daBf == 'bf-ace-wrath'))
		{
			bf.animation.finishCallback = function(str:String)
			{
				bf.animation.finishCallback = null;
				isOnLoop = true;
				startVibin = true;
				if (PlayState.deaths >= 1 || PlayState.shownHint)
				{
					add(PlayState.retroPortrait);
					add(PlayState.speechBubble);
					add(PlayState.hintDropText);
					add(PlayState.hintText);

					PlayState.retroPortrait.animation.play('Enraged');
					FlxTween.tween(PlayState.retroPortrait, {alpha: 1}, 0.1);
					PlayState.speechBubble.animation.play('normalOpen');
					PlayState.speechBubble.animation.finishCallback = function(anim:String):Void
					{
						if (PlayState.deaths >= 1 && !PlayState.shownHint)
						{
							PlayState.hintText.resetText(ectospasmHintDialogue[dialogueIndex]);
						}
						else
						{
							PlayState.hintText.resetText(ectospasmInsultDialogue[PlayState.deaths]);
						}
						PlayState.hintText.start(0.04, true);
						PlayState.hintText.completeCallback = function()
						{
							disableInput = false;
						}
					}
				}
			}
		}

		// (Arcy) No Fail mode unlock
		if (!StoryMenuState.modeUnlocked[1])
		{
			StoryMenuState.modeUnlocked[1] = true;
			FlxG.save.data.modeUnlocked = StoryMenuState.modeUnlocked;

			StoryMenuState.unlockedModes.push('nofail');
			FlxG.save.flush();
		}

		// Count the deaths for Ectospasm
		if (PlayState.SONG.song == 'Ectospasm')
		{
			PlayState.deaths++;
			if (PlayState.deaths >= ectospasmInsultDialogue.length)
			{
				PlayState.deaths = 0;
			}
		}

		if (PlayState.SONG.song == 'Ectospasm' && PlayState.deaths >= 1 && !PlayState.shownHint)
		{
			PlayState.instance.camHUD.zoom = 1;
			disableInput = true;
			allowRetry = false;
		}

		// (Arcy) Don't allow skipping on the special chart dialogue
		if (PlayState.SONG.song == 'Ectospasm' && PlayState.deaths == 5 && PlayState.shownHint)
		{
			disableInput = true;
		}

		if(allowRetry && !disableInput && FlxG.save.data.InstantRespawn)
		{
			LoadingState.loadAndSwitchState(new PlayState());
		}
	}

	var startVibin:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT && allowRetry && !disableInput)
		{
			endBullshit();
		}
		else if (controls.ACCEPT && startVibin && !disableInput)
		{
			dialogueIndex++;
			if (dialogueIndex >= ectospasmHintDialogue.length)
			{
				PlayState.shownHint = true;
				PlayState.deaths = -1;
				endBullshit();
			}
			else
			{
				FlxG.sound.play(Paths.sound('clickText'), 0.4);
				PlayState.hintText.resetText(ectospasmHintDialogue[dialogueIndex]);
				PlayState.hintText.start(0.04, true);
			}
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			if(deathLoopSfx != null) {
				deathLoopSfx.stop();
			}

			if (PlayState.isStoryMode)
				FlxG.switchState(new StoryMenuState());
			else
				FlxG.switchState(new FreeplayState());
			PlayState.loadRep = false;
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
			startVibin = true;
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}

		if (PlayState.hintDropText.text != PlayState.hintText.text)
			PlayState.hintDropText.text = PlayState.hintText.text;
	}

	override function beatHit()
	{
		super.beatHit();

		if (startVibin && !isEnding)
		{
			bf.playAnim('deathLoop', true);
		}
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			PlayState.startTime = 0;
			isEnding = true;

			// If they retry early, swap the sprite here.
			if(!isOnLoop && bf.curCharacter == 'bf-wrath-death')
			{
				remove(bf);
				bf = new Boyfriend(bf.x, bf.y, 'bf-wrath-death2');
				bf.playAnim('deathLoop');
				add(bf);
			}

			bf.playAnim('deathConfirm', true);

			FlxG.sound.music.stop();

			if(deathLoopSfx != null) {
				deathLoopSfx.stop();
			}

			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));

			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.cameras.list[FlxG.cameras.list.length - 1].fade(FlxColor.BLACK, 2, false);
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					// 7th retry easter egg chart
					if (PlayState.SONG.song == 'Ectospasm' && PlayState.deaths == 5 && PlayState.shownHint)
					{
						PlayState.SONG = Song.loadFromJson('ectospasm-truehell', 'ectospasm');
					}
					else if (PlayState.SONG.song == 'Ectospasm' && PlayState.deaths == 6)
					{
						PlayState.SONG = Song.loadFromJson('ectospasm-hell', 'ectospasm');
					}

					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
