classdef CompSens  % Compressed Sensing 
    
    
    properties
        init_guess_flag
        num_itrs
        th_for_CS
        init_guess
        init_guess4display
        NRMSE_per_iter
        final_rec4display
        rec
    end % properties
    
    
    methods
        %% ========================= DEFINITION ==============================
        function C =  CompSens(D,num_itrs,init_guess_flag,th_for_CS) %,iters_to_export)
              
            C.init_guess_flag = init_guess_flag;
            C.num_itrs = num_itrs;
            C.th_for_CS = th_for_CS;
            %% ================ prep init guess =================
            
            % ------ prepare initial guess --------
            switch init_guess_flag
                    
                case 'ZF'
                    init_guess=zeros(D.N,D.N);
                    snt = D.SenseMaps; % sensitivity masks
                    for ncoil=1:D.NC
                        kspace_ncoil = squeeze(D.KspaceSampled(ncoil,:,:));
                        im_ncoil = ifft2(kspace_ncoil);
                        init_guess = init_guess + im_ncoil./squeeze(snt(ncoil,:,:)).*squeeze(D.w_Roemer(ncoil,:,:));
                        %SampledImages(:,:,ncoil)=im_ncoil;
                    end
%                     sos_ZF_kspace = sos(SampledImages);
%                     if D.extra_fftshift_flag==1% added in CSprocess18
%                         sos_ZF_kspace = fftshift(sos_ZF_kspace,2);
%                     end
                 


                case 'CORE_conv_im'
                    init_guess = D.CORE_conv_im;
           end
            
            
%             % -------- save results --------
             C.init_guess = init_guess;
             
             C.init_guess4display = prep4display(init_guess,D.extra_fftshift_flag,D.rotangle,D.mask4display);
 

        end % function C =  CSprocess4
        
        
        %% ========================= CS_IterRec ==============================
        function C = CS_IterRec(C,D)  % Compressed Sensing with the Stationary Wavelet Transform,
          
            waveletfunc='db2';
            %th_num = length(C.th_for_CS);

            
            %% =============== CS iterations: iterative SWT thresholding ================
            
            spatiald = zeros(D.NC,D.N,D.N);
            
            % ------ initialize quality vectors without init guess ------
            C.NRMSE_per_iter  = zeros(1,C.num_itrs);
            
            % --------------- CS LOOPS ----------------
            
            
            for iter=1:C.num_itrs
                if iter==1
                    rec = C.init_guess;
                    
                     figure; imagesc(abs(rec)); colormap gray; caxis([0 0.8])
                       title(['Init guess '])
                    
                end
                if mod(iter,10)==0
                    disp(['iter=',num2str(iter)])
                end
                
                
                %%  sparsity constraint, i.e., wavelet thresholding- enforced on the combined coil data
                rec = wavelet_soft_th(rec,C.th_for_CS) ;
                rec(isnan(rec)==1) = 0; % eliminate NaN values
                
                %% data consitency- enforced on individual channel data
                for ncoil=1:D.NC
                    % multiply combined-ncoilannels image by coil sensitivities
                    sense_map_ncoil = squeeze(D.SenseMaps(ncoil,:,:));
                    kspace_ncoil = fft2(rec.*sense_map_ncoil);
                    
                    sampled_kspace_ncoil = squeeze(D.KspaceSampled(ncoil,:,:));
                    
                    kspace_ncoil_w_samples = kspace_ncoil - D.sampling_mask.*kspace_ncoil + D.sampling_mask.*sampled_kspace_ncoil;
                    
                    spatiald(ncoil,:,:) = ifft2(kspace_ncoil_w_samples);
                   
                end % for ncoil
                
                %% combine data from all coils using Roemer's method
                rec=zeros(D.N,D.N);
                for ncoil=1:D.NC
                    rec=rec+squeeze(spatiald(ncoil,:,:))./squeeze(D.SenseMaps(ncoil,:,:)).*squeeze(D.w_Roemer(ncoil,:,:));
                    % In the Brain Phantom the sensitivity maps are synthetic,
                    % so they are sometimes zeros. In this case, Nan values 
                    % are created in the last calculation.
                    % Here we eliminate NaN values:
                    rec_vec = rec(:);
                    inds = find(isnan(abs(rec_vec))==1);
                    rec_vec(inds) = 0;
                    rec = reshape(rec_vec,D.N,D.N);
                end

                
                % =============== shift & mask =================
                rec4display = prep4display(rec,D.extra_fftshift_flag,D.rotangle,D.mask4display);

                    
                %------ calc magnitue error  -------  
                C.NRMSE_per_iter(iter) = calc_NRMSE(D.GoldStandard4display,rec4display); 
                        
                
                
            end % for iter
            
            C.final_rec4display = rec4display;
            C.rec = rec; %

        end % CS_IterRec
               
        
    
      end % methods
  
    
end % classdef

