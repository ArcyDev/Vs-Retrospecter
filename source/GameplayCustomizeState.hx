import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

#if windows
import Discord.DiscordClient;
#end


class GameplayCustomizeState extends MusicBeatState
{

    var defaultX:Float = FlxG.width * 0.55 - 135;
    var defaultY:Float = FlxG.height / 2 - 50;

    var sick:FlxSprite;

    var text:FlxText;
    var blackBorder:FlxSprite;

    var bf:Boyfriend;
    var dad:Character;
    var gf:Character;

    var strumLine:FlxSprite;
    var strumLineNotes:FlxTypedGroup<FlxSprite>;
    var playerStrums:FlxTypedGroup<FlxSprite>;
    private var camHUD:FlxCamera;

    public override function create() {
        #if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Customizing Gameplay Modules", null);
		#end

        sick = new FlxSprite().loadGraphic(Paths.image('sick','shared'));
        sick.antialiasing = FlxG.save.data.antialiasing;
        sick.scrollFactor.set();
        if (FlxG.save.data.background > 0)
		{
			var wrathBgScale:Float = .72;
			var wrathXAdjust:Float = 0;
			var wrathYAdjust:Float = -128;

			// wrath_sky
			var sky:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('wrath_sky', 'wrath'));
			sky.antialiasing = FlxG.save.data.antialiasing;
			sky.screenCenter();
			sky.scale.x = 0.85;
			sky.scale.y = 0.85;
			sky.scrollFactor.set(0.5, 0.5);
			sky.active = false;
			sky.x += wrathXAdjust;
			sky.y += wrathYAdjust + 250;
			add(sky);

			// wrath_gates
			var gates:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('wrath_gates', 'wrath'));
			gates.antialiasing = FlxG.save.data.antialiasing;
			gates.screenCenter();
			gates.scale.x = 0.85;
			gates.scale.y = 0.85;
			gates.scrollFactor.set(0.55, 0.55);
			gates.active = false;
			gates.x += wrathXAdjust;
			gates.y += wrathYAdjust - 150;
			add(gates);

