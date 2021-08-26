package;

import flixel.FlxG;
import flixel.FlxSprite;

import ChromaticAberrationShader;

using StringTools;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var animScale:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;

	// Shader effects
	public var chrom:ChromaticAberrationShader;
	public var chromEnabled:Bool = false;
	public var chromIntensity:Float = 0;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		animScale = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		antialiasing = FlxG.save.data.antialiasing;

		switch (curCharacter)
		{
			case 'gf-wrath':
				// GIRLFRIEND CODE
				if (FlxG.save.data.cacheImages)
				{
					frames = FileCache.instance.fromSparrow('shared_gf', 'characters/shaded_wrath/Goth_GF');
				}
				else
				{
					frames = Paths.getSparrowAtlas('shaded_wrath/Goth_GF','shared',true);
				}
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairLeft', 'GF Dancing Beat Hair blowing CAR', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('hairRight', 'GF Dancing Beat Hair blowing CAR', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24,false);

				addScale('sad', 0.9, 0.9);
				addScale('danceLeft', 0.9, 0.9);
				addScale('danceRight', 0.9, 0.9);
				addScale('hairLeft', 0.9, 0.9);
				addScale('hairRight', 0.9, 0.9);

				playAnim('danceRight');
			case 'gf-saku':
				// GIRLFRIEND CODE
				if (FlxG.save.data.cacheImages)
				{
					frames = FileCache.instance.fromSparrow('shared_gfSaku', 'characters/Saku_GF');
				}
				else
				{
					frames = Paths.getSparrowAtlas('Saku_GF','shared',true);
				}
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairLeft', 'GF Dancing Beat Hair blowing CAR', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('hairRight', 'GF Dancing Beat Hair blowing CAR', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24,false);

				addScale('sad', 0.9, 0.9);
				addScale('danceLeft', 0.9, 0.9);
				addScale('danceRight', 0.9, 0.9);
				addScale('hairLeft', 0.9, 0.9);
				addScale('hairRight', 0.9, 0.9);

				playAnim('danceRight');
			case 'retro':
				if (FlxG.save.data.cacheImages)
				{
					frames = FileCache.instance.fromSparrow('shared_retroMenu', 'characters/RetroSpecter');
				}
				else
				{
					frames = Paths.getSparrowAtlas('RetroSpecter','shared',true);
				}
				animation.addByPrefix('idle', 'Retro IDLE', 24, false);
				animation.addByPrefix('singUP', 'Retro UP', 24);
				animation.addByPrefix('singRIGHT', 'Retro RIGHT', 24);
				animation.addByPrefix('singDOWN', 'Retro DOWN', 24);
				animation.addByPrefix('singLEFT', 'Retro LEFT', 24);

				// (tsg - 5/28/21) added offsets for the anims, gonna wanna change these once we get rid of the placeholder sprites
				// (tsg - 6/18/21) changed offsets for d6 finals
				addOffset('idle');
				addOffset("singUP", 40, -25);
				addOffset("singRIGHT", 45, -18);
				addOffset("singLEFT", 40, -14);
				addOffset("singDOWN", 35, -35);

				playAnim('idle');
			case 'retro-intro':
				if (FlxG.save.data.cacheImages)
				{
					frames = FileCache.instance.fromSparrow('shared_retroIntro', 'characters/shaded_wrath/IntroCutscene');
				}
				else
				{
					frames = Paths.getSparrowAtlas('shaded_wrath/IntroCutscene','shared',true);
				}
				animation.addByPrefix('intro', 'Phase 01 Instanz 1', 24, false);

				addScale('intro', .95, .95);

				playAnim('intro');
				animation.stop(); // Don't play the cutscene, just initialize the animation
			case 'retro-tf':
				if (FlxG.save.data.cacheImages)
				{
					frames = FileCache.instance.fromSparrow('shared_retroTransform', 'characters/shaded_wrath/Retro2');
				}
				else
				{
					frames = Paths.getSparrowAtlas('shaded_wrath/Retro2','shared',true);
				}
				animation.addByPrefix('tf', 'transformation', 24, false);

				addOffset('tf', 140, 230);

				playAnim('tf');
				animation.stop(); // Don't play the cutscene, just initialize the animation
			case 'retro-end1':
				if (FlxG.save.data.cacheImages)
				{
					frames = FileCache.instance.fromSparrow('shared_retroEnd1', 'characters/shaded_wrath/EndCutscene1');
				}
				else
				{
					frames = Paths.getSparrowAtlas('shaded_wrath/EndCutscene1','shared',true);
				}
				animation.addByPrefix('end', 'retrophase2-3cutscene_01', 24, false);

				playAnim('end');
				animation.stop(); // Don't play the cutscene, just initialize the animation
			case 'retro-end2':
				if (FlxG.save.data.cacheImages)
				{
					frames = FileCache.instance.fromSparrow('shared_retroEnd2', 'characters/shaded_wrath/EndCutscene2');
				}
				else
				{
					frames = Paths.getSparrowAtlas('shaded_wrath/EndCutscene2','shared',true);
				}
				animation.addByPrefix('end', 'retrophase2-3cutscene_02', 24, false);

				playAnim('end');
				animation.stop(); // Don't play the cutscene, just initialize the animation
			case 'retro-end3':
				if (FlxG.save.data.cacheImages)
				{
					frames = FileCache.instance.fromSparrow('shared_retroEnd3', 'characters/shaded_wrath/EndCutscene3');
				}
				else
				{
					frames = Paths.getSparrowAtlas('shaded_wrath/EndCutscene3','shared',true);
				}
				animation.addByPrefix('end', 'retrophase2-3cutscene_03', 24, false);

				playAnim('end');
				animation.stop(); // Don't play the cutscene, just initialize the animation
			case 'retro-end4':
				if (FlxG.save.data.cacheImages)
				{
					frames = FileCache.instance.fromSparrow('shared_retroEnd4', 'characters/shaded_wrath/EndCutscene4');
				}
				else
				{
					frames = Paths.getSparrowAtlas('shaded_wrath/EndCutscene4','shared',true);
				}
				animation.addByPrefix('end', 'retrophase2-3cutscene_04_01', 24, false);

				playAnim('end');
				animation.stop(); // Don't play the cutscene, just initialize the animation
			case 'retro-end5':
				if (FlxG.save.data.cacheImages)
				{
					frames = FileCache.instance.fromSparrow('shared_retroEnd5', 'characters/shaded_wrath/EndCutscene5');
				}
				else
				{
					frames = Paths.getSparrowAtlas('shaded_wrath/EndCutscene5','shared',true);
				}
				animation.addByPrefix('end', 'retrophase2-3cutscene_04_02', 24, false);

				playAnim('end');
				animation.stop(); // Don't play the cutscene, just initialize the animation
			case 'retro-end6':
				if (FlxG.save.data.cacheImages)
				{
					frames = FileCache.instance.fromSparrow('shared_retroEnd6', 'characters/shaded_wrath/EndCutscene6');
				}
				else
				{
					frames = Paths.getSparrowAtlas('shaded_wrath/EndCutscene6','shared',true);
				}
				animation.addByPrefix('end', 'retrophase2-3cutscene_04_03', 24, false);

				playAnim('end');
				animation.stop(); // Don't play the cutscene, just initialize the animation
			case 'retro-end7':
				if (FlxG.save.data.cacheImages)
				{
					frames = FileCache.instance.fromSparrow('shared_retroEnd7', 'characters/shaded_wrath/EndCutscene7');
				}
				else
				{
					frames = Paths.getSparrowAtlas('shaded_wrath/EndCutscene7','shared',true);
				}
				animation.addByPrefix('end', 'retrophase2-3cutscene_05', 24, false);

				playAnim('end');
				animation.stop(); // Don't play the cutscene, just initialize the animation
			case 'retro-end8':
				if (FlxG.save.data.cacheImages)
				{
					frames = FileCache.instance.fromSparrow('shared_retroEnd8', 'characters/shaded_wrath/EndCutscene8');
				}
				else
				{
					frames = Paths.getSparrowAtlas('shaded_wrath/EndCutscene8','shared',true);
				}
				animation.addByPrefix('end', 'retrophase2-3cutscene_06', 24, false);

				playAnim('end');
				animation.stop(); // Don't play the cutscene, just initialize the animation
			case 'retro-wrath':
				if (FlxG.save.data.cacheImages)
				{
					frames = FileCache.instance.fromSparrow('shared_retroWrath', 'characters/shaded_wrath/WrathRetroSpecter');
				}
				else
				{
					frames = Paths.getSparrowAtlas('shaded_wrath/WrathRetroSpecter','shared',true);
				}
				animation.addByPrefix('idle', 'Retro IDLE', 24, false);
				animation.addByPrefix('singUP', 'Retro UP', 24);
				animation.addByPrefix('singRIGHT', 'Retro RIGHT', 24);
				animation.addByPrefix('singDOWN', 'Retro DOWN', 24);
				animation.addByPrefix('singLEFT', 'Retro LEFT', 24);
				animation.addByPrefix('enough', 'Enough', 24, false);

				addOffset('idle');
				addOffset("singUP", 25, -10);
				addOffset("singRIGHT", 35, -25);
				addOffset("singLEFT", 30, -21);
				addOffset("singDOWN", 25, -31);

				// (tsg - 7/14/21) change retro's scaling and offset slightly to fix size inconsistencies
				// (Arcy - 7/17/21) Also downsize Retro entirely to fit with Retro 2
				addScale('idle', .95, .95);
				addScale("singUP", 1, 1);
				addScale('singRIGHT', .95, .95);
				addScale('singLEFT', .95, .95);
				addScale("singDOWN", .975, .975);
				addScale('enough', .95, .95);

				// Fancy shader stuff
				if (FlxG.save.data.chrom)
				{
					chrom = new ChromaticAberrationShader();
					shader = chrom; // Equip Chrom
					chromIntensity = 0.002;
					chrom.rOffset.value = [0, 0];
					chrom.gOffset.value = [0, 0];
					chrom.bOffset.value = [0, 0];
				}

				playAnim('idle');
			case 'retro2-wrath':
				if (FlxG.save.data.cacheImages)
				{
					frames = FileCache.instance.fromSparrow('shared_retro2Wrath', 'characters/shaded_wrath/WrathRetroSpecter_2');
				}
				else
				{
					frames = Paths.getSparrowAtlas('shaded_wrath/WrathRetroSpecter_2','shared',true);
				}
				//animation.addByPrefix('tf', 'transformation', 24, false);
				animation.addByPrefix('idle', 'Retro IDLE', 24, false);
				animation.addByPrefix('singUP', 'Retro UP', 24);
				animation.addByPrefix('singRIGHT', 'Retro RIGHT', 24);
				animation.addByPrefix('singDOWN', 'Retro DOWN', 24);
				animation.addByPrefix('singLEFT', 'Retro LEFT', 24);

				// (tsg - 5/30/21) added offsets for the anims, gonna wanna change these once we get rid of the placeholder sprites
				// (tsg - 6/5/21) i changed them since we got rid of the placeholder sprites
				// (tsg - 6/13/21) changed the right offset to reflect d6's new sprite
				addOffset('idle', -33, 5);
				addOffset("singUP", -34, 202);
				addOffset("singRIGHT", -126, 64);
				addOffset("singLEFT", -36, 194);
				addOffset("singDOWN", -55, 217);
				//addOffset('tf', 140, 230);

				addScale('idle', 1.1, 1.1);
				addScale('singUP', 1.1, 1.1);
				addScale('singRIGHT', 1.1, 1.1);
				addScale('singLEFT', 1.1, 1.1);
				addScale('singDOWN', 1.1, 1.1);

				// Fancy shader stuff
				if (FlxG.save.data.chrom)
				{
					chrom = new ChromaticAberrationShader();
					shader = chrom; // Equip Chrom
					chromIntensity = 0.0035;
					chrom.rOffset.value = [0, 0];
					chrom.gOffset.value = [0, 0];
					chrom.bOffset.value = [0, 0];
				}

				//playAnim('tf');
				//animation.play('tf');
				//animation.curAnim.curFrame = 0;
				playAnim('idle');
			case 'sakuroma':
				if (FlxG.save.data.cacheImages)
				{
					frames = FileCache.instance.fromSparrow('shared_sakuroma', 'characters/shaded_wrath/sakuroma');
				}
				else
				{
					frames = Paths.getSparrowAtlas('shaded_wrath/sakuroma','shared',true);
				}
				animation.addByPrefix('idle', 'SakuIdle', 24, false);
				animation.addByPrefix('singUP', 'SakuUp', 24);
				animation.addByPrefix('singRIGHT', 'SakuRight', 24);
				animation.addByPrefix('singDOWN', 'SakuDown', 24);
				animation.addByPrefix('singLEFT', 'SakuLeft', 24);
				animation.addByPrefix('laugh', 'Saku Giggle', 24);

				addOffset("singDOWN", 0, -150);
				addOffset("laugh", 28, -95);

				playAnim('idle');
			case 'sakuromaMenu':
				if (FlxG.save.data.cacheImages)
				{
					frames = FileCache.instance.fromSparrow('shared_sakuromaMenu', 'characters/SakuromaBop');
				}
				else
				{
					frames = Paths.getSparrowAtlas('SakuromaBop','shared',true);
				}
				animation.addByPrefix('idle', 'SakuromaBop idle', 24, false);

				addOffset('idle', 0, 20);

				playAnim('idle');
			case 'izzurius':
				if (FlxG.save.data.cacheImages)
				{
					frames = FileCache.instance.fromSparrow('shared_izzuriusMenu', 'characters/IzzyBop');
				}
				else
				{
					frames = Paths.getSparrowAtlas('IzzyBop','shared',true);
				}
				animation.addByPrefix('idle', 'IzzyBop', 24, false);

				addOffset('idle', 0, -30);

				playAnim('idle');
			case 'insatian':
				if (FlxG.save.data.cacheImages)
				{
					frames = FileCache.instance.fromSparrow('shared_insatianMenu', 'characters/InsatianBop');
				}
				else
				{
					frames = Paths.getSparrowAtlas('InsatianBop','shared',true);
				}
				animation.addByPrefix('idle', 'InsatianBop', 24, false);

				addOffset('idle', 50);

				playAnim('idle');
			case 'hivemine':
				if (FlxG.save.data.cacheImages)
				{
					frames = FileCache.instance.fromSparrow('shared_hivemineMenu', 'characters/HivemineBop');
				}
				else
				{
					frames = Paths.getSparrowAtlas('HivemineBop','shared',true);
				}
				animation.addByPrefix('idle', 'Hivemine bop', 24, false);

				addOffset('idle', 125, 60);

				playAnim('idle');
			case 'atrocean':
				if (FlxG.save.data.cacheImages)
				{
					frames = FileCache.instance.fromSparrow('shared_atroceanMenu', 'characters/AtroceanBop');
				}
				else
				{
					frames = Paths.getSparrowAtlas('AtroceanBop','shared',true);
				}
				animation.addByPrefix('idle', 'bop', 24, false);

				addOffset('idle', 125);

				playAnim('idle');
			case 'dozirc':
				if (FlxG.save.data.cacheImages)
				{
					frames = FileCache.instance.fromSparrow('shared_dozircMenu', 'characters/DozircBop');
				}
				else
				{
					frames = Paths.getSparrowAtlas('DozircBop','shared',true);
				}
				animation.addByPrefix('idle', 'bop', 24, false);

				addOffset('idle', 125);

				playAnim('idle');

			case 'bf':
				if (FlxG.save.data.cacheImages)
				{
					frames = FileCache.instance.fromSparrow('shared_bf', 'characters/BOYFRIEND');
				}
				else
				{
					frames = Paths.getSparrowAtlas('BOYFRIEND','shared',true);
				}

				//trace(tex.frames.length);

				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				//animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				//animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				//animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				//animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				//animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				//animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				//animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				//animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, false);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				//animation.addByPrefix('scared', 'BF idle shaking', 24);

				loadOffsetFile(curCharacter);

				playAnim('idle');

				flipX = true;

			case 'bf-retro':
				if (FlxG.save.data.cacheImages)
				{
					frames = FileCache.instance.fromSparrow('shared_bfRetro', 'characters/RetroBF');
				}
				else
				{
					frames = Paths.getSparrowAtlas('RetroBF','shared',true);
				}

				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				//animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				//animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				//animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				//animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				//animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				//animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				//animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				//animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				//animation.addByPrefix('firstDeath', "BF dies", 24, false);
				//animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				//animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				//animation.addByPrefix('scared', 'BF idle shaking', 24);

				addOffset('idle', -5);
				//addOffset("singUP", -29, 27);
				//addOffset("singRIGHT", -38, -7);
				//addOffset("singLEFT", 12, -6);
				//addOffset("singDOWN", -10, -50);
				//addOffset("singUPmiss", -29, 27);
				//addOffset("singRIGHTmiss", -30, 21);
				//addOffset("singLEFTmiss", 12, 24);
				//addOffset("singDOWNmiss", -11, -19);
				addOffset("hey", 7, 4);
				//addOffset('firstDeath', 37, 11);
				//addOffset('deathLoop', 37, 5);
				//addOffset('deathConfirm', 37, 69);
				//addOffset('scared', -4);

				playAnim('idle');

				flipX = true;

			case 'bf-ace':
				if (FlxG.save.data.cacheImages)
				{
					frames = FileCache.instance.fromSparrow('shared_bfAce', 'characters/AceBF');
				}
				else
				{
					frames = Paths.getSparrowAtlas('AceBF','shared',true);
				}

				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				//animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				//animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				//animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				//animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				//animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				//animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				//animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				//animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				//animation.addByPrefix('firstDeath', "BF dies", 24, false);
				//animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				//animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				//animation.addByPrefix('scared', 'BF idle shaking', 24);

				addOffset('idle', -5);
				//addOffset("singUP", -29, 27);
				//addOffset("singRIGHT", -38, -7);
				//addOffset("singLEFT", 12, -6);
				//addOffset("singDOWN", -10, -50);
				//addOffset("singUPmiss", -29, 27);
				//addOffset("singRIGHTmiss", -30, 21);
				//addOffset("singLEFTmiss", 12, 24);
				//addOffset("singDOWNmiss", -11, -19);
				addOffset("hey", 7, 4);
				//addOffset('firstDeath', 37, 11);
				//addOffset('deathLoop', 37, 5);
				//addOffset('deathConfirm', 37, 69);
				//addOffset('scared', -4);

				playAnim('idle');

				flipX = true;

			case 'bf-retro-wrath':
				if (FlxG.save.data.cacheImages)
				{
					frames = FileCache.instance.fromSparrow('shared_bfRetroWrath', 'characters/shaded_wrath/WrathRetroBF');
				}
				else
				{
					frames = Paths.getSparrowAtlas('shaded_wrath/WrathRetroBF','shared',true);
				}

				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				//animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				//animation.addByPrefix('scared', 'BF idle shaking', 24);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				//addOffset("hey", 7, 4);
				addOffset('firstDeath', 37, 11);
				addOffset('deathLoop', 37, 5);
				addOffset('deathConfirm', 37, 69);
				//addOffset('scared', -4);

				playAnim('idle');

				flipX = true;
			case 'bf-wrath':
				if (FlxG.save.data.cacheImages)
				{
					frames = FileCache.instance.fromSparrow('shared_bfWrath', 'characters/shaded_wrath/BOYFRIEND');
				}
				else
				{
					frames = Paths.getSparrowAtlas('shaded_wrath/BOYFRIEND','shared',true);
				}

				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				//animation.addByPrefix('hey', 'BF HEY', 24, false);

				//animation.addByPrefix('scared', 'BF idle shaking', 24);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				//addOffset("hey", 7, 4);
				//addOffset('scared', -4);

				addScale('idle', 0.9, 0.9);
				addScale('singUP', 0.9, 0.9);
				addScale('singRIGHT', 0.9, 0.9);
				addScale('singLEFT', 0.9, 0.9);
				addScale('singDOWN', 0.9, 0.9);
				addScale('singUPmiss', 0.9, 0.9);
				addScale('singRIGHTmiss', 0.9, 0.9);
				addScale('singLEFTmiss', 0.9, 0.9);
				addScale('singDOWNmiss', 0.9, 0.9);

				playAnim('idle');

				flipX = true;

			case 'bf-wrath-death':
				if (FlxG.save.data.cacheImages)
				{
					frames = FileCache.instance.fromSparrow('shared_bfWrathDeath', 'characters/shaded_wrath/bfDeath');
				}
				else
				{
					frames = Paths.getSparrowAtlas('shaded_wrath/bfDeath','shared',true);
				}

				animation.addByPrefix('firstDeath', "BF dies", 24, false);

				addOffset('firstDeath', 400, 30);

				addScale('firstDeath', 0.9, 0.9);

				flipX = true;

			case 'bf-wrath-death2':
				if (FlxG.save.data.cacheImages)
				{
					frames = FileCache.instance.fromSparrow('shared_bfWrathDeath2', 'characters/shaded_wrath/bfDeath2');
				}
				else
				{
					frames = Paths.getSparrowAtlas('shaded_wrath/bfDeath2','shared',true);
				}

				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				addOffset('deathLoop', 307, 28);
				addOffset('deathConfirm', 308, 29);

				addScale('deathLoop', 0.9, 0.9);
				addScale('deathConfirm', 0.9, 0.9);

				flipX = true;
			case 'bf-ace-wrath':
				if (FlxG.save.data.cacheImages)
				{
					frames = FileCache.instance.fromSparrow('shared_bfAceWrath', 'characters/shaded_wrath/WrathAceBF');
				}
				else
				{
					frames = Paths.getSparrowAtlas('shaded_wrath/WrathAceBF','shared',true);
				}

				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				//animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				//animation.addByPrefix('scared', 'BF idle shaking', 24);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				//addOffset("hey", 7, 4);
				addOffset('firstDeath', 37, 11);
				addOffset('deathLoop', 37, 5);
				addOffset('deathConfirm', 37, 69);
				//addOffset('scared', -4);

				playAnim('idle');

				flipX = true;
		}

		//dance();

		if (isPlayer)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
			{
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
	}

	public function loadOffsetFile(character:String, library:String = 'shared')
	{
		var offset:Array<String> = CoolUtil.coolTextFile(Paths.txt('images/characters/' + character + "Offsets", library));

		for (i in 0...offset.length)
		{
			var data:Array<String> = offset[i].split(' ');
			addOffset(data[0], Std.parseInt(data[1]), Std.parseInt(data[2]));
		}
	}

	override function update(elapsed:Float)
	{
		if (!curCharacter.startsWith('bf'))
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			if (holdTimer >= Conductor.stepCrochet * 0.004)
			{
				dance();
				holdTimer = 0;
			}
		}

		switch (curCharacter)
		{
			case 'gf-wrath':
				if ((animation.curAnim.name == 'hairLeft' || animation.curAnim.name == 'hairRight') && animation.curAnim.finished)
				{
					playAnim('dance' + animation.curAnim.name.substr(4));
				}
			case 'gf-saku':
				if ((animation.curAnim.name == 'hairLeft' || animation.curAnim.name == 'hairRight') && animation.curAnim.finished)
				{
					playAnim('dance' + animation.curAnim.name.substr(4));
				}
		}

		if (chromEnabled)
		{
			// (Arcy) Put Chrom back to normal
			if (chrom.gOffset.value[0] < 0)
			{
				chrom.gOffset.value[0] += 0.01 * elapsed;
			}
			else if (chrom.gOffset.value[0] > 0)
			{
				chrom.gOffset.value[0] = 0;
			}

			if (chrom.bOffset.value[0] > 0)
			{
				chrom.bOffset.value[0] -= 0.01 * elapsed;
			}
			else if (chrom.bOffset.value[0] < 0)
			{
				chrom.bOffset.value[0] = 0;
			}
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance(forced:Bool = false)
	{
		if (!debugMode)
		{
			switch (curCharacter)
			{
				case 'gf-wrath' | 'gf-saku':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
						{
							playAnim('danceRight');
						}
						else
						{
							playAnim('danceLeft');
						}
					}
				case 'retro2-wrath':
					if (chromEnabled)
					{
						// (Arcy) Chrom gets colorful
						chrom.gOffset.value = [-0.002, 0];
						chrom.bOffset.value = [0.002, 0];
					}

					playAnim('idle');
				default:
					playAnim('idle', forced);
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		// (Arcy) Special effects
		if (chromEnabled && AnimName != animation.name)
		{
			// (Arcy) Chrom gets more colorful
			chrom.gOffset.value = [-chromIntensity, 0];
			chrom.bOffset.value = [chromIntensity, 0];
		}

		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
		{
			offset.set(0, 0);
		}
		if (animScale.exists(AnimName))
		{
			var daScale = animScale.get(AnimName);
			scale.set(daScale[0], daScale[1]);
		}
		else
		{
			scale.set(1, 1);
		}

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	public function addScale(name:String, x:Float = 0, y:Float = 0)
	{
		animScale[name] = [x, y];
	}
}
