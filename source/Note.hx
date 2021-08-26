package;

import PlayState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;

using StringTools;

// (TSG) note type shit
enum NoteType {
	Normal;					// FNF: Normal Note
	Poison;					// VS RetroSpecter: Poison Note
	Spectre;				// VS RetroSpecter: Spectre Note
	SakuNote;				// Vs RetroSpecter: Hidden Saku Note
}

class Note extends FlxSprite
{
	public var strumTime:Float = 0;
	public var baseStrum:Float = 0;

	public var charterSelected:Bool = false;

	public var rStrumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var rawNoteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var modifiedByLua:Bool = false;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var originColor:Int = 0; // The sustain note's original note's color

	public var noteCharterObject:FlxSprite;

	// Retro-specific variables
	public var noteType:NoteType = NoteType.Normal;
	public var noteXOffset:Float = 0;

	public var noteYOff:Int = 0;

	public static var swagWidth:Float = 160 * 0.7;

	public var rating:String = "shit";

	public var modAngle:Float = 0; // The angle set by modcharts
	public var localAngle:Float = 0; // The angle to be edited inside Note.hx

	public var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];
	public var quantityColor:Array<Int> = [3, 2, 1, 2, 0, 2, 1, 2];
	public var arrowAngles:Array<Int> = [180, 90, 270, 0];

	public var isParent:Bool = false;
	public var parent:Note = null;
	public var spotInLine:Int = 0;
	public var sustainActive:Bool = true;

	public var children:Array<Note> = [];

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?mustHit = false, ?inCharter:Bool = false, ?type:NoteType)
	{
		super();

		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		mustPress = mustHit;

		if (type != null)
		{
			noteType = type;
		}

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;

		if (inCharter)
		{
			this.strumTime = strumTime;
			rStrumTime = strumTime;
		}
		else
		{
			this.strumTime = strumTime;
			#if sys
			if (PlayState.isSM)
			{
				rStrumTime = strumTime;
			}
			else
				rStrumTime = (strumTime - FlxG.save.data.offset + PlayState.songOffset);
			#else
			rStrumTime = (strumTime - FlxG.save.data.offset + PlayState.songOffset);
			#end
		}

		if (this.strumTime < 0 )
		{
			this.strumTime = 0;
		}

		this.noteData = noteData;

		switch (noteType)
		{
			case Normal:
				switch (PlayState.SONG.noteStyle)
				{
					default:
						// Sorry for being lazy and not making this its own special section
						if ((PlayState.SONG.song == 'Spectral' || PlayState.SONG.song == 'Ectospasm') && !mustPress)
						{
							if (FlxG.save.data.cacheImages)
							{
								frames = FileCache.instance.fromSparrow('shared_notesRetro2', 'NOTE_assets_retro');
							}
							else
							{
								frames = Paths.getSparrowAtlas('NOTE_assets_retro','shared');
							}

							// (Arcy) Retro note offset
							// (Arcy) Some notes vary
							switch(noteData)
							{
								case 0:
									noteXOffset = -15;
								case 1:
									noteXOffset = -10;
								case 2:
									noteXOffset = -10;
								case 3:
									noteXOffset = -15;
							}
						}
						else
						{
							if (FlxG.save.data.cacheImages)
							{
								if (FlxG.save.data.customStrumLine || !mustPress)
								{
									frames = FileCache.instance.fromSparrow('shared_notesRetro', 'NOTE_assets_retrobf');
								}
								else
								{
									frames = FileCache.instance.fromSparrow('shared_notesDefault', 'NOTE_assets');
								}
							}
							else
							{
								if (FlxG.save.data.customStrumLine || !mustPress)
								{
									frames = Paths.getSparrowAtlas('NOTE_assets_retrobf','shared');
								}
								else
								{
									frames = Paths.getSparrowAtlas('NOTE_assets','shared');
								}
							}
						}

						animation.addByPrefix('greenScroll', 'green0');
						animation.addByPrefix('redScroll', 'red0');
						animation.addByPrefix('blueScroll', 'blue0');
						animation.addByPrefix('purpleScroll', 'purple0');

						animation.addByPrefix('purpleholdend', 'pruple end hold');
						animation.addByPrefix('greenholdend', 'green hold end');
						animation.addByPrefix('redholdend', 'red hold end');
						animation.addByPrefix('blueholdend', 'blue hold end');

						animation.addByPrefix('purplehold', 'purple hold piece');
						animation.addByPrefix('greenhold', 'green hold piece');
						animation.addByPrefix('redhold', 'red hold piece');
						animation.addByPrefix('bluehold', 'blue hold piece');

						setGraphicSize(Std.int(width * 0.7));
						updateHitbox();
						antialiasing = FlxG.save.data.antialiasing;
				}
			case Poison:
				if (FlxG.save.data.cacheImages)
				{
					frames = FileCache.instance.fromSparrow('shared_notesPoison', 'PoisonArrows');
				}
				else
				{
					frames = Paths.getSparrowAtlas('PoisonArrows','shared');
				}

				if (FlxG.save.data.downscroll)
				{
					animation.addByPrefix('greenScroll', 'PoisonArrows Downscroll Up', 24, true);
					animation.addByPrefix('redScroll', 'PoisonArrows Downscroll Right', 24, true);
					animation.addByPrefix('blueScroll', 'PoisonArrows Downscroll Down', 24, true);
					animation.addByPrefix('purpleScroll', 'PoisonArrows Downscroll Left', 24, true);
				}
				else
				{
					animation.addByPrefix('greenScroll', 'PoisonArrows Upscroll Up', 24, true);
					animation.addByPrefix('redScroll', 'PoisonArrows Upscroll Right', 24, true);
					animation.addByPrefix('blueScroll', 'PoisonArrows Upscroll Down', 24, true);
					animation.addByPrefix('purpleScroll', 'PoisonArrows Upscroll Left', 24, true);
				}

				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();
				antialiasing = FlxG.save.data.antialiasing;

				// (Arcy) Poison note offset
				// (Arcy) Some notes vary
				switch(noteData)
				{
					case 0:
						noteXOffset = -15;
					case 1:
						noteXOffset = -5;
					case 2:
						noteXOffset = -5;
					case 3:
						noteXOffset = -10;
				}
			case Spectre:
				// This actually doesn't work but I don't think we'll have any Spectre trails
				if (sustainNote && prevNote != null)
				{
					frames = Paths.getSparrowAtlas('SpectreNoteTrail');

					animation.addByPrefix('purpleholdend', 'blue hold end');
					animation.addByPrefix('greenholdend', 'blue hold end');
					animation.addByPrefix('redholdend', 'blue hold end');
					animation.addByPrefix('blueholdend', 'blue hold end');

					animation.addByPrefix('purplehold', 'blue hold piece');
					animation.addByPrefix('greenhold', 'blue hold piece');
					animation.addByPrefix('redhold', 'blue hold piece');
					animation.addByPrefix('bluehold', 'blue hold piece');
				}
				else
				{
					if (FlxG.save.data.downscroll)
					{
						if (FlxG.save.data.cacheImages)
						{
							frames = FileCache.instance.fromSparrow('shared_spectreNotesDownscroll', 'SpectreNoteDownscroll');
						}
						else
						{
							frames = Paths.getSparrowAtlas('SpectreNoteDownscroll','shared');
						}
					}
					else
					{
						if (FlxG.save.data.cacheImages)
						{
							frames = FileCache.instance.fromSparrow('shared_spectreNotesUpscroll', 'SpectreNote');
						}
						else
						{
							frames = Paths.getSparrowAtlas('SpectreNote','shared');
						}
					}

					animation.addByPrefix('greenScroll', 'SpecterArrowUp');
					animation.addByPrefix('redScroll', 'SpecterArrowRight');
					animation.addByPrefix('blueScroll', 'SpecterArrowDown');
					animation.addByPrefix('purpleScroll', 'SpecterArrowLeft');
				}

				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();
				antialiasing = FlxG.save.data.antialiasing;
			case SakuNote:
				frames = Paths.getSparrowAtlas('NOTE_heart');

				animation.addByPrefix('greenScroll', 'green0');
				animation.addByPrefix('redScroll', 'red0');
				animation.addByPrefix('blueScroll', 'blue0');
				animation.addByPrefix('purpleScroll', 'purple0');

				setGraphicSize(Std.int(width * 0.6));
				updateHitbox();
				antialiasing = FlxG.save.data.antialiasing;
			default:

				if (inCharter)
				{
					frames = Paths.getSparrowAtlas('NOTE_assets');

					for (i in 0...4)
					{
						animation.addByPrefix(dataColor[i] + 'Scroll', dataColor[i] + ' alone'); // Normal notes
						animation.addByPrefix(dataColor[i] + 'hold', dataColor[i] + ' hold'); // Hold
						animation.addByPrefix(dataColor[i] + 'holdend', dataColor[i] + ' tail'); // Tails
					}

					setGraphicSize(Std.int(width * 0.7));
					updateHitbox();
					antialiasing = FlxG.save.data.antialiasing;
				}
				else
				{
					switch (PlayState.SONG.noteStyle)
					{
						default:
							// Sorry for being lazy and not making this its own special section
							if ((PlayState.SONG.song == 'Spectral' || PlayState.SONG.song == 'Ectospasm') && !mustPress)
							{
								frames = FileCache.instance.fromSparrow('shared_notesRetro2', 'NOTE_assets_retro');
							}
							else
							{
								frames = FileCache.instance.fromSparrow('shared_notesRetro', 'NOTE_assets_retrobf');
							}

							animation.addByPrefix('greenScroll', 'green0');
							animation.addByPrefix('redScroll', 'red0');
							animation.addByPrefix('blueScroll', 'blue0');
							animation.addByPrefix('purpleScroll', 'purple0');

							animation.addByPrefix('purpleholdend', 'pruple end hold');
							animation.addByPrefix('greenholdend', 'green hold end');
							animation.addByPrefix('redholdend', 'red hold end');
							animation.addByPrefix('blueholdend', 'blue hold end');

							animation.addByPrefix('purplehold', 'purple hold piece');
							animation.addByPrefix('greenhold', 'green hold piece');
							animation.addByPrefix('redhold', 'red hold piece');
							animation.addByPrefix('bluehold', 'blue hold piece');

							setGraphicSize(Std.int(width * 0.7));
							updateHitbox();
							antialiasing = FlxG.save.data.antialiasing;
					}
				}
		}

		// Somehow bypassed the note type cases???
		// (Arcy) I don't know how this happens
		/*if (animation.getByName('greenScroll') == null || animation.getByName('redScroll') == null || animation.getByName('blueScroll') == null || animation.getByName('purpleScroll') == null)
		{
			// Sorry for being lazy and not making this its own special section
			if ((PlayState.SONG.song == 'Spectral' || PlayState.SONG.song == 'Ectospasm') && !mustPress)
			{
				frames = FileCache.instance.fromSparrow('shared_notesRetro2', 'NOTE_assets_retro');
			}
			else
			{
				frames = FileCache.instance.fromSparrow('shared_notesRetro', 'NOTE_assets_retrobf');
			}
			setGraphicSize(Std.int(width * PlayState.daPixelZoom));
			updateHitbox();

			frames = Paths.getSparrowAtlas('NOTE_assets');

			for (i in 0...4)
			{
				animation.addByPrefix(dataColor[i] + 'Scroll', dataColor[i] + ' alone'); // Normal notes
				animation.addByPrefix(dataColor[i] + 'hold', dataColor[i] + ' hold'); // Hold
				animation.addByPrefix(dataColor[i] + 'holdend', dataColor[i] + ' tail'); // Tails
			}

			setGraphicSize(Std.int(width * 0.7));
			updateHitbox();

			antialiasing = FlxG.save.data.antialiasing;
		}*/

		x += swagWidth * noteData;
		animation.play(dataColor[noteData] + 'Scroll');
		originColor = noteData; // The note's origin color will be checked by its sustain notes

		if (FlxG.save.data.stepMania && !isSustainNote)
		{
			// I give up on fluctuating bpms. something has to be subtracted from strumCheck to make them look right but idk what.
			// I'd use the note's section's start time but neither the note's section nor its start time are accessible by themselves
			//strumCheck -= ???

			var ind:Int = Std.int(Math.round(rStrumTime / (Conductor.stepCrochet / 2)));

			var col:Int = 0;
			col = quantityColor[ind % 8]; // Set the color depending on the beats

			animation.play(dataColor[col] + 'Scroll');
			localAngle -= arrowAngles[col];
			localAngle += arrowAngles[noteData];
			originColor = col;
		}

		// we make sure its downscroll and its a SUSTAIN NOTE (aka a trail, not a note)
		// and flip it so it doesn't look weird.
		// THIS DOESN'T FUCKING FLIP THE NOTE, CONTRIBUTERS DON'T JUST COMMENT THIS OUT JESUS
		// then what is this lol
		// BRO IT LITERALLY SAYS IT FLIPS IF ITS A TRAIL AND ITS DOWNSCROLL
		if (FlxG.save.data.downscroll && sustainNote)
			flipY = true;

		var stepHeight = (0.45 * Conductor.stepCrochet * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? PlayState.SONG.speed : PlayStateChangeables.scrollSpeed, 2));

		if (isSustainNote && prevNote != null)
		{
			alpha = 0.6;

			x += width / 2;

			originColor = prevNote.originColor;

			animation.play(dataColor[originColor] + 'holdend'); // This works both for normal colors and quantization colors
			updateHitbox();

			x -= width / 2;

			//if (noteTypeCheck == 'pixel')
			//	x += 30;
			if (inCharter)
				x += 30;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(dataColor[prevNote.originColor] + 'hold');
				prevNote.updateHitbox();

				prevNote.scale.y *= (stepHeight + 1) / prevNote.height; // + 1 so that there's no odd gaps as the notes scroll
				prevNote.updateHitbox();
				prevNote.noteYOff = Math.round(-prevNote.offset.y);

				// prevNote.setGraphicSize();

				noteYOff = Math.round(-offset.y);
			}
		}

		if (FlxG.save.data.downscroll)
		{
			if (noteType == NoteType.Poison)
				noteYOff += Std.int(173 * scale.y);
			else if (noteType == NoteType.Spectre)
				noteYOff += Std.int(114 * scale.y);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		angle = modAngle + localAngle;

		if (!modifiedByLua)
		{
			if (!sustainActive)
			{
				alpha = 0.3;
			}
		}

		if (mustPress)
		{
			if (isSustainNote)
			{
				if (strumTime - Conductor.songPosition <= ((166 * Conductor.timeScale) * 0.5)
					&& strumTime - Conductor.songPosition >= (-166 * Conductor.timeScale))
					canBeHit = true;
				else
					canBeHit = false;
			}
			else
			{
				// Make bad notes harder to hit
				if (noteType == NoteType.Poison)
				{
					if (strumTime - Conductor.songPosition <= ((166 * Conductor.timeScale) * 0.2)
						&& strumTime - Conductor.songPosition >= (-166 * Conductor.timeScale) * 0.4)
					{
						canBeHit = true;
					}
					else
					{
						canBeHit = false;
					}
				}
				else if (noteType == NoteType.Spectre)
				{
					if (strumTime - Conductor.songPosition <= ((166 * Conductor.timeScale) * 0.5)
						&& strumTime - Conductor.songPosition >= (-166 * Conductor.timeScale) * 0.5)
					{
						canBeHit = true;
					}
					else
					{
						canBeHit = false;
					}
				}
				else
				{
					if (strumTime - Conductor.songPosition <= (166 * Conductor.timeScale)
						&& strumTime - Conductor.songPosition >= (-166 * Conductor.timeScale))
						canBeHit = true;
					else
						canBeHit = false;
				}
			}
			if (strumTime - Conductor.songPosition < -166 && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
			{
				wasGoodHit = true;
			}
		}

		if (tooLate && !wasGoodHit)
		{
			if (alpha > 0.3)
			{
				alpha = 0.3;
			}
		}
	}

	/**
	* Changes the noteData to the value passed in and redoes the x position calculations.
	*
	* @param	noteDir			The value of the note to change to. Left = 0 | Down = 1 | Up = 2 | Right = 3
	*/
	public function changeNoteDirection(noteDir:Int)
	{
		x = 50; // Some hard-coded value I guess?? I don't wanna break anything

		switch (noteDir)
		{
			case 0:
				x += swagWidth * 0;
				noteData = noteDir;

				// Change sprite accordingly
				if (isSustainNote)
				{
					animation.play('purpleholdend');
					if (prevNote.isSustainNote)
					{
						prevNote.animation.play('purplehold');
					}
				}
				else
				{
					animation.play('purpleScroll');
				}
			case 1:
				x += swagWidth * 1;
				noteData = noteDir;

				// Change sprite accordingly
				if (isSustainNote)
				{
					animation.play('blueholdend');
					if (prevNote.isSustainNote)
					{
						prevNote.animation.play('bluehold');
					}
				}
				else
				{
					animation.play('blueScroll');
				}
			case 2:
				x += swagWidth * 2;
				noteData = noteDir;

				// Change sprite accordingly
				if (isSustainNote)
				{
					animation.play('greenholdend');
					if (prevNote.isSustainNote)
					{
						prevNote.animation.play('greenhold');
					}
				}
				else
				{
					animation.play('greenScroll');
				}
			case 3:
				x += swagWidth * 3;
				noteData = noteDir;

				// Change sprite accordingly
				if (isSustainNote)
				{
					animation.play('redholdend');
					if (prevNote.isSustainNote)
					{
						prevNote.animation.play('redhold');
					}
				}
				else
				{
					animation.play('redScroll');
				}
		}
	}
}
