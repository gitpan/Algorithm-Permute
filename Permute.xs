#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef __cplusplus
}
#endif

#include <stdio.h>

#ifdef TRUE
    #undef TRUE
#endif

#ifdef FALSE
    #undef FALSE
#endif

#define TRUE  1
#define FALSE 0

typedef unsigned int  UINT;
typedef unsigned long ULONG;

ULONG factorial(UINT n)
{
    UINT i;
    ULONG res = 1;
    if (n <= 1)
        return 1;
    else {
        for (i = 1; i <=n; i++)
            res *= i;
        return res;
    }
}

void next(int n, SV **p, UINT *loc, int *pdone)
{   
    int i;
    SV *tmp;
    if (n > 1)
        if (loc[n] < n)
        {
            tmp = newSVsv(p[loc[n]]);
            sv_setsv(p[loc[n]], p[loc[n] + 1]);
            sv_setsv(p[loc[n] + 1], tmp); /* n */
            loc[n] = loc[n] + 1;
        }
        else
        {
            next(n - 1, p, loc, pdone);
            tmp = newSVsv(p[loc[n]]);
            for (i = n - 1; i >= 1; i--)
                sv_setsv(p[i + 1], p[i]);
            sv_setsv(p[1], tmp);
            loc[n] = 1;
        }
    else
        *pdone = TRUE;
}

MODULE = Algorithm::Permute     PACKAGE = Algorithm::Permute        
PROTOTYPES: DISABLE

void
permute(av)
    AV *av
    PREINIT:
    UINT spaces, *loc;
    SV **p;
    int done = FALSE;
    IV i, num;
    UINT j;

    PPCODE:
    if ((num = av_len(av) + 1) == 0) 
        XSRETURN_UNDEF;

    if ((p = (SV**) safemalloc(sizeof(SV*) * (num + 1))) == NULL)
        XSRETURN_UNDEF;
    if ((loc = (UINT*) safemalloc(sizeof(UINT) * (num + 1))) == NULL)
        XSRETURN_UNDEF;

    spaces = factorial(num);
    EXTEND(sp, spaces);

    for (i = 1; i <= num; i++) {
        p[i] = av_pop(av);
        loc[i] = 1;     
    }

    while (!done)
    {
        PUSHs(newRV_noinc(sv_2mortal((SV*)av_make(num, p + 1))));
        next(num, p, loc, &done);
    }
	safefree(p);
	safefree(loc);


AV*
permute_ref(av)
    AV *av
    PREINIT:
    UINT spaces, *loc;
    SV **p;
    int done = FALSE;
    IV i, num;
    UINT j;

    CODE:
    if ((num = av_len(av) + 1) == 0) 
        XSRETURN_UNDEF;

    if ((p = (SV**) safemalloc(sizeof(SV*) * (num + 1))) == NULL)
        XSRETURN_UNDEF;
    if ((loc = (UINT*) safemalloc(sizeof(UINT) * (num + 1))) == NULL)
        XSRETURN_UNDEF;

    spaces = factorial(num);
    EXTEND(sp, spaces);

    for (i = 1; i <= num; i++) {
        p[i] = av_pop(av);
        loc[i] = 1;     
    }
    RETVAL = newAV();
    while (!done)
    {
        av_push(RETVAL, newRV_noinc((SV*)av_make(num, p + 1)));
        next(num, p, loc, &done);
    }
	safefree(p);
	safefree(loc);

    OUTPUT:
    RETVAL
