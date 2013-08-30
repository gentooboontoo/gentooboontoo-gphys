#include <stdio.h>
#include <stdlib.h>
#include "ruby.h"
#include "narray.h"

#ifndef HAVE_INT32_T
typedef int int32_t;
#endif

/* for compatibility with ruby 1.6 */
#ifndef RARRAY_PTR
#define RARRAY_PTR(a) (RARRAY(a)->ptr)
#endif
#ifndef RARRAY_LEN
#define RARRAY_LEN(a) (RARRAY(a)->len)
#endif
#ifndef StringValueCStr
#define StringValueCStr(s) STR2CSTR(s)
#endif
#ifndef StringValuePtr
#define StringValuePtr(s) STR2CSTR(s)
#endif

struct multibit_IO {
    FILE *fp;
};

static void
multibit_IO_closer(ptr)
     struct multibit_IO *ptr;
{
    if (ptr->fp)
      fclose(ptr->fp);
    free(ptr);
}

/*
VALUE
multibit_IO_close(self)
     VALUE self;
{
    struct multibit_IO *ptr;
    Data_Get_Struct(self, struct multibit_IO, ptr);
    multibit_IO_closer(ptr);
    return Qnil;
}
*/

static VALUE
multibit_IO_alloc(VALUE klass)
{
    struct multibit_IO *ptr = ALLOC(struct multibit_IO);
    return Data_Wrap_Struct(klass, 0, multibit_IO_closer, ptr);
}


static VALUE
multibit_IO_initialize(VALUE self, VALUE path)
{
    struct multibit_IO *ptr;
    Data_Get_Struct(self, struct multibit_IO, ptr);
    ptr->fp = fopen(StringValueCStr(path),"rb");
    if (!ptr->fp)
      rb_raise(rb_eArgError, "Cannot open file: %s\n", StringValueCStr(path));
    return Qnil;
}

