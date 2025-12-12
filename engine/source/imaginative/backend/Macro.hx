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
		Compiler.addMetadata('@:build(imaginative.backend.Macro.buildFlxSpriteGroup())', 'flixel.group.FlxTypedSpriteGroup');
		Compiler.addMetadata('@:build(imaginative.backend.Macro.overrideDebugString())', 'flixel.util.FlxStringUtil');
		#if SCRIPT_SUPPORT
		Compiler.include('imaginative', true);
		Compiler.include('haxe', true, ['haxe.atomic.*', 'haxe.macro.*']);
		Compiler.include('flixel', true, ['flixel.addons.editors.spine.*', 'flixel.addons.nape.*', 'flixel.system.macros.*', 'flixel.addons.tile.FlxRayCastTilemap', 'flixel.addons.weapon.*']);
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

		return classFields.concat(tempClass.fields);
	}
	/**
	 * Implements forceIsOnScreen from Codename Engine.
	 * @return Array<Field>
	 */
	public static macro function buildFlxObject():Array<Field> {
		var classFields = Context.getBuildFields();
		var tempClass = macro class TempClass {
			/**
			 * If true, the object will always be considered to be on screen.
			 */
			public var forceIsOnScreen:Bool = false;
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

		return classFields.concat(tempClass.fields);
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
}
#end