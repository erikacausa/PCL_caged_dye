function [CagedResults, distance, direction] = Caged_dye_manual_line( exp_name, exp_path, px2mum, rotation, direction, exp_path_gen)
% Main file for the analysis of uncaged fluorescein in the PCL
% requires as input the name of the experiment and the path
% the conversion factor between pixels and numbers
% the rotation angle to have the epithelium horizontal in the FOV


%{
% Version 1.0
% © Erika Causa, Luigi Feriani 2023 (ec787@cam.ac.uk) 
% 
% Caged_dye_manual_line.m is licensed under a Creative Commons 
% Attribution-NonCommercial-NoDerivatives 4.0 International License.s
% 
% Original work
%
%}


% some flags for different checks
check_line = false; % to check how the line of the epithelium contour appear after drawing it
check_beampos = false; % to check if the position of the beam matches the selected one
flag_rotation = false; % to check frame after rotation


flag_redraw = true; % for contour redrawing
flag_fluo_spot = false; % for showing fluo activation frame
flag_meas_line = true; % for checking on the measuring line translation



%% initial inputs 

% Calculate rotation angle in radians with -
teta = - rotation*pi/180;

%input camera mode 
%camera_mode = input('Is the camera mode MONO16 or RAW8? If it is MONO 16 type [1] otherwise type any other keys... ');
camera_mode = 1;

% numbers of query points for the contour polyline
qp = 500;

% frame dimensions in pixels
x_pxl = 1408;
y_pxl = 900;

% beam position in unrotated image 
% (this works if the laser is fixed in the set-up so the coordinates of the
% activation point are known and always the same in all the experiments)
x1_beam = 725.20151;
y1_beam = 405.86236;



%% parse exp_name and find movies of experiment

[ bf_fullname, fluo_fullname ] = find_movies_of_experiment( exp_name, exp_path );



%% Load bright field video

% create movie object
bf_mo = moviereader(bf_fullname);

% actually load the frame stack
[bf_fs, bf_ts] = bf_mo.read;

% Store number of frames
bf_Nframes = bf_mo.NumberOfFrames;

% calulate time step and sampling frequency
fps = bf_mo.FrameRate;

% convert stack to double
bf_fs = mat2gray(double(bf_fs));



%% rotate the BF frames in order to have the epithelium horizontal 

alfa = rotation;

% rotate the BF video 
for i=1:bf_Nframes
    bf_fs(:,:,i) = imrotate(bf_fs(:,:,i), alfa,'nearest','crop');
end

% store BF first frame
bf_firstframe = bf_fs(:,:,1);

% check if the rotation is ok
if flag_rotation == true
    imshow(bf_firstframe);
end



%% manually draw epithelium contour and store the file

% check on whether the epithelium contour has already been drawn
polyline_save = fullfile(exp_path_gen,['roi.mat']);

while flag_redraw == true

    if isempty(dir(polyline_save))  

        % show first bf frame, ask to draw the epithelium contour manually
        figure('units','normalized','outerposition',[0 0 1 1]);
        imshow(bf_firstframe);
        title('Draw manually epithelium contour...');

        % save the drawn epithelium contour points
        roi = drawpolyline('Color','r')
        save(polyline_save,'roi');

    else

        fprintf('Epithelium contour file found, loading line... ');
        load(polyline_save);
        fprintf('Done!\n');

    end %if

    % store the x and y coordinates of the drawn contour points
    x_draw = roi.Position(:,1);
    y_draw = roi.Position(:,2);

    % Fit the drawn contour line and sample it

    % fit the drawn line with cubic spline data interpolation > creates a line
    % of qp points
    num_x_point = length(x_draw);
    qp = fix((x_draw(num_x_point,1)-x_draw(1,1)));
    xx = linspace(x_draw(1,1), x_draw(num_x_point,1), qp);       %query points
    yy = spline(x_draw,y_draw,xx);
    
   if check_line == true
       
        % Show the epithelium contour fit and ask the users if they're happy with it or they want to redraw it

        figure('units','normalized','outerposition',[0 0 1 1]);

        % Drawn points and fit
        subplot(1,2,1);
        imshow(bf_firstframe);
        hold on
        plot(x_draw,y_draw,'*g','MarkerSize',10);
        hold on
        plot(xx,yy,'g','LineWidth', 1.5);
        title('Fit of the drawn points');


        % Sampling of the fitted contour line
        subplot(1,2,2);
        imshow(bf_firstframe);
        hold on
        plot(xx,yy,'.','LineWidth',1.2);
        title('Epithelium line');

        % Dialog
        button = questdlg('Are you happy with the fit?',...
                 'Fit check', 'Yes', 'No', 'Yes');

        if strcmp(button,'No')
            flag_redraw=true;
            delete(polyline_save);
        else
            flag_redraw = false;
        end

        close;
        
    else       
        flag_redraw = false;
    end %if


end %while



%% load fluo movie and chop it to start with fluo maximum

[ fluo_fs, fluo_rts, bg_fluo, fluo_spot ] = load_fluo_movie( fluo_fullname );


%% rotate fluo movie

for i=1:size(fluo_fs,3)
    fluo_fs(:,:,i) = imrotate(fluo_fs(:,:,i),alfa,'nearest','crop');
end

% rotate also the first frame after activation
fluo_spot = imrotate(fluo_spot,alfa,'nearest','crop');

