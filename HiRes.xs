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


MODULE = Time::HiRes            PACKAGE = Time::HiRes

# usleep and ualarm I can handle.
void
usleep(useconds)
        int useconds 

int
ualarm(useconds,interval)
	int useconds
	int interval

# a little trickier.
void
gettimeofday()
        PREINIT:
        struct timeval Tp;
        PPCODE:
	int status;
        status = gettimeofday (&Tp, NULL);
        EXTEND(sp, 2);
        PUSHs(sv_2mortal(newSViv(Tp.tv_sec)));
        PUSHs(sv_2mortal(newSViv(Tp.tv_usec)));

# sleep and time could have been done as Perl wrappers to usleep and time;
# I implemenated alarm that way. Since I undertook this as an educational 
# experience as well as a solution for real-life problem, I did some each
# way.

void
sleep(fseconds)
        double fseconds 
	CODE:
	int useconds = fseconds * 1000000;
	usleep (useconds);

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

# $Id: HiRes.xs,v 1.1 1996/09/03 18:26:35 wegscd Exp $

# $Log: HiRes.xs,v $
# Revision 1.1  1996/09/03 18:26:35  wegscd
# Initial revision
#
#
