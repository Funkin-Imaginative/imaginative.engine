#pragma once

namespace native
{

	#ifdef HX_WINDOWS
    void registerDPIAware();

    void fixScaling();

    static bool fixedScaling = false;
	#elif HX_LINUX

	short getMonitorRefreshRate();
	#endif

} // namespace native