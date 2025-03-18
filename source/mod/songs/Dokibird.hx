package mod.songs;

import funkin.graphics.adobeanimate.FlxAtlasSprite;
import flixel.util.FlxTimer;
import funkin.modding.events.ScriptEvent;
import funkin.modding.events.ScriptEvent.UpdateScriptEvent;
import funkin.graphics.FunkinSprite;
import funkin.audio.FunkinSound;
import funkin.play.song.Song;
import funkin.play.PlayState;
import funkin.Paths;
import funkin.play.cutscene.VideoCutscene;
import funkin.play.PlayStatePlaylist;

class Dokibird extends Song
{
  var hasPlayedCutscene:Bool;
  var game:PlayState;
  var smoke:FlxAtlasSprite;
  var dokiMic:FunkinSprite;

  public function new()
  {
    super('dokibird');

    hasPlayedCutscene = false;
  }

  override function onSongStart(event:ScriptEvent)
  {
    super.onSongStart(event);
    game = PlayState.instance;

    dokiMic = FunkinSprite.createSparrow(-195, 94, "doki-mic-drop");
    dokiMic.animation.addByPrefix("anim", "maple-micdrop", 30, true);
    dokiMic.camera = game.camGame;
    dokiMic.zIndex = 350;
    dokiMic.alpha = 0.001;
    game.currentStage.add(dokiMic);
    game.currentStage.refresh();

    smoke = new FlxAtlasSprite(0, 0, Paths.animateAtlas("smoke"));
    smoke.camera = game.camHUD;
    smoke.alpha = 0.001;
    game.add(smoke);
    // smoke.playAnimation("Symbol 2");
  }

  public override function onSongEnd(event:ScriptEvent):Void
  {
    super.onSongEnd(event);

    if (!PlayStatePlaylist.isStoryMode) hasPlayedCutscene = true;

    if (!hasPlayedCutscene)
    {
      trace('Pausing countdown to play a video cutscene (`dokibird`)');

      hasPlayedCutscene = true;

      FunkinSound.playOnce(Paths.sound("dokibird-endscene-sfx"), 1, () -> {
        game.endSong(true);
      });

      FlxTimer.wait(0.6, () -> {
        dokiMic.alpha = 1;
        dokiMic.animation.play("anim");
        game.currentStage.getDad().alpha = 0;
      });
      FlxTimer.wait(1.9, () -> {
        smoke.alpha = 1;
        smoke.playAnimation("");
      });

      event.cancel();
    }
  }

  override function onUpdate(event:UpdateScriptEvent)
  {
    super.onUpdate(event);
  }

  override function onCreate(event:ScriptEvent):Void
  {
    super.onCreate(event);
    hasPlayedCutscene = false;
  }
}
