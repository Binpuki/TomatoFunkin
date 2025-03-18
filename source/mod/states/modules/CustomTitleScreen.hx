package mod.states.modules;

import funkin.modding.events.ScriptEvent.StateChangeScriptEvent;
import flixel.addons.transition.FlxTransitionableState;
import funkin.modding.module.Module;
import funkin.modding.base.ScriptedMusicBeatState;
import funkin.ui.title.TitleState;
import flixel.FlxG;
import funkin.graphics.FunkinSprite;
import funkin.graphics.adobeanimate.FlxAtlasSprite;
import funkin.Paths;
import funkin.Conductor;

class CustomTitleScreen extends Module
{
  public function new()
  {
    super('CustomTitleScreen');
  }

  public function onStateChangeEnd(event:StateChangeScriptEvent)
  {
    if (Std.isOfType(event.targetState, TitleState))
    {
      if (event.targetState.skippedIntro)
      {
        FlxTransitionableState.skipNextTransIn = true;
        FlxG.switchState(() -> ScriptedMusicBeatState.init('CustomTitle'));
      } // I gave up so I use this shitty way
    }
  }

  function onUpdate()
  {
    var state = FlxG.state;
    if (Std.isOfType(state, TitleState))
    {
      if (state.skippedIntro)
      {
        FlxTransitionableState.skipNextTransIn = true;
        FlxG.switchState(() -> ScriptedMusicBeatState.init('CustomTitle'));
      }
    }
  }
}
