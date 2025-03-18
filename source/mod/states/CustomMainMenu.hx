package mod.states;

import funkin.modding.base.ScriptedMusicBeatState;
import flixel.FlxSubState;
import funkin.Paths;
import funkin.ui.MusicBeatState;
import flixel.addons.display.FlxBackdrop;
import funkin.modding.base.ScriptedFlxSpriteGroup;
import flixel.FlxObject;
import funkin.graphics.FunkinCamera;
import funkin.audio.FunkinSound;
import flixel.addons.transition.FlxTransitionableState;
import funkin.util.Constants;
import funkin.util.WindowUtil;
import funkin.ui.title.TitleState;
import funkin.ui.story.StoryMenuState;
import funkin.ui.options.OptionsState;
import funkin.ui.freeplay.FreeplayState;
import funkin.ui.debug.DebugMenuSubState;
import funkin.graphics.FunkinSprite;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.FlxCamera;
import flixel.FlxG;
import StringTools;

class CustomMainMenu extends ScriptedMusicBeatState
{
  // this holds freeplay state (if there's a one to display over menu that is)
  var freeplay:FreeplayState;

  var checker:FlxBackdrop;
  var menuItems:ScriptedFlxSpriteGroup;
  var curSelected:Int = 0;
  var theBarThing:FunkinSprite;
  var theBarThing2:FunkinSprite;
  var funiPoster:FunkinSprite;
  var camHUD:FlxCamera;
  var optionShit:Array<String> = ['story', 'freeplay', 'merch', 'credits', 'options'];

  override function create()
  {
    super.create();
    camHUD = new FlxCamera();
    camHUD.bgColor = 0x00000000;

    leftWatermarkText.text = Constants.VERSION;
    leftWatermarkText.cameras = leftWatermarkText.cameras = [camHUD];

    // silly Easter egg
    rightWatermarkText.text = "Tomato Funkin v.0.1.0 (Demo 1)";
    rightWatermarkText.cameras = [camHUD];

    transIn = FlxTransitionableState.defaultTransIn;
    transOut = FlxTransitionableState.defaultTransOut;

    persistentUpdate = persistentDraw = true;

    FlxG.cameras.reset(new FunkinCamera('mainMenu'));
    FlxG.cameras.add(camHUD, false);

    camFollow = new FlxObject(0, 0, 1, 1);
    add(camFollow);
    FlxG.camera.follow(camFollow, null, 0.06);
    FlxG.camera.snapToTarget();

    checker = new FlxBackdrop(Paths.image('funiBg'), 0x11, 0, 0);
    checker.setGraphicSize(Std.int(checker.width * 0.74));
    checker.updateHitbox();
    checker.screenCenter(0x01);
    add(checker);

    funiPoster = new FunkinSprite(580, -120).loadTexture("menu-art-rand1");
    funiPoster.setGraphicSize(Std.int(funiPoster.width * 0.6));
    funiPoster.updateHitbox();
    funiPoster.scrollFactor.set();
    add(funiPoster);

    theBarThing = new FunkinSprite(-50, -64).loadTexture("some-sortacloth-thingsll");
    theBarThing.scrollFactor.set();
    add(theBarThing);

    theBarThing2 = new FunkinSprite(243, 542).loadTexture("some-sortacloth-thingsll");
    theBarThing2.flipY = theBarThing2.flipX = true; // double flip Wut?
    theBarThing2.scrollFactor.set();
    add(theBarThing2);

    if (freeplay == null || !freeplay.alive) FunkinSound.playMusic('freakyMenu', {overrideExisting: true, restartTrack: false});
    menuItems = new ScriptedFlxSpriteGroup();
    add(menuItems);

    for (i in 0...optionShit.length)
    {
      var offset:Float = 150 - (Math.max(optionShit.length, 4) - 4) * 80;
      var menuItem:FunkinSprite = new FunkinSprite(90, (i * 120) + offset);
      menuItem.frames = Paths.getSparrowAtlas('mainmenustate-buttons');
      switch (optionShit[i])
      {
        case 'story':
          menuItem.animation.addByPrefix('idle', 'capsule-story-noselect', 24);
          menuItem.animation.addByPrefix('selected', 'capsule-story0', 24);
        case 'credits':
          menuItem.animation.addByPrefix('idle', 'capsule-credits-noselect', 24);
          menuItem.animation.addByPrefix('selected', 'capsule-credits0', 24);
        case 'freeplay':
          menuItem.animation.addByPrefix('idle', 'capsule-freeplay-noselect', 24);
          menuItem.animation.addByPrefix('selected', 'capsule-freeplay0', 24);
        case 'merch':
          menuItem.animation.addByPrefix('idle', 'capsule-merch-noselect', 24);
          menuItem.animation.addByPrefix('selected', 'capsule-merch0', 24);
        case 'options':
          menuItem.animation.addByPrefix('idle', 'capsule-options-noselect', 24);
          menuItem.animation.addByPrefix('selected', 'capsule-options0', 24);
      }

      menuItem.animation.play('idle');
      menuItems.add(menuItem);
      menuItem.setGraphicSize(Std.int(menuItem.width * 0.9));

      var scr:Float = (optionShit.length - 4) * 0.135;
      if (optionShit.length < 6) scr = 0;
      menuItem.scrollFactor.set(0, scr);
      menuItem.updateHitbox();
      changeItem(0);
      if (freeplay != null && freeplay.alive)
      {
        // open freeplay over MainMenu
        trace("Is Sticker: " + (freeplay.stickerSubState != null));
        openSubState(new FreeplayState(
          {
            fromResults: freeplay.fromResultsParams
          }, freeplay.stickerSubState));
        freeplay = null;
      }
    }
  }

