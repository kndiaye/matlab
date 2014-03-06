//--------------------------------------------------------------
// file: tvalue.c - T-value(s) between two samples
//                   
// [T] = tvalue(A,B)
// INPUTS:
// A - MxK matrix (M=number of observations in the 1st sample, K=number of measures)
// B - NxK matrix (N=number of observations in the 2nd sample, K=number of measures)
// OUTPUTS:
// T - 1xK vector of T-values
//--------------------------------------------------------------
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

// Compile trough: 
// mex -v -g tvalue.c

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray
*prhs[] )
{
    int K; // Sizes
    int k;
    double *A, *B;
    int nA, nB;
    double *T; // Output: T-values
    
    if (nrhs < 1)
        mexErrMsgTxt("Not enough input arguments.");
    if (nrhs > 2)
        mexErrMsgTxt("Too many input arguments.");
    if (!mxIsDouble(prhs[0]) || ((nrhs > 1) && (!mxIsDouble(prhs[1]))))
        mexErrMsgTxt("Arguments must be type double.");
    K = mxGetN(prhs[0]); // Number of dimensions
    if (nrhs > 1)
        if (K != mxGetN(prhs[1]))
            mexErrMsgTxt("Matrix dimensions (number of columns) must agree.");
    if (mxIsComplex(prhs[0]) || ((nrhs > 1) && (mxIsComplex(prhs[1]))))
        mexWarnMsgTxt("Complex parts ignored.");
    
    // edist(MxK,NxK) => MxN
    A = mxGetPr(prhs[0]);
    nA = mxGetM(prhs[0]); // Number of rows in A
    
    if (nrhs > 1) {
        nB = mxGetM(prhs[1]); // Number of rows in B
        B = mxGetPr(prhs[1]);
    }

    K = mxGetN(prhs[0]); // Number of columns in output
    
    plhs[0] = mxCreateDoubleMatrix(1,K,mxREAL);
        
    // Outputs:
    T = mxGetPr(plhs[0]);    
    
    // Now the t-value computation
    for (k=0; k<K; k++)
    {
        double mA=0.0, mB=0.0, vA=0.0, vB=0.0;        
        int i;
        
        for (i=0; i<nA; i++)
            mA += A[i+k*nA];
        mA=mA/nA;
        
        for (i=0; i<nA; i++)
            vA += (A[i+k*nA]-mA)*(A[i+k*nA]-mA);
        vA=vA/(nA-1);
        
        if (nrhs > 1) {            
            for (i=0; i<nB; i++)
                mB += B[i+k*nB];
            mB=mB/nB;            
            for (i=0; i<nB; i++)
                vB += (B[i+k*nB]-mB)*(B[i+k*nB]-mB);
            vB=vB/(nB-1);
            }
        
        T[k]=(mA-mB)/sqrt(vA/nA + vB/nB);
                
    }  
    
} // end mexFunction()
