/* 
   Permute.xs

   Copyright (c) 1999,2000  Edwin Pratomo

   You may distribute under the terms of either the GNU General Public
   License or the Artistic License, as specified in the Perl README file,
   with the exception that it cannot be placed on a CD-ROM or similar media
   for commercial distribution without the prior approval of the author.

*/

#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <stdio.h>
#ifdef __cplusplus
}
#endif

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

typedef struct {
    bool is_done;
    SV **items;
    UINT *loc;
    UINT *p;
    IV num;
} Permute;

/* private _next */
void _next(int n, UINT *p, UINT *loc, bool *is_done)
{   
    int i;
    if (n > 1)
        if (loc[n] < n)
        {
            p[loc[n]] = p[loc[n] + 1];
            p[loc[n] + 1] = n;
            loc[n] = loc[n] + 1;
        }
        else
        {
            _next(n - 1, p, loc, is_done);
            for (i = n - 1; i >= 1; i--)
                p[i + 1] = p[i];
            p[1] = n;
            loc[n] = 1;
        }
    else
        *is_done = TRUE;
}

MODULE = Algorithm::Permute     PACKAGE = Algorithm::Permute        
PROTOTYPES: DISABLE

Permute* 
new(CLASS, av)
    char *CLASS
    AV *av
    PREINIT:
    IV i, num;
    UINT j;

    CODE:
    RETVAL = (Permute*) safemalloc(sizeof(Permute));
    if (RETVAL == NULL) {
        warn("Unable to create an instance of Algorithm::Permute");
        XSRETURN_UNDEF;
    }

    RETVAL->is_done = FALSE;
    if ((num = av_len(av) + 1) == 0) 
        XSRETURN_UNDEF;

    if ((RETVAL->items = (SV**) safemalloc(sizeof(SV*) * (num + 1))) == NULL)
        XSRETURN_UNDEF;
    if ((RETVAL->p = (UINT*) safemalloc(sizeof(UINT) * (num + 1))) == NULL)
        XSRETURN_UNDEF;
    if ((RETVAL->loc = (UINT*) safemalloc(sizeof(UINT) * (num + 1))) == NULL)
        XSRETURN_UNDEF;

    RETVAL->num = num;

    for (i = 1; i <= num; i++) {
        *(RETVAL->items + i) = av_shift(av);
        *(RETVAL->p + i) = num - i + 1;
        *(RETVAL->loc + i) = 1;     
    }

    OUTPUT:
    RETVAL

void
next(self)
    Permute *self

    PREINIT:
    IV n;
    IV i;
    SV *tmp;

    PPCODE:
    if (self->is_done) 
        XSRETURN_EMPTY;
    else {
        EXTEND(sp, self->num);  
        for (i = 1; i <= self->num; i++) {
            PUSHs(sv_2mortal(newSVsv(*(self->items + *(self->p + i)))));
        }
        n = self->num;
        if (*(self->loc + n) < n)
        {
            *(self->p + *(self->loc + n)) = *(self->p + *(self->loc + n) + 1);
            *(self->p + *(self->loc + n) + 1) = n;
            *(self->loc + n) = *(self->loc + n) + 1;
        }
        else
        {
            _next(n - 1, self->p, self->loc, &(self->is_done));
            for (i = n - 1; i >= 1; i--)
                *(self->p + i + 1) = *(self->p + i);
            *(self->p + 1) = n;
            *(self->loc + n) = 1;
        }
    }

void
DESTROY(self)
    Permute *self
    CODE:
    safefree(self->p); /* must free elements first? */
    safefree(self->loc); 
    safefree(self);

void 
peek(self)
    Permute *self
    PREINIT:
    int i;
    PPCODE: 
    if (self->is_done) 
        XSRETURN_EMPTY;
    EXTEND(sp, self->num);
    for (i = 1; i <= self->num; i++)
        PUSHs(sv_2mortal(newSVsv(*(self->items + *(self->p + i)))));

void
reset(self)
    Permute *self
    PREINIT:
    int i;
    CODE:
    self->is_done = FALSE;
    for (i = 1; i <= self->num; i++) {
        *(self->p + i) = self->num - i + 1;
        *(self->loc + i) = 1;     
    }
