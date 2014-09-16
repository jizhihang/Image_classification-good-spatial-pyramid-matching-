function [spm_sig,labels] = computeSPM(idx_database,spm)

suffix = spm.suffix;
pyramid_level = spm.pyramid_level;
dic_wc = spm.dic_wc;
select_dic_word = spm.dic_word_id;
if(iscolumn(select_dic_word))
    select_dic_word = select_dic_word';
end

idx_paths = idx_database.feature_path;
labels = idx_database.label;

pyramid_bin_total = getBinsFromPyramidLevel(pyramid_level);
hist_bin = pyramid_bin_total*dic_wc;
spm_sig = zeros(length(idx_paths),hist_bin);

for i = 1:length(idx_paths)
    % here the image is a image that every feature is a dictionary word
    load(idx_paths{i});
    [dir_name,base_name] = fileparts(idx_paths{i});
    subset.width = idx_sig.width;
    subset.height = idx_sig.height;
    re_map_id = 1;
    subset.data = [];
    subset.x = [];
    subset.y = [];
    for w_id = select_dic_word,
        select_w_idx = (idx_sig.data==w_id);
        w_count = sum(select_w_idx);
        subset.data = [subset.data;ones(w_count,1)*re_map_id];
        subset.x = [subset.x;(idx_sig.x(select_w_idx))'];
        subset.y = [subset.y;(idx_sig.y(select_w_idx))'];
        re_map_id = re_map_id+1;
    end
    out_file = fullfile(dir_name,[base_name,suffix,'.mat']);
    SPM_histogram = buildPyramidHis(subset,pyramid_level,dic_wc);
    save(out_file,'SPM_histogram');
    spm_sig(i,:) = SPM_histogram;
end

end
