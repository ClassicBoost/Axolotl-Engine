package gameObjects.userInterface;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import meta.CoolUtil;
import meta.data.Conductor;
import meta.data.Timings;
import meta.state.PlayState;
import sys.FileSystem;

using StringTools;

class ClassHUD extends FlxTypedGroup<FlxBasic>
{
	// set up variables and stuff here
	public static var scoreBar:FlxText;
	var scoreLast:Float = -1;

	// fnf mods
	var scoreDisplay:String = 'beep bop bo skdkdkdbebedeoop brrapadop';

	var cornerMark:FlxText; // engine mark at the upper right corner
	public static var centerMark:FlxText; // song display name and difficulty at the center

	private var SONG = PlayState.SONG;

	private var stupidHealth:Float = 0;

	private var timingsMap:Map<String, FlxText> = [];

	public static var healthBarBG:FlxSprite;
	public static var healthBar:FlxBar;
	public static var iconP1:HealthIcon;
	public static var iconP2:HealthIcon;

	var infoDisplay:String = CoolUtil.dashToSpace(PlayState.SONG.song);
	var diffDisplay:String = CoolUtil.difficultyFromNumber(PlayState.storyDifficulty);
	var engineDisplay:String = "FOREVER ENGINE PLUS v" + Main.axolotlVersion + "(v" + Main.gameVersion + ')\n';

	var composerDisplay:String;

	var textcolor:FlxColor;

	public static var composerTxt:FlxText;

	public static var msDisplay:String = '';
	public static var msTxt:FlxText;

	public static var newMS:String = '';
	public static var addMS:Float = 0.0;

