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

PROTOTYPES: DISABLE

#include "config.h"

#if defined(HAS_USLEEP) || defined(HAS_SELECT)

#ifdef HAS_USLEEP

void
usleep(useconds)
        int useconds 

#else

#ifdef I_SYS_SELECT
#  include <sys/select.h>
#endif

void
usleep(useconds)
    	PREINIT:
	struct timeval tv;
	PPCODE:
	tv.tv_sec = 0;
	tv.tv_usec = SvIV(ST(0));
	select(0, (Select_fd_set_t)NULL, (Select_fd_set_t)NULL,
		(Select_fd_set_t)NULL, &tv);

#endif

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
        EXTEND(sp, 2);
        PUSHs(sv_2mortal(newSViv(Tp.tv_sec)));
        PUSHs(sv_2mortal(newSViv(Tp.tv_usec)));

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

# $Id: HiRes.xs,v 1.3 1997/10/13 20:56:15 wegscd Exp wegscd $

# $Log: HiRes.xs,v $
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
