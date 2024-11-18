package;

/* Haxe */
import haxe.io.Path as FilePath;
import sys.FileSystem;

using Lambda;
using StringTools;
using haxe.ds.ArraySort;

/* Flixel */
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.math.FlxVelocity;
import flixel.sound.FlxSound;
import flixel.sound.FlxSoundGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.util.FlxSave;
import flixel.util.FlxSignal;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import flixel.util.typeLimit.OneOfFour;
import flixel.util.typeLimit.OneOfThree;
import flixel.util.typeLimit.OneOfTwo;

using flixel.util.FlxArrayUtil;
using flixel.util.FlxBitmapDataUtil;
using flixel.util.FlxColorTransformUtil;
using flixel.util.FlxDestroyUtil;
using flixel.util.FlxSpriteUtil;
using flixel.util.FlxStringUtil;

/* Engine */
import backend.Controls;
import backend.configs.PlayConfig;
import backend.interfaces.ITexture;
import backend.music.Conductor;
import backend.music.group.BeatGroup;
import backend.music.group.BeatSpriteGroup;
import backend.music.interfaces.IBeat;
import backend.music.states.BeatState;
import backend.music.states.BeatSubState;
import backend.objects.Position;
import backend.objects.TypeXY;
import backend.scripting.Script;
import backend.scripting.events.ScriptEvent;
import backend.scripting.group.ScriptGroup;
import backend.scripting.interfaces.IScript;
import backend.scripting.types.GlobalScript;
import backend.system.Main;
#if MOD_SUPPORT
import backend.system.Modding;
#end
import backend.system.Paths;
import backend.system.Settings;
import objects.BaseSprite;
import objects.BeatSprite;
import objects.Character;
import objects.gameplay.ArrowField;
import objects.gameplay.Note;
import objects.gameplay.Strum;
import objects.holders.DifficultyHolder;
import objects.holders.LevelHolder;
import objects.ui.HealthIcon;
import objects.ui.SpriteText;
import objects.window.FlxWindow;
import objects.window.WindowBounds;
import states.PlayState;
import utils.ParseUtil;
import utils.PlatformUtil;

using utils.FunkinUtil;
using utils.SpriteUtil;

/* Libs */
#if ALLOW_VIDEOS
import hxvlc.flixel.FlxVideo;
import hxvlc.flixel.FlxVideoSprite;
#end