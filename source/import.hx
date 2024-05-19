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

// alphabetical order
import fnf.backend.musicbeat.*;
import fnf.backend.scripting.*; import fnf.backend.scripting.events.*;
import fnf.backend.BareCameraPoint; // backend
import fnf.backend.CameraPoint;
import fnf.backend.Conductor;
import fnf.backend.Controls;
import fnf.backend.Highscore;
import fnf.backend.PlayerSettings;
import fnf.backend.SaveManager;
import fnf.backend.Section; import fnf.backend.Section.SwagSection;
import fnf.backend.Song; import fnf.backend.Song.SwagSong;
import fnf.objects.PlayField;
import fnf.states.LoadingState; // states
import fnf.states.PlayState;
import fnf.utils.*;

#if discord_rpc import discord_rpc.DiscordRpc; #end
#if hxvlc import hxvlc.flixel.*; #end

using StringTools;