function [ arclength_map, arclength_counts ] = create_arclength_map( x_line, y_line, thickline_mask )
%create_arclength_map finds the closest point on the eaasuring line for
%each of the points in the thickened mask (so we can average the
%contribution of the pixels that correspond to the same "bin" on the
%measuring line)


% create new t_line now, asimply as an index along **_r
t_line = cumsum(ones(size(x_line)));

% find couples of pixels in the thickened line
[y_tm, x_tm] = find(thickline_mask);

% now find to which point along the line they are closest
idx = knnsearch([x_line(:),y_line(:)],[x_tm(:),y_tm(:)]);


% closest t_line for each tm point
tt_tm = t_line(idx);



% so now I have sum(thick_mask(:)) points, with coordinates x_tm, y_tm,
% each of them knowing which point along the line they're closest to
% (tt_tm), and at what arclength (in pixels) that corresponds (ll_tm). I can use
% this with the fluorescence video, as a "distance_map" to then do an
% Intensity_vs_arclength plot
arclength_map = nan(size(thickline_mask));
arclength_map(sub2ind(size(arclength_map),y_tm,x_tm)) = tt_tm; % at each x_tm,y_tm write the closest point along the line (tt_tm)

% how many points are closest to each of the line points (tt_tm). This is
% equivalent to say: arclength_counts(i) = sum(tt_tm == i)
arclength_counts = accumarray(tt_tm,ones(size(tt_tm(:))),[],[],NaN); %the non-nans are numel(unique(tt_tm)), or equivalently



end
