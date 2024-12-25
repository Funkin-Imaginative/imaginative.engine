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
import flixel.window.FlxWindow;
import flixel.window.WindowBounds;

using flixel.util.FlxArrayUtil;
using flixel.util.FlxBitmapDataUtil;
using flixel.util.FlxColorTransformUtil;
using flixel.util.FlxDestroyUtil;
using flixel.util.FlxSpriteUtil;
using flixel.util.FlxStringUtil;

/* Engine */
import imaginative.backend.Console._log;
import imaginative.backend.Console.log;
import imaginative.backend.Console;
import imaginative.backend.Controls;
#if DISCORD_RICH_PRESENCE
import imaginative.backend.RichPresence;
#end
import imaginative.backend.gameplay.Judging;
import imaginative.backend.gameplay.Scoring;
import imaginative.backend.interfaces.ITexture;
import imaginative.backend.music.Conductor;
import imaginative.backend.music.group.BeatGroup;
import imaginative.backend.music.group.BeatSpriteGroup;
import imaginative.backend.music.interfaces.IBeat;
import imaginative.backend.music.states.BeatState;
import imaginative.backend.music.states.BeatSubState;
import imaginative.backend.objects.Position;
import imaginative.backend.objects.TypeXY;
import imaginative.backend.scripting.Script;
import imaginative.backend.scripting.events.ScriptEvent;
import imaginative.backend.scripting.group.ScriptGroup;
import imaginative.backend.scripting.interfaces.IScript;
import imaginative.backend.scripting.types.GlobalScript;
import imaginative.backend.system.Main;
#if MOD_SUPPORT
import imaginative.backend.system.Modding;
#end
import imaginative.backend.system.Paths;
import imaginative.backend.system.Settings;
import imaginative.objects.BaseSprite;
import imaginative.objects.BeatSprite;
import imaginative.objects.Character;
import imaginative.objects.gameplay.arrows.ArrowField;
import imaginative.objects.gameplay.arrows.Note;
import imaginative.objects.gameplay.arrows.Strum;
import imaginative.objects.gameplay.arrows.Sustain;
import imaginative.objects.holders.DifficultyHolder;
import imaginative.objects.holders.LevelHolder;
import imaginative.objects.ui.HealthIcon;
import imaginative.objects.ui.SpriteText;
import imaginative.states.PlayState;
import imaginative.utils.ParseUtil;
import imaginative.utils.PlatformUtil;

using imaginative.utils.FunkinUtil;
using imaginative.utils.SpriteUtil;

/* Libs */
#if ALLOW_VIDEOS
import hxvlc.flixel.FlxVideo;
import hxvlc.flixel.FlxVideoSprite;
#end