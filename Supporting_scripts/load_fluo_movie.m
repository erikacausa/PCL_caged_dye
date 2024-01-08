function [ fluo_fs, fluo_rts, bg_fluo, fluo_spot, fluo_lastframe ] = load_fluo_movie( fluo_fullname )
%load_fluo_movie Loads the fluorescence movie, splits it in pre-peak and
%post-peak.
% fluo_fs, fluo_rts start when the fluorescence signal is at its maximum,
% bg_fluo is the average of the fluorescence signal up until 5 frames
% before the fluorescence maximum (not robust, but ok with a single short laser
% pulse)



%% load fluo video

fluo_mo = moviereader(fluo_fullname);
fprintf('Reading fluo movie... ');
[fluo_fs, fluo_ts] = fluo_mo.read;
fprintf('Done!\n');


%% plot the average intensity to chop the video to the excitation pulse

% calculate spatial average fluorescence intensity
fluo_int = sum(sum(fluo_fs,1), 2) ./ (size(fluo_fs,1) * size(fluo_fs,2));
fluo_int = fluo_int(:);

% find frame of max pulse
[~, pk_fr] = max(fluo_int);

% usually the spot frame with maximum intensity is the second after the
% activation so the one before the max int one should be the activation one
fluo_spot = fluo_fs(:,:,pk_fr-1);

fluo_lastframe = fluo_fs(:,:,pk_fr-1 + 50);

% save the video pre-pulse
fluo_bgfs = fluo_fs(:,:,1:pk_fr-5);
% fluo_bgts = fluo_ts(1:pk_fr-5);
% fluo_bgint = fluo_int(1:pk_fr-5);


% average video pre-pulse
bg_fluo = mean(fluo_bgfs,3);


% chop the fluo video from max pulse onwards
fluo_fs(:,:,1:pk_fr) = [];
fluo_ts(1:pk_fr) = [];

fps = 1 / (fluo_ts(2)-fluo_ts(1));
fluo_rts = fluo_ts - fluo_ts(1) + 2 * 1/fps; %timestamp relative to pulse max


end

