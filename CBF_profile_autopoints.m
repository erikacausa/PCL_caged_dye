function [CBF] = CBF_profile_autopoints(CagedResults, pos)
% Code to measure CBF from bright field video with measuring line already
% defined. Finds 3 points on the measuring line and calulcates CBF in boxes
% of different sizes centred in the points

% calulate sampling frequency
dt = 1/CagedResults.fps;

% find the y coordinates of the curve for the 3 x coordinates
x_dist = 150; %distance between the boxes in pxl
y_dist = 70; %distance between the boxes centre and the epithelium in pxl
y_pos = (pos-1)*1.5/CagedResults.px2mum;
y_curve_1 = spline(CagedResults.xx, CagedResults.yy, CagedResults.x_beam);
y_curve_2 = spline(CagedResults.xx, CagedResults.yy, CagedResults.x_beam-x_dist);
y_curve_3 = spline(CagedResults.xx, CagedResults.yy, CagedResults.x_beam+x_dist);

%select centres of the boxes
x_box = [CagedResults.x_beam+x_dist; CagedResults.x_beam; CagedResults.x_beam-x_dist];
y_box = [y_curve_3 + y_pos - y_dist; y_curve_1 + y_pos - y_dist; y_curve_2 + y_pos - y_dist];


% FFT
window = hann(floor(CagedResults.bf_Nframes/2));

box_size = [20 30 40]; % half of the box size


% initializates vectors with measurement of mean and std of the frequencies
m = zeros(size(box_size,2), size(x_box,1));
s = zeros(size(box_size,2), size(x_box,1));

%% Run FFT in all the positions for the different sizes of the boxes

for i = 1 : size(box_size,2)

    [Freq, maxi] = FFT_boxes(CagedResults.bf_fs, box_size(i), window, CagedResults.bf_Nframes, x_box(1), y_box(1), CagedResults.fps);

    pd_f = fitdist(nonzeros(Freq(:)),'Normal')
    m1(i) = mean(pd_f);
    s1(i) = std(pd_f);

end


for i = 1 : size(box_size,2)

    [Freq, maxi] = FFT_boxes(CagedResults.bf_fs, box_size(i), window, CagedResults.bf_Nframes, x_box(2), y_box(2), CagedResults.fps);

    pd_f = fitdist(nonzeros(Freq(:)),'Normal');
    m2(i) = mean(pd_f);
    s2(i) = std(pd_f);

end

for i = 1 : size(box_size,2)

    [Freq, maxi] = FFT_boxes(CagedResults.bf_fs, box_size(i), window, CagedResults.bf_Nframes, x_box(3), y_box(3), CagedResults.fps);

    pd_f = fitdist(nonzeros(Freq(:)),'Normal');
    m3(i) = mean(pd_f);
    s3(i) = std(pd_f);
   
end


%% Plot values of the frequencies measured in the boxes for the different sizes


figure
errorbar(2*box_size, m1, s1, "s","MarkerSize",10,...
    "MarkerFaceColor","red")
hold on
errorbar(2*box_size, m2, s2, "s","MarkerSize",10,...
    "MarkerFaceColor","green")
hold on
errorbar(2*box_size, m3, s3, "s","MarkerSize",10,...
    "MarkerFaceColor","blue")
xlim([2 110]);
ylim([0 20]);
xlabel('Box sizes [pxl]')
ylabel('Frequency [Hz]')
savefig('CBFs.fig')


%% Plot boxes in their position

bf_firstframe = CagedResults.bf_fs(:,:,1);

figure
imshow(bf_firstframe);

for i = 1 : size (box_size,2)
    hold on
    rectangle('Position',[x_box(1)-box_size(i),y_box(1)-box_size(i),2*box_size(i), 2*box_size(i)], 'Edgecolor', 'r');
end

hold on

for i = 1 : size (box_size,2)
    hold on
    rectangle('Position',[x_box(2)-box_size(i),y_box(2)-box_size(i),2*box_size(i), 2*box_size(i)], 'Edgecolor', 'g');
end

hold on

for i = 1 : size (box_size,2)
    hold on
    rectangle('Position',[x_box(3)-box_size(i),y_box(3)-box_size(i),2*box_size(i), 2*box_size(i)], 'Edgecolor', 'b');
end

savefig('CBF_evaluation_points.fig')


%% Save variables for output

CBF.pos = pos; %position with respect to the epithelium
CBF.alfa = CagedResults.alfa;
CBF.bf_firstframe = bf_firstframe;
CBF.y_dist = y_dist;
CBF.x_dist = x_dist;
CBF.line = [CagedResults.xx(1,:);CagedResults.yy(1,:)];
CBF.x_centre = x_box;
CBF.y_centre = y_box;
CBF.box_size = box_size; %half of the box size
CBF.freq = [m1; m2; m3];
CBF.freq_err = [s1; s2; s3];

CBF_save=fullfile(CagedResults.exp_path,['CBF.mat']);
save(CBF_save,'CBF','-v7.3');

