/* 
   Permute.xs

   Copyright (c) 1999 - 2007  Edwin Pratomo

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

/* For 5.005 compatibility */
#ifndef aTHX_
#  define aTHX_
#endif
#ifndef aTHX
#  define aTHX
#endif
#ifdef ppaddr
#  define PL_ppaddr ppaddr
#endif

/* (Robin) This hack is stolen from Graham Barr's Scalar-List-Utils package.
   The comment therein runs:

   Some platforms have strict exports. And before 5.7.3 cxinc (or Perl_cxinc)
   was not exported. Therefore platforms like win32, VMS etc have problems
   so we redefine it here -- GMB

   With any luck, it will enable us to build under ActiveState Perl.
*/
#if PERL_VERSION < 7/* Not in 5.6.1. */
#  define SvUOK(sv)           SvIOK_UV(sv)
#  ifdef cxinc
#    undef cxinc
#  endif
#  define cxinc() my_cxinc(aTHX)
static I32
my_cxinc(pTHX)
{
    cxstack_max = cxstack_max * 3 / 2;
    Renew(cxstack, cxstack_max + 1, struct context);      /* XXX should fix CXINC macro */
    return cxstack_ix + 1;
}
#endif

/* (Robin) Assigning to AvARRAY(array) expands to an assignment which has a typecast on the left-hand side.
 * So it was technically illegal, but GCC is decent enough to accept it
 * anyway. Unfortunately other compilers are not usually so forgiving...
 */
#if PERL_VERSION >= 9
#  define AvARRAY_set(av, val) ((av)->sv_u.svu_array) = val
#else
#  define AvARRAY_set(av, val) ((XPVAV*)  SvANY(av))->xav_array = (char*) val
#endif

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

/* permute_engine() and afp_destructor() are from Robin Houston
 * <robin@kitsite.com> */
void permute_engine(
AV* av, 
SV** array, 
I32 level, 
I32 len, SV*** tmparea, OP* callback)
{
	SV** copy    = tmparea[level];
	int  index   = level;
	bool calling = (index + 1 == len);
	SV*  tmp;
	
	Copy(array, copy, len, SV*);
	
	if (calling)
	    AvARRAY_set(av, copy);

	do {
		if (calling) {
		    PL_op = callback;
		    CALLRUNOPS(aTHX);
		}
		else {
		    permute_engine(av, copy, level + 1, len, tmparea, callback);
		}
		if (index != 0) {
			tmp = copy[index];
			copy[index] = copy[index - 1];
			copy[index - 1] = tmp;
		}
	} while (index-- > 0);
}

struct afp_cache {
    SV***         tmparea;
    AV*           array;
    I32           len;
    SV**          array_array;
    U32           array_flags;
    SSize_t       array_fill;
    SV**          copy;          /* Non-magical SV list for magical array */
};

static
void afp_destructor(void *cache)
{
    struct afp_cache *c = cache;
    I32               x;
    
    /* PerlIO_stdoutf("DESTROY!\n"); */

    for (x = c->len; x >= 0; x--) free(c->tmparea[x]);
    free(c->tmparea);
    if (c->copy) {
        for (x = 0; x < c->len; x++) SvREFCNT_dec(c->copy[x]);
        free(c->copy);
    }
    
    AvARRAY_set(c->array, c->array_array);
    SvFLAGS(c->array) = c->array_flags;
    AvFILLp(c->array) = c->array_fill;
    free(c);
}

MODULE = Algorithm::Permute     PACKAGE = Algorithm::Permute        
PROTOTYPES: DISABLE

Permute* 
new(CLASS, av)
    char *CLASS
    AV *av
    PREINIT:
    IV i, num;

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

void
permute(callback_sv, array_sv)
SV* callback_sv;
SV* array_sv;
  PROTOTYPE: &\@
  PREINIT:
    CV*           callback;
	GV*			  agv;
    I32           x;
    PERL_CONTEXT* cx;
    I32           gimme = G_VOID;  /* We call our callback in VOID context */

    bool          old_catch;
    struct afp_cache *c;
	I32 hasargs = 0;
	SV** newsp;
  PPCODE:
{
    if (!SvROK(callback_sv) || SvTYPE(SvRV(callback_sv)) != SVt_PVCV)
        Perl_croak(aTHX_ "Callback is not a CODE reference");
    if (!SvROK(array_sv)    || SvTYPE(SvRV(array_sv))    != SVt_PVAV)
        Perl_croak(aTHX_ "Array is not an ARRAY reference");
    
    c = malloc(sizeof(struct afp_cache));
    callback = (CV*)SvRV(callback_sv);
    c->array    = (AV*)SvRV(array_sv);
    c->len      = 1 + av_len(c->array);
    
	agv = gv_fetchpv("A", TRUE, SVt_PVAV);
	SAVESPTR(GvSV(agv));

    if (SvREADONLY(c->array))
        Perl_croak(aTHX_ "Can't permute a read-only array");

    if (c->len == 0) {
        /* Should we warn here? */
        free(c);
        return;
    }
    
    c->array_array = AvARRAY(c->array);
    c->array_flags = SvFLAGS(c->array);
    c->array_fill  = AvFILLp(c->array);

    /* Magical array. Realise it temporarily. */
    if (SvRMAGICAL(c->array)) {
        c->copy = (SV**) malloc (c->len * sizeof *(c->copy));
        for (x = 0; x < c->len; x++) {
            SV **svp = av_fetch(c->array, x, FALSE);
            c->copy[x] = (svp) ? SvREFCNT_inc(*svp) : &PL_sv_undef;
        }
        SvRMAGICAL_off(c->array);
        AvARRAY_set(c->array, c->copy);
        AvFILLp(c->array) = c->len - 1;
    } else {
        c->copy = 0;
    }
    
    SvREADONLY_on(c->array); /* Can't change the array during permute */ 
    
    /* Allocate memory for the engine to scribble on */   
    c->tmparea = (SV***) malloc((c->len + 1) * sizeof *(c->tmparea));
    for (x = c->len; x >= 0; x--)
        c->tmparea[x]  = malloc(c->len * sizeof **(c->tmparea));
    
    /* Set up the context for the callback */
    SAVESPTR(CvROOT(callback)->op_ppaddr);
    CvROOT(callback)->op_ppaddr = PL_ppaddr[OP_NULL];  /* Zap the OP_LEAVESUB */
#ifdef PAD_SET_CUR
   	PAD_SET_CUR(CvPADLIST(callback),1);
#else
   	SAVESPTR(PL_curpad);
   	PL_curpad = AvARRAY((AV*)AvARRAY(CvPADLIST(callback))[1]);
#endif
    SAVETMPS;
    SAVESPTR(PL_op);

    PUSHBLOCK(cx, CXt_NULL, SP);  /* make a pseudo block */
	PUSHSUB(cx);

    old_catch = CATCH_GET;
    CATCH_SET(TRUE);
    save_destructor(afp_destructor, c);
    
    permute_engine(c->array, AvARRAY(c->array), 0, c->len, 
        c->tmparea, CvSTART(callback));
    
	POPBLOCK(cx,PL_curpm);
    CATCH_SET(old_catch);
}