static int32_t *
multibit_read_2D(fp, pos, nbit, sh0, sh1, f0, l0, s0, f1, l1, s1, idx0, idx1,
                 ival)
    // IN
     FILE *fp;    // binary file to read
     long pos;  // starting postion of the current 2D block in fp (bytes)
     long nbit; // number of bits of each data element (>= 0, integer)
     long sh0;  // shape of the 2D array - lengths of the 1st D
     long sh1;  // shape of the 2D array - lengths of the 2nd D
     long f0;   // first index of the subset to read regarding the 1st D
     long f1;   // first index of the subset to read regarding the 2nd D
     long l0;   // last index of the subset to read regarding the 1st D
     long l1;   // last index of the subset to read regarding the 2nd D
     long s0;   // step of the subset to read regarding the 1st D
     long s1;   // step of the subset to read regarding the 2nd D
     long *idx0;// If non-NULL, index map of the subset regarding the 1st D
                // Then f0, s0, and l0 must be 0, 1 and len-1 of idx0
     long *idx1;// If non-NULL, index map of the subset regarding the 2nd D
                // Then f1, s1, and l1 must be 0, 1 and len-1 of idx1
    // OUT
     int32_t *ival;  // to return (allocated if NULL)
{
    long pf, pl, bskip;
    unsigned char *buf;
    long sz, size;
    long len;
    int status;
    long i, i0, i1, ns, nl, k, j, ib;
    int w, b;
    unsigned char cn[5];
    unsigned char mk[8] = {0xff,0x7f,0x3f,0x1f,0x0f,0x07,0x03,0x01};
            // bit mask. in binary, 01111111, 00111111, 00011111,..., 00000001
    unsigned int one = 1;
    long fa0, fa1, la0, la1; // actual f0, f1, l0, l1

    // << read the file >>

    if(idx0 == NULL){
        fa0 = f0;
        la0 = l0;
    } else {
        fa0 = 0;       // possible min val (to use actual min is impactless)
        la0 = sh0-1;   // possible max val (to use actual max is impactless)
    }
    if(idx1 == NULL){
        fa1 = f1;
        la1 = l1;
    } else {
        for( i=0, fa1=sh1-1, la1=0 ; i<=l1 ; i++){
            if(idx1[i] < fa1){ fa1=idx1[i]; }  // find actual minimum
            if(idx1[i] > la1){ la1=idx1[i]; }  // find actual maximum
        }
    }

    bskip = (fa0+sh0*fa1) * nbit / 8;
    pf = pos + bskip;                             // first file pos to read
    pl = pos + ( (la0+sh0*la1+1)*nbit -1 ) / 8;   // last file pos to read

    size = pl-pf+1;
    //printf("=== %d %d %d  %d %d\n",pf,pl,size,sh0,la1);
    buf = ALLOCA_N(unsigned char, size);
    status = fseek(fp, pf, SEEK_SET);
    if (status) { rb_raise(rb_eStandardError,
                  "Could not move to the specified position %d",pf); }
    sz = fread(buf,1,size,fp);
    if (sz!=size) { rb_raise(rb_eStandardError,
                    "Could not read %d bytes from %d",size,pf); }

    // << multibit -> int32_t >>
    
    if(ival==NULL){
        len = ((l0-f0)/s0+1) * ((l1-f1)/s1+1);   // total len of ival
        ival = (int32_t *) xmalloc(len*sizeof(int32_t));
    }

    k = 0;
    for(i1=f1; i1<=l1; i1+=s1){
        for(i0=f0; i0<=l0; i0+=s0, k++){
            if(idx0 == NULL && idx1 == NULL){
                i = i0+sh0*i1;
            } else if (idx0 == NULL) {
                i = i0+sh0*idx1[i1];
            } else if (idx1 == NULL) {
                i = idx0[i0]+sh0*i1;
            } else {
                i = idx0[i0]+sh0*idx1[i1];
                //printf("--- %d\n",i);
            }
            ib = i*nbit;
            ns = ib / 8 - bskip;              // start position  i*nbit/8
            nl = (ib+nbit-1) / 8 - bskip;     // end position
            w = ib % 8;
            cn[0] = buf[ns] & mk[w];  // mask the first w bits
            for(j=1; j<= nl-ns; j++){
                cn[j] = buf[ns+j];
            }
            ival[k] = 0;
            for(j=0; j<=nl-ns; j++){
                b = w + nbit - (j+1)*8 ;
                if (b>0) {
                    ival[k] += cn[j] * (one<<b); //cn[j]<<b (truncation-free)
                } else if (b==0) {
                    ival[k] += cn[j];
                } else {
                    ival[k] += cn[j] >> (-b);
                }
            }
            //printf("%d   %d\n",(int)k,ival[k]);
        }
    }
    return(ival);
}
// Array -> C pointer with range checking (from Ruby-DCL)
static long *
ary2long(src, sh, len)
    VALUE src;
    long sh;
    long *len;
{
    VALUE *ptr;
    long i;
    long *rtn,x;

    *len = RARRAY_LEN(src);
    ptr = RARRAY_PTR(src);
    rtn = ALLOC_N(long, *len);
    for (i = 0; i < *len; i++) {
        x = NUM2INT(ptr[i]);
        if(x<-sh||x>=sh){rb_raise(rb_eArgError,
                "%d-th index (%d) is not in the index range", i,x);}
        if(x<0){x += sh;}
        rtn[i] = x;
    }
    return rtn;
}

// NArray -> C pointer with range checking (from Ruby-DCL)
static long *
na2long(src, sh, len)
    VALUE src;
    long sh;
    long *len;
{
    VALUE chk;
    long i;
    long *rtn, x;
    int32_t *ptr;

    chk = rb_obj_is_kind_of(src, cNArray);
    if (chk == Qfalse) {
        rb_raise(rb_eTypeError, "expect an integer NArray");
    }

    src = na_cast_object(src, NA_LINT);
    *len = NA_TOTAL(src);
    ptr = NA_PTR_TYPE(src, int32_t *);
    rtn = ALLOC_N(long, *len);
    for (i = 0; i < *len; i++) {
	x = (long)ptr[i];
        if(x<-sh||x>=sh){rb_raise(rb_eArgError,
                "%d-th index (%d) is not in the index range", i,x);}
        if(x<0){x += sh;}
        rtn[i] = x;
    }
    
    return rtn;
}

