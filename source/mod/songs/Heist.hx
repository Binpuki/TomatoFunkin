package mod.songs;

import flixel.FlxSprite;
import flixel.FlxG;
import funkin.modding.events.ScriptEvent;
import flixel.util.FlxTimer;
import funkin.play.cutscene.VideoCutscene;
import funkin.modding.events.ScriptEvent.SongLoadScriptEvent;
import funkin.play.PlayState;
import funkin.modding.events.ScriptEvent.CountdownScriptEvent;
import funkin.play.song.Song;

class Heist extends Song
{
  var CUTSCENE_PATH = 'mods/Tomato Funkin DEMO/videos/heist-cutscene-compressed.mp4'; // Where is the video?
  var SONG_DELAY = 2100; // How long to wait before starting the song alongside the video? (in ms) 1000ms = 1s

  var hasSeenInitialCutScene:Bool = false;
  var hasStartedTheSong:Bool = false;

  public function new()
  {
    super('heist');
  }

  override function onSongLoaded(event:SongLoadScriptEvent)
  {
    hasSeenInitialCutScene = false;
    hasStartedTheSong = true;
    super.onSongLoaded(event);
  }

  override function onCountdownStart(event:CountdownScriptEvent)
  {
    event.cancel();
    if (hasSeenInitialCutScene) return;
    PlayState.instance.camCutscene.visible = true;
    PlayState.instance.mayPauseGame = false;

    VideoCutscene.onVideoStarted.addOnce(() -> {
      hasStartedTheSong = false;
    });

    VideoCutscene.onVideoEnded.addOnce(() -> {
      PlayState.instance.isInCutscene = false;
      PlayState.instance.mayPauseGame = true;
    });
    VideoCutscene.play(CUTSCENE_PATH);
    hasSeenInitialCutScene = true;
  }

  override function onUpdate(event:UpdateScriptEvent)
  {
    if (PlayState.instance != null && !PlayState.instance.mayPauseGame) PlayState.instance.justUnpaused = true;
    if (!hasStartedTheSong && VideoCutscene.vid.bitmap.position > (SONG_DELAY / VideoCutscene.vid.bitmap.duration))
    {
      trace('Tracking: ' + SONG_DELAY + '/' + VideoCutscene.vid.bitmap.duration);
      PlayState.instance.startSong();
      PlayState.instance.isInCountdown = true;
      hasStartedTheSong = true;
    }
    super.onUpdate(event);
  }

  override function onSongRetry(event:ScriptEvent)
  {
    FlxG.resetState(); // We rely a lot on timing, so this reset is necessary
  }
}
