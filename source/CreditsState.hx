package;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

using StringTools;
#if windows
import Discord.DiscordClient;
#end


class CreditGroup extends FlxBasic
{
	public var name:FlxTypeText; // Positions are based off this text location
	public var nameStr:String;
	public var tag:FlxTypeText;
	public var icon:FlxSprite;
	public var color:FlxColor;
	public var link:String;
	public var quotes:Array<String>;
	public var nodes:Array<CreditGroup>; // Left, Down, Up, Right

	var quoteIndex:Int = -1;

	public function new(Name:FlxTypeText, NameString:String, Tag:FlxTypeText, Icon:FlxSprite, Color:FlxColor, Link:String, Quotes:Array<String>)
	{
		super();

		name = Name;
		nameStr = NameString;
		tag = Tag;
		icon = Icon;
		color = Color;
		link = Link;
		quotes = Quotes;
		nodes = [null, null, null, null];

		quoteIndex = FlxG.random.int(0, quotes.length);
	}

	public function tweenPosition(X:Float, Y:Float, Duration:Float = 1, ?Options:TweenOptions)
	{
		FlxTween.tween(name, {x: X, y: Y}, Duration, Options);
		FlxTween.tween(tag, {x: X, y: Y + 20}, Duration, Options);
		FlxTween.tween(icon, {x: X - 50, y: Y}, Duration, Options);
	}

	public function setPosition(X:Float, Y:Float)
	{
		name.setPosition(X, Y);
		tag.setPosition(X, Y + 20);
		icon.setPosition(X - 50, Y);
	}

	public function getNextQuote():String
	{
		quoteIndex++;

		if (quoteIndex >= quotes.length)
			quoteIndex = 0;

		return quotes[quoteIndex];
	}

	public function select()
	{
		name.setFormat("VCR OSD Mono", 24, color);
	}

	public function deselect()
	{
		name.setFormat("VCR OSD Mono", 24, FlxColor.WHITE);
	}
}

class CreditsState extends MusicBeatState
{
	// Array key:
	// 0 - Name
	// 1 - Twitter Tag
	// 2 - Icon name
	// 3 - Color
	// 4 - Twitter Link
	// 5 - Array of quotes

