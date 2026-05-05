# MAE 2030
[![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=dsavransky/MAE2030)

MATLAB functions and scripts and Jupyter Python notebooks for sophomore dynamics class (Cornell MAE 2030, Princeton MAE 206). Based on Engineering Dynamics by Kasdin &amp; Paley (2011).

These programs are intended to demonstrate various aspects of dynamics and numerical integration and animation of dynamical systems with MATLAB. The examples are largely based on the textbook Engineering Dynamics by Kasdin  &amp; Paley and serve as supplementary materials to the text and associated lectures.

Comments, questions, and additions are very welcome. If you are an instructor using these materials for your course, I'd love to hear from you.  Please email ds264@cornell.edu. 

Many thanks to the various Cornell MAE 2030 cohorts who have helped find and fix numerous errors and typos throughout the codebase. Your bonus points should post shortly. 

## MATLAB 

MATLAB code was tested (to varying degrees) in R2016b - R2025b, but should work in any version after R2014b. Some plot commands may not work in earlier releases, other functionality should work in any release after 2009a. Some functionality associated with 3D plotting and GUIDE-based GUIs has now been deprecated, impacting the functionality of a few of the GUIs in later chapters.  Help in porting these to App Designer (or figure-based) GUIs would be appreciated.

The subdirectory Shared contains common resources used in multiple functions and should be added to the MATLAB path.

The codes are split into chapter directories that (somewhat roughly) match the contents of the textbook chapters.

## Python 

Static views of the Jupyter Notebooks can be viewed directly in GitHub: https://github.com/dsavransky/MAE2030/tree/main/Notebooks

If you wish to execute these notebooks, you will need Python >= 3.11 and Jupyter (see https://jupyter.org/install).  You will also need the `sympy` and `sympyhelpers` packages.  You can install both by running:

```
pip install sympyhelpers
```

For more information, see: https://sympyhelpers.readthedocs.io/en/latest/
