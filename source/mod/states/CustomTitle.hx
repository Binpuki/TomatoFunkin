package mod.states;

import funkin.Paths;
import funkin.Conductor;
import funkin.ui.MusicBeatState;
import funkin.graphics.FunkinSprite;
import funkin.graphics.shaders.ColorSwap;
import funkin.graphics.adobeanimate.FlxAtlasSprite;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import funkin.ui.title.AttractState;
import funkin.audio.FunkinSound;
import funkin.ui.mainmenu.MainMenuState;
import flixel.util.FlxTimer;
import StringTools;

class CustomTitle extends MusicBeatState
{
  public function new()
  {
    super();
  }

  var initialized:Bool = false;
  var swagShader:ColorSwap;

  override function create()
  {
    super.create();
    swagShader = new ColorSwap();

    startIntro();
  }

  var logoBl:FunkinSprite;
  var dokiBitch:FlxAtlasSprite;

  function startIntro():Void
  {
    playMenuMusic();

    var bg:FunkinSprite = new FunkinSprite(0, 0).loadTexture("doki-bg");
    bg.screenCenter();
    add(bg);

    logoBl = FunkinSprite.createSparrow(21, 18, "dokiLogoBumpin");
    logoBl.animation.addByPrefix('bump', 'doki-logoBumpin-2', 24);
    logoBl.animation.play('bump');
    logoBl.setGraphicSize(Std.int(logoBl.width * 1));
    logoBl.updateHitbox();
    add(logoBl);

    dokiBitch = new FlxAtlasSprite(0, 0, Paths.animateAtlas('doki-freakymenu'));
    dokiBitch.scale.set(1, 1);
    dokiBitch.updateHitbox();
    dokiBitch.anim.play('doki-freakymenu', true);
    add(dokiBitch);

    var button:FunkinSprite = new FunkinSprite(105, 612).loadTexture("enterbutton");
    add(button);

    dokiBitch.shader = button.shader = logoBl.shader = bg.shader = swagShader.shader; // funi Shader
    skipIntro();

    if (FlxG.sound.music != null) FlxG.sound.music.onComplete = moveToAttract;
  }

  function moveToAttract():Void
  {
    FlxG.switchState(() -> new AttractState());
  }

  function playMenuMusic():Void
  {
    var shouldFadeIn:Bool = (FlxG.sound.music == null);
    // Load music. Includes logic to handle BPM changes.
    FunkinSound.playMusic('freakyMenu',
      {
        startingVolume: 0.0,
        overrideExisting: true,
        restartTrack: false
      });
    // Fade from 0.0 to 1 over 4 seconds
    if (shouldFadeIn) FlxG.sound.music.fadeIn(4.0, 0.0, 1.0);
  }

  var transitioning:Bool = false;

  override function update(elapsed:Float):Void
  {
    FlxG.bitmapLog.add(FlxG.camera.buffer);

    if (FlxG.keys.pressed.UP) FlxG.sound.music.pitch += 0.5 * elapsed;
    if (FlxG.keys.pressed.DOWN) FlxG.sound.music.pitch -= 0.5 * elapsed;

    Conductor.instance.update();

    if (FlxG.keys.justPressed.Y)
    {
      FlxTween.cancelTweensOf(FlxG.stage.window, ['x', 'y']);
      FlxTween.tween(FlxG.stage.window, {x: FlxG.stage.window.x + 300}, 1.4, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.35});
      FlxTween.tween(FlxG.stage.window, {y: FlxG.stage.window.y + 100}, 0.7, {ease: FlxEase.quadInOut, type: PINGPONG});
    }

    if (FlxG.sound.music != null) Conductor.instance.update(FlxG.sound.music.time);

    // do controls.PAUSE | controls.ACCEPT instead?
    var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

    if (pressedEnter && transitioning && skippedIntro)
    {
      FlxG.switchState(() -> new MainMenuState());
    }

    if (pressedEnter && !transitioning && skippedIntro)
    {
      if (FlxG.sound.music != null) FlxG.sound.music.onComplete = null;

      FlxG.camera.flash(0xFFFFFFFF, 1);
      FunkinSound.playOnce(Paths.sound('confirmMenu'), 0.7);
      transitioning = true;
      new FlxTimer().start(2, function(tmr:FlxTimer) {
        FlxG.switchState(new MainMenuState());
      });
    }

    if (pressedEnter && !skippedIntro && initialized) skipIntro();

    if (controls.UI_LEFT) swagShader.update(-elapsed * 0.1);
    if (controls.UI_RIGHT) swagShader.update(elapsed * 0.1);
    super.update(elapsed);
  }

  var isRainbow:Bool = false;
  var skippedIntro:Bool = false;

  override function beatHit():Bool
  {
    super.beatHit();

    if (skippedIntro)
    {
      if (logoBl != null && logoBl.animation != null) logoBl.animation.play('bump', true);
      if (dokiBitch != null && dokiBitch.anim != null) dokiBitch.anim.play('doki-freakymenu', true);
    }
  }

  function skipIntro():Void
  {
    if (!skippedIntro)
    {
      FlxG.camera.flash(0xFFFFFFFF, initialized ? 0 : 1);
      skippedIntro = true;
    }
  }
}
