package;

// flixel
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxState;
import flixel.FlxSubState;

// groups
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

// util
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.util.typeLimit.*;

// tweens
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

// math
import flixel.math.FlxMath;
import flixel.math.FlxPoint;

// sound
import flixel.sound.FlxSound;

// text
import flixel.text.FlxText;

import sys.FileSystem;

#if (DISCORD_RICH_PRESENCE && discord_rpc) import discord_rpc.DiscordRpc; #end
#if (ALLOW_VIDEOS && hxvlc) import hxvlc.flixel.*; #end

import haxe.io.Path as HaxePath;

// engine related

// backend
import backend.configs.*;
import backend.interfaces.*;
import backend.music.*;
import backend.scripting.events.ScriptEvent;
import backend.scripting.*;
import backend.structures.*;
import backend.*;
import backend.Paths.FunkinPath;

import objects.sprites.*;
import objects.sprites.BaseSprite.AnimType;
import objects.*;

// import states.*;

import utils.*;

using StringTools;