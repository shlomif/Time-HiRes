#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <sys/time.h>
#ifdef __cplusplus
}
#endif

#if !defined(HAS_USLEEP) && defined(HAS_SELECT)
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


#if !defined(HAS_UALARM) && defined(HAS_SETITIMER)
#define HAS_UALARM

int
ualarm(int usec, int interval)
{
   struct itimerval itv;
   itv.it_value.tv_sec = 0;
   itv.it_value.tv_usec = usec;
   itv.it_interval.tv_sec = 0;
   itv.it_interval.tv_usec = interval;
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

# $Id: HiRes.xs,v 1.6 1997/11/11 02:32:35 wegscd Exp $

# $Log: HiRes.xs,v $
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
