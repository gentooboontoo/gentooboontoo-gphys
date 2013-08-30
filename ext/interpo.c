/* interpo.c : Extention library regarding interpolation of GPhys
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

static VALUE
interpo_do(obj, shape_to, idxmap, val_from, missval, extrapo)
     VALUE obj;
     VALUE shape_to; // [Array] shape of the new grid
     VALUE idxmap;   // [Array] index mapping
     VALUE val_from; // [NArray] values to be interpolated
     VALUE missval;  // [nil or Float] missing value if Float
     VALUE extrapo; // [false/true] whether to extrapolate
{
    VALUE val_to;
    VALUE chk , ary;
    struct NARRAY *naf;
    VALUE vm;
    int natype;
    int *sht;  // shape to (could be size_t if NArray is changed)
    int *shf;  // shape from (could be size_t if NArray is changed)
    size_t cshf;
    size_t rankf, rankt, lent;
    double *pt, *pf;
    int nomiss;
    double vmiss;
    int extr;
    size_t i, it, kf, j, k, l;
    int *mtyp;
    size_t *dm, *dm2, *dm2f, *dm3, *dm3f, *dm4, *dm4f;
    int **di, nid, nic;
    double **df, *f, a;
    int *idf, idfc, *idt;

    // check arguments

    if (TYPE(shape_to) != T_ARRAY){
        rb_raise(rb_eTypeError, "1st arg must be an array");
    }
    if (TYPE(idxmap) != T_ARRAY){
        rb_raise(rb_eTypeError, "2nd arg must be an array");
    }

    chk = rb_obj_is_kind_of(val_from, cNArray);
    if (chk == Qfalse) {
	rb_raise(rb_eTypeError, "3rd arg must be an NArray");
    }

    // read argument (shape_to)

    rankt = RARRAY_LEN(shape_to);
    sht = ALLOCA_N(int, rankt);
    for(i=0; i<rankt; i++){
	sht[i] = NUM2INT( RARRAY_PTR(shape_to)[i] );
    }

    // read argument (val_from)

    natype = NA_TYPE(val_from);  // saved
    val_from = na_cast_object(val_from, NA_DFLOAT);
    rankf = NA_RANK(val_from);
    GetNArray(val_from, naf);
    shf = naf->shape;
    pf = NA_PTR_TYPE(val_from, double *);

    // read argument (missval)

    nomiss = (missval == Qnil);
    if (!nomiss){
	vmiss = NUM2DBL(missval);
    } else {
	vmiss = -999.0;   // dummy to avoid compiler warning (not used)
    }
    extr = (extrapo != Qfalse);  // false -> 0(false); else -> true

    // read argument (idxmap) 

    if (RARRAY_LEN(idxmap) != rankf){
        rb_raise(rb_eArgError, "length of 2nd arg and rank of 3rd arg must agree");
    }

    mtyp = ALLOCA_N(int,    rankf);
    dm   = ALLOCA_N(size_t, rankf);
    dm2  = ALLOCA_N(size_t, rankf);
    dm2f = ALLOCA_N(size_t, rankf);
    dm3  = ALLOCA_N(size_t, rankf);
    dm3f = ALLOCA_N(size_t, rankf);
    dm4  = ALLOCA_N(size_t, rankf);
    dm4f = ALLOCA_N(size_t, rankf);
    di   = ALLOCA_N(int *,    rankf);
    df   = ALLOCA_N(double *, rankf);
    nid = 0;
    for(i=0; i<rankf; i++){
	vm = RARRAY_PTR(idxmap)[i];
	if (RARRAY_LEN(vm) == 1) {
	    mtyp[i] = 0;   // simple copying
	    dm[i]  = NUM2INT( RARRAY_PTR(vm)[0] ); 
	} else if ( RARRAY_PTR(vm)[1] == Qnil ) {
	    mtyp[i] = 1;   // mapping from 1D
	    dm[i]  = NUM2INT( RARRAY_PTR(vm)[0] ); 
	    di[i] = NA_PTR_TYPE( RARRAY_PTR(vm)[2], int *);
	    df[i] = NA_PTR_TYPE( RARRAY_PTR(vm)[3], double *);
	    nid++;
	} else {
	    dm[i]  = NUM2INT( RARRAY_PTR(vm)[0] ); 
	    ary = RARRAY_PTR(vm)[1];
	    mtyp[i] = RARRAY_LEN(ary)+1;   // mapping from multi-D
	    switch( mtyp[i] ){
	    case 4:  // do not break
		dm4[i] = NUM2INT( RARRAY_PTR(ary)[2] ); 
		dm4f[i]= sht[NUM2INT( RARRAY_PTR(ary)[1] )]; 
	    case 3:  // do not break
		dm3[i] = NUM2INT( RARRAY_PTR(ary)[1] ); 
		dm3f[i]= sht[NUM2INT( RARRAY_PTR(ary)[0] )];
	    case 2:
		dm2[i] = NUM2INT( RARRAY_PTR(ary)[0] ); 
		dm2f[i]= sht[dm[i]]; 
	    }
	    di[i] = NA_PTR_TYPE( RARRAY_PTR(vm)[2], int *);
	    df[i] = NA_PTR_TYPE( RARRAY_PTR(vm)[3], double *);
	    nid++;
	}
    }

    f = ALLOCA_N(double, nid);
    nic = 1 << nid ;   // ==> 2**nid

    // prepare output object

    val_to = na_make_object(NA_DFLOAT, rankt, sht, cNArray);  // double for a momnent
    lent = NA_TOTAL(val_to);
    pt = NA_PTR_TYPE(val_to, double *);


    // do interpolation

    idt  = ALLOCA_N(int, rankt);
    idf  = ALLOCA_N(int, rankf);

    for(it=0; it<lent; it++){
	l = it;
	for(j=0; j<rankt; j++){
	    idt[j] = l % sht[j];
	    l /= sht[j];
	}
	k = 0;
	for(j=0; j<rankf; j++){
	    switch(mtyp[j]){
	    case 0:
		idf[j] = idt[dm[j]];
		break;
	    case 1:
		idf[j] = di[j][ idt[dm[j]] ];
		f[k] = df[j][ idt[dm[j]] ];
		k++;
		break;
	    case 2:
		idf[j] = di[j][ idt[dm[j]] + dm2f[j]*idt[dm2[j]] ];
		f[k] = df[j][ idt[dm[j]] + dm2f[j]*idt[dm2[j]] ];
		k++;
		break;
	    case 3:
                idf[j] = di[j][ idt[dm[j]] + 
			      dm2f[j]*(idt[dm2[j]] + dm3f[j]*idt[dm3[j]]) ];
		f[k] = df[j][ idt[dm[j]] + 
			      dm2f[j]*(idt[dm2[j]] + dm3f[j]*idt[dm3[j]]) ];
		k++;
		break;
	    case 4:
		idf[j] = di[j][ idt[dm[j]] + 
			      dm2f[j]*(idt[dm2[j]] + dm3f[j]*
				       (idt[dm3[j]]+dm4f[j]*idt[dm4[j]])) ];
		f[k] = df[j][ idt[dm[j]] + 
			      dm2f[j]*(idt[dm2[j]] + dm3f[j]*
				       (idt[dm3[j]]+dm4f[j]*idt[dm4[j]])) ];
		k++;
		break;
	    }
	}
	pt[it] = 0.0;
	for(l=0; l<nic; l++){   // loop for 2**nid times
	    a = 1.0;
	    for(k=0; k<nid; k++){
		a = ( (l>>k)%2 ? a*f[k] : a*(1.0 - f[k]) );
	    }
	    cshf=1;
	    kf = 0;
	    k = 0;
	    for(j=0; j<rankf; j++){
		idfc = idf[j];
                if(!extr && idfc<0){
                    pt[it] = vmiss;
                    break;
                }
		if(mtyp[j]>0){
                    if ( (l>>k)%2 && idfc<shf[j]-1 ){
                        idfc += 1;
                    }
		    k++;
		}
		kf += idfc*cshf;
		cshf *= shf[j];
	    }
            if (pt[it] == vmiss) {break;}
	    if (nomiss || pf[kf] != vmiss){
		pt[it] += a*pf[kf];
	    } else {
		pt[it] = vmiss;
		break;
	    }
            //printf("$$$$ %d %f %f\n",it, a, pf[kf]);
	}
        //printf("//// %d %f\n",it, pt[it]);
    }

    // finish
    val_to = na_cast_object(val_to, natype);
    return val_to;
}

static void
__interpo_find_loc_1D(N, P, n, p, vmiss, extr, ids, f)
     double *P, *p;   // INPUT
     size_t N, n;     // INPUT
     double vmiss;    // INPUT
     int extr;        // INPUT
     int *ids;        // OUTPUT
     double *f;       // OUTPUT
{
    size_t j;
    int i, il, ir;
    int down;

    // first time finding : use a simple looping 
    j = 0;
    for(i=0; i<n-1; i++){
	if ( p[i] != vmiss && p[i+1] != vmiss && 
             (p[i]-P[j])*(P[j]-p[i+1]) >= 0 ){
	    break;
	}
    }
    if (i<n-1){
	// found
	ids[j] = i;
    } else if (extr) {
	// not found --> to be extrapolated
	if ( (P[j]-p[0])*(p[0]-p[n-1]) >= 0 ){
	    ids[j] = i = 0;
	} else {
	    ids[j] = i = n-2;
	}
    } else {
        ids[j] = -999999;   // a negative value
        i = 0;
    }
    f[j] = (p[i]-P[j])/(p[i]-p[i+1]);

    // second or later time finding : start from the previous position
    for(j=1; j<N; j++){
	down = 1; // true : move i downward next time
	il = ir = i;
	while (1){
	    if ( (p[i]-P[j])*(P[j]-p[i+1]) >= 0 ) {
		break;
	    } else {
		if ( il>0 && ( down || ir==n-2 )  ){
		    il--;
		    i = il;
		    down = 0; // false
		} else if ( ir<n-2 && ( !down || il==0 ) ){
		    ir++;
		    i = ir;
		    down = 1; // true
		} else {
		    // not found
                    if (extr) {
                        // to be extrapolated
                        if ( (P[j]-p[0])*(p[0]-p[n-1]) >= 0 ){
                            i = 0;
                        } else {
                            i = n-2;
                        }
                    } else {
                        i = -999999;  // a negative value (changed to 0 below)
		    }
		    break;
		}
	    }
	}
	ids[j] = i;
        if(i<0){i = 0; down = 0;}
	f[j] = (p[i]-P[j])/(p[i]-p[i+1]);
    }
}

static VALUE
interpo_find_loc_1D(obj, X, x, missval, extrapo)
     VALUE obj;
     VALUE X; // [NArray(1D)] coordinate values onto which interpolation is made
     VALUE x; // [NArray(1D)] coordinate values of original data
     VALUE missval; // [Float] missing value in x
     VALUE extrapo; // [false/true] whether to extrapolate
{
    VALUE na_ids, na_f;
    VALUE chk;
    size_t N, n;
    struct NARRAY *na;
    double *P, *p, vmiss;
    int extr;
    int *ids;
    double *f;
    int shape[1];  // could be size_t if NArray is changed

    // check and unwrap the input arguments

    chk = rb_obj_is_kind_of(X, cNArray);
    if (chk == Qfalse) {rb_raise(rb_eTypeError, "expect NArray (1st arg)");}

    chk = rb_obj_is_kind_of(x, cNArray);
    if (chk == Qfalse) {rb_raise(rb_eTypeError, "expect NArray (2nd arg)");}

    X = na_cast_object(X, NA_DFLOAT);
    GetNArray(X, na);
    N = na->total;
    P = (double *)NA_PTR(na, 0);

    x = na_cast_object(x, NA_DFLOAT);
    GetNArray(x, na);
    n = na->total;
    p = (double *)NA_PTR(na, 0);

    vmiss = NUM2DBL(missval);

    extr = (extrapo != Qfalse);  // false -> 0(false); else -> true

    // prepare output NArrays

    shape[0] = N;
    na_ids = na_make_object(NA_LINT, 1, shape, cNArray);
    GetNArray(na_ids, na);
    ids = (int *) NA_PTR(na, 0);
    na_f = na_make_object(NA_DFLOAT, 1, shape, cNArray);
    GetNArray(na_f, na);
    f = (double *) NA_PTR(na, 0);

    // Do the job

    __interpo_find_loc_1D(N, P, n, p, vmiss, extr, ids, f);

    // Return

    return rb_ary_new3(2, na_ids, na_f);
}

/* To apply interpo_find_loc_1D multi-dimensionally 
 */
