package;

import flixel.FlxSprite;
import flixel.math.FlxPoint;

class CompoundSprite extends FlxSprite
{
	public var currentAnimationIndex:Int;
	public var currentAnimatingSprite:FlxSprite;
    public var animationEndCallback:(name:String) -> Void;

    private var animSprites:Array<FlxSprite>;
	private var animOffsets:Array<FlxPoint>;
    private var pivotPoint:FlxPoint;

    /**
    * Creates a new RMSprite. WARNING: Do NOT manually play animations on the sprites you pass in here.
    * @param	sprites		List of sprites in order of their animations
	* @param	x			X position of the sprite
	* @param	y		    Y position of the sprite
	* @param	pivotX		Percentage along the width the sprite should anchor to
	* @param	pivotY		Percentage along the height the sprite should anchor to
	*/
    public function new(sprites:Array<FlxSprite>, x:Float, y:Float, ?offsets:Array<FlxPoint>/*, pivotX:Float, pivotY:Float*/) {
        super(x, y);

        animSprites = sprites;
		if (offsets != null)
		{
			animOffsets = offsets;
		}
        //pivotPoint = new FlxPoint(pivotX, pivotY);

		create();
    }

    public function create() {
        for(i in 0...animSprites.length)
        {
            var sprite:FlxSprite = animSprites[i];

            //sprite.animation.callback = onAnimationFrameChange;
            //sprite.origin.set(sprite.width / 2, sprite.height);
            sprite.alpha = 0.0000000001;
			if (animOffsets != null)
			{
				sprite.setPosition(getPosition().x + animOffsets[i].x, getPosition().y + animOffsets[i].y);
			}
			else
			{
				sprite.setPosition(getPosition().x, getPosition().y);
			}

            if(i == animSprites.length - 1)
            {
                sprite.animation.finishCallback = onAnimationFinish;
            }
            else
            {
                sprite.animation.finishCallback = (aName:String) ->
                {
                    currentAnimatingSprite.alpha = 0;  // Hide sprite we don't need anymore

					currentAnimationIndex = i;
                    currentAnimatingSprite = animSprites[i+1];
                    animSprites[i+1].alpha = 1;
                    animSprites[i+1].animation.play(aName, true);
                };
            }
        }
    }

    public function playAll(animName:String, force:Bool) {
		currentAnimationIndex = 0;
        currentAnimatingSprite = animSprites[0];
		animSprites[0].alpha = 1;
        animSprites[0].animation.play(animName, force);
        //animation.play(animName, force);
    }

    public function onAnimationFrameChange(name:String, frameNumber:Int, frameIndex:Int) {
        var frameWidth = currentAnimatingSprite.width;
        var frameHeight = currentAnimatingSprite.height;

        var newXPos = getPosition().x - pivotPoint.x * frameWidth;
        var newYPos = getPosition().y - pivotPoint.y * frameHeight;

        currentAnimatingSprite.setPosition(newXPos, newYPos);
    }

    public function onAnimationFinish(name:String) {
        currentAnimatingSprite = null;

        if(animationEndCallback != null)
        {
            animationEndCallback(name);
        }
    }
}