package;

/* Haxe */
import haxe.io.Path as FilePath;
import sys.FileSystem;

using Lambda;
using StringTools;

/* Flixel */
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
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
using flixel.util.FlxColorTransformUtil;
using flixel.util.FlxDestroyUtil;
using flixel.util.FlxSpriteUtil;
using flixel.util.FlxStringUtil;

/* Engine */
import backend.Controls;
import backend.Paths;
import backend.configs.ModConfig;
import backend.configs.PlayConfig;
import backend.interfaces.IBeat;
import backend.interfaces.IScript;
import backend.music.BeatState;
import backend.music.BeatSubState;
import backend.music.Conductor;
import backend.scripting.Script;
import backend.scripting.ScriptGroup;
import backend.scripting.events.ScriptEvent;
import backend.scripting.types.GlobalScript;
import backend.scripting.types.InvaildScript;
import backend.structures.PositionStruct;
import backend.system.FlxWindow;
import backend.system.Main;
import objects.DifficultyObject;
import objects.LevelObject;
import objects.sprites.BaseSprite;
import objects.sprites.BeatSprite;
import objects.sprites.Character;
import states.PlayState;
import utils.FunkinUtil;
import utils.ParseUtil;
import utils.PlatformUtil;

using utils.FlxColorUtil;
using utils.SpriteUtil;

/* Libs */
#if ALLOW_VIDEOS
import hxvlc.flixel.FlxVideo;
import hxvlc.flixel.FlxVideoSprite;
#end