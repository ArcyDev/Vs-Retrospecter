package;

import lime.utils.Assets;

using StringTools;

class CoolUtil
{
	public static var difficultyArray:Array<String> = ['HEAVEN', 'EASY', "NORMAL", "HARD", "HELL"];
	public static var modeArray:Array<String> = ['STANDARD', "NO FAIL", "FREESTYLE", "RANDOMIZED"];

	public static function difficultyFromInt(difficulty:Int):String
	{
		return difficultyArray[difficulty];
	}

	public static function modeString():String
	{
		return modeArray[PlayState.storyMode];
	}

	/**
	 * Carbon fixed it we're all good :)
	 *
	 * @param	legalNotes		A defined boolean array with 4 values that represent which of the 4 notes can be set.
	 * @return					A random legal integer that represents the note value.
	 */
	public static function getRandomNoteData(legalNotes:Array<Bool>):Int
	{
		var availablePositions:Array<Int> = new Array<Int>();

		for(i in 0...legalNotes.length)
		{
			if(legalNotes[i])
			{
				availablePositions.push(i);
			}
		}

		var choice:Int = Math.floor(Std.int(Math.random() * availablePositions.length));

		return availablePositions[choice];
	}

	public static function coolTextFile(path:String):Array<String>
	{
		if(!Assets.exists(path, TEXT))
		{
			return null;
		}

		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}
}
