/*--------------------------------------------------------------
// file: edist.c - compute euclidian distance matrix
// D = edist(A,B)
// INPUTS:
// A - mxd matrix (m=number of points, d=number of dimensions)
// B - kxd matrix (k=number of points, d=number of dimensions)
// OUTPUTS:
// D - mxk matrix of euclidian distances
//--------------------------------------------------------------*/
#include <math.h>
#include "mex.h"

/*--------------------------------------------------------------
// function: mexFunction - Entry point from Matlab environment
// INPUTS:
// nlhs - number of left hand side arguments (outputs)
// plhs[] - pointer to table where created matrix pointers are
// to be placed
// nrhs - number of right hand side arguments (inputs)
// prhs[] - pointer to table of input matrices
//--------------------------------------------------------------*/
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray
*prhs[] )
{
  int M,N,K; /* Sizes */
  int m,n,k; /* Loop variables */
  double *pA, *pB, *pD;

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

  /* edist(MxK,NxK) => MxN */
  M = mxGetM(prhs[0]); /* Number of rows in output */
  N = mxGetM(prhs[1]); /* Number of columns in output */
  K = mxGetN(prhs[0]); /* Number of dimensions */

  plhs[0] = mxCreateDoubleMatrix(M,N,mxREAL);

  pA = mxGetPr(prhs[0]);
  pB = mxGetPr(prhs[1]);
  pD = mxGetPr(plhs[0]);

  /* Now the distance computation */
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
      pD[m+M*n] = sqrt(sum);
    }
  }

} /* end mexFunction() */
