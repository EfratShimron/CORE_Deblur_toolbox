clear all;
close all;
restoredefaultpath % clear all existing paths 
addpath(genpath(pwd))

% This Matlab toolbox includes an implementation of the CORE-PI reconstruction 
% method that was published in:
%     Shimron, Webb, Azhari, "CORE-Deblur: Parallel MRI Reconstruction by
%     Deblurring Using Compressed Sensing"
% To be published in the MRI journal (2020).
% When publishing results that are based on this toolbox, please kindly cite this paper.

% CORE-Deblur is a general reconstrution method that involves Parallel
% Imaging (PI) and Compressed Sensing (CS).
% CORE-Deblur is suitable for image reconstruction from multi-coil 
% 2D Cartesian k-space data. 

% The code package contains exmaples with two datasets: 
% (1) In-vivo 7t brain imaging data.
% (2) Data of a Realistic Analytical Brain Phantom, reproduced with
% permission from the authors of this paper:
%     Guerquin-Kern, Matthieu, et al. "Realistic analytical phantoms for parallel 
%     magnetic resonance imaging." IEEE Transactions on Medical Imaging 31.3
%     (2011): 626-636.
% If you use the brain phantom data in your code, please cite its publication. 


% (c) E. Shimron, H. Azhari, 2020


% ====================================================
%      CHOOSE ONE EXAMPLE FROM THE FOLLOWING LIST 
% ====================================================
% ---- examples with different subsampling schemes, all with a reduction factor of R=6  ----
%demo = 'brain_phantom_example';  sampling_scheme='periodic';          
%demo = 'brain_phantom_example';  sampling_scheme='variying-period';   
%demo = 'brain_phantom_example';  sampling_scheme='variable-density';  
%demo = 'brain_phantom_example';  sampling_scheme='random';            

