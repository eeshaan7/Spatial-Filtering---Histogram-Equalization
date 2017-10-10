function [] = myCegaHE2 (inImg, nBins)

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
            org_H(bin,k) = org_H(bin,k) + 1;
        end
    end
end

% Converting Histogram Values to PDF
org_H = org_H/(m*n);
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
        if(temp - floor(temp) < 0.5)
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

% Starting Gap Adjustment Process

for k = 1:1:r
    first = 1;
    last = 2;
    for i = last:1:256
        if(new_H(i,k) ~= new_H(first,k))
            break;
        end
    end
    last = i;
    curr = last;
    a = 3;
    b = 3;    
    while (last < 256)
        % Calculating Distance
        Dist = new_H(curr,k) - new_H(first,k);
        % Calculating Gap Limiter L(G)
        G = new_H(curr,k);
        temp = a * (((G/127.0)-1)^2);
        if (temp - floor(temp) < 0.5)
            temp = floor(temp);
        else
            temp = ceil(temp);
        end
        Lim = temp + b;
        
        if (Dist <= Lim)
            % Do nothing and find next value for last
            for i = last:1:256
                if(new_H(i,k) ~= G)
                    break;
                end
            end
            last = i;
        else
            % Pull back H(x) by Dist - Lim
            gap = Dist - Lim;
            for i = last:1:256
                if(new_H(i,k) ~= G)
                    break;
                else
                    new_H(i,k) = new_H(i,k) - gap; 
                end
            end
            last = i;
        end
        first = curr;
        curr = last;
    end
end

% Creating Output Image
outImg = zeros(m,n,r);
for i = 1:1:m
    for j = 1:1:n
        for k = 1:1:r
            bin = floor((I(i,j,k)/sizeBins)) + 1;
            outImg(i,j,k) = new_H(bin,k);
        end
    end
end
outImg=uint8(outImg);
%disp(outImg);
subplot(2,3,4);
imshow(outImg);
title('After Gap Adjustment');


% Starting Gray Value Recovery Process
for k = 1:1:r
    first = 1;
    last = 2;
    for i = last:1:256
        if(new_H(i,k) ~= new_H(first,k))
            break;
        end
    end
    last = i;
    %disp(last);
    curr = last;
    while (last < 256)
        % Calculating Distance as the difference in intensity values
        Dist = new_H(curr,k) - new_H(first,k);
        if (Dist > 1)
            % Start the recovery process
            inc = 1;
            for i = first + 1:1:curr
                new_H(i,k) = new_H(i,k) + inc;
                inc = inc + 1;
                if(inc == Dist)
                    break;
                end
            end
            inc = inc - 1;
            while (i <= curr)
                new_H(i,k) = new_H(i,k) + inc;
                i = i + 1;
            end
        end
        for i = last:1:256
            if(new_H(i,k) ~= new_H(curr,k))
                break;
            end
        end
        last = i;
        first = curr;
        curr = last;
    end
end

% Creating Output Image
outImg = zeros(m,n,r);
for i = 1:1:m
    for j = 1:1:n
        for k = 1:1:r
            bin = floor((I(i,j,k)/sizeBins)) + 1;
            outImg(i,j,k) = new_H(bin,k);
        end
    end
end
outImg=uint8(outImg);
%disp(outImg);
subplot(2,3,5);
imshow(outImg);
title('After Gray Value Recovery');

% Starting Dark Region Enhancement

for k = 1:1:r
    % Calculating Mean Intensity of Image
    sum = 0;
    for i = 1:1:m
        for j = 1:1:n
            bin = floor((I(i,j,k)/sizeBins)) + 1;
%             if (bin > nBins)
%                 bin = nBins;
%             end
            sum = sum + new_H(bin,k);
        end
    end
    avg = sum/(m*n);
    
    % Calculating gradient sum of the x th gray value of the dark region
    Grad = zeros(nBins);
    count = 0; % Count will store count of pixels in dark region having intensity less than mean value
    
    for i = 1:1:m
        for j = 1:1:n
        bin = floor((I(i,j,k)/sizeBins)) + 1;
%             if (bin > nBins)
%                 bin = nBins;
%             end
        curr_I = new_H(bin,k);
        if (curr_I < avg)
            count = count + 1;
        end
        
        if (j >= 2 && j <= n-1)
            bin = floor((I(i,j-1,k)/sizeBins)) + 1;
            left_I = new_H(bin,k);
            bin = floor((I(i,j+1,k)/sizeBins)) + 1;
            right_I = new_H(bin,k);
            temp = abs(right_I - left_I);
            Grad(curr_I + 1) = Grad(curr_I + 1) + temp;
        end
        
        if (i >= 2 && i <= m-1)
            bin = floor((I(i-1,j,k)/sizeBins)) + 1;
            top_I = new_H(bin,k);
            bin = floor((I(i+1,j,k)/sizeBins)) + 1;
            bottom_I = new_H(bin,k);
            temp = abs(bottom_I - top_I);
            Grad(curr_I + 1) = Grad(curr_I + 1) + temp;
        end
        end
    end
    
    % Calculating Gradient Probabilities and CDF for all values less than mean
    avg = ceil(avg) - 1;
    sum = Grad(1);
    for i = 2:1:avg
        sum = sum + Grad(i);
        Grad(i) = Grad(i) + Grad(i-1);
    end
    
    for i = avg+1:1:nBins
        Grad(i) = Grad(avg);
    end
    
    Grad = Grad / sum;
    
    % Calculating rfp values
    rfp = 255 - new_H(nBins,k);
    R = (rfp * count)/(m*n);
    
    % Distributing R to enhance gray values
    Space = zeros(nBins);
    for i = 1:1:nBins
        Space(i) = floor(Grad(i) * R);
    end
    
    for i = 1:1:nBins
        new_H(i,k) = new_H(i,k) + Space(i);
    end

end

% Creating Output Image
outImg = zeros(m,n,r);
for i = 1:1:m
    for j = 1:1:n
        for k = 1:1:r
            bin = floor((I(i,j,k)/sizeBins)) + 1;
            outImg(i,j,k) = new_H(bin,k);
        end
    end
end
outImg = uint8(outImg);
%disp(outImg);
subplot(2,3,6);
imshow(outImg);
title('After Dark Region Enhancement');

end