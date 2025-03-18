package mod.util;

import funkin.play.PlayState;
import funkin.play.event.SongEvent;
import funkin.modding.events.ScriptEvent;
import funkin.play.cutscene.VideoCutscene;
import hxcodec.flixel.FlxVideoSprite;
import funkin.modding.module.ModuleHandler;
import flixel.FlxG;

class PlayVideoEvent extends SongEvent
{
  function new()
  {
    super('PlayVideo');
  }

  override function handleEvent(data)
  {
    if (PlayState.instance == null || PlayState.instance.currentStage == null) return;
    if (PlayState.instance.isMinimalMode) return;
    ModuleHandler.getModule("VideoModule").scriptCall("createVid", [data.value.path, data.value.isCutscene]);
  }

  function getEventSchema()
  {
    return [
      {
        name: "path",
        title: "Path to Video",
        defaultValue: "Path goes here!",
        type: "string"
      },
      {
        name: "isCutscene",
        title: "Hide HUD",
        type: "bool",
        defaultValue: false
      }
    ];
  }

  function getTitle()
  {
    return "Play Video";
  }
}