static VALUE
interpo_find_loc_1D_MD(obj, X, x, dimc, missval, extrapo)
     VALUE obj;
     VALUE X; // [NArray(1D)] coordinate values onto which interpolation is made
     VALUE x; // [NArray(multi-D)] coordinate values of original data
     VALUE dimc; // [Integer] the dimension in x except which mapping has been set
     VALUE missval; // [Float] missing value in x
     VALUE extrapo; // [false/true] whether to extrapolate
{
    VALUE na_ids, na_f;
    VALUE chk;
    size_t N, n1;
    struct NARRAY *na;
    double *P, *p, *p1, vmiss;
    int extr;
    int *ids, *ids1;
    double *f, *f1;
    int *shr;  // shape of the result (could be size_t if NArray is changed)
    int *shl;  // shape of multi-D loop (could be size_t if NArray is changed)
    int *shx;  // shape of x (could be size_t if NArray is changed)
    int dmc; // dimc
    int rank, dl, dc;
    size_t *cshxl, *cshrl, *cshl; // cumulative shapes for looping
    size_t fxl;    // same but only for the dimension treated here
    size_t il, i, j, ix, ir, totl;

    // check and unwrap the input arguments

    chk = rb_obj_is_kind_of(X, cNArray);
    if (chk == Qfalse) {rb_raise(rb_eTypeError, "expect NArray (1st arg)");}

    chk = rb_obj_is_kind_of(x, cNArray);
    if (chk == Qfalse) {rb_raise(rb_eTypeError, "expect NArray (2nd arg)");}

    X = na_cast_object(X, NA_DFLOAT);
    GetNArray(X, na);
    N = na->total;
    P = (double *)NA_PTR(na, 0);

    dmc = NUM2INT( dimc ); 

    vmiss = NUM2DBL(missval);

    extr = (extrapo != Qfalse);  // false -> 0(false); else -> true

    x = na_cast_object(x, NA_DFLOAT);
    GetNArray(x, na);
    p = (double *)NA_PTR(na, 0);
    shx = na->shape; 
    n1 = shx[dmc];

    rank = NA_RANK(x);

    if (dmc<0 || dmc>=rank){
        rb_raise(rb_eArgError, "Specified dimension (4th argument) is outside the dims of the multi-D coordinate variable");
    }

    // prepare output NArrays

    shl = ALLOCA_N(int, rank-1);
    shr = ALLOCA_N(int, rank);
    shr[0] = N;
    totl = 1;
    for(dl=0,dc=0; dl<rank-1; dl++,dc++){
	if(dc==dmc){dc++;}  // to skip shx[dmc]
	shr[dl+1] = shl[dl] = shx[dc]; 
	totl *= shl[dl];
    }

    cshl = ALLOCA_N(size_t, rank-1);
    cshl[0] = 1;
    for(dl=1; dl<rank-1; dl++){
	cshl[dl] = cshl[dl-1]*shl[dl-1];
    }

    cshxl = ALLOCA_N(size_t, rank-1);
    if(dmc==0) {
 	fxl = 1;
	cshxl[0] = shx[0];
    } else {
 	fxl = shx[0];
	cshxl[0] = 1;
    }

    for(dl=1,dc=1; dl<rank-1; dl++,dc++){
	if(dc==dmc){
	    fxl = cshxl[dl-1]*shx[dc-1];
	    dc++;
            cshxl[dl] = fxl*shx[dc-1];
	} else {
            cshxl[dl] = cshxl[dl-1]*shx[dc-1];
        }
    }
    if (dmc==rank-1){
	fxl = cshxl[rank-2]*shx[rank-2];
    }

    cshrl = ALLOCA_N(size_t, rank-1);
    cshrl[0] = shr[0];
    for(dl=1; dl<rank-1; dl++){
	cshrl[dl] = cshrl[dl-1]*shr[dl];
    }

    na_ids = na_make_object(NA_LINT, rank, shr, cNArray);
    GetNArray(na_ids, na);
    ids = (int *) NA_PTR(na, 0);
    na_f = na_make_object(NA_DFLOAT, rank, shr, cNArray);
    GetNArray(na_f, na);
    f = (double *) NA_PTR(na, 0);

    // Do the job

    p1 =  ALLOCA_N(double, n1);
    ids1 =  ALLOCA_N(int, N);
    f1 =  ALLOCA_N(double, N);
    for(il=0; il<totl; il++){

	// put a 1D subset of p into p1 (p1 = p[..., true,...])

	ix = 0;
	ir = 0;
	for(dl=0; dl<rank-1; dl++){
	    i = (il/cshl[dl]) % shl[dl];
	    ix += cshxl[dl]*i;
	    ir += cshrl[dl]*i;
	}

	for(j=0; j<n1; j++){
	    p1[j] = p[ix+fxl*j];
	}

	// find loc in 1D

	__interpo_find_loc_1D(N, P, n1, p1, vmiss, extr, ids1, f1);

	// substitute ids1 and f1 (1D) into ids and f (multi-D)
 
	for(j=0; j<N; j++){
	    ids[ir+j] = ids1[j];
	    f[ir+j] = f1[j];
	    //printf("  %d %f\n",ids1[j],f1[j]);
	}
	//printf("\n");

    }

    // Return

    return rb_ary_new3(2, na_ids, na_f);
}


void
init_gphys_interpo()
{
    static VALUE mNumRu;
    static VALUE cGPhys;

    // rb_require("narray");  // it does not work
    mNumRu = rb_define_module("NumRu");
    cGPhys = rb_define_class_under(mNumRu, "GPhys", rb_cObject);
    rb_define_private_method(cGPhys, "c_interpo_find_loc_1D", interpo_find_loc_1D, 4);
    rb_define_private_method(cGPhys, "c_interpo_find_loc_1D_MD", interpo_find_loc_1D_MD, 5);

    rb_define_private_method(cGPhys, "c_interpo_do", interpo_do, 5);

    // to make "find loc" methods available outside GPhys as class methods
    rb_define_singleton_method(cGPhys, "interpo_find_loc_1D", interpo_find_loc_1D, 2);
    rb_define_singleton_method(cGPhys, "interpo_find_loc_1D_MD", interpo_find_loc_1D_MD, 3);
}
