package;

// funny longest to shortest :> @RodneyAnImaginativePerson
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.sound.FlxSound;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.util.FlxSort;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.FlxBasic;
import flixel.FlxState;
import flixel.FlxG;

import fnf.backend.BareCameraPoint;
import fnf.backend.CameraPoint;
import fnf.backend.scripting.*;

import fnf.states.sub.MusicBeatSubstate;
import fnf.backend.Section.SwagSection;
import fnf.backend.PlayerSettings;
import fnf.backend.Song.SwagSong;
import fnf.states.MusicBeatState;
import fnf.backend.SaveManager;
import fnf.states.LoadingState;
import fnf.backend.Conductor;
import fnf.backend.Highscore;
import fnf.backend.Controls;
import fnf.states.PlayState;
import fnf.backend.Section;
import fnf.utils.CoolUtil;
import fnf.backend.Song;
import fnf.utils.Paths;

#if hxvlc
import hxvlc.flixel.*;
#end

#if discord_rpc
import discord_rpc.DiscordRpc;
#end

using StringTools;