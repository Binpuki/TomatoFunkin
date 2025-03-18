package mod.states.modules;

import flixel.FlxSprite;
import funkin.audio.FunkinSound;
import flixel.util.FlxTimer;
import funkin.play.PauseSubState;
import funkin.play.PlayStatePlaylist;
import flixel.addons.transition.FlxTransitionableState;
import funkin.play.PlayState;
import funkin.modding.events.ScriptEvent;
import funkin.ui.freeplay.FreeplayState;
import funkin.modding.module.Module;
import funkin.modding.base.ScriptedMusicBeatState;
import funkin.ui.mainmenu.MainMenuState;
import flixel.FlxG;

class CustomMainMenuScreen extends Module
{
  var freePlay:FreeplayState = null;
  var state:Int = 0;

  // 0 - Outside
  // 1 - In Freeplay
  // 2 - Closing
  // 3 - Rank Anim

  function new()
  {
    super("custom-menu-mod");
  }

  override function onCreate(event:ScriptEvent)
  {
    PauseSubState.PAUSE_MENU_ENTRIES_STANDARD[4].callback = onPlayStateExit;
    super.onCreate(event);
  }

  function onPlayStateExit(state:PauseSubState):Void // The action when exiting from a song
  {
    state.allowInput = false;

    PlayState.instance.deathCounter = 0;

    FlxTransitionableState.skipNextTransIn = true;
    FlxTransitionableState.skipNextTransOut = true;

    if (PlayStatePlaylist.isStoryMode)
    {
      PlayStatePlaylist.reset();
      state.openSubState(new funkin.ui.transition.StickerSubState(null, (sticker) -> new funkin.ui.story.StoryMenuState(sticker)));
    }
    else
    {
      state.openSubState(new funkin.ui.transition.StickerSubState(null, (sticker) -> {
        //      if (FlxG.save.data.useNewMenu)
        //     {
        var st = ScriptedMusicBeatState.init("CustomMainMenu");
        st.scriptSet("freeplay", new FreeplayState(null, sticker));
        st.persistentUpdate = false;
        st.persistentDraw = true;
        return st;
        // }
        // else
        //   return FreeplayState.build(null, sticker);
      }));
    }
  }

  override function onStateChangeEnd(event:StateChangeScriptEvent)
  {
    if (Std.isOfType(event.targetState, MainMenuState))
    {
      FlxG.switchState(() -> {
        trace("FREEPLAY: ");
        trace(freePlay);
        var st = ScriptedMusicBeatState.init("CustomMainMenu");
        st.scriptSet("freeplay", freePlay);
        if (freePlay != null && freePlay.prepForNewRank) state = 3;
        return st; // 3
      });
    }
    super.onStateChangeEnd(event);
  }

  override function onSubStateOpenEnd(event:SubStateScriptEvent)
  {
    if (Std.isOfType(event.targetState, FreeplayState)) freePlay = event.targetState;
    super.onSubStateOpenEnd(event);
  }

  //* This replaces freeplay's closing routine
  override function onUpdate(event:UpdateScriptEvent)
  {
    super.onUpdate(event);
    if (freePlay == null || !freePlay.active) return;

    if (freePlay.subState != null)
    {
      freePlay.backingCard.cardGlow.visible = false;
      return;
    }
    var observer_value = freePlay.backingCard.cardGlow.visible; // freePlay.backingCard.funnyScroll.visible

    if (state == 1 && observer_value)
    {
      // `prevOpange` got shown AND hidden
      trace("We are closing freeplay now");
      FlxTimer.globalManager.clear();
      FlxG.state.persistentDraw = true;

      state = 2;
      freePlay.backingCard.cardGlow.visible = false;
      trace("Closing");
      new FlxTimer().start(0.4, (_) -> {
        FlxTransitionableState.skipNextTransIn = true;
        FlxTransitionableState.skipNextTransOut = true;
        FunkinSound.playMusic('freakyMenu',
          {
            overrideExisting: true,
            restartTrack: true,
            persist: true
          });
        // FlxG.sound.music.fadeIn(4.0, 0.0, 1.0);
        freePlay.close();
        freePlay.alive = false;
        state = 0;
      });
    }
    else if (state != 1 && observer_value)
    {
      // We are done initing
      trace("Done initting");
      state = 1;
      freePlay.backingCard.cardGlow.visible = false;
    }
  }
}
