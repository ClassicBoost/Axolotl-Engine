package meta.state.menus;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gameObjects.userInterface.menu.Checkmark;
import gameObjects.userInterface.menu.Selector;
import meta.MusicBeat.MusicBeatState;
import meta.data.dependency.Discord;
import gameObjects.*;
import meta.data.dependency.FNFSprite;
import meta.data.font.Alphabet;
import meta.subState.OptionsSubstate;

class WarningState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		warnText = new FlxText(0, 0, FlxG.width,
			'WARNING\n\n
			
			This Engine is in an alpha state\nYeah, that\'s it lol.\n(No I don\'t support what Yoshubs did)\n

			${Main.devMode == true ? 'devMode is currently on\nGo to Main.hx to disable this mode.' : ''}
			
			Press any ENTER or ESCAPE to Continue',
			32);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			var back:Bool = controls.BACK;
			if (controls.ACCEPT || back) {
				if (Init.showPreOptions || Init.trueSettings.get('Debug Info')) {
				FlxG.save.data.showPreOptions = false;
				FlxG.save.flush();
				Main.switchState(this, new OptionsPREState());
				}
				else
				Main.switchState(this, new TitleState());
			}
		}
		super.update(elapsed);
	}
}
