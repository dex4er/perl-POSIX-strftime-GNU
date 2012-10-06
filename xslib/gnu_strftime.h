#include "EXTERN.h"
#include "perl.h"
#include <time.h>

size_t gnu_strftime (char *s, size_t maxsize, const char *format, const struct tm *tp, int ut, int ns);
