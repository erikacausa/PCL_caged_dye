function [x_maxfluo, y_maxfluo, arclength_maxfluo_um] = calculate_xy_maxfluo(FS, x_line, y_line, arclength_line_um)
%calculate_xy_maxfluo finds x,y coordinates of maximum fluo arclength as found by
%fitting


% this cats in a vertical array all the arclength coordinates of the fluo
% max
arclength_maxfluo_um = arrayfun(@(i)FS(i).fit_out.arclength_fluo_max_um, 1:numel(FS))';

% create a matrix, frames x N points of the line. In each row there's the
% difference between that frame's arclength coordinate of the fluo max and the arclenth of the points on the line
diff_mat = arclength_maxfluo_um - arclength_line_um(:)';

% I want to find the position of the least positive number per each line
diff_mat2 = diff_mat;
diff_mat2(diff_mat < 0) = NaN;

%the location of the minimum of this matrix gives the inf of the interval where the
%arclenght is
[inf_coeff, w] = min(diff_mat2,[],2);

inf_int_x = x_line(w);
inf_int_y = y_line(w);

% I want to find the position of the least negative number per each line
diff_mat2 = diff_mat;
diff_mat2(diff_mat > 0) = NaN;

%the location of the minimum of this matrix gives the inf of the interval where the
%arclenght is
[sup_coeff, w] = max(diff_mat2,[],2);

sup_int_x = x_line(w);
sup_int_y = y_line(w);

% now basically interpolate between the inf and sup of each interval (it's
% a weighted mean
x_maxfluo = (inf_coeff .* inf_int_x + abs(sup_coeff) .*  sup_int_x) ./ (inf_coeff + abs(sup_coeff) );
y_maxfluo = (inf_coeff .* inf_int_y + abs(sup_coeff) .*  sup_int_y) ./ (inf_coeff + abs(sup_coeff) );


end

