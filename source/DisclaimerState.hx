package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class DisclaimerState extends FlxState
{
    var selectSprite:FlxSprite;
    var isFlashing:Bool = true;
    var barProgress:Float = 0;

    var loadingBG:FlxSprite;
    var loadingBarBG:FlxSprite;
    var loadingBar:FlxBar;
    var loadingImage:FlxSprite;
    var continueText:FlxText;
    var disclaimer:Bool = false;
	var stopspamming:Bool = false;

	static var firstPass:Bool = false;

	override public function create():Void
	{
        // (tsg) rebind save directory to the com.ayetsg.funkin.vsretrospecter package
		FlxG.save.bind('vsretrospecter', 'FNF Vs Retrospecter');
        PlayerSettings.init();
		KadeEngineData.initSave();
		Highscore.load();

        // Check if the warning even needs to be shown
        //if (!FlxG.save.data.flashing)
            //FlxG.switchState(new TitleState());

        var warningText:FlxText = new FlxText(0, 50, 0, "WARNING", 72);
        warningText.setFormat(Paths.font("vcr.ttf"), 72, FlxColor.WHITE);
        warningText.screenCenter(X);
        var description1:FlxText = new FlxText(0, 200, 0, "This mod contains flashing lights", 36);
        description1.setFormat(Paths.font("vcr.ttf"), 36, FlxColor.WHITE);
        description1.screenCenter(X);
        var description2:FlxText = new FlxText(0, 250, 0, "and other effects that may trigger seizures", 36);
        description2.setFormat(Paths.font("vcr.ttf"), 36, FlxColor.WHITE);
        description2.screenCenter(X);
        var description3:FlxText = new FlxText(0, 300, 0, "for people with photosensitive epilepsy.", 36);
        description3.setFormat(Paths.font("vcr.ttf"), 36, FlxColor.WHITE);
        description3.screenCenter(X);

        var askText:FlxText = new FlxText(0, 400, 0, "Do you want to keep these flashy effects on?", 36);
        askText.setFormat(Paths.font("vcr.ttf"), 36, FlxColor.WHITE);
        askText.screenCenter(X);

        selectSprite = new FlxSprite(460, 495).makeGraphic(140, 75, FlxColor.GRAY);
        var yes:FlxText = new FlxText(470, 500, "YES", 64);
        yes.setFormat(Paths.font("vcr.ttf"), 64, FlxColor.WHITE);
        var no:FlxText = new FlxText(690, 500, "NO", 64);
        no.setFormat(Paths.font("vcr.ttf"), 64, FlxColor.WHITE);

        var bgArt = new FlxSprite(0, 0).loadGraphic(Paths.image('neonBG', 'preload'));

        var confirmText = new FlxText(0, 650, 0, "Hit Enter to Confirm", 36);
        confirmText.setFormat(Paths.font("vcr.ttf"), 36, FlxColor.WHITE);
        confirmText.screenCenter(X);

        add(selectSprite);
        add(warningText);
        add(description1);
        add(description2);
        add(description3);
        add(askText);
        add(yes);
        add(no);
        add(bgArt);
        add(confirmText);

        loadingBG = new FlxSprite(0, 0).loadGraphic(Paths.image('LoadingScreen', 'preload'));

        loadingBarBG = new FlxSprite(0, 700).loadGraphic(Paths.image('healthBar', 'shared'));
        loadingBarBG.screenCenter(X);

        loadingBar = new FlxBar(loadingBarBG.x + 4, loadingBarBG.y + 4, LEFT_TO_RIGHT, Std.int(loadingBarBG.width - 8), Std.int(loadingBarBG.height - 8), this,
            'barProgress', 0, 100);
        loadingBar.numDivisions = 100;
        loadingBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);

        continueText = new FlxText(0, 650, 0, "Loading", 36);
        continueText.setFormat(Paths.font("vcr.ttf"), 36, FlxColor.BLACK);
        continueText.screenCenter(X);

        loadingImage = new FlxSprite(1130, 575);
        loadingImage.frames = Paths.getSparrowAtlas('GetReal', 'preload');
        loadingImage.scale.set(0.5, 0.5);
        loadingImage.animation.addByPrefix('dumpy', 'dumpy', 60);
        loadingImage.animation.play('dumpy');

        add(loadingBG);
        add(loadingBarBG);
        add(loadingBar);
        add(continueText);
        add(loadingImage);

        FileCache.loadFiles();
        updateLoadingText();

		super.create();
	}

	override function update(elapsed:Float)
	{
        if (!FileCache.instance.loaded)
            barProgress = FileCache.instance.progress;
        else
        {
            // Set it to loaded
            if (barProgress != 100)
            {
                barProgress = 100;
                continueText.text = "Hit Enter to continue";
                continueText.screenCenter(X);
				remove(loadingImage);
            }

            if (!disclaimer && (FlxG.keys.justPressed.ENTER || PlayerSettings.player1.controls.ACCEPT))
            {
				if (firstPass)
				{
					FlxG.switchState(new TitleState());
				}
				else
				{
					disclaimer = true;
					stopspamming = true;
					FlxTween.tween(loadingBG, {alpha: 0}, 1, {ease: FlxEase.cubeInOut, onComplete: function(flx:FlxTween) {
						stopspamming = false;
					}});
					FlxTween.tween(loadingBarBG, {alpha: 0}, 1, {ease: FlxEase.cubeInOut});
					FlxTween.tween(loadingBar, {alpha: 0}, 1, {ease: FlxEase.cubeInOut});
					FlxTween.tween(continueText, {alpha: 0}, 1, {ease: FlxEase.cubeInOut});

					FlxG.sound.play(Paths.sound('confirmMenu'));
				}
            }
            else if (disclaimer && !stopspamming)
            {
                if ((FlxG.keys.justPressed.LEFT || PlayerSettings.player1.controls.LEFT_P) && selectSprite.x == 660)
                {
                    FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
                    selectSprite.x = 460;
                    isFlashing = true;
                }
                else if ((FlxG.keys.justPressed.RIGHT || PlayerSettings.player1.controls.RIGHT_P) && selectSprite.x == 460)
                {
                    FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
                    selectSprite.x = 660;
                    isFlashing = false;
                }
                else if (FlxG.keys.justPressed.ENTER || PlayerSettings.player1.controls.ACCEPT)
                {
                    FlxG.save.data.flashing = isFlashing;
                    FlxG.save.data.chrom = isFlashing;
                    FlxG.save.data.ghostTrails = isFlashing;
					firstPass = true;
                    FlxG.switchState(new TitleState());
                }
            }
        }

		super.update(elapsed);
	}

    function updateLoadingText()
    {
        if (barProgress != 100)
        {
            switch(continueText.text)
            {
                case 'Loading':
                    continueText.text = 'Loading.';
                case 'Loading.':
                    continueText.text = 'Loading..';
                case 'Loading..':
                    continueText.text = 'Loading...';
                case 'Loading...':
                    continueText.text = 'Loading';
            }

            new FlxTimer().start(0.1, function(tmr:FlxTimer){ updateLoadingText(); });
        }
    }
}
