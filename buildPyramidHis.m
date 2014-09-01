function spm_histogram = buildPyramidHis(index_im,pyramid_level,dic_wc)

   %% get width and height of input image
    width = index_im.width;
    height = index_im.height;
    
    %% compute histogram at the finest level
    pyramid_cell = cell(pyramid_level,1);
    binsHigh = 2^(pyramid_level-1);
    pyramid_cell{1} = zeros(binsHigh, binsHigh, dic_wc);

    for i=1:binsHigh
        for j=1:binsHigh

            % find the coordinates of the current bin
            x_lo = floor(width/binsHigh * (i-1));
            x_hi = floor(width/binsHigh * i);
            y_lo = floor(height/binsHigh * (j-1));
            y_hi = floor(height/binsHigh * j);
            
            texton_patch = index_im.data( (index_im.x > x_lo) & (index_im.x <= x_hi) & ...
                                            (index_im.y > y_lo) & (index_im.y <= y_hi));
            
            % make histogram of features in bin
            pyramid_cell{1}(i,j,:) = hist(texton_patch, 1:dic_wc)./length(index_im.data);
        end
    end

    %% compute histograms at the coarser levels
    num_bins = binsHigh/2;
    for l = 2:pyramid_level
        pyramid_cell{l} = zeros(num_bins, num_bins, dic_wc);
        for i=1:num_bins
            for j=1:num_bins
                pyramid_cell{l}(i,j,:) = ...
                pyramid_cell{l-1}(2*i-1,2*j-1,:) + pyramid_cell{l-1}(2*i,2*j-1,:) + ...
                pyramid_cell{l-1}(2*i-1,2*j,:) + pyramid_cell{l-1}(2*i,2*j,:);
            end
        end
        num_bins = num_bins/2;
    end

    %% stack all the histograms with appropriate weights
    pyramid = [];
    for l = 1:pyramid_level-1
        pyramid = [pyramid pyramid_cell{l}(:)' .* 2^(-l)];
    end
    pyramid = [pyramid pyramid_cell{pyramid_level}(:)' .* 2^(1-pyramid_level)];
    spm_histogram = pyramid;
end