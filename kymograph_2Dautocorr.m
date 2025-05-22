%% this code serves to plot a keymograph and 2D autocorrelation on a line parallel to the epithelium for video with cilia profile

clear all
close all

% inputs

px2mum = 0.0658;

folder_save = 'E:\2022-10 MD0793\Good\Autocorr_fit';


% exp on paper
exp_path_gen = 'E:\2021-12_Oscillations\T1\16\pos2';
bf_fullname = 'p_[0.  1.5]_bf.09Dec2021_14.04.36.movie';
teta = 90; %rotation angle for having the epithelium horizontal

% the following is needed to find a good position for the line in the
% ciliary layer
y_dist = 80; %this is to move the line vertically with respect to the activation spot
aix = 60; %this is to move the line horizontally with respect to the activation spot


cd(exp_path_gen)

% position of the dye activation spot in the unrotated FOV
x1_beam = 725.20151;
y1_beam = 405.86236;


%frame dim
%small size
x_pxl = 1408;
y_pxl = 900;

x_dist = 50; %half of the length of the line on which measure the keymograph in pxl



%% Read the video file
bf_mo = moviereader(bf_fullname); 
bf_fs_raw = bf_mo.read;
fps = bf_mo.FrameRate;


%% Process video

bf_fs = bf_fs_raw;


% rotate video
bf_fs = imrotate(bf_fs, teta,'nearest','crop');
bf_fs = mat2gray(double(bf_fs));


% find beam position in rotated frame from calculated laser position

x1_diff = - x1_beam + x_pxl/2;
y1_diff = y1_beam - y_pxl/2;

x2_diff = x1_diff*cos(teta)-y1_diff*sin(teta);
y2_diff = x1_diff*sin(teta)+y1_diff*cos(teta);

x_beam = x2_diff + x_pxl/2;
y_beam = y2_diff + y_pxl/2;


% initialise line
x1 = x_beam + aix;
y1 = y_beam+y_dist;
x2 = x_beam + aix - 2*x_dist;
y2 = y_beam+y_dist;


%% Kymograph %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numFrames = round(size(bf_fs,3)/1);
framerate = fps;
kymographData = zeros(numFrames, abs(x2 - x1) + 1);

% Extract Pixel Values

for frameNum = 1:numFrames
    frame = bf_fs(:,:,frameNum);
    % Extract pixel values along the selected line
    lineProfile = improfile(frame, [x1, x2], [y1, y2]);
    kymographData(frameNum, :) = lineProfile;
end

% Calculate distance axis in um
pixelsPerUm = px2mum;
line_length = abs(x2-x1);
distanceInUm = linspace(0, abs(x2 - x1) * pixelsPerUm, 100);

% Calculate time axis in seconds
timeInSeconds = (1:numFrames) / framerate;


% Normalize the kymograph data to the range [0, 1]
kymographData = mat2gray(kymographData);

%% Display the Kymograph (vertical)
figure;
imshow(kymographData, [], 'InitialMagnification', 'fit');
xlabel('Position along the line [um]');
ylabel('Time [s]');
title('Kymograph of image intensity');
colormap('parula');
colorbar;

axis on

yTicks = linspace(1, length(timeInSeconds), 4); 
yTickLabels = timeInSeconds(round(yTicks)); 
yticklabels(yTickLabels);
yticks(yTicks);


xTicks = linspace(1, length(distanceInUm), 8); 
xTickLabels = distanceInUm(round(xTicks)); 
xticklabels(xTickLabels);
xticks(xTicks);

%% Display the keymograph (horizontal)

% Rotate the kymograph data
rotatedKymographData = imrotate(kymographData, 90); % Rotate 90 degrees counterclockwise

% Define the new x and y axes
newX = linspace(0, abs(x2 - x1) * pixelsPerUm, size(rotatedKymographData, 2));
newY = timeInSeconds;


figureWidth = 7.5;  % inches
figureHeight = 3; 
figure('Position', [100, 200, figureWidth*100, figureHeight*100]); 
sz = 10;

wi = 2;

imshow(rotatedKymographData, [], 'InitialMagnification', 'fit');
xlabel('Time [s]');
ylabel({'Position along'; 'the line [um]'});
colormap('gray');
c = colorbar;
c.Label.String = ({'kymograph' ;'intensity [a.u.]'});

% Set font size
set(gca, 'FontSize', 12, 'FontWeight', 'bold');

% Thicken the axes
set(gca, 'LineWidth', 1.2);

axis on;


