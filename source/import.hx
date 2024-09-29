package;

/* Flixel */
import haxe.io.Path as HaxePath;

import sys.FileSystem;

import flixel.*;

import flixel.group.*;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

import flixel.math.*;

import flixel.sound.*;

import flixel.text.*;

import flixel.tweens.*;
import flixel.tweens.FlxTween.FlxTweenManager;

import flixel.util.*;
import flixel.util.typeLimit.*;

/* Engine */
import backend.*;
import backend.Paths.FunkinPath;
import backend.configs.*;
import backend.interfaces.*;
import backend.music.*;

import backend.scripting.*;
import backend.scripting.events.ScriptEvent;

import backend.structures.*;
import backend.system.*;

import objects.*;

import objects.sprites.*;
import objects.sprites.BaseSprite.AnimType;

import utils.*;

/* Libs */
#if ALLOW_VIDEOS import hxvlc.flixel.*; #end

/* Using */
using Lambda;
using StringTools;