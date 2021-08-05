#include "config.h"
#ifdef HAVE_COMPLEX_H
#include <complex.h>
#endif
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "fftw3.h"
#include "dgt.h"
#include "tfutil.h"
#include "ltfat_time.h"


/*  This routine computes the DGT factorization using strided FFTs so
    the memory layout is optimized for the matrix product. */

void dgt_fac(ltfat_complex *f, ltfat_complex *gf, const int L, const int W,
	     const int R, const int a, const int M, ltfat_complex *cout, int dotime)
{

   /*  --------- initial declarations -------------- */

   int b, N, c, d, p, q, h_a, h_m;
   
   ltfat_complex *gbase, *fbase, *cbase;

   int l, k, r, s, u, w, rw, nm, mm, km;
   int ld1, ld2, ld3;
   int rem;

   fftw_plan p_before, p_after, p_veryend;
   ltfat_complex *ff, *cf;

   double scalconst;
   
   double st0, st1, st2, st3, st4, st5, st6, st7;

   /*  ----------- calculation of parameters and plans -------- */
   
   if (dotime)
   {
      st0=ltfat_time();
   }

   b=L/M;
   N=L/a;
   
   c=gcd(a, M,&h_a, &h_m);
   p=a/c;
   q=M/c;
   d=b/p;

   h_a=-h_a;

   /* Scaling constant needed because of FFTWs normalization. */
   scalconst=1.0/((double)d*sqrt((double)M));

   /*printf("%i %i %i %i %i\n",c,d,p,q,W);*/

   ff = (ltfat_complex*)ltfat_malloc(L*W*sizeof(ltfat_complex));
   cf = (ltfat_complex*)ltfat_malloc(c*d*q*q*W*R*sizeof(ltfat_complex));

   /* Create plans. In-place. */
   
   p_before = fftw_plan_many_dft(1, &d, c*p*q*W,
				 ff, NULL,
				 c*p*q*W, 1,
				 ff, NULL,
				 c*p*q*W, 1,
				 FFTW_FORWARD, FFTW_OPTITYPE);


   p_after = fftw_plan_many_dft(1, &d, c*q*q*W*R,
				cf, NULL,
				c*q*q*W*R, 1,
				cf, NULL,
				c*q*q*W*R, 1,
				FFTW_BACKWARD, FFTW_OPTITYPE);
   
  /* Create plan. In-place. */
   p_veryend = fftw_plan_many_dft(1, &M, N*R*W,
				  cout, NULL,
				  1, M,
				  cout, NULL,
				  1, M,
				  FFTW_FORWARD, FFTW_OPTITYPE);
      

   if (dotime)
   {
      st1=ltfat_time();
      printf("DGT_FAC_1: Planning phase %f\n",st1-st0);
   }


   /*  ---------- compute signal factorization ----------- */

   /* Leading dimensions of the 4dim array. */
   ld2=p*q*W;
   ld3=c*p*q*W;

   for (s=0;s<d;s++)
   {
      for (r=0;r<c;r++)
      {		  
	 for (w=0;w<W;w++)
	 {
	    for (l=0;l<q;l++)
	    {
	       for (k=0;k<p;k++)
	       {	       	       
		  rem = positiverem(k*M+s*p*M-l*h_a*a, L);
#ifdef HAVE_COMPLEX_H
		  ff[k+(l+q*w)*p+r*ld2+s*ld3]=f[r+rem+L*w]*scalconst;
#else
		  ff[k+(l+q*w)*p+r*ld2+s*ld3][0]=f[r+rem+L*w][0]*scalconst;
		  ff[k+(l+q*w)*p+r*ld2+s*ld3][1]=f[r+rem+L*w][1]*scalconst;
#endif
	       }
	    }
	 }
      }
   }           

   if (dotime)
   {
      st2=ltfat_time();
      printf("DGT_FAC_1: First permutation %f\n",st2-st1);
   }


   
   /* Do fft to complete signal factorization.*/
   fftw_execute(p_before);

   if (dotime)
   {
      st3=ltfat_time();
      printf("DGT_FAC_1: First FFT %f\n",st3-st2);
   }


   /* ----------- compute matrix multiplication ----------- */


   /* Do the matmul  */
   for (r=0;r<c;r++)
   {
      for (s=0;s<d;s++)
      {	
	 gbase=gf+(r+s*c)*p*q*R;
	 fbase=ff+(r+s*c)*p*q*W;
	 cbase=cf+(r+s*c)*q*q*W*R;

	 for (nm=0;nm<q*W;nm++)
	 {
	    for (mm=0;mm<q*R;mm++)
	    {
#ifdef HAVE_COMPLEX_H
	       cbase[mm+nm*q*R]=0.0;
	       for (km=0;km<p;km++)
	       {
		 cbase[mm+nm*q*R]+=conj(gbase[km+mm*p])*fbase[km+nm*p];
	       }
#else
	       cbase[mm+nm*q*R][0]=0.0;
	       cbase[mm+nm*q*R][1]=0.0;
	       for (km=0;km<p;km++)
	       {
		  cbase[mm+nm*q*R][0]+=gbase[km+mm*p][0]*fbase[km+nm*p][0]+gbase[km+mm*p][1]*fbase[km+nm*p][1];
		  cbase[mm+nm*q*R][1]+=gbase[km+mm*p][0]*fbase[km+nm*p][1]-gbase[km+mm*p][1]*fbase[km+nm*p][0];
	       }
#endif
	    }		  
	 }	      	 
      }
   }

   if (dotime)
   {
      st4=ltfat_time();
      printf("DGT_FAC_1: Matrix multiplication %f\n",st4-st3);
   }


   /*  -------  compute inverse coefficient factorization ------- */

   /* Do inverse fft of length d */
   fftw_execute(p_after);

   if (dotime)
   {
      st5=ltfat_time();
      printf("DGT_FAC_1: Second FFT: IFFT %f\n",st5-st4);
   }
   

   /* Leading dimensions of cf */
   ld1=q*R;
   ld2=q*R*q*W;
   ld3=c*q*R*q*W;
         
   /* Complete inverse fac of coefficients */
   for (rw=0;rw<R;rw++)
   {
      for (w=0;w<W;w++)
      {
	 for (s=0;s<d;s++)
	 {
	    for (u=0;u<q;u++)
	    {	       
	       for (l=0;l<q;l++)
	       {
		  rem= positiverem(u+s*q-l*h_a,N)*M;
		  for (r=0;r<c;r++)
		  {	
#ifdef HAVE_COMPLEX_H	  
		     cout[r+l*c+rem*M+rw*M*N+w*M*N*R]=cf[u+rw*q+(l+q*w)*ld1+r*ld2+s*ld3];
#else
		     cout[r+l*c+rem+rw*M*N+w*M*N*R][0]=cf[u+rw*q+(l+q*w)*ld1+r*ld2+s*ld3][0];
		     cout[r+l*c+rem+rw*M*N+w*M*N*R][1]=cf[u+rw*q+(l+q*w)*ld1+r*ld2+s*ld3][1];
#endif
		  }
	       }
	    }
	 }
      }      
   }     

   if (dotime)
   {
      st6=ltfat_time();
      printf("DGT_FAC_1: Second permutation %f\n",st6-st5);
   }

   /* FFT to modulate the coefficients. */
   fftw_execute(p_veryend);   

   if (dotime)
   {
      st7=ltfat_time();
      printf("DGT_FAC_1: Final FFT %f\n",st7-st6);
      printf("DGT_FAC_1: Total time %f\n",st7-st0);
   }

    /* -----------  Clean up ----------------- */   
   fftw_destroy_plan(p_before);
   fftw_destroy_plan(p_after);
   fftw_destroy_plan(p_veryend);

   ltfat_free(ff);
   ltfat_free(cf);
   
}
