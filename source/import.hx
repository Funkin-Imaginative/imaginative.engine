package;

/* Flixel */
import haxe.io.Path as HaxePath;
import sys.FileSystem;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.math.FlxRect;
import flixel.math.FlxVector;
import flixel.math.FlxVelocity;
import flixel.sound.FlxSound;
import flixel.sound.FlxSoundGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxDirection;
import flixel.util.FlxGradient;
import flixel.util.FlxPool;
import flixel.util.FlxSave;
import flixel.util.FlxSignal;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import flixel.util.typeLimit.OneOfFour;
import flixel.util.typeLimit.OneOfThree;
import flixel.util.typeLimit.OneOfTwo;

using Lambda;
using StringTools;
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
import backend.music.BeatState;
import backend.music.BeatSubState;
import backend.music.Conductor;
import backend.scripting.ModState;
import backend.scripting.ModSubState;
import backend.scripting.Script;
import backend.scripting.ScriptGroup;
import backend.scripting.events.ScriptEvent;
import backend.structures.PositionStruct;
import backend.system.Main;
import objects.DifficultyObject;
import objects.LevelObject;
import objects.sprites.BaseSprite.AnimType;
import objects.sprites.BaseSprite;
import objects.sprites.BeatSprite;
import objects.sprites.Character;
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