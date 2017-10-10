function [] = myHistEqual (inImg, nBins)

% Reading Image
I = imread(inImg);
[m,n,r] = size(I);

% Initializing Originial Image Histogram by assigning value 0 to each bin 
org_H = zeros(nBins,r);
sizeBins = floor((256 / nBins));

% Generating Histogram for Original Image
for i = 1:1:m
    for j = 1:1:n
        for k = 1:1:r
            bin = floor((I(i,j,k)/sizeBins)) + 1;
%             if(bin > nBins)
%                 bin = nBins;
%             end
            org_H(bin,k) = org_H(bin,k) + 1;
        end
    end
end

% Converting Histogram Values to PDF
org_H = org_H/(m*n);

% Converting PDF to CDF
for i = 2:nBins
    for j = 1:1:r
        org_H(i,j) = org_H(i-1,j) + org_H(i,j);
    end
end

% Creating Histogram after Histogram Equalization
new_H = zeros(nBins,r);

for i = 1:1:nBins
    for j = 1:1:r
        temp = org_H(i,j) * (nBins-1);
        % Assigning values of CDF to corresponding correct bin
        if(temp - floor(temp) < 0.5)
            % Correct Bin will be floor(temp)
            correct_bin = floor(temp);
        else
            % Correct Bin will ceil(temp)
            correct_bin = ceil(temp);
        end
%         % Filling Entries of New Histogram
        new_H(i,j) = (correct_bin * sizeBins) + floor(0.5 * sizeBins);
    end
end

% Creating Output Image
outImg = zeros(m,n,r);

for i = 1:1:m
    for j = 1:1:n
        for k = 1:1:r
            bin = floor((I(i,j,k)/sizeBins)) + 1;
%             if(bin > nBins)
%                 bin = nBins;
%             end
            outImg(i,j,k) = new_H(bin,k);
        end
    end
end
outImg=uint8(outImg);
imshow(outImg);

end