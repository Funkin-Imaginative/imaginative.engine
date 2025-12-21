package imaginative.backend.scripting;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

using haxe.macro.ExprTools;
using haxe.macro.MacroStringTools;

class ScriptMacro {
	/**
	 * Adds shortcut functions to classes that contain a script group.
	 * **NOTE:** If the variable you chose is static, the macro will account for that.
	 * @param scriptGroupName The name of the script group variable.
	 * @param differentiateFunctionNames If true the generated function names will be different to avoid issues.
	 * example: "call" will become "scriptCall" and "event" will become "eventCall".
	 * @param makeInline If true then all generated fields will be inlined
	 * @return Array<Field>
	 */
	public static macro function addShortcuts(scriptGroupName:String, differentiateFunctionNames:Bool, makeInline:Bool):Array<Field> {
		var classFields = Context.getBuildFields();
		if (![for (field in classFields) field.name].contains(scriptGroupName)) {
			Context.error('Variable "$scriptGroupName" doesn\'t exist.', Context.currentPos());
			return classFields;
		}

		final mainVarName = [scriptGroupName].toFieldExpr(Context.currentPos());
		final callFuncName = differentiateFunctionNames ? 'scriptCall' : 'call';
		final eventFuncName = differentiateFunctionNames ? 'eventCall' : 'event';

		var tempClass = macro class TempClass {
			/**
			 * Call's a function in the script instance.
			 * @param func Name of the function to call.
			 * @param args Arguments of said function.
			 * @param def If it's null then return this.
			 * @return `Dynamic` ~ Whatever is in the functions return statement.
			 */
			public function $callFuncName(func:String, ?args:Array<Dynamic>, ?def:Dynamic):Dynamic {
				if ($mainVarName != null)
					return $mainVarName.call(func, args, def);
				return def;
			}
			/**
			 * Call's a function in the script instance and triggers an event.
			 * @param func Name of the function to call.
			 * @param event The event class.
			 * @return `ScriptEvent`
			 */
			public function $eventFuncName<SC:ScriptEvent>(func:String, event:SC):SC {
				if ($mainVarName != null)
					return $mainVarName.event(func, event);
				return event;
			}
		}
		// If you already have the function in the class, it will ignore the macro created one.
		tempClass.fields = tempClass.fields.filter((field) -> {
			final names = [for (field in classFields) field.name];
			final contains = names.contains(field.name);
			if (contains) Context.info('Field "${field.name}" already existed, will now ignore implementation.', Context.currentPos());
			return !contains;
		});
		final scriptGroup = classFields.filter(field -> return field.name == scriptGroupName)[0];
		for (field in tempClass.fields) {
			if (makeInline) field.access.push(AInline);
			if (scriptGroup.access.contains(AStatic) && !field.access.contains(AStatic))
				field.access.push(AStatic);
		}
		return classFields.concat(tempClass.fields);
	}
}
#end