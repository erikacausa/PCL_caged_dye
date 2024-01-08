function [ x_line, y_line, arclength_line ] = find_line_fitting_maskcloud( mask )
%find_line_fitting_maskcloud find the line that best fits the points that
%are true in the mask
%   fits both x and y against a parametrised variable, returns x and y
%   within the mask size





% decide how to fit the image, either as is or transpose first
[y_mask,x_mask] = find(mask);
[y_maskt,x_maskt] = find(mask');

flag_asis = sum(abs(diff(y_mask))) < sum(abs(diff(y_maskt)));

if flag_asis
    x_mask = smooth(x_mask,floor(numel(x_mask)/10));
    y_mask = smooth(y_mask,floor(numel(y_mask)/10));
else
    mask = mask';
    x_mask = smooth(x_maskt,floor(numel(x_maskt)/10));
    y_mask = smooth(y_maskt,floor(numel(y_maskt)/10));
end

% parametrise
tt = cumsum(ones(size(x_mask))); %this is actually an index along *_mask

% fit
fitx = fit(tt,x_mask,fittype('poly5'),fitoptions('Method','NonlinearLeastSquares','Robust','Bisquare'));
fity = fit(tt,y_mask,fittype('poly5'),fitoptions('Method','NonlinearLeastSquares','Robust','Bisquare'));



% the line created is almost surely too dense, no need for those many points

% create new arc variable along the fitted line
ll = vertcat(0,cumsum(hypot(diff(fitx(tt)),diff(fity(tt)))));

% downsample the line, should improve s/n
ll_r = unique(round(ll)); % find arclengths that approximate multiples of 1px
tt_r = knnsearch(ll,ll_r); % find the indices of points in the ll array that actually are superclose to points ll_r

% find x and y coordinates of the points thus selected
yy_r = fity(tt_r);
xx_r = fitx(tt_r);
ll_r = vertcat(0,cumsum(hypot(diff(xx_r),diff(yy_r))));% now re-measure the arclength given the points selected


% some points now will probably out of the field of view, let's fix that
% doesn't really affect too much the outcome but why not

idx_oofov = xx_r < 1 | xx_r > size(mask,2);
idx_oofov = idx_oofov | yy_r < 1 | yy_r > size(mask,1);

x_line = xx_r(~idx_oofov);
y_line = yy_r(~idx_oofov);
arclength_line = vertcat(0,cumsum(hypot(diff(x_line),diff(y_line))));

% create new tt_r now, asimply as an index along **_r
tt_r = cumsum(ones(size(x_line)));

if ~flag_asis
    % swap coordinates again
    dummy = x_line;
    x_line = y_line;
    y_line = dummy;
    mask = mask';
end

hf = figure(703);clf
imagesc(mask);
hold on
plot(x_line,y_line);
pause(4)
close(hf)
end

