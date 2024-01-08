function [norm_fluo_thickline, arclength_line_um] = normalise_fluo_thickline(fluo_thickline, arclength_line, px2mum)
%normalise_fluo_thickline normalise each fluorescence profile so it has area 1


arclength_line_um = arclength_line .* px2mum;
norm_fluo_thickline = fluo_thickline ./ repmat(trapz(arclength_line_um,fluo_thickline,2), 1, size(fluo_thickline, 2));


end

