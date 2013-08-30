/* ext_coord.c : Extention library related to coordinate handling in GPhys
 */

#include<stdio.h>
#include<string.h>
#include "ruby.h"
#include "narray.h"

#ifndef RARRAY_PTR
#  define RARRAY_PTR(ary) (RARRAY(ary)->ptr)
#endif
#ifndef RARRAY_LEN
#  define RARRAY_LEN(ary) (RARRAY(ary)->len)
#endif

/* cut_range : a private method for AssocCoord (used in AssocCoord#cut)
 */
static VALUE
assoc_coord_cut_range(self, vmins, vmaxs, crds, masks, crdaxexist, orgaxlens)
     VALUE self, vmins, vmaxs, crds, masks, crdaxexist, orgaxlens;
     // All input variables are supposed to be Arrays
{
    VALUE wheres, whna;  // return value (Array)
    int nc, ic, na, ia, jlen, j, klen, k, ndimk, dimk;
    int *lens, lentot, lenmax, *mod, *sub, **mlt, *jmlt, *dimk2a; 
    int last_non0, l, cidx, *natype, *nomask, included, whcount;
    int32_t **axexist, *whptr, *whbuf;
    double *vmax, *vmin, val, **dval;
    float   **fval;
    int8_t **mask;

    nc = RARRAY_LEN(crds);     // lengths of vmins,vmaxs,crds,masks,crdaxexist
    na = RARRAY_LEN(orgaxlens);
    wheres = rb_ary_new();

    /* input check */

    if(nc==0){rb_raise(rb_eArgError,"crds empty [%s:%d]",__FILE__,__LINE__);}
    if(na==0){rb_raise(rb_eArgError,"orgaxlens empty [%s:%d]",__FILE__,__LINE__);}
    if ( nc!=RARRAY_LEN(vmins) || nc!=RARRAY_LEN(vmaxs) || 
         nc!=RARRAY_LEN(masks) || nc!=RARRAY_LEN(crdaxexist) ) {
	rb_raise(rb_eArgError,"lengths of array do not agree [%s:%d]",
		 __FILE__,__LINE__);
    }

    /* info regaring lengths of original axes */

    lentot = 1;
    lenmax = -1;
    lens = ALLOCA_N(int,na);
    for(ia=0; ia<na; ia++){
	lens[ia] = NUM2INT( RARRAY_PTR(orgaxlens)[ia] );
	lentot *= lens[ia];
	if (lens[ia] > lenmax) { lenmax = lens[ia]; }
    }
    ndimk = ( (na==1) ? 1 : (na-1) ) ;
    mod = ALLOCA_N(int,ndimk);
    sub = ALLOCA_N(int,ndimk);
    mlt = ALLOCA_N(int*,nc);
    axexist = ALLOCA_N(int32_t*,nc);
    for(ic=0; ic<nc; ic++){
	mlt[ic] = ALLOCA_N(int,ndimk);
	axexist[ic] = NA_PTR_TYPE( RARRAY_PTR(crdaxexist)[ic], int32_t* );
    }
    jmlt = ALLOCA_N(int,nc);
    dimk2a = ALLOCA_N(int,ndimk);

    /* ruby objs to C for coordinates and cut params */

    vmin = ALLOCA_N(double,nc);
    vmax = ALLOCA_N(double,nc);
    dval = ALLOCA_N(double*,nc);
    fval = ALLOCA_N(float*,nc);
    mask = ALLOCA_N(int8_t*,nc);
    nomask = ALLOCA_N(int,nc);
    natype = ALLOCA_N(int,nc);
    for(ic=0; ic<nc; ic++){
	vmin[ic] = NUM2DBL( RARRAY_PTR(vmins)[ic] );
	vmax[ic] = NUM2DBL( RARRAY_PTR(vmaxs)[ic] );
	natype[ic] = NA_TYPE( RARRAY_PTR(crds)[ic]);
	if ( natype[ic] == NA_DFLOAT ) {
	    dval[ic] = NA_PTR_TYPE( RARRAY_PTR(crds)[ic], double* );
	} else if ( natype[ic] == NA_SFLOAT ) {
	    fval[ic] = NA_PTR_TYPE( RARRAY_PTR(crds)[ic], float* );
	} else {
	    rb_raise(rb_eArgError,"Associate coordinates must be float or sfloat [%s:%d]",__FILE__,__LINE__);
	}
	if ( RARRAY_PTR(masks)[ic] == Qnil ){
	    mask[ic] = NULL;
	    nomask[ic] = 1;
	} else {
	    mask[ic] = NA_PTR_TYPE( RARRAY_PTR(masks)[ic], u_int8_t* );
	    nomask[ic] = 0;
	}
    }

    /* prepare output objs */
    whbuf = ALLOCA_N(int32_t,lenmax);
    
    /* main loop */
    for(ia=0; ia<na; ia++){

	/* parameters for positioning */
	jlen = lens[ia];
	klen = lentot / jlen;

	for(dimk=0; dimk<ndimk; dimk++){
	    if (dimk<ia || na==1) { 
		dimk2a[dimk] = dimk;
	    } else {
		dimk2a[dimk] = dimk+1;
	    }
	}
	for(dimk=0; dimk<ndimk; dimk++){
	    if(dimk==0){
		mod[dimk] = lens[dimk2a[dimk]];
		sub[dimk] = 1;
		for(ic=0; ic<nc; ic++){
		    if( axexist[ic][dimk2a[dimk]] == 1 ){  // has the ax
			mlt[ic][dimk] = 1;
		    } else {
			mlt[ic][dimk] = 0;
		    }
		}
	    } else {
		mod[dimk] = mod[dimk-1] * lens[dimk2a[dimk]];
		sub[dimk] = mod[dimk-1];
		for(ic=0; ic<nc; ic++){
		    if( axexist[ic][dimk2a[dimk]] == 1 ){  // has the ax
			last_non0 = 1;
			for(l=dimk-1; l>=0; l--) {
			    if( mlt[ic][l] != 0){
				last_non0 = mlt[ic][l];
				break;
			    }
			}
			mlt[ic][dimk] = last_non0 * lens[dimk2a[dimk]];
		    } else {
			mlt[ic][dimk] = 0;
		    }
		}
	    }
	    for(ic=0; ic<nc; ic++){
		if (dimk>=ia) { mlt[ic][dimk] *= lens[ia];}
	    }
	    //printf("## %d %d %d %d : ",ia,dimk,mod[dimk],sub[dimk]);//DEL later
	    //for(ic=0;ic<nc;ic++){printf(" %d",mlt[ic][dimk]);}    //DEL later
	    //printf("\n");                                         //DEL later
	}
	for(ic=0; ic<nc; ic++){
	    jmlt[ic] = 1;
	    for(dimk=0; dimk<ia; dimk++){
		if( axexist[ic][dimk] == 1 ){  // has the ax
		    jmlt[ic] *= lens[dimk];
		}
	    }
	}

	/* judge in/out */
	whcount = 0;
	for(j=0; j<jlen; j++){
	    for(k=0; k<klen; k++){
		included = 0;  // initialization to avoid -Wall warning
		for(ic=0; ic<nc; ic++){
		    cidx = 0;
		    for(dimk=0; dimk<ndimk; dimk++){
			cidx += ( (k/sub[dimk]) % mod[dimk] ) * mlt[ic][dimk];
		    }
		    cidx += jmlt[ic]*j;
		    if ( natype[ic] == NA_DFLOAT ) {
			val = dval[ic][cidx];
		    } else {
			val = fval[ic][cidx];
		    }
		    //printf("! %d %d %d  %d %f\n",j,k,ic,cidx,val); //DEL later
		    included = ( (nomask[ic] || mask[ic][cidx]) &&
			         val >= vmin[ic] && 
			         val <= vmax[ic] );
		    if (!included) {break;}
		}
		if(included){
		    whbuf[whcount] = j;
		    whcount++;
		    break;
		}
	    }
	}
	whna = na_make_object(NA_LINT, 1, &whcount, cNArray);
	rb_ary_push( wheres, whna ); 
	whptr = NA_PTR_TYPE( whna, int32_t* );
	for(j=0; j<whcount; j++){
	    whptr[j] = whbuf[j];
	}
    }

    return( wheres );
}

void
init_ext_coord()
{
    static VALUE mNumRu;
    static VALUE cAssocCoords;

    // rb_require("narray");  // it does not work
    mNumRu = rb_define_module("NumRu");
    cAssocCoords = rb_define_class_under(mNumRu, "AssocCoords", rb_cObject);
    rb_define_private_method(cAssocCoords,"cut_range",assoc_coord_cut_range,6);
}
