function [FitStruct] = fit_fluo_thickline(norm_fluo_thickline, arclength_line_um, fluo_framerate )
%fit_fluo_thickline fits the fluo profile along the measuring line with a
%gaussian


% define fitting function
ft = fittype( @(A,arclength_fluo_max_um, sigma, offset, ll) A.*exp(-0.5*((ll-arclength_fluo_max_um)./sigma).^2) + offset,...
    'Independent','ll');

% set upfitting options
fo = fitoptions('Method','NonLinearLeastSquares');
fo.Lower = [0 0 0 0];
fo.Upper = [1 max(arclength_line_um)*10 diff(minmax(arclength_line_um)) 1];


% for loop that actually fits stuff

for fc = size(norm_fluo_thickline,1):-1:1

    % amplitude is 1/sqrt(2*pi*sigma^2), but sigma^2 = 2*Diffcoeff*time
    sigma_0 = sqrt( 2 * 425 * fc / fluo_framerate);
    fo.StartPoint = [1/sqrt(2 * pi * sigma_0^2) , mean(arclength_line_um),  sigma_0, 0];
    
    FitStruct(fc).fit_out = fit(arclength_line_um(:), norm_fluo_thickline(fc,:)', ft, fo);

end %for

end

