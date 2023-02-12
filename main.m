clear;
clc;

% default path setting
root = './images/';
scr_dir = 'group/';
T_dst = 'results/';

% image list
img_list = dir([root, scr_dir]);

% default configuration
config.patch_size = 50;
config.stride = 50;
config.region = 10;
config.channel = 3;
% caculate points on the circle of search region
config.points = initPoints(config.region);

% main iteration 
for i = 1 : length(img_list)
    %% detection preperation
    % preclude directory
    if img_list(i).isdir
        continue;
    end
    % read image
    I = imread([root, scr_dir, img_list(i).name]);
    % convert to grayscale
    if ndims(I) == 3
        I = rgb2gray(I);
    end
    %% begin detection
    % print image name
    fprintf('Detecting in image %s...\t\t', img_list(i).name);
    % start timer
    tic;
    T = anlpt(I, config);
    % end timer
    cost = toc;
    % print time cost
    fprintf('finished in %.3fs.\n', cost);
    %% write image into destination
    imwrite(T, [root, T_dst, img_list(i).name]);
end
