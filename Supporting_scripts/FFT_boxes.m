function [Freq , maxi] = FFT_boxes(bf_fs, box_size, window, bf_Nframes, x_beam, y_beam, fps)
    
    % cut square in the video
    
    bf_fs_cut = bf_fs(y_beam-box_size:y_beam+box_size,x_beam-box_size:x_beam+box_size,:);
    
    % remove offset
    
    fs_no_offset = bf_fs_cut- mean(bf_fs_cut,3);
    
    %% Calculate FFT 

    gk = zeros(size(bf_fs_cut,1), size(bf_fs_cut,2),floor(size(bf_fs_cut,3)/2));


    % take autocorrelation over time   
    for i = 1 : size(bf_fs_cut,1)

        idk = reshape(fs_no_offset(i,:,:),size(bf_fs_cut,2),size(bf_fs_cut,3))'; 

        gk(i,:,:) = (AutoCorr(idk,floor(size(bf_fs_cut,3)/2)))';
    end


    for i = 1 : size(gk,1)
        for j = 1 : size(gk,2)

        [pxx, frequencies] = periodogram((squeeze(gk(i,j,:)))',window,floor(bf_Nframes/2),fps);

        amplitude(i,j,:) = pxx;
        end
    end
    
    %% Find peaks in the frequency spectra


    % find freq spectra peaks
    [maxi,I] = max(amplitude,[],3); % maxi gives the amplitude of the peaks, I the positions along f

    % Calculate frequency map (the frequency is the position of the peak for
    % every pixel)

    Freq = zeros(size(I,1), size(I,2));

    for i = 1 : size(I,1)

        for j = 1 : size(I,2)

                Freq(i,j) = frequencies(I(i,j));
        end
    end

end
