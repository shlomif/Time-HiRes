#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef WIN32
#include <time.h>
#else
#include <sys/time.h>
#endif
#ifdef __cplusplus
}
#endif

#if !defined(HAS_GETTIMEOFDAY) && defined(WIN32)
#define HAS_GETTIMEOFDAY

/* shows up in winsock.h?
struct timeval {
 long tv_sec;
 long tv_usec;
}
*/

int
gettimeofday (struct timeval *tp, int nothing)
{
 SYSTEMTIME st;
 time_t tt;
 struct tm tmtm;
 /* mktime converts local to UTC */
 GetLocalTime (&st);
 tmtm.tm_sec = st.wSecond;
 tmtm.tm_min = st.wMinute;
 tmtm.tm_hour = st.wHour;
 tmtm.tm_mday = st.wDay;
 tmtm.tm_mon = st.wMonth - 1;
 tmtm.tm_year = st.wYear - 1900;
 tmtm.tm_isdst = -1;
 tt = mktime (&tmtm);
 tp->tv_sec = tt;
 tp->tv_usec = st.wMilliseconds * 1000;
 return 1;
}
#endif

#if !defined(HAS_USLEEP) && defined(HAS_SELECT)
#ifndef SELECT_IS_BROKEN
#define HAS_USLEEP

void
usleep(unsigned long usec)
{
    struct timeval tv;
    tv.tv_sec = 0;
    tv.tv_usec = usec;
    select(0, (Select_fd_set_t)NULL, (Select_fd_set_t)NULL,
		(Select_fd_set_t)NULL, &tv);
}
#endif
#endif

#if !defined(HAS_USLEEP) && defined(WIN32)
#define HAS_USLEEP

void
usleep(unsigned long usec)
{
    long msec;
    msec = usec / 1000;
    Sleep (msec);
}
#endif


#if !defined(HAS_UALARM) && defined(HAS_SETITIMER)
#define HAS_UALARM

int
ualarm(int usec, int interval)
{
   struct itimerval itv;
   itv.it_value.tv_sec = usec / 1000000;
   itv.it_value.tv_usec = usec % 1000000;
   itv.it_interval.tv_sec = interval / 1000000;
   itv.it_interval.tv_usec = interval % 1000000;
   return setitimer(ITIMER_REAL, &itv, 0);
}
#endif


MODULE = Time::HiRes            PACKAGE = Time::HiRes

PROTOTYPES: ENABLE

#ifdef HAS_USLEEP

void
usleep(useconds)
        int useconds 

void
sleep(fseconds)
        double fseconds 
	CODE:
	int useconds = fseconds * 1000000;
	usleep (useconds);

#endif

#ifdef HAS_UALARM

int
ualarm(useconds,interval=0)
	int useconds
	int interval

int
alarm(fseconds,finterval=0)
	double fseconds
	double finterval
	PREINIT:
	int useconds, uinterval;
	CODE:
	useconds = fseconds * 1000000;
	uinterval = finterval * 1000000;
	RETVAL = ualarm (useconds, uinterval);

#endif

#ifdef HAS_GETTIMEOFDAY

void
gettimeofday()
        PREINIT:
        struct timeval Tp;
        PPCODE:
	int status;
        status = gettimeofday (&Tp, NULL);
        if (GIMME_V == G_ARRAY) {
	     EXTEND(sp, 2);
             PUSHs(sv_2mortal(newSViv(Tp.tv_sec)));
             PUSHs(sv_2mortal(newSViv(Tp.tv_usec)));
        } else {
             EXTEND(sp, 1);
             PUSHs(sv_2mortal(newSVnv(Tp.tv_sec + (Tp.tv_usec / 1000000.0))));
        }

double
time()
        PREINIT:
        struct timeval Tp;
        CODE:
	int status;
        status = gettimeofday (&Tp, NULL);
        RETVAL = Tp.tv_sec + (Tp.tv_usec / 1000000.);
	OUTPUT:
	RETVAL

#endif

# $Id: HiRes.xs,v 1.9 1998/07/07 02:42:06 wegscd Exp wegscd $

# $Log: HiRes.xs,v $
# Revision 1.9  1998/07/07 02:42:06  wegscd
# Win32 usleep()
#
# Revision 1.8  1998/07/02 01:47:26  wegscd
# Add Win32 code for gettimeofday.
#
# Revision 1.7  1997/11/13 02:08:12  wegscd
# Add missing EXTEND in gettimeofday() scalar code.
#
# Revision 1.6  1997/11/11 02:32:35  wegscd
# Do something useful when calling gettimeofday() in a scalar context.
# The patch is courtesy of Gisle Aas.
#
# Revision 1.5  1997/11/06 03:10:47  wegscd
# Fake ualarm() if we have setitimer.
#
# Revision 1.4  1997/11/05 05:41:23  wegscd
# Turn prototypes ON (suggested by Gisle Aas)
#
# Revision 1.3  1997/10/13 20:56:15  wegscd
# Add PROTOTYPES: DISABLE
#
# Revision 1.2  1997/05/23 01:01:38  wegscd
# Conditional compilation, depending on what the OS gives us.
#
# Revision 1.1  1996/09/03 18:26:35  wegscd
# Initial revision
#
#
