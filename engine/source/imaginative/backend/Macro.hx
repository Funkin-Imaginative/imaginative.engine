package imaginative.backend;

#if macro
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.ExprTools;

class Macro {
	@SuppressWarnings('checkstyle:FieldDocComment')
	public static function init():Void {
		Compiler.addMetadata('@:build(imaginative.backend.Macro.buildFlxBasic())', 'flixel.FlxBasic');
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
			public var extra:Map<String, Dynamic> = new Map<String, Dynamic>();
		}
		return classFields.concat(tempClass.fields);
	}
}
#end