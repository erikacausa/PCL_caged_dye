function [fluo_thickline] = calculate_fluo_along_line(fluo_fs, bg_fluo, arclength_map, arclength_counts, thickline_mask) 
%calculate_fluo_along_line uses accumarray on the arclength_map mask to
%find fluorescence profile along line


% initialise
fluo_thickline = zeros(size(fluo_fs,3),max(arclength_map(:)));
% fluo_thickline = zeros(size(fluo_fs,3),numel(unique(arclength_map(~isnan(arclength_map)))));

for fc = 1:size(fluo_fs,3)
    
    % extract frame
    frame = fluo_fs(:,:,fc);
    
    % accumarray dummy profile, this has many nans in it
    dummy_fluoprofile = accumarray(arclength_map(thickline_mask), frame(thickline_mask),[],[],NaN) ./ arclength_counts;
    
    % store in matrix
    fluo_thickline(fc,:) = dummy_fluoprofile(~isnan(dummy_fluoprofile));
    
end %for


% background along thickline
bg_thickline = accumarray(arclength_map(thickline_mask), bg_fluo(thickline_mask),[],[],NaN) ./ arclength_counts;
bg_thickline = bg_thickline(~isnan(bg_thickline));

% remove background
fluo_thickline = fluo_thickline - repmat(bg_thickline',size(fluo_fs,3),1);

end