% store first fluo frame
fluo_firstframe = fluo_spot;

% show first fluo frame
if flag_fluo_spot == true
     figure
     imshow(fluo_firstframe);
     title('First FoV in which fluorescent signal is detected');
end



%% find beam position in rotated frame from known laser position

x1_diff = - x1_beam + x_pxl/2;
y1_diff = y1_beam - y_pxl/2;

x2_diff = x1_diff*cos(teta)-y1_diff*sin(teta);
y2_diff = x1_diff*sin(teta)+y1_diff*cos(teta);

x_beam = x2_diff + x_pxl/2;
y_beam = y2_diff + y_pxl/2;

if check_beampos == true
    % plot 
    figure
    imshow(fluo_firstframe);
    hold on
    plot(x_beam, y_beam, 'rx','LineWidth',1.2, 'DisplayName','Laser position');
    hold on
    plot(x_beam_det, y_beam_det, 'bx','LineWidth',1.2, 'DisplayName','Manual beam detection');
    hold off
    legend
end


%% translate the epithelium contour so the curve passes for the beam position - obtain the measuring line

% calculate the displacement and translate
    
% find the y coordinate of the curve for x = x_beam
y_curve = spline(xx, yy, x_beam);

% calculate the distance between the beam and the curve
y_translation = y_curve - y_beam;
%y_translation = 3.8518 /px2mum;
distance = y_translation * px2mum;

% translate
x_line = xx;
y_line= yy - y_translation;

% define the measuring line
y_line = y_line';
x_line = x_line';

% plot first fluo frame, beam position and measuring line in order to check
if flag_meas_line == true;
    
    figure;
    imshow(bf_firstframe);
    hold on
    plot(x_beam, y_beam, 'rx','MarkerSize', 10, 'DisplayName','beam position');
    hold on 
    %plot(x_beam, y_curve, 'b.','LineWidth',2, 'DisplayName','drawn points');
    %hold on
    plot(xx,yy,'g--', 'LineWidth',2, 'DisplayName','epithelium contour');
    hold on
    plot(x_line, y_line, 'b', 'LineWidth',2, 'DisplayName','measuring line');
    hold off
    legend
    
end

arclength_line = vertcat(0,cumsum(hypot(diff(x_line),diff(y_line))));

% create new tt_r now, asimply as an index along **_r
tt_r = cumsum(ones(size(x_line)));



%% manual check of the direction of the measuring line being the same as power stroke

[x_line, y_line, arclength_line, direction] = manual_check_line_direction(x_line, y_line, arclength_line, bf_firstframe, direction);

[k,dist] = dsearchn([x_line , y_line] , [x_beam , y_beam]);

x_fluo_spot = [x_line(1:k) ; x_beam];
y_fluo_spot = [y_line(1:k) ; y_beam];

arclength_line_spot = vertcat(0,cumsum(hypot(diff(x_fluo_spot),diff(y_fluo_spot))));
arclength_spot = arclength_line_spot(size(arclength_line_spot));
arclength_spot_um = arclength_spot(1) * px2mum;



%% create thickened line mask

[ thickline_mask ] = find_measuring_thickline_mask( x_line, y_line, size(bf_firstframe) );



%% create arclength map
% find for each of the points in the thickened line mask which is the
% closest point along the measuring line, so we can average the
% contribution of all the pixels of the thickened line that share the same
% closest point on the measuring line

[ arclength_map, arclength_counts ] = create_arclength_map( x_line, y_line, thickline_mask );



%% plot the average intensity within the thick_line mask

fluo_int = squeeze(mean(mean(fluo_fs,1),2));
if camera_mode==1
    fluo_int_mask = squeeze(sum(sum( fluo_fs .* uint16(repmat(thickline_mask,1,1,numel(fluo_rts))) ,1),2)) ./ sum(thickline_mask(:));
else
    fluo_int_mask = squeeze(sum(sum( fluo_fs .* uint8(repmat(thickline_mask,1,1,numel(fluo_rts))) ,1),2)) ./ sum(thickline_mask(:));
end



%% for loop that for each frame calculates the fluorescence profile along the line

fluo_thickline = calculate_fluo_along_line(fluo_fs, bg_fluo, arclength_map, arclength_counts, thickline_mask); 



%% normalise each fluorescence profile so it has area 1

[norm_fluo_thickline, arclength_line_um] = normalise_fluo_thickline(fluo_thickline, arclength_line, px2mum);



%% Fit fluo profile on the thickline with Gaussian profile

FitStruct = fit_fluo_thickline(norm_fluo_thickline, arclength_line_um, 1/mean(diff(fluo_rts)) );


%% convert the ll coordinate of the fluo peak into x, y coordinates

[x_maxfluo, y_maxfluo, arclength_maxfluo_um] = calculate_xy_maxfluo(FitStruct, x_line, y_line, arclength_line_um);



%%  quick and dirty save all variables in struct for output

VARS = whos;

for i = 1:numel(VARS)
    CagedResults.(VARS(i).name) = eval(VARS(i).name);
end

% saving the entire fluo_fs would be a waste of disk space
CagedResults.fluo_firstframe = fluo_fs(:,:,1);
CagedResults = rmfield(CagedResults,'fluo_fs');
CagedResults_save=fullfile(exp_path,['CagedResults.mat']);
save(CagedResults_save,'CagedResults', '-v7.3');


end %function

    
