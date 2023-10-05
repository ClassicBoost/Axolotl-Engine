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

using StringTools;

class CountdownAssets extends FlxTypedGroup<FlxBasic>
{
    // there is kinda nothing here
    public function new() {
		// call the initializations and stuffs
		super();        
    }

    public function countdown(swagCounter:Int) {
        var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
        introAssets.set('default', [
            ForeverTools.returnSkinAsset('ready', PlayState.assetModifier, PlayState.changeableSkin, 'UI'),
            ForeverTools.returnSkinAsset('set', PlayState.assetModifier, PlayState.changeableSkin, 'UI'),
            ForeverTools.returnSkinAsset('go', PlayState.assetModifier, PlayState.changeableSkin, 'UI')
        ]);

        var introAlts:Array<String> = introAssets.get('default');
        for (value in introAssets.keys())
        {
            if (value == PlayState.curStage)
                introAlts = introAssets.get(value);
        } 
        switch (swagCounter)
			{
				case 0:
					FlxG.sound.play(Paths.sound('countdowns/${PlayState.assetModifier}/intro3'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (PlayState.assetModifier == 'pixel')
						ready.setGraphicSize(Std.int(ready.width * PlayState.daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('countdowns/${PlayState.assetModifier}/intro2'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (PlayState.assetModifier == 'pixel')
						set.setGraphicSize(Std.int(set.width * PlayState.daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('countdowns/${PlayState.assetModifier}/intro1'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (PlayState.assetModifier == 'pixel')
						go.setGraphicSize(Std.int(go.width * PlayState.daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('countdowns/${PlayState.assetModifier}/introGo'), 0.6);
			}
    }
}