package meta.subState;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import meta.MusicBeat.MusicBeatSubState;
import flixel.addons.display.FlxBackdrop;
import meta.data.font.Alphabet;
import flixel.util.FlxTimer;
import meta.data.*;
import meta.state.*;
import meta.state.menus.*;
import gameObjects.userInterface.*;

class PauseSubState extends MusicBeatSubState
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Botplay', 'Practice Mode', 'Options', 'Exit to menu'];
	var curSelected:Int = 0;

	var startTimer:FlxTimer;

	var pauseMusic:FlxSound;
	var extraInfo:FlxText;

	var bgfront:FlxBackdrop;

	public static var countDown:CountdownAssets;

	private var disableControls:Bool = false;

	var bg:FlxSprite;

	public function new(x:Float, y:Float)
	{
		super();
		#if debug
		// trace('pause call');
		#end

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, 0/*FlxG.random.int(0, Std.int(pauseMusic.length / 2))*/);

		FlxG.sound.play(Paths.sound('menus/pauseStart'));

		FlxG.sound.list.add(pauseMusic);

		disableControls = false;

		#if debug
		// trace('pause background');
		#end

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		bgfront = new FlxBackdrop(Paths.image('menus/base/checkeredBG'), 1, 1);
		bgfront.alpha = 0;
		bgfront.antialiasing = true;
		bgfront.scrollFactor.set();
		add(bgfront);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += CoolUtil.dashToSpace(PlayState.SONG.song);
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		#if debug
		// trace('pause info');
		#end

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyFromNumber(PlayState.storyDifficulty);
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var levelDeaths:FlxText = new FlxText(20, 15 + 64, 0, "", 32);
		levelDeaths.text += "Blue balled: " + PlayState.deaths;
		levelDeaths.scrollFactor.set();
		levelDeaths.setFormat(Paths.font('vcr.ttf'), 32);
		levelDeaths.updateHitbox();
		add(levelDeaths);

		extraInfo = new FlxText(20, 15 + 250, 0, "", 32);
		extraInfo.scrollFactor.set();
		extraInfo.setFormat(Paths.font('vcr.ttf'), 32);
		extraInfo.updateHitbox();
		add(extraInfo);

		countDown = new CountdownAssets();

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;
		levelDeaths.alpha = 0;
		extraInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		levelDeaths.x = FlxG.width - (levelDeaths.width + 20);
		extraInfo.x = FlxG.width - (levelDeaths.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(bgfront, {alpha: 0.6}, 1, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(levelDeaths, {alpha: 1, y: levelDeaths.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		FlxTween.tween(extraInfo, {alpha: 1, y: extraInfo.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		add(countDown);

		#if debug
		// trace('change selection');
		#end

		changeSelection();

		#if debug
		// trace('cameras');
		#end

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		#if debug
		// trace('cameras done');
		#end
	}

	override function update(elapsed:Float)
	{
		#if debug
		// trace('call event');
		#end

		super.update(elapsed);

		#if debug
		// trace('updated event');
		#end

		
		var scrollSpeed:Float = 50;
		bgfront.x -= scrollSpeed * elapsed;
		bgfront.y -= scrollSpeed * elapsed;

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		extraInfo.text = '';
		if (PlayState.cpuControlled) extraInfo.text += '\nBOTPLAY';
		if (PlayState.practiceMode) extraInfo.text += '\nPRACTICE MODE';

		if (!disableControls) {
		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					startCountdown();
					disableControls = true;
				case "Restart Song":
					Main.switchState(this, new PlayState());
				case 'Botplay':
					PlayState.cpuControlled = !PlayState.cpuControlled;
				case 'Practice Mode':
					PlayState.practiceMode = !PlayState.practiceMode;
				case 'Options':
					Main.switchState(this, new OptionsMenuState());
				case "Exit to menu":
					PlayState.resetMusic();
					PlayState.deaths = 0;
					PlayState.inSong = false;

					if (PlayState.isStoryMode)
						Main.switchState(this, new StoryMenuState());
					else {
						Main.switchState(this, new FreeplayState());
						ForeverTools.resetMenuMusic();
					}
			}
		}
		}

		if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}

		#if debug
		// trace('music volume increased');
		#end

		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.02 * elapsed;
	}

	private function startCountdown() {
		var fuckCounter:Int = 0;
		FlxTween.tween(bg, {alpha: 0}, 0.2, {ease: FlxEase.linear});
		FlxTween.tween(bgfront, {alpha: 0}, 0.2, {ease: FlxEase.linear});
		startTimer = new FlxTimer().start(Conductor.crochet / 2000, function(tmr:FlxTimer)
			{
				countDown.countdown(fuckCounter);
	
				fuckCounter += 1;
				if (fuckCounter >= 5) close();
			}, 5);
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		#if debug
		// trace('mid selection');
		#end

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}

		#if debug
		// trace('finished selection');
		#end
		//
	}
}
