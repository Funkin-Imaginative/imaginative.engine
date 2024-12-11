package imaginative.backend.macro;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end
import imaginative.backend.objects.SelfContainedSprite;

#if DISABLE_DCE @:keep #end class SelfContainedMacro {
	public static function findByName(fields:Array<Field>, name:String):Null<Field> {
		#if macro
		var result:Field = null;
		for (field in fields)
			if (field.name == name) {
				result = field;
				break;
			}
		return result;
		#end
	}

	macro public static function makeItWork():Array<Field> {
		#if macro
		log('Running macro.');

		var fields:Array<Field> = Context.getBuildFields();

		for (field in fields) {
			if (findByName([field], 'update') != null) {
				var backup:FieldType = field.kind;
				trace(backup);
				field.kind = FFun({
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

			if (findByName([field], 'draw') != null) {
				var backup:FieldType = field.kind;
				field.kind = FFun({
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
		}

		log('Macro ran.');

		return fields;
		#end
	}
}