xTicks = linspace(1, length(timeInSeconds), 5); 
xTickLabels = round(timeInSeconds(round(xTicks)));
xticklabels(xTickLabels);
xticks(xTicks);

yTicks = linspace(1, length(distanceInUm), 5); 
yTickLabels = fliplr(round(distanceInUm(round(yTicks)),2));
yticklabels(yTickLabels);
yticks(yTicks);

savefig('Kymograph.fig')




%% showline
figure
y_lim = 201;
x_lim = 401;
hi = imshow(bf_fs(y_lim:800,x_lim:1000,1));
hold on
plot([x1-x_lim, x2-x_lim], [y1-y_lim, y2-y_lim], 'r', 'LineWidth', 4);  

figureWidth = 7;  % inches
figureHeight = 7;

newFigurePosition = [100, 100, figureWidth*50, figureHeight*50];  
set(gcf, 'Position', newFigurePosition);

% add scalebar
my_scalebar(gca,hi,10,px2mum,[520 400]);

savefig('Kymograph_line.fig')







%% 2D autocorrelation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Extract the line between (x1, y1) and (x2, y1) from each frame
line_length = abs(x2 - x1) + 1;  % Length of the line
num_frames = size(bf_fs, 3);     % Number of frames
line_data = zeros(num_frames, line_length);

for t = 1:num_frames
    frame = bf_fs(:,:,t);  % Extract the current frame
    line_data(t, :) = frame(round(y1),round( min(x1, x2)):round(max(x1, x2)));  % Extract the line
end

matrix = line_data;

% Find the minimum value in the matrix
minValue = min(matrix, [], 'all');

% Add the absolute value of minValue to all elements in the matrix
matrix = matrix + abs(minValue);


% Calculate the current mean of the matrix
current_mean = mean(matrix(:));

% Subtract the current mean from each element in the matrix
normalized_matrix = matrix - current_mean;

line_data = normalized_matrix' ;


% Calculate 2D autocorrelation along the line for each frame
correlation_d = xcorr2(line_data);



%% take correlation in 1/4 of the final matrix and plot

m = size(correlation_d,1);
n = size(correlation_d,2);

% until 100 in lag time
corr = correlation_d(1:m/2,n/2:n-332);

% Find the minimum and maximum values in the matrix
minValue = min(corr, [], 'all');
maxValue = max(corr, [], 'all');

% Normalize the matrix to the [-1, 1] range
normalized_corr = 2 * (corr - minValue) / (maxValue - minValue) - 1;


figureWidth = 7.5;  % inches
figureHeight = 3; 
figure('Position', [100, 200, figureWidth*100, figureHeight*100]); 

colormap(parula);
imagesc(corr(:,20:end))
c = colorbar;
c.Label.String = ({'2D autocorrelation' ;'[a.u.]'});

% Add labels and title
xlabel('Lag Time');
ylabel({'Position along'; 'the line [um]'});

% Define and set the y ticks and labels
yTicks = linspace(1, length(distanceInUm), 5); 
yTickLabels = fliplr(round(distanceInUm(round(yTicks)),2));
yticklabels(yTickLabels);
yticks(yTicks);
set(gca, 'FontSize', 12, 'FontWeight', 'bold');

set(gca, 'LineWidth', 1.2)

pbaspect([5, 0.7, 1]); % [width, height, depth]

savefig('autocorr_line.fig')

%% plot autocorr on horizontal line

figureWidth = 7.5;  % Set your desired width in inches
figureHeight = 3; % Set your desired height in inches
figure('Position', [100, 200, figureWidth*100, figureHeight*100]); % Multiplying by 100 to convert inches to pixels

xx = linspace(1,size(normalized_corr,2),size(normalized_corr,2));
plot(xx, corr(25,:),'r','LineWidth',2)
hold on
plot(xx, corr(50,:),'g','LineWidth',2)
hold on
plot(xx, corr(75,:),'b','LineWidth',2)

% Add labels and title
xlabel('Lag Time');
ylabel({'2D autocorrelation [a.u.]'});

% Set font size
set(gca, 'FontSize', 12, 'FontWeight', 'bold');

% Thicken the axes
set(gca, 'LineWidth', 1.2)

axis square


%% fit for one height (constant space shift)

height = 75;
cut = 530; % how many frames to consider

%cut data
m = size(correlation_d,1);
n = size(correlation_d,2);

%corr = correlation_d(1:m/2,n/2:n);
% until 100 in lag time
corr = correlation_d(1:m/2,n/2:n-cut);

% Find the minimum and maximum values in the matrix
minValue = min(corr, [], 'all');
maxValue = max(corr, [], 'all');

