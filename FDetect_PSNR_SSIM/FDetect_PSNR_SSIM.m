% Read the image
%imagePath = 'singlepic.jpg';
imagePath = 'grouppic.jpg';
%imagePath = 'grouppic2.jpg';
img = imread(imagePath);

% Create a face detector object
faceDetector = vision.CascadeObjectDetector();

% Detect faces in the image
bbox = step(faceDetector, img);

% Display the original image with detected faces
figure;
imshow(img);
hold on;

% Initialize cell array to store cropped faces
croppedFaces = cell(1, size(bbox, 1));

% Loop through each detected face and crop it
for i = 1:size(bbox, 1)
    % Extract the bounding box for the current face
    faceBoundingBox = bbox(i, :);
    
    % Draw a rectangle around the detected face
    rectangle('Position', faceBoundingBox, 'EdgeColor', 'r', 'LineWidth', 2);
    
    % Crop the face from the original image and store in the cell array
    croppedFaces{i} = imcrop(img, faceBoundingBox);
end

hold off;

% Loop through each detected face and create PSNR and SSIM plots
for i = 1:numel(croppedFaces)
    % Load the original face
    originalFace = croppedFaces{i};
    
    % Initialize arrays to store PSNR, SSIM, and quality values
    psnrValues = zeros(1, 10);
    ssimValues = zeros(1, 10);
    qualityValues = 10:10:100;

    % Loop through different quality factors, compress the face, and compute PSNR and SSIM
    for j = 1:numel(qualityValues)
        % Compress the face with different quality factors and write to file
        imwrite(originalFace, sprintf('compressed_face%d_q%d.jpg', i, qualityValues(j)), 'Quality', qualityValues(j));
        
        % Load the compressed face image for PSNR and SSIM calculation
        compressedImage = imread(sprintf('compressed_face%d_q%d.jpg', i, qualityValues(j)));
        
        % Compute PSNR for each color channel
        psnrRed = psnr(originalFace(:,:,1), compressedImage(:,:,1));
        psnrGreen = psnr(originalFace(:,:,2), compressedImage(:,:,2));
        psnrBlue = psnr(originalFace(:,:,3), compressedImage(:,:,3));
        
        % Compute overall PSNR as the average of individual channel PSNR values
        psnrValues(j) = (psnrRed + psnrGreen + psnrBlue) / 3;
        
        % Compute SSIM for each color channel
        ssimRed = ssim(originalFace(:,:,1), compressedImage(:,:,1));
        ssimGreen = ssim(originalFace(:,:,2), compressedImage(:,:,2));
        ssimBlue = ssim(originalFace(:,:,3), compressedImage(:,:,3));
        
        % Compute overall SSIM as the average of individual channel SSIM values
        ssimValues(j) = (ssimRed + ssimGreen + ssimBlue) / 3;
    end

    % Plot PSNR and SSIM for each face
    figure;

    % Original Face subplot
    subplot(3, 1, 1);
    imshow(originalFace);
    title(['Original Face ' num2str(i)]);

    % PSNR subplot 
    subplot(3, 1, 2);
    plot(qualityValues, psnrValues, '-o');
    title(['PSNR vs JPEG Quality - Face ' num2str(i)]);
    xlabel('JPEG Quality');
    ylabel('PSNR');
    grid on;

    % Find the index of the maximum PSNR value
    [maxPSNR, maxIndexPSNR] = max(psnrValues);

    % Annotate the plot with the maximum PSNR value and its corresponding quality factor
    text(qualityValues(maxIndexPSNR), maxPSNR, sprintf('Max PSNR: %.2f at Q = %d', maxPSNR, qualityValues(maxIndexPSNR)), ...
        'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'BackgroundColor', 'w');
    xlim([min(qualityValues) - 5, max(qualityValues) + 5]);

    % SSIM subplot in red
    subplot(3, 1, 3);
    plot(qualityValues, ssimValues, '-o', 'Color', 'red');  % Set the line color to red
    title(['SSIM vs JPEG Quality - Face ' num2str(i)]);
    xlabel('JPEG Quality');
    ylabel('SSIM');
    grid on;

    % Find the index of the maximum SSIM value
    [maxSSIM, maxIndexSSIM] = max(ssimValues);

    % Annotate the plot with the maximum SSIM value and its corresponding quality factor
    text(qualityValues(maxIndexSSIM), maxSSIM, sprintf('Max SSIM: %.4f at Q = %d', maxSSIM, qualityValues(maxIndexSSIM)), ...
        'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom', 'BackgroundColor', 'w');
    xlim([min(qualityValues) - 5, max(qualityValues) + 5]);
end

% PSNR focuses on measuring the amount of noise or distortion, SSIM goes beyond that and considers the structural similarity
% between images. Depending on the specific use case and
% the importance of human perception, one metric may be preferred over the other.

%PSNR would be more useful in senarios like preserving details in medical images.**
% SSIM is helpful when we care about how people see the images, like in TV or movie streaming.

