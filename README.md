
-----------------------------------------------------------------------------------
# A Matlab toolbox for CORE-Deblur
#### Paper: [CORE-Deblur: Parallel MRI Reconstruction by Deblurring Using Compressed Sensing"](https://arxiv.org/abs/2004.01147)
----------------------------------------------------------------------------------

CORE-Deblur is a Parallel Imaging + Compressed Sensing (PI+CS) method. **CORE-Deblur enables reducing the number of Compressed Sensing iterations by a factor of 10.**



This toolbox contains Matlab code that implements the CORE-Deblur algorith that is described in the paper. The toolbox includes examples with simulated phantom data and and in-vivo 7T brain data.


## Getting Started
Clone or download the repository.

To see the demos run one of thes following Matlab scripts:

1. [**demo1_in_vivo**](demo1_in_vivo.m) - this code includes two examples with in-vivo 32-coils 7T brain data and subsampling with a reduction factor of R=4. It will reproduce the results from Figures 3 and 4 in the paper, e.g.

<img src="README_figures/demo1_iters.jpg" width=1000 align=left>

<br />
<br />
<br />
<br />
<br />
<br />
<br />


2. [**demo2_brain_phantom**](demo2_brain_phantom.m) - this code includes four examples with simulated brain phantom data and subsampling with a reduction factor of R=10. It will  reproduce the results from this figure (Fig. 2 in the paper):

<img src="README_figures/brain_phantom_fig.jpg" width=1000 align=left>.



## Acknowledgments
The in-vivo data is courtesy of Prof. Andrew G. Webb from Leiden University Medical Center (LUMC).

The Realistic Analytical Brain Phantom data was utilized here with permission from
the authors of:
    Guerquin-Kern, Matthieu, et al. "Realistic analytical phantoms for parallel
    magnetic resonance imaging." IEEE Transactions on Medical Imaging 31.3
    (2011): 626-636.
If you use that data in your publications, please cite this paper.

## Prerequisites
A liscence for Matlab is required. The code was tested with Matlab2017R.
