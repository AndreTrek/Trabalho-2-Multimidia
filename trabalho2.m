%Initial image loading and pre-processing for Hough Transform
image = imread('S1002L03.jpg');
imshow(image);

image_equ = histeq(image); %Applying histogram equalization

hbfilter = fspecial('average', [55 55]); %Applying High Boost filter twice
img_suave = imfilter(image_equ, hbfilter);
img_mascara = imsubtract(image_equ, img_suave);
img_highboost = imadd(image_equ, img_mascara);
img_suave = imfilter(img_highboost, hbfilter);
img_mascara = imsubtract(img_highboost, img_suave);
img_highboost = imadd(img_highboost, img_mascara);

image_thresh = im2bw(img_highboost, graythresh(img_highboost)); %Otsu threshold

%Parameters
canny_sensitivity = 0.99; %(0.9 ~ 0.99)
hough_sensitivity = 0.94; %(0.93 ~ 0.97)
hough_edge_thresh = 0.05;
pupil_radius_min = 30;
pupil_radius_max = 65;
iris_radius_min = 90;
iris_radius_max = 130;
found_iris = false;
%Parameters

%Applying Canny edge detector for iris detection
image_canny = edge(image_thresh,'Canny', canny_sensitivity);

%Detecting pupil
[pupilCenters, pupilRadii] = imfindcircles(image,[pupil_radius_min pupil_radius_max],'ObjectPolarity','dark');
viscircles(pupilCenters, pupilRadii,'EdgeColor','b');

%Detecting iris
while 1
    if hough_sensitivity > 0.98
        break;
    end
    [irisCenters, irisRadii] = imfindcircles(image_canny,[90 130], 'Method', 'TwoStage','ObjectPolarity','bright','Sensitivity', hough_sensitivity, 'EdgeThreshold', hough_edge_thresh);
    if size(irisCenters, 1) ~= 0
        centersStrong1 = irisCenters(1:1,:); 
        radiiStrong1 = irisRadii(1:1);
        if norm(irisCenters(1:1,:) - pupilCenters(1:1,:)) > 2
            centersStrong1 = pupilCenters(1:1,:);
        end
        viscircles(centersStrong1, radiiStrong1,'EdgeColor','r');
        break;
    end
    hough_sensitivity = hough_sensitivity + 0.01;
end