/*
 = MultibitIO::read2D : A wrapper of multibit_read_2D. 
 
 In addtion to be a simple wrapper, a scaling facotor and 
 an offset can be specfied optionally:
 The return value is sfloat NArray if factor and/or offset
 is given (non-nil). Otherwise, it will be an integer NArray.

 Also, [fls][01] can be nil if idx0 and/or idx1 is present.
 */
static VALUE
wrp_multibit_read_2D(self, pos, nbit, sh0, sh1, f0, l0, s0, f1, l1, s1,
                     idx0, idx1, factor, offset )
     VALUE self;
     VALUE pos;  // starting postion of the current 2D block in fp (bytes)
     VALUE nbit; // number of bits of each data element (>= 0, integer)
     VALUE sh0;  // shape of the 2D array - lengths of the 1st D
     VALUE sh1;  // shape of the 2D array - lengths of the 2nd D
     VALUE f0;   // first index of the subset to read regarding the 1st D.
                 // nil ok if idx0 is non-nil (same for l0, s0).
     VALUE f1;   // first index of the subset to read regarding the 2nd D.
                 // nil ok if idx1 is non-nil (same for l1, s1).
     VALUE l0;   // last index of the subset to read regarding the 1st D.
     VALUE l1;   // last index of the subset to read regarding the 2nd D.
     VALUE s0;   // step of the subset to read regarding the 1st D.
     VALUE s1;   // step of the subset to read regarding the 2nd D.
     VALUE idx0; // If non-nil, index map of the subset regarding the 1st D
                 // Then f0, s0, and l0 are automatically set (so nil ok)
     VALUE idx1; // If non-nil, index map of the subset regarding the 2nd D
                 // Then f1, s1, and l1 are automatically set (so nil ok)
     VALUE factor;  // (optional) nil or scale_factor (Numeric)
     VALUE offset;  // (optional) nil oradd_offset (Numeric)
{
    VALUE na;
    struct multibit_IO *ptr;
    FILE *fp;    // binary file to read
    long Pos;    // starting postion of the current 2D block in fp (bytes)
    long Nbit;   // number of bits of each data element (>= 0, integer)
    long Sh0;    // shape of the 2D array - lengths of the 1st D
    long Sh1;    // shape of the 2D array - lengths of the 2nd D
    long F0;     // first index of the subset to read regarding the 1st D
    long F1;     // first index of the subset to read regarding the 2nd D
    long L0;     // last index of the subset to read regarding the 1st D
    long L1;     // last index of the subset to read regarding the 2nd D
    long S0;     // step of the subset to read regarding the 1st D
    long S1;     // step of the subset to read regarding the 2nd D
    long *Idx0;  // If non-NULL, index map of the subset regarding the 1st D
                 // Then f0, s0, and l0 must be 0, 1 and len-1 of idx0
    long *Idx1;  // If non-NULL, index map of the subset regarding the 2nd D
                 // Then f1, s1, and l1 must be 0, 1 and len-1 of idx1
    int lens[2];
    long len;
    int32_t *ival;
    float *fval;
    float Factor, Offset;
    long i;

    Data_Get_Struct(self, struct multibit_IO, ptr);
    fp = ptr->fp;

    Pos = NUM2INT(pos);
    Nbit = NUM2INT(nbit);
    Sh0 = NUM2INT(sh0);
    Sh1 = NUM2INT(sh1);
    if (idx0 == Qnil){
        F0 = NUM2INT(f0);
        if(F0<-Sh0||F0>=Sh0){rb_raise(rb_eArgError,
                  "f0 (=%d) is not in the index range of the 1st dim", f0);}
        if(F0<0){F0 += Sh0;}
        L0 = NUM2INT(l0);
        if(L0<-Sh0||L0>=Sh0){rb_raise(rb_eArgError,
                  "l0 (=%d) is not in the index range of the 1st dim", l0);}
        if(L0<0){L0 += Sh0;}
        S0 = NUM2INT(s0);
        if(S0<=0){rb_raise(rb_eArgError,"s0 (step) must be positive integer");}
        Idx0 = NULL;
    } else {
        switch (TYPE(idx0)) {
        case T_ARRAY: 
            Idx0 = ary2long(idx0, Sh0, &len);
            break;
        case T_DATA:
            Idx0 = na2long(idx0, Sh0, &len);
            break;
        default:
            rb_raise(rb_eTypeError, "idx0 must be Array or NArray");
            break;
        }
        F0 = 0;
        L0 = len-1;
        S0 = 1;
    }

    if (idx1 == Qnil){
        F1 = NUM2INT(f1);
        if(F1<-Sh1||F1>=Sh1){rb_raise(rb_eArgError,
                  "f1 (=%d) is not in the index range of the 2nd dim", f1);}
        if(F1<0){F1 += Sh1;}
        L1 = NUM2INT(l1);
        if(L1<-Sh1||L1>=Sh1){rb_raise(rb_eArgError,
                  "l1 (=%d) is not in the index range of the 2nd dim", l1);}
        if(L1<0){L1 += Sh1;}
        S1 = NUM2INT(s1);
        if(S1<=0){rb_raise(rb_eArgError,"s1 (step) must be positive integer");}
        Idx1 = NULL;
    } else {
        switch (TYPE(idx1)) {
        case T_ARRAY: 
            Idx1 = ary2long(idx1, Sh1, &len);
            break;
        case T_DATA:
            Idx1 = na2long(idx1, Sh1, &len);
            break;
        default:
            rb_raise(rb_eTypeError, "idx1 must be Array or NArray");
            break;
        }
        F1 = 0;
        L1 = len-1;
        S1 = 1;
    }

    lens[0] = (L0-F0)/S0+1;
    lens[1] = (L1-F1)/S1+1;

    if (factor==Qnil && offset==Qnil){
        na = na_make_object(NA_LINT, 2, lens, cNArray);
        ival = NA_PTR_TYPE(na, int32_t *);
    } else {
        na = na_make_object(NA_SFLOAT, 2, lens, cNArray);
        ival = NULL;         // then it is allocated in the following
        fval = NA_PTR_TYPE(na, float *);
    }

    ival = multibit_read_2D(fp, Pos, Nbit, Sh0, Sh1, F0, L0, S0, F1, L1, S1, 
                     Idx0,Idx1,ival);

    if (factor!=Qnil || offset!=Qnil){
        if (factor!=Qnil) {
            Factor = NUM2DBL(factor);
        } else {
            Factor = 1.0;
        }
        if (offset!=Qnil) {
            Offset = NUM2DBL(offset);
        } else {
            Offset = 0.0;
        }
        for(i=0; i<lens[0]*lens[1]; i++){
            fval[i] = ival[i]*Factor + Offset;
        }
	free(ival);
    }


    return(na);
}


