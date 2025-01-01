clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
clear;  % Erase all existing variables. Or clearvars if you want.
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 25;

%===============================================================================
%{
% Get the name of the image the user wants to use.
baseFileName = 'egg 1.jpg';
% Get the full filename, with path prepended.
folder = []; % Determine where demo folder is (works with all versions).
fullFileName = fullfile(folder, baseFileName);
%}

% Specify the folder where the files live.
myFolder = 'C:/Users/danielzhang/Downloads/MATLAB/vt eggs label/C';
% Check to make sure that folder actually exists.  Warn user if it doesn't.
if ~isfolder(myFolder)
    errorMessage = sprintf('Error: The following folder does not exist:\n%s\nPlease specify a new folder.', myFolder);
    uiwait(warndlg(errorMessage));
    myFolder = uigetdir(); % Ask for a new one.
    if myFolder == 0
         % User clicked Cancel
         return;
    end
end
% Get a list of all files in the folder with the desired file name pattern.
filePattern = fullfile(myFolder, '*.jpg'); % Change to whatever pattern you need.
theFiles = dir(filePattern);

dataTable = [];

for k = 1 : length(theFiles)
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(theFiles(k).folder, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    % Now do whatever you want with this file name,

    %===============================================================================
    % Read in a demo image.
    grayImage = imread(fullFileName);
    % Get the dimensions of the image.
    % numberOfColorChannels should be = 1 for a gray scale image, and 3 for an RGB color image.
    [rows, columns, numberOfColorChannels] = size(grayImage)
    if numberOfColorChannels > 1
      % It's not really gray scale like we expected - it's color.
      % Use weighted sum of ALL channels to create a gray scale image.
      grayImage = rgb2gray(grayImage);
      % ALTERNATE METHOD: Convert it to gray scale by taking only the green channel,
      % which in a typical snapshot will be the least noisy channel.
      % grayImage = grayImage(:, :, 2); % Take green channel.
    end
    % Display the image.
    subplot(2, 2, 1);
    imshow(grayImage, []);
    axis on;
    axis image;
    caption = sprintf('Original Gray Scale Image');
    title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
    drawnow;
    hp = impixelinfo();
    
    % Set up figure properties:
    % Enlarge figure to full screen.
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    % Get rid of tool bar and pulldown menus that are along top of figure.
    % set(gcf, 'Toolbar', 'none', 'Menu', 'none');
    % Give a name to the title bar.
    set(gcf, 'Name', 'Demo by ImageAnalyst', 'NumberTitle', 'Off')
    drawnow;
    
    % Let's compute and display the histogram.
    [pixelCount, grayLevels] = imhist(grayImage);
    subplot(2, 2, 2); 
    bar(grayLevels, pixelCount); % Plot it as a bar chart.
    grid on;
    title('Histogram of original image', 'FontSize', fontSize, 'Interpreter', 'None');
    xlabel('Gray Level', 'FontSize', fontSize);
    ylabel('Pixel Count', 'FontSize', fontSize);
    xlim([0 grayLevels(end)]); % Scale x axis manually.
    
    % Binarize the image by thresholding.
    mask = grayImage > 130;
    % Display the mask image.
    subplot(2, 2, 3);
    imshow(mask);
    axis on;
    axis image; % Make sure image is not artificially stretched because of screen's aspect ratio.
    title('Binary Image Mask', 'fontSize', fontSize);
    drawnow;
    
    % Get rid of blobs touching the border.
    mask = imclearborder(mask);
    % Extract just the largest blob.
    mask = bwareafilt(mask, 1);
    
    % Display the mask image.
    subplot(2, 2, 4);
    imshow(mask);
    axis on;
    axis image; % Make sure image is not artificially stretched because of screen's aspect ratio.
    title('Lobster-only Mask', 'FontSize', fontSize);
    drawnow;
    
    % Get rid of black islands (holes) in struts without filling large black areas.
    subplot(2, 2, 4);
    mask = ~bwareaopen(~mask, 1000);
    mask = imfill(mask,"holes")
    imshow(mask);
    axis on;
    axis image; % Make sure image is not artificially stretched because of screen's aspect ratio.
    title('Final Cleaned Mask', 'FontSize', fontSize);
    drawnow;
    
    imwrite(mask, baseFileName + "mask.png")
    stats = regionprops("table",mask,"Area","Eccentricity","EquivDiameter","Extent","FilledArea","Perimeter","Solidity")
    dataTable = [dataTable; stats]

end

dataTable
