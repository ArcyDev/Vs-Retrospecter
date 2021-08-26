package;

import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var char:String = 'bf';
	public var isPlayer:Bool = false;
	public var isOldIcon:Bool = false;

	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public function new(?char:String = "bf", ?isPlayer:Bool = false)
	{
		super();

		this.char = char;
		this.isPlayer = isPlayer;

		loadGraphic(Paths.image('iconGrid'), true, 150, 150);

		animation.add('bf', [0, 1], 0, false, isPlayer);
		animation.add('gf', [2], 0, false, isPlayer);
		animation.add('bf-retro', [10, 11], 0, false, isPlayer);			// VS RetroSpecter: Bf Retrospecter character
		animation.add('bf-ace', [20, 21], 0, false, isPlayer);			    // VS RetroSpecter: Bf Ace character
		animation.add('bf-retro-wrath', [10, 11], 0, false, isPlayer);		// VS RetroSpecter: BF Retrospecter Wrath character
		animation.add('bf-ace-wrath', [20, 21], 0, false, isPlayer);		// VS RetroSpecter: BF Ace Wrath character
		animation.add('bf-wrath', [0, 1], 0, false, isPlayer);				// VS RetroSpecter: BF Wrath character
		animation.add('bf-wrath2', [0, 1], 0, false, isPlayer);				// VS RetroSpecter: BF Wrath character
		animation.add('lock', [59], 0, false, isPlayer);					// VS RetroSpecter: Lock icon for locked songs
		animation.add('retro', [3, 4], 0, false, isPlayer);					// VS RetroSpecter: Retro Phase 1
		animation.add('retro-wrath', [3, 4, 13], 0, false, isPlayer);		// VS RetroSpecter: Retro Phase 1
		animation.add('retro2', [5, 6], 0, false, isPlayer);				// VS RetroSpecter: Retro Phase 1
		animation.add('retro2-wrath', [5, 6, 15, 16], 0, false, isPlayer);	// VS RetroSpecter: Retro Phase 2
		animation.add('sakuroma', [7, 8, 9], 0, false, isPlayer);			// VS Sakuroma: Sakuroma Phase 1
		animation.play(char);

		isPlayer = isOldIcon = false;

		antialiasing = FlxG.save.data.antialiasing;

		//changeIcon(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
		{
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
		}
	}
}
