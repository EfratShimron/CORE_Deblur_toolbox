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


demo = 'brain_phantom_example'; 

Sampling_type_vec = [1] % 2 3 4];  % here we run 4 different experiments, 
% to reproduce Fig. 2 in the paper (each row in the figure is a different experiment)


% ---- examples with different subsampling schemes, all with a reduction factor of R=6  ----

for j = 1:length(Sampling_type_vec)
   
    if Sampling_type_vec==1; sampling_scheme='periodic';
    elseif Sampling_type_vec==2;  sampling_scheme='variying-period';
    elseif Sampling_type_vec==3;  sampling_scheme='variable-density';
    elseif Sampling_type_vec==4;  sampling_scheme='random';
    end


% ================ preparations: load k-space data & sensitivity maps  ================

D = DataProcess(demo,sampling_scheme);

% display sampling mask 
figure;
imshow(D.KspaceSampPattern_DC_in_center); axis equal; axis tight; axis off;
title_str = [sampling_scheme,' Sampling, R=',num2str(D.R)];
title(title_str,'FontSize',12);  colormap (gray);

% % display gold standard image 
% figure; imagesc(D.GoldStandard4display); title(['Gold Standard']); caxis([D.cmin D.cmax]); axis off; colormap (gray); axis image;

% =======================================================================
%                               step I: CORE 
% Here we compute the convolution image, which will be used in step 2
% as the initial guess for the Compressed Sensing reconstruction.
% =======================================================================

% create convolution kernel (you can replace this with your own kernel!)
sigma = 0.25; % Width of the gaussian kernel. Default is 0.25
D = create_gaussian_kernel(D,sigma);

% compute the convolution image using the CORE technique
D = CORE(D);

% ========= Calc error image & NRMSE ========
err_mat = abs(abs(D.GoldStandard4display)- abs(D.CORE_conv_im4display));
NRMSE = calc_NRMSE(D.GoldStandard4display,D.CORE_conv_im4display);

% ======== display Gold Standard + Rec + Error ======
MAT = [D.GoldStandard4display   ones(D.N,5) D.CORE_conv_im4display ; ones(2,5+2*D.N); ones(D.N,D.N)  ones(D.N,5) err_mat*4];

figure; imagesc(abs(MAT)); axis off; axis image; colormap gray; caxis([0 D.cmax]);
text(10,10,'Gold Standard','Color','w')
text(10+D.N,10,'conv image','Color','w')
text(10+D.N,D.N+2+10,'Error magnified x4','Color','w');
text(10+D.N,2*D.N-10,sprintf('NRMSE=%.5f',NRMSE),'Color','w');


% =======================================================================
%                         step II: Compressed Sensing              
% ========================================================================

NumIters_CORE_Deblur =10; % this is a good choice for many in-vivo datasets subsampled with reduction factor up to R=5
NumIters_CS =100; % this is a good choice for many in-vivo datasets subsampled with reduction factor up to R=5

switch demo 
    case 'In_vivo_example_1'
        NumIters_CORE_Deblur = 11;  
        NumIters_CS = 90;
        th_for_CS = 0.0012;
    case 'In_vivo_example_2'
        NumIters_CORE_Deblur = 6;     
        NumIters_CS = 99;
        th_for_CS = 0.0012;
    case 'brain_phantom_example'
        NumIters_CORE_Deblur = 10;      
        NumIters_CS = 2500; 
        th_for_CS = 5e-5;
end    
            
init_guess_flag = 'CORE_conv_im';
                              
%iters_to_export = [0 NumIters_CORE_Deblur];
disp('CORE_Deblur + compressed sensing..')
C_DEBLUR =  CompSens(D,NumIters_CORE_Deblur,init_guess_flag,th_for_CS);
C_DEBLUR =  CS_IterRec(C_DEBLUR,D);




% =======================================================================
%     method for comparison: Zero-Fill (ZF) initiated Compressed Sensing              
% ========================================================================
% ============= ZERO-FILL-CS   =============
disp('Zero-Fill compressed sensing..')
%iters_to_export = [0 NumIters_CS];
C_ZF =  CompSens(D,NumIters_CS,'ZF',th_for_CS);
C_ZF =  CS_IterRec(C_ZF,D);


% =======================================================================
%                             figures
% =======================================================================

CS_ZF_err = C_ZF.final_rec4display - D.GoldStandard4display;
CORE_Deblur_err = C_DEBLUR.final_rec4display - D.GoldStandard4display;

C_DEBLUR_final_NRMSE = [sprintf('%.4f',C_DEBLUR.NRMSE_per_iter(end))];
CS_ZF_final_NRMSE = [sprintf('%.4f',C_ZF.NRMSE_per_iter(end))];

% -------- plots -------------

SPACE = ones(D.N,1)*D.cmax;
% MAT = [D.GoldStandard4display  SPACE  C_ZF.init_guess4display SPACE  C_DEBLUR.init_guess4display;  ones(1,D.N*3+2)*D.cmax;...
%     ones(D.N,D.N)*D.cmax  SPACE   C_ZF.final_rec4display   SPACE   C_DEBLUR.final_rec4display;  ones(1,D.N*3+2)*D.cmax;...
%     ones(D.N,D.N)*D.cmax  SPACE  CS_ZF_err*100    SPACE  CORE_Deblur_err*100];
figure; imagesc(abs(MAT)); colormap gray; axis off; caxis([D.cmin D.cmax]); axis image;
% hold on;
% text(D.N+5,2*D.N-14,[num2str(NumIters_CS),' iters'],'Color','w') %,'FontSize',12);
% hold on;
% text(2*D.N+6,2*D.N-14,[num2str(NumIters_CORE_Deblur),' iters'],'Color','w') %,'FontSize',12);
% hold on;
% text(D.N+5,3*D.N-14,num2str(CS_ZF_final_NRMSE),'Color','w') %,'FontSize',12);
% hold on;
% text(2*D.N+6,3*D.N-14,C_DEBLUR_final_NRMSE,'Color','w') %,'FontSize',12);
% title(['    Gold standard (left)     ;     CS (middle)       ;      CORE-Deblur (right)      '])

SPACE = ones(D.N,1)*D.cmax;
MAT = [D.KspaceSampPattern_DC_in_center  SPACE  C_ZF.final_rec4display  SPACE   C_DEBLUR.final_rec4display SPACE  CS_ZF_err*5    SPACE  CORE_Deblur_err*5];
figure; imagesc(abs(MAT)); colormap gray; axis off; caxis([D.cmin D.cmax]); axis image;
hold on;
text(3*D.N+5,D.N-14,num2str(CS_ZF_final_NRMSE),'Color','w') %,'FontSize',12);
hold on;
text(4*D.N+6,D.N-14,C_DEBLUR_final_NRMSE,'Color','w') %,'FontSize',12);


% here we concatenate the results of different experiments in order to
% display them together later (this reproduces Fig. 2 from the paper)
if j==1
    MAT_all_examples = [];
end

MAT_all_examples = [MAT_all_examples; MAT];


end % for j

figure; imagesc(abs(MAT_all_examples)); colormap gray; axis off; caxis([D.cmin D.cmax]); axis image;
title('sampling patter; ZF-CS rec;  CORE-Deblur rec; ZF-CS err x5; CORE-Deblur errx5')
