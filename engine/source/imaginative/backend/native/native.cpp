#include "native.hpp"

#ifdef HX_WINDOWS

#include <windows.h>
#include <dwmapi.h>
#include <winuser.h>
#include <wingdi.h>

#define attributeDarkMode 20
#define attributeDarkModeFallback 19

#define attributeCaptionColor 34
#define attributeTextColor 35
#define attributeBorderColor 36

struct HandleData
{
    DWORD pid = 0;
    HWND handle = 0;
};

BOOL CALLBACK findByPID(HWND handle, LPARAM lParam)
{
    DWORD targetPID = ((HandleData *)lParam)->pid;
    DWORD curPID = 0;

    GetWindowThreadProcessId(handle, &curPID);
    if (targetPID != curPID || GetWindow(handle, GW_OWNER) != (HWND)0 || !IsWindowVisible(handle))
    {
        return TRUE;
    }

    ((HandleData *)lParam)->handle = handle;
    return FALSE;
}

HWND curHandle = 0;
void getHandle()
{
    if (curHandle == (HWND)0)
    {
        HandleData data;
        data.pid = GetCurrentProcessId();
        EnumWindows(findByPID, (LPARAM)&data);
        curHandle = data.handle;
    }
}


void native::registerDPIAware()
{
	#ifdef HX_WINDOWS
    SetProcessDPIAware();
	#ifdef DPI_AWARENESS_CONTEXT
    SetProcessDpiAwarenessContext(
		#ifdef DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2
        DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2
		#else
        DPI_AWARENESS_CONTEXT_SYSTEM_AWARE
		#endif
    );
	#endif
	#endif
}

void native::fixScaling()
{
	getHandle();
    if (curHandle != (HWND)0)
    {
		HDC curHDC = GetDC(curHandle);
        RECT curRect;
        GetClientRect(curHandle, &curRect);
        FillRect(curHDC, &curRect, (HBRUSH)GetStockObject(BLACK_BRUSH));
        ReleaseDC(curHandle, curHDC);
    }
}

#elif  HX_LINUX
#include <X11/Xlib.h>
#include <X11/extensions/Xrandr.h>

// https://stackoverflow.com/questions/17797636/c-linux-get-the-refresh-rate-of-a-monitor
short native::getMonitorRefreshRate()
{
    Display *dpy = XOpenDisplay(NULL);
    Window root = RootWindow(dpy, 0);
    XRRScreenConfiguration *conf = XRRGetScreenInfo(dpy, root);
    short current_rate = XRRConfigCurrentRate(conf);
    XCloseDisplay(dpy);

    return current_rate;
}
#endif