package engine.source.imaginative.utils;

#if (linux && cpp)
import cpp.Int16;

@:buildXml('<include name="../../../../engine/source/imaginative/backend/native/build.xml" />')
@:include('refreshrate.hpp')
extern class LinuxUtil {
	@:native('getMonitorRefreshRate')
	static function getMonitorRefreshRate():Int16;
}
#end
