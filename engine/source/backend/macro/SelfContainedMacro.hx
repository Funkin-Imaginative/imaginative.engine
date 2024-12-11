package backend.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import backend.objects.SelfContainedSprite;

class SelfContainedMacro {
	public static function findByName(fields:Array<Field>, name:String):Null<Field> {
		var result:Field = null;
        for (field in fields)
            if (field.name == name) {
                result = field;
				break;
			}
        return result;
    }

	macro public static function makeItWork():Array<Field> {
		trace('Ran macro!');

		var fields:Array<Field> = Context.getBuildFields();

		var updateFunc:Field = findByName(fields, 'update');
		if (updateFunc != null) {
			var backup:FieldType = updateFunc.kind;
			updateFunc.kind = FFun({
				args: backup.args,
				ret: macro:Void,
				expr: macro {
					var i:Int = 0;
					var basic:FlxBasic = null;
					while (i < length) {
						basic = members[i++];
						if (basic != null && basic.exists && basic.active)
							if (basic is SelfContainedSprite)
								cast(basic, SelfContainedSprite).sprite_update(elapsed);
							else
								basic.update(elapsed);
					}
				},
				params: backup.params
			});
		}
		var drawFunc:Field = findByName(fields, 'draw');
		if (drawFunc != null) {
			var backup:FieldType = drawFunc.kind;
			drawFunc.kind = FFun({
				args: backup.args,
				ret: macro:Void,
				expr: macro {
					var i:Int = 0;
					var basic:FlxBasic = null;
					var oldDefaultCameras = FlxCamera._defaultCameras;
					if (cameras != null)
						FlxCamera._defaultCameras = cameras;

					while (i < length) {
						basic = members[i++];

						if (basic != null && basic.exists && basic.visible)
							if (basic is SelfContainedSprite)
								cast(basic, SelfContainedSprite).sprite_draw();
							else
								basic.draw();
					}

					FlxCamera._defaultCameras = oldDefaultCameras;
				},
				params: backup.params
			});
		}

		return fields;
	}
}