  override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    checker.x += 0.5 * (elapsed / (1 / 120));
    checker.y -= 0.16 / 144;

    if (FlxG.sound.music != null && FlxG.sound.music.volume < 0.8) FlxG.sound.music.volume += 0.5 * elapsed;

    doControl();
  }

  function doControl()
  {
    if (controls.UI_UP_P) changeItem(-1);

    if (controls.UI_DOWN_P) changeItem(1);

    if (controls.DEBUG_MENU)
    {
      persistentUpdate = false;

      openSubState(new DebugMenuSubState());
    }

    if (controls.BACK)
    {
      FunkinSound.playOnce(Paths.sound('cancelMenu'));
      FlxG.switchState(new TitleState());
    }

    if (controls.ACCEPT)
    {
      FunkinSound.playOnce(Paths.sound('confirmMenu'));
      switch (optionShit[curSelected])
      {
        case 'story':
          new FlxTimer().start(0.4, function(_) FlxG.switchState(new StoryMenuState()));

        case 'freeplay':
          persistentDraw = true;
          persistentUpdate = false;
          FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = true;
          new FlxTimer().start(0.4, function(_) openSubState(new FreeplayState()));
        case 'merch':
          WindowUtil.openURL(Constants.URL_MERCH);
          return; // maybe skip animating here???
        case 'options':
          new FlxTimer().start(0.4, function(_) FlxG.switchState(new OptionsState()));
        case 'credits':
          new FlxTimer().start(0.4, function(_) FlxG.switchState(ScriptedMusicBeatState.init("PsychCredits")));
      }

      for (i in 0...menuItems.members.length)
      {
        if (i == curSelected) continue;
        FlxTween.tween(menuItems.members[i], {alpha: 0}, 0.4,
          {
            ease: FlxEase.quadOut,
            onComplete: function(twn:FlxTween) {
              menuItems.members[i].kill();
            }
          });
      }
    }
  }

  function changeItem(huh:Int = 0)
  {
    if (huh != 0) FunkinSound.playOnce(Paths.sound('scrollMenu'));
    menuItems.members[curSelected].animation.play('idle');
    menuItems.members[curSelected].updateHitbox();

    curSelected += huh;

    if (curSelected >= menuItems.length) curSelected = 0;
    if (curSelected < 0) curSelected = menuItems.length - 1;

    menuItems.members[curSelected].animation.play('selected');
    menuItems.members[curSelected].centerOffsets();
  }

  override function onOpenSubStateComplete(targetState:FlxSubState)
  {
    new FlxTimer().start(0.45, restoreOptions);

    super.onOpenSubStateComplete(targetState);
  }

  function restoreOptions()
  {
    for (i in 0...menuItems.members.length)
    {
      if (i == curSelected) continue;
      menuItems.members[i].revive();
      menuItems.members[i].alpha = 1;
    }
  }
}