static uint
str_to_uint1(unsigned char *ptr)
{
  uint i0 = ptr[0];
  return i0;
}
static uint
str_to_uint2(unsigned char *ptr)
{
  uint i0 = ptr[0];
  uint i1 = ptr[1];
  return (i0<<8) + i1;
}
static uint
str_to_uint3(unsigned char *ptr)
{
  uint i0 = ptr[0];
  uint i1 = ptr[1];
  uint i2 = ptr[2];
  return (i0<<16) + (i1<<8) + i2;
}
#define STR2UINT(num) \
static VALUE \
rb_str_to_uint##num(int argc, VALUE *argv, VALUE self) \
{ \
  if (argc > 1) { \
    rb_raise(rb_eArgError, "wrong number of arguments (%d for 0)", argc); \
  } \
  unsigned char *ptr = (unsigned char*)StringValuePtr(self);	\
  if (argc == 1) { \
    unsigned long n = FIX2UINT(argv[0]); \
    if (n >= RSTRING_LEN(self)) { \
      rb_raise(rb_eArgError, "out of index"); \
    } \
    ptr += n; \
  } \
  uint i = str_to_uint##num(ptr); \
  return UINT2NUM(i); \
}
STR2UINT(1)
STR2UINT(2)
STR2UINT(3)