			// wrath_backrocks
			var backrocks:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('wrath_backrocks', 'wrath'));
			backrocks.antialiasing = FlxG.save.data.antialiasing;
			backrocks.screenCenter();
			backrocks.scale.x = wrathBgScale;
			backrocks.scale.y = wrathBgScale;
			backrocks.scrollFactor.set(0.6, 0.6);
			backrocks.active = false;
			backrocks.x += wrathXAdjust;
			backrocks.y += wrathYAdjust;
			add(backrocks);

			// wrath_gems
			var gem1:FlxSprite = new FlxSprite(0, 0);
			gem1.frames = FileCache.instance.fromSparrow('wrath_gem1', 'gem1');
			gem1.animation.addByPrefix('green', 'green', 0, false);
			gem1.antialiasing = FlxG.save.data.antialiasing;
			gem1.screenCenter();
			gem1.scale.x = wrathBgScale;
			gem1.scale.y = wrathBgScale;
			gem1.scrollFactor.set(0.6, 0.6);
			gem1.active = false;
			gem1.x += wrathXAdjust + 200; // gem adjustment
			gem1.y += wrathYAdjust + 150; // more gem adjustment
			gem1.animation.play('green');
			add(gem1);

			var gem2:FlxSprite = new FlxSprite(0, 0);
			gem2.frames = FileCache.instance.fromSparrow('wrath_gem2', 'gem2');
			gem2.animation.addByPrefix('green', 'green', 0, false);
			gem2.antialiasing = FlxG.save.data.antialiasing;
			gem2.screenCenter();
			gem2.scale.x = wrathBgScale;
			gem2.scale.y = wrathBgScale;
			gem2.scrollFactor.set(0.7, 0.7);
			gem2.active = false;
			gem2.x += wrathXAdjust + 200; // gem adjustment
			gem2.y += wrathYAdjust + 150; // more gem adjustment
			gem2.animation.play('green');
			add(gem2);

			// wrath_cave
			var cave = new FlxSprite(0, 0).loadGraphic(Paths.image('wrath_cave', 'wrath'));
			cave.antialiasing = FlxG.save.data.antialiasing;
			cave.screenCenter();
			cave.scale.x = wrathBgScale;
			cave.scale.y = wrathBgScale;
			cave.scrollFactor.set(0.8, 0.8);
			cave.x += wrathXAdjust;
			cave.y += wrathYAdjust;
			add(cave);

			// wrath_ground
			var ground:FlxSprite = new FlxSprite(0, 0);
			ground.frames = FileCache.instance.fromSparrow('wrath_ground', 'ground');
			ground.animation.addByPrefix('green', 'green', 0, false);
			ground.antialiasing = FlxG.save.data.antialiasing;
			ground.screenCenter();
			ground.scale.x = wrathBgScale;
			ground.scale.y = wrathBgScale;
			ground.scrollFactor.set(1, 1);
			ground.active = false;
			ground.x += wrathXAdjust;
			ground.y += wrathYAdjust;
			ground.animation.play('green');
			add(ground);

			// wrath_rocks
			var rocks = new FlxSprite(0, 0);
			rocks.frames = FileCache.instance.fromSparrow('wrath_frontRocks', 'frontRocks');
			rocks.animation.addByPrefix('green', 'green', 0, false);
			rocks.antialiasing = FlxG.save.data.antialiasing;
			rocks.screenCenter();
			rocks.scale.x = wrathBgScale;
			rocks.scale.y = wrathBgScale;
			rocks.scrollFactor.set(1.1, 1.1);
			rocks.active = false;
			rocks.x += wrathXAdjust;
			rocks.y += wrathYAdjust + 200; // rock adjustment
			rocks.animation.play('green');
			add(rocks);
		}

		//Conductor.changeBPM(102);
		persistentUpdate = true;

        super.create();

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
        FlxG.cameras.add(camHUD);

        camHUD.zoom = FlxG.save.data.zoom;


		var camFollow = new FlxObject(0, 0, 1, 1);

		dad = new Character(100, 100, 'retro-wrath');

        bf = new Boyfriend(770, 450, 'bf-wrath');

        gf = new Character(100, 200, 'gf-wrath');
		gf.scrollFactor.set(0.95, 0.95);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x + 400, dad.getGraphicMidpoint().y);

		camFollow.setPosition(camPos.x, camPos.y);

        add(gf);
        add(bf);
        add(dad);

        add(sick);

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.01);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = 0.9;
		FlxG.camera.focusOn(camFollow.getPosition());

		strumLine = new FlxSprite(0, FlxG.save.data.strumline).makeGraphic(FlxG.width, 14);
		strumLine.scrollFactor.set();
        strumLine.alpha = 0.4;

        add(strumLine);

		if (FlxG.save.data.downscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();

        sick.cameras = [camHUD];
        strumLine.cameras = [camHUD];
        playerStrums.cameras = [camHUD];

		generateStaticArrows(0);
		generateStaticArrows(1);

        text = new FlxText(5, FlxG.height + 40, 0, "Click and drag around gameplay elements to customize their positions. Press R to reset. Q/E to change zoom. Press Escape to go back.", 12);
		text.scrollFactor.set();
		text.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

        blackBorder = new FlxSprite(-30,FlxG.height + 40).makeGraphic((Std.int(text.width + 900)),Std.int(text.height + 600),FlxColor.BLACK);
		blackBorder.alpha = 0.5;

        text.cameras = [camHUD];

        text.scrollFactor.set();

		add(blackBorder);

		add(text);

		FlxTween.tween(text,{y: FlxG.height - 18},2,{ease: FlxEase.elasticInOut});
		FlxTween.tween(blackBorder,{y: FlxG.height - 18},2, {ease: FlxEase.elasticInOut});

        if (!FlxG.save.data.changedHit)
        {
            FlxG.save.data.changedHitX = defaultX;
            FlxG.save.data.changedHitY = defaultY;
        }

        sick.x = FlxG.save.data.changedHitX;
        sick.y = FlxG.save.data.changedHitY;


        FlxG.mouse.visible = true;

    }

    override function update(elapsed:Float) {
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

        super.update(elapsed);

        if (FlxG.save.data.zoom < 0.8)
            FlxG.save.data.zoom = 0.8;

        if (FlxG.save.data.zoom > 1.2)
            FlxG.save.data.zoom = 1.2;

        FlxG.camera.zoom = FlxMath.lerp(0.9, FlxG.camera.zoom, 0.95);
        camHUD.zoom = FlxMath.lerp(FlxG.save.data.zoom, camHUD.zoom, 0.95);

        if (FlxG.mouse.overlaps(sick) && FlxG.mouse.pressed)
        {
            sick.x = (FlxG.mouse.x - sick.width / 2) - 60;
            sick.y = (FlxG.mouse.y - sick.height) - 60;
        }

        for (i in playerStrums)
            i.y = strumLine.y;
        for (i in strumLineNotes)
            i.y = strumLine.y;

        if (FlxG.keys.justPressed.Q)
        {
            FlxG.save.data.zoom += 0.02;
            camHUD.zoom = FlxG.save.data.zoom;
        }

        if (FlxG.keys.justPressed.E)
        {
            FlxG.save.data.zoom -= 0.02;
            camHUD.zoom = FlxG.save.data.zoom;
        }


        if (FlxG.mouse.overlaps(sick) && FlxG.mouse.justReleased)
        {
            FlxG.save.data.changedHitX = sick.x;
            FlxG.save.data.changedHitY = sick.y;
            FlxG.save.data.changedHit = true;
        }

        if (FlxG.keys.justPressed.R)
        {
            sick.x = defaultX;
            sick.y = defaultY;
            FlxG.save.data.changedHitX = sick.x;
            FlxG.save.data.changedHitY = sick.y;
            FlxG.save.data.changedHit = false;
        }

        if (controls.BACK)
        {
            FlxG.mouse.visible = false;
            FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new OptionsMenu());
        }

    }

    override function beatHit()
    {
        super.beatHit();

        bf.playAnim('idle', true);
        dad.dance(true);
        gf.dance();

        FlxG.camera.zoom += 0.015;
        camHUD.zoom += 0.010;
    }


    // ripped from play state cuz im lazy

	private function generateStaticArrows(player:Int):Void
        {
            for (i in 0...4)
            {
                // FlxG.log.add(i);
                var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);
                babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets_retrobf', 'shared');
                babyArrow.animation.addByPrefix('green', 'arrowUP');
                babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
                babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
                babyArrow.animation.addByPrefix('red', 'arrowRIGHT');
                babyArrow.antialiasing = FlxG.save.data.antialiasing;
                babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
                switch (Math.abs(i))
                {
                    case 0:
                        babyArrow.x += Note.swagWidth * 0;
                        babyArrow.animation.addByPrefix('static', 'arrowLEFT');
                        babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
                        babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
                    case 1:
                        babyArrow.x += Note.swagWidth * 1;
                        babyArrow.animation.addByPrefix('static', 'arrowDOWN');
                        babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
                        babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
                    case 2:
                        babyArrow.x += Note.swagWidth * 2;
                        babyArrow.animation.addByPrefix('static', 'arrowUP');
                        babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
                        babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
                    case 3:
                        babyArrow.x += Note.swagWidth * 3;
                        babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
                        babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
                        babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
                }
                babyArrow.updateHitbox();
                babyArrow.scrollFactor.set();

                babyArrow.ID = i;

                if (player == 1)
                    playerStrums.add(babyArrow);

                babyArrow.animation.play('static');
                babyArrow.x += 50;
                babyArrow.x += ((FlxG.width / 2) * player);

                strumLineNotes.add(babyArrow);
            }
        }
}