function normalized_iris = normalizeIris(image)
%image = imread('S1007R07.jpg');
[~, irisRadius, pupilCenter, pupilRadius] = detectIris(image);

in=pupilRadius;
out=irisRadius;
cx=pupilCenter(1, 1);
cy=pupilCenter(1, 2);
phi0 = 0;
phiEnd = 2*pi;

normalized_iris = imresize(mat2gray(transImageInvPolar(double(image), cx, cy, in, out, phi0, phiEnd, 0)), [660 54]);
imwrite(normalized_iris, 'normalizedIris.jpg');