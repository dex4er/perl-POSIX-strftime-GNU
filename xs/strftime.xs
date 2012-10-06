#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "gnu_strftime.h"

/*    Based on util.c
 *
 *    Copyright (C) 1993, 1994, 1995, 1996, 1997, 1998, 1999, 2000, 2001,
 *    2002, 2003, 2004, 2005, 2006, 2007, 2008 by Larry Wall and others
 *
 *    You may distribute under the terms of either the GNU General Public
 *    License or the Artistic License, as specified in the README file.
 *
 */
static char *
my_gnu_strftime(pTHX_ const char *fmt, int sec, int min, int hour, int mday, int mon, int year, int wday, int yday, int isdst)
{
  char *buf;
  int buflen;
  struct tm mytm;
  int len;

  PERL_ARGS_ASSERT_MY_STRFTIME;

  init_tm(&mytm);	/* XXX workaround - see init_tm() above */
  mytm.tm_sec = sec;
  mytm.tm_min = min;
  mytm.tm_hour = hour;
  mytm.tm_mday = mday;
  mytm.tm_mon = mon;
  mytm.tm_year = year;
  mytm.tm_wday = wday;
  mytm.tm_yday = yday;
  mytm.tm_isdst = isdst;
  mini_mktime(&mytm);
  /* use libc to get the values for tm_gmtoff and tm_zone [perl #18238] */
#if defined(HAS_MKTIME) && (defined(HAS_TM_TM_GMTOFF) || defined(HAS_TM_TM_ZONE))
  STMT_START {
    struct tm mytm2;
    mytm2 = mytm;
    mktime(&mytm2);
#ifdef HAS_TM_TM_GMTOFF
    mytm.tm_gmtoff = mytm2.tm_gmtoff;
#endif
#ifdef HAS_TM_TM_ZONE
    mytm.tm_zone = mytm2.tm_zone;
#endif
  } STMT_END;
#endif
  buflen = 64;
  Newx(buf, buflen, char);
  len = gnu_strftime(buf, buflen, fmt, &mytm, 1, 0);
  /*
  ** The following is needed to handle to the situation where
  ** tmpbuf overflows.  Basically we want to allocate a buffer
  ** and try repeatedly.  The reason why it is so complicated
  ** is that getting a return value of 0 from strftime can indicate
  ** one of the following:
  ** 1. buffer overflowed,
  ** 2. illegal conversion specifier, or
  ** 3. the format string specifies nothing to be returned(not
  **	  an error).  This could be because format is an empty string
  **    or it specifies %p that yields an empty string in some locale.
  ** If there is a better way to make it portable, go ahead by
  ** all means.
  */
  if ((len > 0 && len < buflen) || (len == 0 && *fmt == '\0'))
    return buf;
  else {
    /* Possibly buf overflowed - try again with a bigger buf */
    const int fmtlen = strlen(fmt);
    int bufsize = fmtlen + buflen;

    Renew(buf, bufsize, char);
    while (buf) {
      buflen = strftime(buf, bufsize, fmt, &mytm);
      if (buflen > 0 && buflen < bufsize)
	break;
      /* heuristic to prevent out-of-memory errors */
      if (bufsize > 100*fmtlen) {
	Safefree(buf);
	buf = NULL;
	break;
      }
      bufsize *= 2;
      Renew(buf, bufsize, char);
    }
    return buf;
  }
}

MODULE = POSIX::strftime::GNU::XS    PACKAGE = POSIX::strftime::GNU::XS

void
strftime(fmt, sec, min, hour, mday, mon, year, wday = -1, yday = -1, isdst = -1)
    SV *            fmt
    int             sec
    int             min
    int             hour
    int             mday
    int             mon
    int             year
    int             wday
    int             yday
    int             isdst
CODE:
{
    char *buf = my_gnu_strftime(aTHX_ SvPV_nolen(fmt), sec, min, hour, mday, mon, year, wday, yday, isdst);
    if (buf) {
        SV *const sv = sv_newmortal();
        sv_usepvn_flags(sv, buf, strlen(buf), SV_HAS_TRAILING_NUL);
        if (SvUTF8(fmt)) {
            SvUTF8_on(sv);
        }
        ST(0) = sv;
    }
}
