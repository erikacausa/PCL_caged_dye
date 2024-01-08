function [ bf_fullname, fluo_fullname ] = find_movies_of_experiment( exp_name, exp_path )
%find_movies_of_experiment given a string with the experiment name, finds
%the bf and fluo names that corresponf to that experiment
%   Returns the full path


%% input check

if nargin < 2 || isempty(exp_path)
    exp_path = pwd;
end


%% code

% to make the find_files_in_folder match only .movies
filenamestr = [exp_name,'.*movie'];

filelist = find_files_in_folder(filenamestr,exp_path);

% check that we got 2 and only 2 results (one bf and one fluorescence
% movie)
if numel(filelist) ~=2
    error('more than two movies with this name were detected');
end %if

% find of the two which one is the bright field video
idx_bf = arrayfun(@(i) ~isempty( strfind(filelist(i).name,'bf') ), 1:numel(filelist))';

if sum(idx_bf) ~= 1
    warning('More/less than one bright field file was found. Please select the bright field file manually');
    [bf_name, bf_path] = uigetfile(fullfile(exp_path,'*.movie'),'Select Bright field movie');
else
    bf_name = filelist(idx_bf).name;
    bf_path = pwd;
end %if

% now I can safely assume that if we have two videos and one is BF, the
% other one is fluo
fluo_name = filelist(~idx_bf).name;
fluo_path = pwd;


%% prepare variables for output

bf_fullname = fullfile(bf_path, bf_name);
fluo_fullname = fullfile(fluo_path, fluo_name);

end

