function pooling_sig = poolingImage(idx_database,pooling_option)
% pooling image using the spatial pyramid matching

dic_dim = pooling_option.dic_dim;
pyramid = pooling_option.pyramid;
num_pic = length(idx_database.feature_path);

p_levels = length(pyramid);
p_bins = pyramid.^2;
p_dim = sum(pyramid.^2);
pooling_sig = zeros(num_pic,p_dim*dic_dim);

for i = 1:num_pic
    % load each image features
    load(idx_database.feature_path{i}); 
    
    pic_pooling_sig = zeros(dic_dim,p_dim);
    img_width = idx_sig.width;
    img_height = idx_sig.height;
    x = idx_sig.x;
    y = idx_sig.y;
    data = idx_sig.data;
    
    b_id = 0;
    % get the pyramid level signature
    for level = 1:p_levels
        n_bins = p_bins(level);
        
        % find which spatial bin each local descriptor belongs to
        w_unit = img_width/pyramid(level);
        h_unit = img_height/pyramid(level);
        x_bin = ceil(x/w_unit);
        y_bin = ceil(y/h_unit);
        idx_bin = (y_bin-1)*pyramid(level)+x_bin;
        
        for bin = 1:n_bins;
            b_id = b_id+1;
            s_idx_bin = find(idx_bin==bin); % the local descriptor in the spatial bin
            if isempty(s_idx_bin)
                continue;
            end
            % here compute the signature on visual vocabulary
            p_idx_data = data(s_idx_bin,:);
            pic_pooling_sig(:,b_id) = histc(p_idx_data,1:dic_dim);    % 
        end
    end
    
    if b_id ~= p_dim
        error('Index number error!');
    end
    
    pic_pooling_sig = pic_pooling_sig(:);
    pooling_sig(i,:) = pic_pooling_sig;
end


end