% Normalize the matrix to the [-1, 1] range
normalized_corr = 2 * (corr - minValue) / (maxValue - minValue) - 1;

xx = linspace(1,size(normalized_corr,2),size(normalized_corr,2));

% Define your custom function
customFunction = @(params, t) params(1) * (cos(params(2).* t - params(3))) .* exp(-t * params(4)) + params(5);

% Generate some example data (replace this with your actual data)
t = xx; % Time values
data = corr(height,:);

% Initial guess for the parameters
initialGuess = [6, 2*pi/0.8, 0, 0.1, -10];

% Fit the model to the data using lsqcurvefit
fittedParams = lsqcurvefit(customFunction, initialGuess, t, data);

% Extract the fitted parameters
A_fitted = fittedParams(1);
w_fitted = fittedParams(2);
fi_fitted = fittedParams(3);
gamma_fitted = fittedParams(4);
k_fitted = fittedParams(5);

% Plot the original data and the fitted curve
fig=figure;
plot(t, data, 'r', t, customFunction(fittedParams, t), 'b-','LineWidth',1.2);
xlabel('t');
ylabel('f(t)');
legend('Data', 'Fitted Curve');
%title('Nonlinear Fit of f(t) = A*(cos(w*t+fi))*exp(-t*gamma)+k)');

% Set font size
set(gca, 'FontSize', 12, 'FontWeight', 'bold');


% Display the fitted parameters
disp(['A fitted: ', num2str(A_fitted)]);
disp(['w fitted: ', num2str(w_fitted)]);
disp(['fi fitted: ', num2str(fi_fitted)]);
disp(['gamma fitted: ', num2str(gamma_fitted)]);
disp(['K fitted: ', num2str(k_fitted)]);

cd(folder_save)

