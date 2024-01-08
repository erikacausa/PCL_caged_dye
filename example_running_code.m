% example of code for running the main functions for analysing Caged dye
% experiments and measure dye speed and cilia CBF


close all
clear all


%% inputs

Temp = 37; %experiment temperature in degrees Celsius
angle = 90; % rotation angle to have  (in degrees) 
exp_path_gen = 'E:\2021-12_Oscillations\T1\16';
last_pos = 4; % number of the last position you want to analyse

% Input direction of power stroke
direction = 1; % direction = 0 if you don't know, 1 if towards right, 2 if towards left

micpix = 0.0658; %micron to pxl factor

% Input the fit you want to run for the dye displacement
fit_type = 2; %type of fit - if = 0 you don't know, if = 1 simple linear, 
              % if = 2 segmented linear with cross-over to define

flag_check_fit = false; % the flag is true if you want to select the fit for every pos

pos = 1; % initial pos

pos_path = exp_path_gen + "\pos" + string(pos);

cd (pos_path)


%% run first position

Caged_save = fullfile(pos_path,['CagedResults.mat']);
    if isempty(dir(Caged_save))

    % run main code

    [CagedResults, distance, direction] = Caged_dye_manual_line( 'p_', pos_path , micpix, false, angle, direction, exp_path_gen)
else
    load('CagedResults.mat')
    distance = CagedResults.distance;
    direction = CagedResults.direction;
end
 
%% plot and save

% Here input the cross-over time
t_crossover = 0.4;

% Run the fitting and plotting function
[hf, fit_type] = CagedResults_plot_manualline_clean (CagedResults, distance, Temp, pos, fit_type, exp_path_gen, t_crossover);


%% run the rest of the positions

for pos = 2 : last_pos
    pos_path = exp_path_gen + "\pos" + string(pos)
    cd (pos_path)
    Caged_save = fullfile(pos_path,['CagedResults.mat']);
    if isempty(dir(Caged_save))
        [CagedResults, distance, direction] = Caged_dye_manual_line( 'p_', pos_path , micpix, false, angle, direction, exp_path_gen)
    else
            load('CagedResults.mat')
            distance = CagedResults.distance;
            direction = CagedResults.direction;
    end
    
    if flag_check_fit == true;
        fit_type = 0;
    end
    fit_type = 2;
    [hf, fit_type] = CagedResults_plot_manual_line (CagedResults, distance, Temp, pos, fit_type, exp_path_gen, t_crossover)
end


%% analyse the CBF for first and last position
 
% define new fields in Result to save CBF

for i = 1:last_pos
    Result(i).CBF_freq = [];
    Result(i).CBF_err = [];
    pos_path = exp_path_gen + "\pos" + string(pos)
    cd (pos_path)
    load('CagedResults.mat')
    [CBF] = CBF_profile_autopoints(CagedResults, pos);

    cd (exp_path_gen)
    load('Result.mat')
    Result(pos).CBF_freq = CBF.freq;
    Result(pos).CBF_err = CBF.freq_err;
end


        
 