    var sectionArrays:Array<Dynamic> = [
		[
			// Artists
			['Andrew J', '@AndrewMJArt', 'andrew', FlxColor.fromRGB(255, 221, 114), 'https://twitter.com/andrewmjart', ['Hi', 'Bruh', 'Help', 'Just Happy To be Here', 'Do Not Ask Me To Do Lineart', 'Cleaned Up Sketch or Death', 'Dilf Lover and Future DILF in the Making', 'Struggles Profoundly on Easy No Fail Mode']],
			['Blue', '@BlueTeaLover1', 'blue', 0xFF9212e7, 'https://twitter.com/bluetealover1', ['Prepare the tea', 'Beware of artists, we own the power to make anything hot.', 'Sleep can be a blessing, an\' a curse.', 'Yes, I am very fancy.', 'I\'m a simple guy, dark purples an\' blues make me content.']],
			['Bones', '@Bskelebunny01', 'bon', FlxColor.fromRGB(246, 110, 191), 'https://twitter.com/bskelebunny01', ['This short munchkin here is OPPRESSED!!', 'to my dear friend Springy, remember that Garcello taught us \"how to blow\"', 'Biggies wike yu shouwd be dead in my handsies >:3', ':3', 'Retro bully me help--', 'himbo is based', 'beware for those who have ocs in suits/tux :333']],
			['D6', '@DSiiiiiix', 'd6', FlxColor.fromRGB(109, 109, 109), 'https://twitter.com/DSiiiiiix', ["what if my quote was so unnecessarily long that it stretched off the screen so no one would read it that would be cool i think that would be so funny like you cant read all of it without going into the files just to read this dumb little quote that would be stupid get out of the files stupid yeah you i see you reading this", "thank you jinx and fae for being there for me when no one else was i miss you guys sm", "hi alex hi alex hi travis hope things are goin alright i miss you guys", "thank you, everyone in birdhouse, for making me feel valid and accepted :)", "remember to find happiness in your life. even if today sucked, tomorrow might be better. you never know.", "thank you soot for keeping me sane through second semester LOL", "thank you nic and gavin for the best 3 years of my life. ik things didn't go as well as they could've but i'll never forget you guys", "please go check out everyone else here they're awesome", "i think i have the most quotes out of everyone here. maybe i do need that duct tape...", "what if when you hovered over me it played a vine boom sound? it doesn't but if it did that would be kind of funny"]],
			['Dax', '@Daxite_', 'dax', FlxColor.fromRGB(43, 39, 125), 'https://twitter.com/daxite_', ["tasty burger eat the burger", "literally one of the only non-furries who worked on this", "freaks", "i hate children", "i'm responsible for sexy goth gf, you're welcome", "i eat kids", "retrosoylent", "resident easy/normal mode shitter", "cardiac arrest in da treehouse", "i heard kee is the secret final boss", "REJOICE", "The hoary bat is a species of bat in the vesper bat family, Vespertilionidae. It lives throughout most of North America and much of South America, with disjunct populations in the Galápagos Islands and Hawaii.", "EATS MOSQUITOES"]],
			['Jade', '@aureumber', 'jade', FlxColor.fromRGB(219, 119, 145), 'https://twitter.com/aureumber', ['I love refridgerators', 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA skin', 'i made the text you clicked to get to this screen :D', 'these people you see here are very cool check them out >:0', 'i dont like this i wanna go home :whyy:', 'why are you people like this :dead:', 'fun fact ive never had a burger', 'complete masochist over here', 'this mod crashed me pc lol', 'help']],
			['Kevin B.', 'kevinbaezfnf@gmail.com', 'kevin', FlxColor.fromRGB(255, 104, 0), null, ["Mba'e??(what in guarani)", "vine boom sound effect", "|  | |\n||  |_" , "Is cool, i respect ya", "Focus and spend time in your goals"]],
			['KittenSneeze', '@thekittensneeze', 'kittensneeze', FlxColor.fromRGB(162, 255, 26), 'https://twitter.com/thekittensneeze', ['It\'s because i\'m allergic to cats okay', 'If you say I sound like Spinel I can and will dropkick you', 'I\'m coming for your kneecaps, Retro', 'We are an entire team of furries, how we even completed this mod is a mystery to me', 'The lesbian here to vibecheck all the furries']],
			["Pyxl",  "@Pyxlbird", 'pyxl', FlxColor.fromRGB(132, 104, 201), "https://twitter.com/pyxlbird", ["What day is it??", "don't mess with me I will cry", "I'll do my best until I don't feel like it.", "hey I'm dying whats up", "Unkown error; quitting application"]],
			['Razur', '@Razur_Draws', 'razur', FlxColor.fromRGB(16, 241, 179), 'https://twitter.com/razur_draws', ['Haha yeah... I made Blammed', 'What the Raz doin tho!?', 'Real italian shit', 'Newgrounds is my home', 'I\'ve been razzling dazzling all day', 'not gonna lie.. just kidding I just lied', 'Shout out to Bakukod\'s Soundcloud', 'Play the Skater Mod too', 'I wish to have a better Wi-fi']],
			['Shiba Chichi', '@lolychichi', 'chichi', FlxColor.fromRGB(254, 196, 208), 'https://twitter.com/lolychichi', ['Gimme Chocolate!', 'I don\'t feel like doing homework, maybe I\'ll take a nap', 'Without the bad times, we wouldn\'t appreciate the good times', 'Could you not call me when I\'m trying to sleep?', 'The hardest part of living is waking up early', 'All artists tend to be a bit weird', 'I\'m tired of crying so much', 'I\'m gonna eat all the cakes in the world', 'I never give up! except..sometimes..', 'I do a good job when i have to']],
			['Speck', '@Speckygb', 'speck', FlxColor.fromRGB(255, 173, 106), 'https://twitter.com/speckygb', ['SORRY IM LATE GUYS', 'The full steam dude', 'someone please teach me how to chart', 'PLAY SPECTR OF TORMENT', 'Drink water.', 'We need more steampunk fnf', 'Shoutouts to my homies JC and DJ', 'Toshi is cool', 'Vitri stan']],
			['Tenzu', '@Tenzubushi', 'tenzu', FlxColor.GRAY, 'https://twitter.com/Tenzubushi', ['what the fuck does "hominid" means?', 'I\'m not a furry, BUT-', 'alguien habla español? Nadie? AYUDA ME TIENEN SECUESTRADO!', 'el completo no es un sándwich aweonao >:c', 'hips > bubz fight me', 'short chubby girls supremacy', 'never gonna give you up, never gonna let you down :)', 'uwu', 'goth gf is too much for this world, but you are not ready for this conversation.', 'MAMAAA TRAEME DESAYUNO']],
			['Wildface', '@wildface1010', 'wild', FlxColor.fromRGB(233, 19, 19), 'https://twitter.com/wildface1010', ["Yes I also made the Seven Deadly Dumpies", "Spare me... Am only a wee lil boi", "Frick you (ungrills your cheese)", "What if we pretend that airplanes in the n-", "Flipaclip my beloved", "Ann from Identity V my beloved", "Kua and Mika my beloved", "Am I... Furry????", "God I fucking love doing line art", "It's time to get funky", "Thanks a lot for checking me out!"]],
			['Wolfwrathknight', '@Wolfwrathknight', 'wolf', FlxColor.fromRGB(0, 124, 254), 'https://twitter.com/wolfwrathknight', ['No one asks a robot what he wants...', 'Who even designed \'Humans\'', 'I\'m COOL, I\'m HOT, I\'m everything you\'re NOT', 'I\'ll deep-clean your systems!', 'Can I have your IP number?', 'I\'ll hakuna your tatas~']]
		],
		[
			// Animators
			['Andrew J', '@AndrewMJArt', 'andrew', FlxColor.fromRGB(255, 221, 114), 'https://twitter.com/andrewmjart', ['Hi', 'Bruh', 'Help', 'Just Happy To be Here', 'Do Not Ask Me To Do Lineart', 'Cleaned Up Sketch or Death', 'Dilf Lover and Future DILF in the Making', 'Struggles Profoundly on Easy No Fail Mode']],
			['KittenSneeze', '@thekittensneeze', 'kittensneeze', FlxColor.fromRGB(162, 255, 26), 'https://twitter.com/thekittensneeze', ['It\'s because i\'m allergic to cats okay', 'If you say I sound like Spinel I can and will dropkick you', 'I\'m coming for your kneecaps, Retro', 'We are an entire team of furries, how we even completed this mod is a mystery to me', 'The lesbian here to vibecheck all the furries']],
			['Razur', '@Razur_Draws', 'razur', FlxColor.fromRGB(16, 241, 179), 'https://twitter.com/razur_draws', ['Haha yeah... I made Blammed', 'What the Raz doin tho!?', 'Real italian shit', 'Newgrounds is my home', 'I\'ve been razzling dazzling all day', 'not gonna lie.. just kidding I just lied', 'Shout out to Bakukod\'s Soundcloud', 'Play the Skater Mod too', 'I wish to have a better Wi-fi']],
			['Wildface', '@wildface1010', 'wild', FlxColor.fromRGB(233, 19, 19), 'https://twitter.com/wildface1010', ["Yes I also made the Seven Deadly Dumpies", "Spare me... Am only a wee lil boi", "Frick you (ungrills your cheese)", "What if we pretend that airplanes in the n-", "Flipaclip my beloved", "Ann from Identity V my beloved", "Kua and Mika my beloved", "Am I... Furry????", "God I fucking love doing line art", "It's time to get funky", "Thanks a lot for checking me out!"]],
			['Wolfwrathknight', '@Wolfwrathknight', 'wolf', FlxColor.fromRGB(0, 124, 254), 'https://twitter.com/wolfwrathknight', ['No one asks a robot what he wants...', 'Who even designed \'Humans\'', 'I\'m COOL, I\'m HOT, I\'m everything you\'re NOT', 'I\'ll deep-clean your systems!', 'Can I have your IP number?', 'I\'ll hakuna your tatas~']]
		],
		[
			// Audio
			['Kamex', '@KamexVGM', 'kamex', FlxColor.fromRGB(186, 226, 255), 'https://twitter.com/kamexvgm', ['The other music dragon thing', 'Switch between each menu theme it\'s fun', 'Hivemine\'s menu theme kinda sucks', 'Retro pays me with doordash meals', 'Everyone is so mean 2 me </3', 'Please use limiters on your FNF vocals everyone I beg of you', 'Phase 2 hot']],
			['RetroSpecter', '@RetroSpecter_', 'retro', FlxColor.fromRGB(23, 216, 228), 'https://twitter.com/RetroSpecter_', ["This mod ruined my mental health and YT channel for 4 months :D", "I can't wait for people to think I made the menu themes even though Kamex did.", "The Dev Team is strapped in the basement and ready to work on Part 2", "The song called 'Retro' sucks.", "Play Metroid ya posers", "Nidoqueen was the start of it all. :pensive:", "I hope you liked the kicks and snares I added!", "A huge shoutout to everyone on our team, they all did a phenomenal job <3", "The OG Minus GF and Demon Sarvente simp", "Huge shoutout to Banbuds for just being an all around cool guy to talk to since I joined the community :)", "I hope you're ready for Sloth's week in 2025!", "Shoutout to my mom for housing me until Youtube became a sustainable job for me", "Phase 2 has 4 balls and a sick back tattoo. It's canon", "Yes, the voice for Retro is my voice in both phases.", "I'm not a furry but: Sakuroma, Salazzle, Garchomp, Renamon, Atrocean, Charizard, Bowser, Toriel, Rogue The Bat, Hivemine, Insatian, Hornet, Iselda, Terry, Toxtricity, Carrot & Wanda, Gardevoir, Nidoqueen, Berserker Retro"]]
		],
		[
			// Programming
			['ArcyDev', '@AwkwardArcy', 'arcy', 0xFFed870f, 'https://twitter.com/AwkwardArcy', ['This whole mod team was amazing to work with. Please check them out!', 'Bark!', 'Please don\'t look at the source code', 'Yes Retro, I\'ll put in this feature at 5 AM', 'Sorry, I don\'t know how to optimize for potatoes', 'Vs Retrospecter development speedrun - 286:37:44.69', 'I am never touching HaxeFlixel ever again', 'Good design patterns? Multithreading? A clean, readable codebase? Sorry, I don\'t know what any of those are']],
			['Carbon', '@LucasLacus02', 'carbon', FlxColor.fromRGB(229, 229, 221), 'https://twitter.com/lucaslacus02', ['I\'m going back to Unity', 'Mutex lock deez nuts', 'I\'m actually a Seagle (Seagull+Eagle)', 'Arcy\'s helper bird', 'While you\'re lying there screamin \'come help me please\' the seagulls, poke yo knees', 'Did someone say multithreading ;)', 'Play Touhou', 'Bird Gang', 'Jade\'s sleep paralysis demon']],
			['TSG', '@AyeTSG', 'tsg', FlxColor.fromRGB(120, 120, 120), 'https://twitter.com/ayetsg', ['bark bark im programming', 'i love tally hall', 'i do a little trolling', 'dame da ne', 'bark', 'axolotls are cool', 'i like cats', 'i like fennec foxes']]
		],
		[
			// Charting
			['Lily Clipee-chan', '@LilyClipster', 'clip', FlxColor.fromRGB(251, 239, 11), 'https://twitter.com/LilyClipster', ["ena my nuts you goblins", "Snow never gave me my rug yet", "haha funni arrows go brr", "owen, you're the best you jerk lol", "Hey mom look, im on the screen", "this is all cus american boy exists"]],
			['Snow', '@SnowTheFox122', 'snow', FlxColor.fromRGB(239, 107, 107), 'https://twitter.com/snowthefox122', ['Professional Fox Boy', 'uwu', 'owo', 'please send help Retro has taken everyone I hold dear hostage cALL LAW ENFORCEMENT--', 'Imagine sleep schedules', 'You got the secret message! You\'re cool. :)', 'Please use modcharts :(', 'Hi Sticky!', 'Hi Anthony!', 'Shoutout to Rex, Grim, Sky, Moon, Metro, Fluffy, Jes, Kuroh, Kat.', 'Death Squad are poggers', 'Discordant Chronicles party time', 'Man, I wonder if I should try singing some time...', 'HEY, CHECK OUT KAMEX TOO >:(', 'Wonder if youve seen all of my quotes yet', 'Hi DF Team! I miss you, I\'ll come back one day. ;w;', 'My boy Harlow, my true beloved.', 'lol the programmers are gonna hate me for all these quotes', 'am i cool yet', 'I should get back to working at that mall...', 'I have 20+ quotes lol']]
		],
		[
			// Special Thanks
			['Crudaka', '@Croodaka', 'crudaka', 0xFFff4700, 'https://twitter.com/Croodaka', []],
			['Iago', '@IagoAnims', 'iago', 0xFFCCCCCC, 'https://twitter.com/IagoAnims', []],
			['Kade', '@KadeDev', 'kade', 0xFF4b6448, 'https://twitter.com/KadeDeveloper', []],
			['Kinix', '@SLKinix', 'kinix', 0xFFa3f9ff, 'https://twitter.com/SLKinix', []],
			['Ravi', '@RavioliBox', 'ravi', 0xFFf9366c, 'https://twitter.com/RavioliBox', []],
			['RobynTheDragon', '@RobynTheDragon', 'robyn', 0xFF9212e7, 'https://twitter.com/RobynTheDragonn', []],
			['Springy_4264', '@Springy_4264', 'springy', 0xFFac0047, 'https://twitter.com/Springy_4264', []]
		]
	];

	var titleNames:Array<String> = ['Artists', 'Animators', 'Programming', 'Special Thanks'];
	var title2Names:Array<String> = ['', 'Audio', 'Charting', ''];

    var iconList:FlxTypedGroup<FlxSprite>;
	var titleList:FlxTypedGroup<FlxText>;
	var secondTitleList:FlxTypedGroup<FlxText>;
	var curSection:Int = 0;
	var curSelected:CreditGroup;
	var textLength:FlxText;
	var quoteText:FlxTypeText;
	var memeText:FlxTypeText;
	var quotePerson:FlxTypeText;

	var creditSections:FlxTypedGroup<FlxTypedGroup<CreditGroup>>;
	var credit2Sections:FlxTypedGroup<FlxTypedGroup<CreditGroup>>;
	var artistCredits:FlxTypedGroup<CreditGroup>;
	var allowInputs:Bool = true;

	var shh:FlxSound;

	override function create()
	{
		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Reading Credits", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
		bg.color = 0xFF803fff;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = FlxG.save.data.antialiasing;
		bg.alpha = 0.75;
		add(bg);

        iconList = new FlxTypedGroup<FlxSprite>();
		titleList = new FlxTypedGroup<FlxText>();
		secondTitleList = new FlxTypedGroup<FlxText>();
		creditSections = new FlxTypedGroup<FlxTypedGroup<CreditGroup>>();
		credit2Sections = new FlxTypedGroup<FlxTypedGroup<CreditGroup>>();
		artistCredits = new FlxTypedGroup<CreditGroup>();

		var title:FlxText = new FlxText(0, 25, 0, 'CREDITS', 100);
		title.setFormat("VCR OSD Mono", 100, FlxColor.WHITE);
		title.screenCenter(X);
		add(title);

		var instructions:FlxText = new FlxText(10, 10, 500, 'Move to select a person\nConfirm to go to their Twitter page\nQ and E to change sections');
        instructions.setFormat("VCR OSD Mono", 18, FlxColor.WHITE, FlxTextAlign.LEFT);
        add(instructions);

		textLength = new FlxText(0, 600, 0, '');
		textLength.setFormat("VCR OSD Mono", 36, FlxColor.WHITE);
		quoteText = new FlxTypeText(textLength.x, 600, 1280, '');
		quoteText.setFormat("VCR OSD Mono", 36, FlxColor.WHITE);
		quoteText.sounds = [FlxG.sound.load(Paths.sound('bfText'), 0.6)];
		add(quoteText);
		memeText = new FlxTypeText(textLength.x, 600, 0, '');
		memeText.setFormat("VCR OSD Mono", 36, FlxColor.WHITE);
		memeText.sounds = [FlxG.sound.load(Paths.sound('bfText'), 0.6)];
		memeText.visible = false;
		add(memeText);
		quotePerson = new FlxTypeText(650, 675, 0, '');
		quotePerson.setFormat("VCR OSD Mono", 24, FlxColor.WHITE);
		add(quotePerson);

		for (i in 0...titleNames.length)
		{
			var subTitle:FlxText = new FlxText(2175, 150, 0, titleNames[i], 50);
			subTitle.setFormat("VCR OSD Mono", 50, FlxColor.WHITE);
			titleList.add(subTitle);

			var secondSubTitle:FlxText = new FlxText(2175, 400, 0, title2Names[i], 50);
			secondSubTitle.setFormat("VCR OSD Mono", 50, FlxColor.WHITE);
			secondTitleList.add(secondSubTitle);
		}

		// Hard code workaround
		credit2Sections.add(new FlxTypedGroup<CreditGroup>());

		for (i in 0...sectionArrays.length)
		{
			var section:FlxTypedGroup<CreditGroup> = new FlxTypedGroup<CreditGroup>();

			for (j in 0...sectionArrays[i].length)
			{
				var icon:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('icons/' + sectionArrays[i][j][2], 'preload'));
				icon.setGraphicSize(50, 50);
				icon.antialiasing = FlxG.save.data.antialiasing;	// (tsg - 8/12/2021) make the icons anti aliased so they dont look like shit
				icon.updateHitbox();
				var name:FlxTypeText = new FlxTypeText(0, 0, 0, sectionArrays[i][j][0]);
				name.setFormat("VCR OSD Mono", 24, FlxColor.WHITE);
				name.start(0.1);
				add(name);
				var tag:FlxTypeText = new FlxTypeText(0, 0, 0, sectionArrays[i][j][1]);
				tag.setFormat("VCR OSD Mono", 18, 0xFFd1d1d1);
				tag.start(0.1);
				add(tag);
				var credit:CreditGroup = new CreditGroup(name, sectionArrays[i][j][0], tag, icon, sectionArrays[i][j][3], sectionArrays[i][j][4], sectionArrays[i][j][5]);

				iconList.add(icon);
				section.add(credit);
			}

			for (i in 0...section.length)
			{
				section.members[i].setPosition(2175 + ((i % 3) * 400), 250 + (Std.int(i / 3) * 100));

				// Left
				if (i % 3 != 0)
				{
					section.members[i].nodes[0] = section.members[i - 1];
				}
				else if (i + 2 < section.length)
				{
					section.members[i].nodes[0] = section.members[i + 2];
				}
				else
				{
					section.members[i].nodes[0] = section.members[section.length - 1];
				}
				// Down
				if (i + 3 < section.length)
				{
					section.members[i].nodes[1] = section.members[i + 3];
				}
				else
				{
					section.members[i].nodes[1] = section.members[i % 3];
				}
				// Up
				if (i - 3 >= 0)
				{
					section.members[i].nodes[2] = section.members[i - 3];
				}
				else
				{
					var remainder:Int = section.length % 3;
					var column:Int = i % 3;
					if (remainder < column + 1)
					{
						section.members[i].nodes[2] = section.members[section.length - remainder - (3 - column - 1) - 1];
					}
					else if (remainder > column + 1)
					{
						section.members[i].nodes[2] = section.members[section.length - (3 - column - 1)];
					}
					else
					{
						section.members[i].nodes[2] = section.members[section.length - 1];
					}
				}
				// Right
				if (i + 1 >= section.length)
				{
					section.members[i].nodes[3] = section.members[i - (i % 3)];
				}
				else if (i % 3 != 2)
				{
					section.members[i].nodes[3] = section.members[i + 1];
				}
				else if (i - 2 < section.length)
				{
					section.members[i].nodes[3] = section.members[i - 2];
				}
				else
				{
					section.members[i].nodes[3] = section.members[section.length - 1];
				}
			}

			if (i == 2 || i == 4)
			{
				credit2Sections.add(section);
			}
			else
			{
				creditSections.add(section);
			}
		}

		// Haha I'm not figuring out the math to connect two sections fuck that
		// Hard coding I don't care
		credit2Sections.members[1].members[0].nodes[1] = creditSections.members[1].members[0];
		creditSections.members[1].members[0].nodes[2] = credit2Sections.members[1].members[0];
		credit2Sections.members[1].members[0].nodes[2] = creditSections.members[1].members[3];
		creditSections.members[1].members[3].nodes[1] = credit2Sections.members[1].members[0];
		credit2Sections.members[1].members[1].nodes[1] = creditSections.members[1].members[1];
		creditSections.members[1].members[1].nodes[2] = credit2Sections.members[1].members[1];
		credit2Sections.members[1].members[1].nodes[2] = creditSections.members[1].members[4];
		creditSections.members[1].members[4].nodes[1] = credit2Sections.members[1].members[1];

		credit2Sections.members[2].members[0].nodes[1] = creditSections.members[2].members[0];
		creditSections.members[2].members[0].nodes[2] = credit2Sections.members[2].members[0];
		credit2Sections.members[2].members[0].nodes[2] = creditSections.members[2].members[0];
		creditSections.members[2].members[0].nodes[1] = credit2Sections.members[2].members[0];
		credit2Sections.members[2].members[1].nodes[1] = creditSections.members[2].members[1];
		creditSections.members[2].members[1].nodes[2] = credit2Sections.members[2].members[1];
		credit2Sections.members[2].members[1].nodes[2] = creditSections.members[2].members[1];
		creditSections.members[2].members[1].nodes[1] = credit2Sections.members[2].members[1];

		credit2Sections.add(new FlxTypedGroup<CreditGroup>());

		// Initialize
		titleList.members[curSection].setPosition(640 - (titleList.members[curSection].width / 2), 150);
		secondTitleList.members[curSection].setPosition(640 - (secondTitleList.members[curSection].width / 2), 400);
		for (i in 0...creditSections.members[curSection].length)
		{
			creditSections.members[curSection].members[i].setPosition(175 + ((i % 3) * 400), 250 + (Std.int(i / 3) * 75));
		}
		for (i in 0...credit2Sections.members[curSection].length)
		{
			credit2Sections.members[curSection].members[i].setPosition(175 + ((i % 3) * 400), 500 + (Std.int(i / 3) * 75));
		}

		curSelected = creditSections.members[curSection].members[0];
		curSelected.select();

		shh = new FlxSound().loadEmbedded(Paths.sound('forD6', 'shared'));
		FlxG.sound.list.add(shh);

		add(titleList);
		add(secondTitleList);
        add(iconList);
		add(creditSections);
		add(credit2Sections);

		updateQuote();

		super.create();
	}

	override function update(elapsed:Float)
	{
        // For animations on beat
		if (TitleState.introMusic != null && TitleState.introMusic.playing)
		{
			Conductor.songPosition = TitleState.introMusic.time;
		}
		else if (FlxG.sound.music != null)
        {
            Conductor.songPosition = FlxG.sound.music.time;
        }

        if (controls.BACK)
        {
            FlxG.switchState(new MainMenuState());
        }
		else if (controls.ACCEPT)
		{
			// (tsg - 8/14/2021) dont try to open null links (such as kevin's)
			if (curSelected.link != null) {
				FlxG.openURL(curSelected.link);
			}
		}

		if (allowInputs && FlxG.keys.justPressed.Q)
		{
			changeSection(-1);
		}
		else if (allowInputs && FlxG.keys.justPressed.E)
		{
			changeSection(1);
		}
		else if (controls.LEFT_P)
		{
			move(0);
		}
		else if (controls.RIGHT_P)
		{
			move(3);
		}
		else if (controls.UP_P)
		{
			move(2);
		}
		else if (controls.DOWN_P)
		{
			move(1);
		}

        for (i in 0...iconList.length)
        {
            iconList.members[i].setGraphicSize(Std.int(FlxMath.lerp(50, iconList.members[i].width, 0.50)));
            iconList.members[i].updateHitbox();
        }

		super.update(elapsed);
	}

    override function beatHit()
    {
        for (i in 0...iconList.length)
        {
            FlxTween.tween(iconList.members[i], {width: 60, height: 60}, 0.05, {ease: FlxEase.cubeOut});
        }
    }

	// 0 - Left
	// 1 - Down
	// 2 - Up
	// 3 - Right
	function move(direction:Int)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));

		curSelected.deselect();
		curSelected = curSelected.nodes[direction];
		curSelected.select();

		updateQuote();
	}

	function changeSection(direction:Int)
	{
		allowInputs = false;

		FlxTween.tween(titleList.members[curSection], {x: (direction < 0 ? 2175 : -1825) - (titleList.members[curSection].width / 2)}, 1, {ease: FlxEase.cubeInOut});
		FlxTween.tween(secondTitleList.members[curSection], {x: (direction < 0 ? 2175 : -1825) - (secondTitleList.members[curSection].width / 2)}, 1, {ease: FlxEase.cubeInOut});
		for (i in 0...creditSections.members[curSection].length)
		{
			creditSections.members[curSection].members[i].tweenPosition((direction < 0 ? 2175 : -1825) + ((i % 3) * 400),  250 + (Std.int(i / 3) * 75), 1, {ease: FlxEase.cubeInOut});
		}
		for (i in 0...credit2Sections.members[curSection].length)
		{
			credit2Sections.members[curSection].members[i].tweenPosition((direction < 0 ? 2175 : -1825) + ((i % 3) * 400),  500 + (Std.int(i / 3) * 75), 1, {ease: FlxEase.cubeInOut});
		}

		curSection += direction;

		if (curSection >= creditSections.length)
		{
			curSection = 0;
		}
		else if (curSection < 0)
		{
			curSection = creditSections.length - 1;
		}

		curSelected.deselect();
		curSelected = creditSections.members[curSection].members[0];
		curSelected.select();

		updateQuote();

		titleList.members[curSection].setPosition((direction < 0 ? -1825 : 2175) + (titleList.members[curSection].width / 2), 150);
		secondTitleList.members[curSection].setPosition((direction < 0 ? -1825 : 2175) + (titleList.members[curSection].width / 2), 400);
		FlxTween.tween(titleList.members[curSection], {x: 640 - (titleList.members[curSection].width / 2)}, 1, {ease: FlxEase.cubeInOut, onComplete: function(flx:FlxTween) { allowInputs = true; }});
		FlxTween.tween(secondTitleList.members[curSection], {x: 640 - (secondTitleList.members[curSection].width / 2)}, 1, {ease: FlxEase.cubeInOut, onComplete: function(flx:FlxTween) { allowInputs = true; }});
		for (i in 0...creditSections.members[curSection].length)
		{
			creditSections.members[curSection].members[i].setPosition((direction < 0 ? -1825 : 2175) + ((i % 3) * 400), 250 + (Std.int(i / 3) * 75));
			creditSections.members[curSection].members[i].tweenPosition(175 + ((i % 3) * 400),  250 + (Std.int(i / 3) * 75), 1, {ease: FlxEase.cubeInOut});
		}

		for (i in 0...credit2Sections.members[curSection].length)
		{
			credit2Sections.members[curSection].members[i].setPosition((direction < 0 ? -1825 : 2175) + ((i % 3) * 400), 500 + (Std.int(i / 3) * 75));
			credit2Sections.members[curSection].members[i].tweenPosition(175 + ((i % 3) * 400),  500 + (Std.int(i / 3) * 75), 1, {ease: FlxEase.cubeInOut});
		}
	}

	function updateQuote()
	{
		if (curSection == creditSections.length - 1)
		{
			quoteText.visible = false;
			memeText.visible = false;
			quotePerson.visible = false;
		}
		else
		{
			var quote = '"' + curSelected.getNextQuote() + '"';
			textLength.text = quote;
			textLength.screenCenter(X);
			quoteText.x = textLength.x;
			if (quoteText.x < -1000)
			{
				quoteText.visible = false;
				quoteText.skip();
				memeText.visible = true;
				memeText.resetText(quote);
				memeText.start(0.05);
			}
			else if (quoteText.x < 0)
			{
				quoteText.visible = true;
				memeText.visible = false;
				memeText.skip();
				quoteText.x = 0;
				quoteText.resetText(quote);
				quoteText.start(0.05);
			}
			else
			{
				quoteText.visible = true;
				memeText.visible = false;
				memeText.skip();
				quoteText.resetText(quote);
				quoteText.start(0.05);
			}

			quotePerson.visible = true;
			quotePerson.resetText('- ' + curSelected.nameStr);
			quotePerson.start(0.05);

			if (quote.contains('vine boom'))
				shh.play(true);
		}
	}
}
