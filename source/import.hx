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

// tweens
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

// math
import flixel.math.FlxMath;
import flixel.math.FlxPoint;

//sound
import flixel.sound.FlxSound;

// text
import flixel.text.FlxText;

import sys.FileSystem;

#if discord_rpc import discord_rpc.DiscordRpc; #end
#if hxvlc import hxvlc.flixel.*; #end

// engine related

// backend
import backend.conducting.*;
import backend.configs.*;
import backend.interfaces.*;
import backend.metas.*;
import backend.scripting.*;
import backend.scripting.events.*;
import backend.*;
import backend.Paths.FunkinPath;

import objects.*;

// import states.*;

import utils.*;

using StringTools;