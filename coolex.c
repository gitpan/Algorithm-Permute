/*
   Copyright (c) 2008  Edwin Pratomo

   You may distribute under the terms of either the GNU General Public
   License or the Artistic License, as specified in the Perl README file,
   with the exception that it cannot be placed on a CD-ROM or similar media
   for commercial distribution without the prior approval of the author.

*/

#include "coolex.h"

COMBINATION* init_combination(IV n, IV r, AV *av) {
	COMBINATION *c = NULL;
	int i;
    unsigned char *b = NULL;
    SV *aryref = newRV_inc((SV*) av);

	/* init bitstring */
	b = (unsigned char*)calloc(n, sizeof(unsigned char));
	if (b == NULL)
	    return NULL;
	
	for (i = 0; i < r; i++)
		b[i] = 1;

	c = (COMBINATION*)safemalloc(sizeof(COMBINATION));
    if (c == NULL) {
        free(b);
        return NULL;
    }
	c->n = n;
	c->r = r;
	c->aryref = aryref;
	c->b = b;
	c->state = 0;
	return c;
}

void free_combination(COMBINATION *c) {
	safefree(c->b);
	SvREFCNT_dec(c->aryref);
	safefree(c);
}

/* coolex algorithm */
bool coolex(COMBINATION *c) {
	static int x = 1, y = 0;
	bool is_done = FALSE;
	
    switch (c->state) {
        case 0: /* state 0: initialized */
            c->state = 1; 
            break;
        case 1: /* state 1: first shift */
            c->b[c->r] =1;
            c->b[0] = 0;
            c->state = 2;
            break;
        default: /* subsequent shifts */
        {
        	while (x < c->n - 1) {
        	    c->b[x++] = 0;
        	    c->b[y++] = 1;
        	    if (c->b[x] == 0) {
        	        c->b[x] = 1, c->b[0] = 0;
        	        if (y > 1) x = 1;
        	        y = 0;
        	    }
        	    return is_done;
            }
            /* reset x and y */
            x = 1, y = 0;
            is_done = TRUE;
        }
    }    
    return is_done;
}

void coolex_visit(COMBINATION *c, SV **p_items) {
    int i, r = 0;
    SV **p;
    AV *av = (AV*)SvRV(c->aryref);
    for (i = 0, p = p_items; i < c->n; i++) {
        if (c->b[i]) {    /* the bitstring matters */
            r++;
            /* tell GC to take care of this */
            if (SvOK(*p)) {
                SvREFCNT_dec(*p);
            }
            SV **svp = av_fetch(av, i, FALSE);
            *p = (svp) ? SvREFCNT_inc(*svp) : &PL_sv_undef;
            p++;
        }
    } 
    assert(r == c->r);
}

