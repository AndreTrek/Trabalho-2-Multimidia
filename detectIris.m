function [irisCenter, irisRadius, pupilCenter, pupilRadius] = detectIris(image)
    %Initial image loading and pre-processing for Hough Transform
    %{
    subplot(1,2,1);
    imshow(image);
    title("Image");
    %}

    image_equ = histeq(image); %Applying histogram equalization

    hbfilter = fspecial('average', [55 55]); %Applying High Boost filter twice
    img_suave = imfilter(image_equ, hbfilter);
    img_mascara = imsubtract(image_equ, img_suave);
    img_highboost = imadd(image_equ, img_mascara);

    img_suave = imfilter(img_highboost, hbfilter);
    img_mascara = imsubtract(img_highboost, img_suave);
    img_highboost2 = imadd(img_highboost, img_mascara);


    image_thresh = im2bw(img_highboost2, graythresh(img_highboost)); %Otsu threshold

    %Parameters
    canny_sensitivity = 0.99; %(0.9 ~ 0.99)
    hough_sensitivity = 0.94; %(0.93 ~ 0.97)
    hough_edge_thresh = 0.05;
    pupil_radius_min = 30;
    pupil_radius_max = 65;
    iris_radius_min = 90;
    iris_radius_max = 130;
    %Parameters

    %Applying Canny edge detector for iris detection
    %image_canny = edge(image_thresh,'Canny', canny_sensitivity);
    image_canny = edge(image_thresh,'Canny', canny_sensitivity);


    %Detecting pupil
    [pupilCenters, pupilRadii] = imfindcircles(image,[pupil_radius_min pupil_radius_max],'ObjectPolarity','dark');
    if size(pupilCenters, 1) == 0
        pupil_sensitivity = 0.85;
        while 1
            if pupil_sensitivity > 0.98
                fprintf("Failed to find pupil\n");
                return;
            end
            [pupilCenters, pupilRadii] = imfindcircles(image,[pupil_radius_min pupil_radius_max],'ObjectPolarity','dark', 'Sensitivity', pupil_sensitivity);
            if size(pupilCenters, 1) ~= 0
                pupilCenter = pupilCenters(1:1,:); 
                pupilRadius = pupilRadii(1:1);
                fprintf("Sensitivity used: %f\n", pupil_sensitivity);
                break;
            end
            pupil_sensitivity = pupil_sensitivity + 0.01;
        end
    else
        pupilCenter = pupilCenters(1:1,:);
        pupilRadius = pupilRadii(1:1);
    end

    %Detecting iris
    while 1
        if hough_sensitivity > 0.98
            fprintf("Failed to find iris\n");
            return;
        end
        [irisCenters, irisRadii] = imfindcircles(image_canny,[iris_radius_min iris_radius_max], 'Method', 'TwoStage','ObjectPolarity','bright','Sensitivity', hough_sensitivity, 'EdgeThreshold', hough_edge_thresh);
        if size(irisCenters, 1) ~= 0
            irisCenter = irisCenters(1:1,:); 
            irisRadius = irisRadii(1:1);
            if norm(irisCenters(1:1,:) - pupilCenter) > 2
                irisCenter = pupilCenter;
            end
            fprintf("Sensitivity used for iris: %f\n", hough_sensitivity);
            break;
        end
        hough_sensitivity = hough_sensitivity + 0.01;
    end
end