void
init_gphys_multibitIO()
{
    VALUE mNumRu;
    VALUE cMultibitIO;

    mNumRu = rb_define_module("NumRu");
    cMultibitIO = rb_define_class_under(mNumRu,"MultibitIO", rb_cObject);
    rb_define_alloc_func(cMultibitIO, multibit_IO_alloc);
    rb_define_private_method(cMultibitIO, "initialize", multibit_IO_initialize, 1);
    rb_define_method(cMultibitIO, "read2D", wrp_multibit_read_2D, 14);
    // rb_define_method(cMultibitIO, "close", multibit_IO_close, 0);
    ///^^ conflicts with the multibit_IO_closer call by GC

    rb_define_method(rb_cString, "to_uint1", rb_str_to_uint1, -1);
    rb_define_method(rb_cString, "to_uint2", rb_str_to_uint2, -1);
    rb_define_method(rb_cString, "to_uint3", rb_str_to_uint3, -1);

}

//-------------------------------

#ifdef MAKETESTDATA

/*-----------------------------------------------------------------
 * Test part : To compile, remove -c option and add -DMAKETESTDATA
 *----------------------------------------------------------------*/
 
static void
create(fp, headskip, nbit, sh0, sh1)
    FILE *fp;
    long headskip;
    long nbit;
    long sh0;
    long sh1;
{
    unsigned int *ival, iv;
    unsigned char * buf, cn;
    long sz, size;
    long len;
    long i, ns, nl, j, ib;
    int w, b;
    unsigned char mk[8] = {0xff,0x7f,0x3f,0x1f,0x0f,0x07,0x03,0x01};
            // bit mask. in binary, 01111111, 00111111, 00011111,..., 00000001
    unsigned int one = 1;

    for(i=0; i<headskip; i++){
        sz = fwrite("-",1,1,fp);   // fill with "-" over headskip bytes
    }

    size = ( (sh0*sh1+1)*nbit -1 ) / 8 + 1;
    buf = (unsigned char *) malloc( size );

    len = sh0*sh1;
    ival = (unsigned int *) malloc(len*sizeof(unsigned int));

    for(i=0; i<len; i++){
        ival[i] = (i%sh0) + i/sh0;
        //printf("%x ",ival[i]);
    }
    //printf("\n");

    for(i=0; i<len; i++){
        ib = i*nbit;
        ns = ib / 8;              // start position  i*nbit/8
        nl = (ib+nbit-1) / 8;     // end position
        w = ib % 8;
        //printf("%d: ",(int)i);
        for(j=0; j<= nl-ns; j++){
            b = w + nbit - (j+1)*8;
            //printf(" (%d)",b);
            if(b>=0){
                cn =  ival[i] / (one<<b);
            } else{
                cn =  ival[i] * (one<<(-b));
            }
            if(j==0){
                buf[ns] = (buf[ns] & ~mk[w]) + cn;
            } else { 
                buf[ns+j] = cn;
            }
            //printf(" %d %x ",(int)(ns+j),buf[ns+j]);
        }
        //printf("\n");
    }

    sz = fwrite(buf,1,size,fp);

    for(j=0; j<size; j++){
        printf("%02x ",buf[j]);
    }
    printf("\n");

    free(buf);
    free(ival);
}

int main()
{
    FILE *fp;
    long headskip = 12;
    long nbit = 15;
    long sh0 = 100;
    long sh1 = 100;
    long pos;
    char fnm[100] = "mltbit.dat";
    long f0=1, l0=91, s0=10, f1=2, l1=5, s1=3;
    long idx0[3] = {3,8,0};
    long idx1[4] = {0,1,90,3};
    int32_t *ival;

    fp = fopen(fnm,"wb");
    create(fp, headskip, nbit, sh0, sh1);
    fclose(fp);

    fp = fopen(fnm,"rb");
    pos = headskip;
    printf("-------------\n");
    ival = multibit_read_2D(fp, pos, nbit, sh0, sh1, f0, l0, s0, f1, l1, s1, 
                            NULL, NULL, NULL);
    printf("-------------\n");
    ival = multibit_read_2D(fp, pos, nbit, sh0, sh1, 0, 3-1, 1, 0, 4-1, 1, 
                            idx0, idx1, NULL);
    fclose(fp);

    return(0);
}

#endif
