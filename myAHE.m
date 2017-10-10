function [] = myAHE (inImg, nBins, wSize)

% Reading Image
I = imread(inImg);
[m,n,r] = size(I);
%outImg = I;

sizeBins = floor((256 / nBins));

% wsize = 1 implies size of window = 3x3
% wsize = x implies size of window = (2*w + 1) x (2*w + 1)
for a = wSize+1:1:m-wSize
    for b = wSize+1:1:n-wSize
        
        % Generating Histogram for Original Image for given window
        org_H = zeros(nBins,r);
        for i = a-wSize:1:a+wSize
            for j = b-wSize:1:b+wSize
                for k = 1:1:r
                    bin = floor((I(i,j,k)/sizeBins)) + 1;
                    org_H(bin,k) = org_H(bin,k) + 1;
                end
            end
        end

        % Converting Histogram Values to PDF
        org_H = org_H/((2*wSize + 1)*(2*wSize + 1));

        % Converting PDF to CDF
        for i = 2:1:nBins
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
                if(ceil(temp) - temp > 0.5)
                    % Correct Bin will be floor(temp)
                    correct_bin = floor(temp);
                else
                    % Correct Bin will ceil(temp)
                    correct_bin = ceil(temp);
                end
                % Filling Entries of New Histogram
                new_H(i,j) = (correct_bin * sizeBins) + floor(0.5 * sizeBins);
            end
        end

        % Creating Output Image
        for k = 1:1:r
            bin = floor((I(a,b,k)/sizeBins)) + 1;
            I(a,b,k) = new_H(bin,k);
        end
        
    end
end

%imshow(I);
%outImg = uint8(outImg);
imshow(I);

end