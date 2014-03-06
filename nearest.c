//------------------------------------------------------------------------
// file: nearest.c - Find nearest points according to euclidian distance
//      [I,D,DD] = nearest(A,B)
// INPUTS:
// A - mxd matrix (m=number of points, d=number of dimensions)
// B - kxd matrix (k=number of points, d=number of dimensions)
// OUTPUTS:
// I - mx1 vector of matching points in B
// D - mx1 vector of distances
// D - mxk matrix of all-to-all euclidian distances
//------------------------------------------------------------------------
#include <math.h>
#include "mex.h"

//--------------------------------------------------------------
// function: mexFunction - Entry point from Matlab environment
// INPUTS:
// nlhs - number of left hand side arguments (outputs)
// plhs[] - pointer to table where created matrix pointers are
// to be placed
// nrhs - number of right hand side arguments (inputs)
// prhs[] - pointer to table of input matrices
//--------------------------------------------------------------
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray
*prhs[] )
{
  int M,N,K; // Sizes
  int m,n,k; // Loop variables
  double *pA, *pB, *pI, *pD, *pDD;
  

  if (nrhs < 2)
    mexErrMsgTxt("Not enough input arguments.");
  if (nrhs > 2)
    mexErrMsgTxt("Too many input arguments.");
  if (!mxIsDouble(prhs[0]) || !mxIsDouble(prhs[1]))
    mexErrMsgTxt("Arguments must be type double.");
  if (mxGetN(prhs[0]) != mxGetN(prhs[1]))
    mexErrMsgTxt("matrix dimensions (number of columns) must agree.");
  if (mxIsComplex(prhs[0]) || mxIsComplex(prhs[1]))
    mexWarnMsgTxt("Complex parts ignored.");

  // edist(MxK,NxK) => MxN
  M = mxGetM(prhs[0]); // Number of rows in input A
  N = mxGetM(prhs[1]); // Number of rows in input B
  K = mxGetN(prhs[0]); // Number of dimensions (columns of A)

 
  plhs[0] = mxCreateDoubleMatrix(M,1,mxREAL);
  pI = mxGetPr(plhs[0]);  
  plhs[1] = mxCreateDoubleMatrix(M,1,mxREAL);
  pD = mxGetPr(plhs[1]);

  if (nlhs >2)
  {
      plhs[2] = mxCreateDoubleMatrix(M,N,mxREAL);
      pDD = mxGetPr(plhs[2]);
  }  
      
  // Now the distance computation
  pA = mxGetPr(prhs[0]);
  pB = mxGetPr(prhs[1]);
  for (m=0; m<M; m++)
  { 
    for (n=0; n<N; n++)
    {
      double sum = 0.0, diff;
      for (k=0; k<K; k++)
      {
        diff = pA[m+M*k] - pB[n+N*k];
        sum += diff*diff;
      }
      sum = sqrt(sum) ;
      if (nlhs > 2)
          pDD[m+M*n] = sum ;
      if (n==0 || (sum < pD[m]))
      { 
          pD[m]=sum;
          pI[m]=n+1; // Matab indexing
      }
    }
  }

} // end mexFunction()
