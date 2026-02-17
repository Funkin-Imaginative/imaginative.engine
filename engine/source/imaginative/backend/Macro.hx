package imaginative.backend;

#if macro
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.ExprTools;

class Macro {
	@SuppressWarnings('checkstyle:FieldDocComment')
	public static function init():Void {
		// MAYBE: Re-add offset variable to FlxAnimation?????
		Compiler.addMetadata('@:build(imaginative.backend.Macro.buildFlxBasic())', 'flixel.FlxBasic');
		Compiler.addMetadata('@:build(imaginative.backend.Macro.buildFlxObject())', 'flixel.FlxObject');
		Compiler.addMetadata('@:build(imaginative.backend.Macro.buildFlxSprite())', 'flixel.FlxSprite');
		Compiler.addMetadata('@:build(imaginative.backend.Macro.buildFlxSpriteGroup())', 'flixel.group.FlxTypedSpriteGroup');
		Compiler.addMetadata('@:build(imaginative.backend.Macro.overrideDebugString())', 'flixel.util.FlxStringUtil');
		#if SCRIPT_SUPPORT
		Compiler.include('imaginative', true, ['*Macro']);
		Compiler.include('haxe', true, ['haxe.atomic.*', 'haxe.macro.*']);
		Compiler.include('flixel', true, ['flixel.addons.editors.spine.*', 'flixel.addons.nape.*', 'flixel.system.macros.*', 'flixel.addons.tile.FlxRayCastTilemap', 'flixel.addons.weapon.*']);
		#end
		Compiler.include('moonchart', true, ['moonchart.backend.*']); // force include, no matter what
		#if (FLX_DEBUG && CAN_HAXE_SCRIPT)
		Compiler.addMetadata('@:build(imaginative.backend.Macro.overrideConsoleUtil())', 'flixel.system.debug.console.ConsoleUtil');
		#end
	}

	/**
	 * Implements extra variables into 'FlxBasic'.
	 * @return Array<Field>
	 */
	public static macro function buildFlxBasic():Array<Field> {
		var classFields = Context.getBuildFields();
		var tempClass = macro class TempClass {
			/**
			 * Extra data the object can hold.
			 */
			public final extra:Map<String, Dynamic> = new Map<String, Dynamic>();
			/**
			 * When true the object has been destroyed, this cannot be reversed.
			 */
			public var destroyed(default, null):Bool = false;
		}

		var destroyFunc = classFields.filter(field -> return field.name == 'destroy')[0];
		switch (destroyFunc.kind) {
			case FFun(f):
				var initExpr:Expr = f.expr;
				f.expr = macro {
					$initExpr;
					destroyed = true;
				}
				destroyFunc.kind = FFun(f);
			default:
		}
		var toStringFunc = classFields.filter(field -> return field.name == 'toString')[0];
		switch (toStringFunc.kind) {
			case FFun(f):
				f.expr = macro {
					return FlxStringUtil.getDebugString([
						LabelValuePair.weak('active', active),
						LabelValuePair.weak('visible', visible),
						LabelValuePair.weak('alive', alive),
						LabelValuePair.weak('exists', exists),
						LabelValuePair.weak('destroyed', destroyed)
					]);
				}
				toStringFunc.kind = FFun(f);
			default:
		}

		return classFields.concat(tempClass.fields);
	}
	/**
	 * Implements forceIsOnScreen from Codename Engine and makes screenCenter compatible with other cameras.
	 * @return Array<Field>
	 */
	public static macro function buildFlxObject():Array<Field> {
		var classFields = Context.getBuildFields();
		var tempClass = macro class TempClass {
			/**
			 * If true, the object will always be considered to be on screen.
			 */
			public var forceIsOnScreen:Bool = false;

			/**
			 * Centers this `FlxObject` on the screen, either by the x axis, y axis, or both.
			 *
			 * @param   axes   On what axes to center the object (e.g. `X`, `Y`, `XY`) - default is both.
			 * @param  camera  The camera to use for centering. If `null`, the default camera is used.
			 * @return  This FlxObject for chaining
			 */
			public function screenCenter(axes:FlxAxes = XY, ?camera:FlxCamera):FlxObject {
				camera ??= getDefaultCamera();
				if (axes.x) x = (camera.width - width) / 2 - (camera.scroll.x * -scrollFactor.x);
				if (axes.y) y = (camera.height - height) / 2 - (camera.scroll.y * -scrollFactor.y);
				return this;
			}
		}

		var onScreenFunc = classFields.filter(field -> return field.name == 'isOnScreen')[0];
		switch (onScreenFunc.kind) {
			case FFun(f):
				var initExpr:Expr = f.expr;
				f.expr = macro {
					if (forceIsOnScreen)
						return true;
					$initExpr;
				}
				onScreenFunc.kind = FFun(f);
			default:
		}

		var newScreenCenterFunc = tempClass.fields.filter(field -> return field.name == 'screenCenter')[0];
		tempClass.fields.remove(newScreenCenterFunc);
		var screenCenterFunc = classFields.filter(field -> return field.name == 'screenCenter')[0];
		screenCenterFunc.name = newScreenCenterFunc.name;
		screenCenterFunc.doc = newScreenCenterFunc.doc;
		screenCenterFunc.access = newScreenCenterFunc.access;
		screenCenterFunc.kind = newScreenCenterFunc.kind;
		screenCenterFunc.meta = newScreenCenterFunc.meta;

		return classFields.concat(tempClass.fields);
	}
	/**
	 * Implements forceIsOnScreen from Codename Engine.
	 * @return Array<Field>
	 */
	public static macro function buildFlxSprite():Array<Field> {
		var classFields = Context.getBuildFields();

		// I hate that I hate to do this twice.
		var onScreenFunc = classFields.filter(field -> return field.name == 'isOnScreen')[0];
		switch (onScreenFunc.kind) {
			case FFun(f):
				var initExpr:Expr = f.expr;
				f.expr = macro {
					if (forceIsOnScreen)
						return true;
					$initExpr;
				}
				onScreenFunc.kind = FFun(f);
			default:
		}

		return classFields;
	}