% Remove the drive letter and colon from exp_path_gen
exp_path_gen_no_drive = erase(exp_path_gen, 'E:\');

% Replace backslashes with forward slashes
exp_path_gen_no_drive = strrep(exp_path_gen_no_drive, '\', '_');

% Construct the filename based on the modified path
filename = strcat('autocorr_fit_', num2str(height), 'px_', exp_path_gen_no_drive);

% Save the figure
saveas(fig, filename, 'fig')


% save data

autocorr_fit.path = exp_path_gen;
autocorr_fit.par = fittedParams;
autocorr_fit.init = initialGuess;
autocorr_fit.func = customFunction;
autocorr_fit.pos = height;
autocorr_fit.cut = n-cut;

filename_struct = strcat(filename, '.mat');

save(filename, 'autocorr_fit')




%% fit for different heights (constant space shift)

% choose space shift and how many frames to consider
%height = [72 82 92]; % works with MCW
height = [50 70 90]; % works with MCW2
%height = [25 50 75]; % for synchronzied
%cut = 640;  % works with MCW and sync
cut = 400;  % works with MCW2


%cut data
m = size(correlation_d,1);
n = size(correlation_d,2);

corr = correlation_d(1:m/2,n/2:n-cut);

% Find the minimum and maximum values in the matrix
minValue = min(corr, [], 'all');
maxValue = max(corr, [], 'all');

% Normalize the matrix to the [-1, 1] range
normalized_corr = 2 * (corr - minValue) / (maxValue - minValue) - 1;

xx = linspace(1,size(normalized_corr,2),size(normalized_corr,2));

fig = figure('Position', [100, 200, figureWidth*100, figureHeight*100]); % Multiplying by 100 to convert inches to pixels


% Define an array of colors (as many as the maximum expected size of height)
numColors = size(height, 2); % Number of colors you want
colors = zeros(numColors, 3); % Initialize a matrix to store the colormap

% Define the starting color (pink) and ending color (yellow)
startColor = [0.7,0.2, 0.3]; % Pink
endColor = [1, 0.6, 0.3]; % Yellow

for i = 1:numColors
    % Linearly interpolate between the start color and end color
    fraction = (i - 1) / (numColors - 1);
    colors(i, :) = startColor + fraction * (endColor - startColor);
end

for i = 1: size(height,2)
    % Define fitting function
    customFunction = @(params, t) params(1) * (cos(params(2).* t - params(3))) .* exp(-t * params(4)) + params(5);

    t = xx; % Time values
    data = corr(height(i),:);

    % Initial guess for the parameters
    %initialGuess = [6, 2*pi/0.8, 0, 0.1, -10]; % works for
    %2021/12_Oscill/6/pos3
    
    %works with Oscill small (MCW)
    if i == 1
        initialGuess = [2, 0.18, -5, 0.05, -5];
    else
        initialGuess = fittedParams;
    end

    % Fit the model to the data 
    fittedParams = lsqcurvefit(customFunction, initialGuess, t, data);

    % Extract the fitted parameters
    A_fitted = fittedParams(1);
    w_fitted = fittedParams(2);
    fi_fitted = fittedParams(3);
    gamma_fitted = fittedParams(4);
    k_fitted = fittedParams(5);

    % Plot the original data and the fitted curve
    plot(t, data, 'o','MarkerSize',4,'MarkerFaceColor',colors(i, :),'MarkerEdgeColor','k');
    alpha(0.5)
    hold on
    plot(t, customFunction(fittedParams, t), '-', 'LineWidth', 3, 'Color', colors(i, :))
    hold on
    
    cd(folder_save)

    % save data
    exp_path_gen_no_drive = erase(exp_path_gen, 'E:\');
    exp_path_gen_no_drive = strrep(exp_path_gen_no_drive, '\', '_');
    autocorr_fit(i).path = exp_path_gen;
    autocorr_fit(i).par = fittedParams;
    autocorr_fit(i).init = initialGuess;
    autocorr_fit(i).func = customFunction;
    autocorr_fit(i).pos = height(i);
    autocorr_fit(i).cut = n-cut;
    
end

filename_struct = strcat(filename, '.mat');

save(filename, 'autocorr_fit')


% Construct the filename based on the modified path
filename = strcat('autocorr_fit_', 'all_', 'px_', exp_path_gen_no_drive);

xlabel('t');
ylabel('f(t)');
legend('Data', 'Fitted Curve');
title('Nonlinear Fit of f(t) = A*(cos(w*t+fi))*exp(-t*gamma)+k)');

% Set font size
set(gca, 'FontSize', 12, 'FontWeight', 'bold');

figureWidth = 7.5;  % Set your desired width in inches
figureHeight = 3; % Set your desired height in inches

xlim([0 350])
    

% Save the figure
saveas(fig, filename, 'fig')


%% Measure MCW angle

delta_fi = zeros(1,size(height,2)-1);
delta_y = zeros(1,size(height,2)-1);
quot = zeros(1,size(height,2)-1);

for i = 2 : size(height,2)
    
    delta_fi(i-1) = autocorr_fit(i).par(3)- autocorr_fit(i-1).par(3);
    delta_y(i-1) = height(i)-height(i-1);
    quot(i-1) = delta_y(i-1)/delta_fi(i-1);
end

quot_av = mean(quot,'all');
fi_av = mean(delta_fi,'all');
y_av = mean(delta_y,'all');
err_fi = std(delta_fi)

err_teta = sqrt((err_fi*y_av/(fi_av^2+y_av^2))^2)*180/pi;

teta = atan(quot_av)*180/pi;
 
autocorr_fit(1).teta = [teta,err_teta];

filename_struct = strcat(filename, '.mat');

save(filename, 'autocorr_fit')

    

%% plot evaluation lines on the autocorr plot

m = size(correlation_d,1);
n = size(correlation_d,2);

corr = correlation_d(1:m/2,n/2:n-382);

% Find the minimum and maximum values in the matrix
minValue = min(corr, [], 'all');
maxValue = max(corr, [], 'all');

% Normalize the matrix to the [-1, 1] range
normalized_corr = 2 * (corr - minValue) / (maxValue - minValue) - 1;


figureWidth = 4;  
figureHeight = 1.5; 

fig2 = figure('Position', [100, 200, figureWidth*100, figureHeight*100]); 

colormap(parula);
imagesc(corr(:,20:end))
c = colorbar;
c.Label.String = ({'2D autocorrelation' ;'[a.u.]'});


for i = 1:size(height,2)
    hold on
    yline(height(i), 'Color', colors(i, :), 'LineWidth', 3); 
end


% Add labels and title
xlabel('Lag Time');
ylabel({'Position along'; 'the line [um]'});

% Define and set the y ticks and labels
yTicks = linspace(1, length(distanceInUm), 5);
yTickLabels = fliplr(round(distanceInUm(round(yTicks)),2)); 
yticklabels(yTickLabels);
yticks(yTicks);

% Set font size
set(gca, 'FontSize', 12, 'FontWeight', 'bold');

% Thicken the axes
set(gca, 'LineWidth', 1.2)


% save

% Construct the filename based on the modified path
filename = strcat('autocorr_fit_lines_', 'all_', 'px_', exp_path_gen_no_drive);


% Save the figure
saveas(fig2, filename, 'fig')



