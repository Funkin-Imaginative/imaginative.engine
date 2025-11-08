package imaginative.utils;

#if TRACE_REFLECT_UTIL_USAGE
import haxe.PosInfos;
#end

/**
 * A reflect util because I wanted to.
 * All the names start with "_" to be safe when doing "using".
 */
class ReflectUtil {
	/**
	 * States if an object has an set field.
	 * @param object The object to check.
	 * @param field The field to check.
	 * @return Bool ~ If the field exists.
	 */
	inline public static function _has(object:Dynamic, field:String #if TRACE_REFLECT_UTIL_USAGE, ?infos:PosInfos #end):Bool {
		#if TRACE_REFLECT_UTIL_USAGE
		var has = object._class() ? Type.getInstanceFields(Type.getClass(object) ?? object).contains(field) : Reflect.hasField(object, field);
		if (!infos.className.endsWith('ReflectUtil')) log('[ReflectUtil._has] $field - $has', DebugMessage, infos);
		return has;
		#else
		return object._class() ? Type.getInstanceFields(Type.getClass(object) ?? object).contains(field) : Reflect.hasField(object, field);
		#end
	}

	/**
	 * Returns a field from an object.
	 * @param object The object to get from.
	 * @param field The field to get.
	 * @param bypassAccessor If true it bypasses the accessor if one exists.
	 * @return Dynamic ~ The field.
	 */
	inline public static function _get(object:Dynamic, field:String, bypassAccessor:Bool = false #if TRACE_REFLECT_UTIL_USAGE, ?infos:PosInfos #end):Dynamic {
		#if TRACE_REFLECT_UTIL_USAGE
		var result:Dynamic;
		// if (!object._has(field)) result = null;
		try {
			if (bypassAccessor) result = Reflect.field(object, field);
			result = Reflect.getProperty(object, field);
		} catch(error:haxe.Exception)
			result = null;
		if (!infos.className.endsWith('ReflectUtil')) log('[ReflectUtil._get] $field - $result (bypass:$bypassAccessor)', DebugMessage, infos);
		return result;
		#else
		// if (!object._has(field)) return null;
		try {
			if (bypassAccessor) return Reflect.field(object, field);
			return Reflect.getProperty(object, field);
		} catch(error:haxe.Exception)
			return null;
		#end
	}
	/**
	 * Sets a field of an object.
	 * @param object The object to set from.
	 * @param field The field to set.
	 * @param value The new data.
	 * @param bypassAccessor If true it bypasses the accessor if one exists.
	 */
	inline public static function _set(object:Dynamic, field:String, value:Dynamic, bypassAccessor:Bool = false #if TRACE_REFLECT_UTIL_USAGE, ?infos:PosInfos #end):Void {
		#if TRACE_REFLECT_UTIL_USAGE if (!infos.className.endsWith('ReflectUtil')) log('[ReflectUtil._set] $field - $value (bypass:$bypassAccessor)', DebugMessage, infos); #end
		if (bypassAccessor) Reflect.setField(object, field, value);
		else Reflect.setProperty(object, field, value);
	}

	/**
	 * Calls a function from an object.
	 * @param object The object to call from.
	 * @param func The function name to call from.
	 * @param args The args to put in the function.
	 * @return Dynamic ~ The functions return data.
	 */
	inline public static function _call(object:Dynamic, func:String, ?args:Array<Dynamic> #if TRACE_REFLECT_UTIL_USAGE, ?infos:PosInfos #end):Dynamic {
		var daFunc:haxe.Constraints.Function = object._get(func);
		#if TRACE_REFLECT_UTIL_USAGE
		var result:Dynamic;
		if (Reflect.isFunction(daFunc))
			result = Reflect.callMethod(object, daFunc, args ?? []);
		result = null;
		if (!infos.className.endsWith('ReflectUtil')) log('[ReflectUtil._call] $func - $result (args:${args.formatArray()})', DebugMessage, infos);
		return result;
		#else
		if (Reflect.isFunction(daFunc))
			return Reflect.callMethod(object, daFunc, args ?? []);
		return null;
		#end
	}

	/**
	 * Deletes a field from an object.
	 * @param object The object to effect.
	 * @param field The field to delete.
	 * @return Bool ~ If the field deletion was successful.
	 */
	inline public static function _delete(object:Dynamic, field:String #if TRACE_REFLECT_UTIL_USAGE, ?infos:PosInfos #end):Bool {
		// doing !object._class() so it only works on dynamic structures
		#if TRACE_REFLECT_UTIL_USAGE
		var result = !object._class() && object._has(field) ? Reflect.deleteField(object, field) : false;
		if (!infos.className.endsWith('ReflectUtil')) log('[ReflectUtil._delete] $field - $result', DebugMessage, infos);
		return result;
		#else
		return !object._class() && object._has(field) ? Reflect.deleteField(object, field) : false;
		#end
	}

	/**
	 * Returns all field names contained in an object.
	 * @param object The object to get from.
	 * @return Array<String> ~ The list of field names.
	 */
	inline public static function _fields(object:Dynamic #if TRACE_REFLECT_UTIL_USAGE, ?infos:PosInfos #end):Array<String> {
		#if TRACE_REFLECT_UTIL_USAGE
		var fields = Reflect.fields(object);
		if (!infos.className.endsWith('ReflectUtil')) log('[ReflectUtil._fields] ${fields.formatArray()}', DebugMessage, infos);
		return fields;
		#else
		return Reflect.fields(object);
		#end
	}

	/**
	 * Returns if an object isn't a dynamic structure.
	 * @param object The object to check.
	 * @return Bool ~ If false then this is a dynamic structure.
	 */
	inline public static function _class(object:Dynamic #if TRACE_REFLECT_UTIL_USAGE, ?infos:PosInfos #end):Bool {
		#if TRACE_REFLECT_UTIL_USAGE
		var result:Dynamic;
		if (object is Class) result = true;
		else if (Type.getClass(object) is Class) result = true;
		else result = false;
		if (!infos.className.endsWith('ReflectUtil')) log('[ReflectUtil._class] $result', DebugMessage, infos);
		return result;
		#else
		if (object is Class) return true;
		if (Type.getClass(object) is Class) return true;
		return false;
		#end
	}
}