	/**
	 * Implements keyValueIterator because it doesn't have one for some reason???
	 * @return Array<Field>
	 */
	public static macro function buildFlxSpriteGroup():Array<Field> {
		var classFields = Context.getBuildFields();
		var tempClass = macro class TempClass {
			/**
			 * Iterates through every member and index.
			 */
			public inline function keyValueIterator() {
				return members.keyValueIterator();
			}
		}
		return classFields.concat(tempClass.fields);
	}

	/**
	 * Overrides the way 'FlxStringUtil.getDebugString()' works.
	 * @return Array<Field>
	 */
	public static macro function overrideDebugString():Array<Field> {
		var classFields = Context.getBuildFields();
		var debugStringFunc = classFields.filter(field -> return field.name == 'getDebugString')[0];
		switch (debugStringFunc.kind) {
			case FFun(f):
				f.expr = macro {
					var output:String = '{';
					for (pair in LabelValuePairs) {
						output += pair.label + ': ' + @:privateAccess imaginative.backend.Console.formatValueInfo(pair.value, true, true) + ', ';
						pair.put();
					}
					output = output.substr(0, output.length - 2).trim();
					return output + '}';
				}
				debugStringFunc.kind = FFun(f);
			default:
		}
		return classFields;
	}

	#if (FLX_DEBUG && CAN_HAXE_SCRIPT)
	/**
	 * Makes ConsoleUtil run RuleScript instead of base hscript.
	 * Why did I implement this? Idk, I thought it would be a good idea.
	 * @return Array<Field>
	 */
	public static macro function overrideConsoleUtil():Array<Field> {
		var classFields = Context.getBuildFields();
		var tempClass = macro class TempClass {
			/**
			 * The hscript parser to make strings into haxe code.
			 */
			static var parser:rulescript.parsers.HxParser;

			/**
			 * The custom hscript interpreter to run the haxe code from the parser.
			 */
			public static var interp:rulescript.interps.RuleScriptInterp;

			/**
			 * Sets up the hscript parser and interpreter.
			 */
			public static function init():Void {
				parser = new rulescript.parsers.HxParser();
				parser.setParameters({
					allowJSON: true,
					allowMetadata: true,
					allowTypes: true,
					allowPackage: false,
					allowImport: false,
					allowUsing: false,
					allowStringInterpolation: true,
					allowPublicVariables: false,
					allowStaticVariables: false,
					allowTypePath: true
				});
				interp = new rulescript.interps.RuleScriptInterp();
			}
		}
		for (name in ['parser', 'interp', 'init']) {
			var field = classFields.filter(field -> return field.name == name)[0];
			field.remove(oldParser);
		}
		return classFields.concat(tempClass.fields);
	}
	#end
}
#end