function im_denoised = wavelet_soft_th(im,th) 
            % This code is based on the Matlab toolbox of the following
            % paper:
            % Kayvanrad, Mohammad H., et al. "Stationary wavelet transform 
            % for under-sampled MRI reconstruction." Magnetic resonance imaging 32.10 (2014): 1353-1364.?
            
            waveletfunc='db2';
            declevel=2;
            sorh='s'; % soft or hard threshold
            rrec=real(im); % real part
            irec=imag(im); % imaginary part
            
            %% ============ wavelet thresholding of the real component============
            
            rthresh = th*ones(3,declevel);
            
            % SWT decompositon
            [swa,swh,swv,swd] = swt2(rrec,declevel,waveletfunc);
            
           % ------------ threshold ------------------
            % Threshold SWT coefficients
            dswh=swh;
            dswv=swv;
            dswd=swd;
            
            % thresholding
            for j=1:declevel
                dswh(:,:,j) = wthresh(swh(:,:,j),sorh,rthresh(1,j));
                dswv(:,:,j) = wthresh(swv(:,:,j),sorh,rthresh(2,j));
                dswd(:,:,j) = wthresh(swd(:,:,j),sorh,rthresh(3,j));
            end
                        
            % SWT reconstruction of the thresholded coefficients
            rrec_after_th = iswt2(swa,dswh,dswv,dswd,waveletfunc);                        
            
            %% ============ wavelet thresholding of the imaginary component ============
            % calculate the thresholds using Birge-Massart strategy for the
            % imaginary component
            % [c,s]=wavedec2(irec,declevel,waveletfunc); %transferring to wavelet domain
            % MM=1*prod(s(1,:));
            % [ithresh,nkeep] = wdcbm2(c,s,alpha,MM);
            
            % SWT decompositon
            [swa,swh,swv,swd] = swt2(irec,declevel,waveletfunc);
            
            % Threshold SWT coefficients
            dswh=swh;
            dswv=swv;
            dswd=swd;
            
            for j=1:declevel
                dswh(:,:,j) = wthresh(swh(:,:,j),sorh,rthresh(1,j));
                dswv(:,:,j) = wthresh(swv(:,:,j),sorh,rthresh(2,j));
                dswd(:,:,j) = wthresh(swd(:,:,j),sorh,rthresh(3,j));
            end
            
            % SWT reconstruction of the thresholded coefficients
            irec_after_th = iswt2(swa,dswh,dswv,dswd,waveletfunc);
                        
            %% combine wavelet thresholded real and imaginary components
            im_denoised = rrec_after_th+1i*irec_after_th;            
            
        end