	// eep
	public function new()
	{
		// call the initializations and stuffs
		super();

		textcolor = 0xFFFFFFFF;

		var stupidAnti:Bool = (!PlayState.curStage.startsWith("school") && !Init.trueSettings.get('Disable Antialiasing'));

		// le healthbar setup
		var barY = FlxG.height * 0.875;
		if (Init.trueSettings.get('Downscroll'))
			barY = 64;

		scoreBar = new FlxText(FlxG.width / 2, Math.floor(barY + 40), 0, scoreDisplay);
		scoreBar.setFormat(Paths.font(PlayState.choosenfont), 18, FlxColor.WHITE);
		scoreBar.setBorderStyle(OUTLINE, FlxColor.BLACK, 1.5);
		updateScoreText();
		// scoreBar.scrollFactor.set();
		scoreBar.antialiasing = stupidAnti;
		scoreBar.color = textcolor;
		add(scoreBar);

		cornerMark = new FlxText(0, 0, 0, engineDisplay);
		cornerMark.setFormat(Paths.font(PlayState.choosenfont), 18, FlxColor.WHITE);
		cornerMark.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		add(cornerMark);
		cornerMark.alpha = 0.8;
		cornerMark.setPosition(FlxG.width - (cornerMark.width + 5), 5);
		cornerMark.color = textcolor;
		cornerMark.antialiasing = stupidAnti;

		centerMark = new FlxText(0,0, 0, '- ${infoDisplay}${(Init.trueSettings.get('Show Difficulty') ? " [" + diffDisplay + "]": "")} -');
		centerMark.setFormat(Paths.font(PlayState.choosenfont), 24, FlxColor.WHITE);
		centerMark.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		add(centerMark);
		centerMark.screenCenter(X);
		centerMark.color = textcolor;
		centerMark.antialiasing = stupidAnti;
		if (Init.trueSettings.get('Downscroll'))
			centerMark.y = (FlxG.height - centerMark.height / 2) - 30;
		else {
			centerMark.y = (FlxG.height / 24) - 10;
		}

		var barY = FlxG.height * 0.875;
		if (Init.trueSettings.get('Downscroll'))
			barY = 64;
		healthBarBG = new FlxSprite(0,
			barY).loadGraphic(Paths.image(ForeverTools.returnSkinAsset('healthBar', PlayState.assetModifier, PlayState.changeableSkin, 'UI')));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8));
		healthBar.scrollFactor.set();
		add(healthBar);

		iconP1 = new HealthIcon('face', true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP1.antialiasing = !PlayState.isPixelStage;
		add(iconP1);

		iconP2 = new HealthIcon('face', false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		iconP2.antialiasing = !PlayState.isPixelStage;
		add(iconP2);

		msTxt = new FlxText(915, 30, 0, '', 20);
		msTxt.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		msTxt.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		msTxt.scrollFactor.set();
		add(msTxt);
		
		composerTxt = new FlxText(5, FlxG.height - 18, 0, "BLAH", 12);
		composerTxt.scrollFactor.set();
		composerTxt.setFormat(Paths.font(PlayState.choosenfont), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		if (!FileSystem.exists(Paths.txt('songs/${PlayState.SONG.song.toLowerCase()}/composerTxt'))) // incase no composer text file
		composerDisplay = '';
		else composerDisplay = '' + CoolUtil.coolTextFile(Paths.txt('songs/${PlayState.SONG.song.toLowerCase()}/composerTxt'));
		// Remove the fuckin [] from the text.
		composerDisplay.substring(0, composerDisplay.length - 1);
		composerDisplay.substring(composerDisplay.length - 1, 0);
		composerTxt.text = '$composerDisplay';
		composerTxt.antialiasing = stupidAnti;
		composerTxt.y = 800;
		composerTxt.screenCenter(X);
		add(composerTxt);

		// counter
		if (Init.trueSettings.get('Counter') != 'None')
		{
			var judgementNameArray:Array<String> = [];
			for (i in Timings.judgementsMap.keys())
				judgementNameArray.insert(Timings.judgementsMap.get(i)[0], i);
			judgementNameArray.sort(sortByShit);
			for (i in 0...judgementNameArray.length)
			{
				var textAsset:FlxText = new FlxText(5
					+ (!left ? (FlxG.width - 10) : 0),
					(FlxG.height / 2)
					- (counterTextSize * (judgementNameArray.length / 2))
					+ (i * counterTextSize), 0, '', counterTextSize);
				if (!left)
					textAsset.x -= textAsset.text.length * counterTextSize;
				textAsset.setFormat(Paths.font(PlayState.choosenfont), counterTextSize, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				textAsset.scrollFactor.set();
				textAsset.color = textcolor;
				textAsset.antialiasing = stupidAnti;
				timingsMap.set(judgementNameArray[i], textAsset);
				add(textAsset);
			}
		}
		updateScoreText();
	}

	var counterTextSize:Int = 18;

	function sortByShit(Obj1:String, Obj2:String):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Timings.judgementsMap.get(Obj1)[0], Timings.judgementsMap.get(Obj2)[0]);

	var left = (Init.trueSettings.get('Counter') == 'Left');

	override public function update(elapsed:Float)
	{
		// pain, this is like the 7th attempt
		if (PlayState.cpuControlled)
			scoreBar.text = '[BOTPLAY]';

		msTxt.text = msDisplay;
		msTxt.alpha -= 0.01;

		healthBar.percent = (PlayState.health * 50);

		if (!PlayState.useNewIconBop) {
		var iconLerp = 0.5;
		iconP1.setGraphicSize(Std.int(FlxMath.lerp(iconP1.initialWidth, iconP1.width, iconLerp)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(iconP2.initialWidth, iconP2.width, iconLerp)));
		} else {
			iconP1.setGraphicSize(Std.int(FlxMath.lerp(iconP1.width, 150, 0.09 / (Init.trueSettings.get('Framerate Cap') / 60))));
			iconP2.setGraphicSize(Std.int(FlxMath.lerp(iconP2.width, 150, 0.09 / (Init.trueSettings.get('Framerate Cap') / 60))));
		}

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		iconP1.animation.curAnim.curFrame = (healthBar.percent < 20 || PlayState.forceLose ? 1 : healthBar.percent > 80 ? 2 : 0);
		iconP2.animation.curAnim.curFrame = (healthBar.percent < 20 || PlayState.forceLose ? 2 : healthBar.percent > 80 ? 1 : 0);

		updateScoreText();
	}

	private final divider:String = " • ";

	public function updateScoreText()
	{
		var importSongScore = PlayState.songScore;
		var importPlayStateCombo = PlayState.combo;
		var importMisses = PlayState.misses;
		if (!PlayState.cpuControlled) {
		scoreBar.text = 'Score: $importSongScore';

		if (Init.trueSettings.get('Display Accuracy')) scoreBar.text += divider + 'Accuracy: ' + Std.string(Math.floor(Timings.getAccuracy() * 100) / 100) + '%' + Timings.comboDisplay;
		if (Init.trueSettings.get('Display Average MS')) scoreBar.text += divider + 'AVG MS: ' + (PlayState.songHits == 0 ? 0 : Math.round(addMS/PlayState.songHits));
		if (Init.trueSettings.get('Display Misses')) scoreBar.text += divider + 'Combo Breaks: ' + Std.string(PlayState.misses);
		if (Init.trueSettings.get('Display Rank')) scoreBar.text += divider + 'Rank: ' + Std.string(Timings.returnScoreRating());
		if (PlayState.practiceMode) scoreBar.text += divider + 'Practice Mode';
		}
		scoreBar.text += '\n';
		scoreBar.x = Math.floor((FlxG.width / 2) - (scoreBar.width / 2));

		// update counter
		if (Init.trueSettings.get('Counter') != 'None')
		{
			for (i in timingsMap.keys())
			{
				timingsMap[i].text = '${(i.charAt(0).toUpperCase() + i.substring(1, i.length))}: ${Timings.gottenJudgements.get(i)}';
				timingsMap[i].x = (5 + (!left ? (FlxG.width - 10) : 0) - (!left ? (6 * counterTextSize) : 0));
			}
		}

		msDisplay = (newMS == '' ? '?' : newMS) + ' MS';

		// update playstate
		PlayState.detailsSub = scoreBar.text;
		PlayState.updateRPC(false);
	}

	public static function startDaSong() {
		FlxTween.tween(composerTxt, {y: FlxG.height - 18}, 1, {ease: FlxEase.cubeOut});
	}

	public static function fadeOutSongText()
	{
		FlxTween.cancelTweensOf(composerTxt);
		FlxTween.tween(centerMark, {alpha: (Init.trueSettings.get('Show Song Progression') ? 0.85 : 0)}, 4, {ease: FlxEase.linear});
		FlxTween.tween(composerTxt, {y: composerTxt.y + 50}, 2, {ease: FlxEase.cubeOut});
	}

	public static function bopScore() {
		msTxt.alpha = 1;
		if (!PlayState.cpuControlled) {
		FlxTween.cancelTweensOf(scoreBar);
		scoreBar.scale.set(1.075, 1.075);

		if (Init.trueSettings.get('Smooth Bop')) FlxTween.tween(scoreBar, {"scale.x": 1, "scale.y": 1}, 0.25, {ease: FlxEase.cubeOut});
		else FlxTween.tween(scoreBar, {"scale.x": 1, "scale.y": 1}, 0.2, {ease: FlxEase.linear});
		}
	}

	public static function bopIcons() {
		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));
	
		iconP1.updateHitbox();
		iconP2.updateHitbox();
	}

	public static function reloadCharacterIcons(?bfIcon:String, ?dadIcon:String, ?updateBar:Bool = false) {
		if (updateBar) healthBar.createFilledBar(PlayState.dadOpponent.barColor, PlayState.boyfriend.barColor);

		iconP1.updateIcon(bfIcon,true);
		iconP2.updateIcon(dadIcon,false);
	}

	public function beatHit() {
		if (Init.trueSettings.get('Icon Bop')) bopIcons();
	}
}