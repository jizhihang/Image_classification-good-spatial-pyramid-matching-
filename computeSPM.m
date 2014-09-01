function [spm_sig,labels] = compileSPM(idx_database,spm)

suffix = spm.suffix;
pyramid_level = spm.pyramid_level;
dic_wc = spm.dic_wc;

idx_paths = idx_database.feature_path;
labels = idx_database.label;

pyramid_bin_total = getBinsFromPyramidLevel(pyramid_level);
hist_bin = pyramid_bin_total*dic_wc;
spm_sig = zeros(length(idx_paths),hist_bin);

for i = 1:length(idx_paths)
    % here the image is a image that every feature is a dictionary word
    load(idx_paths{i});
    [dir_name,base_name] = fileparts(idx_paths{i});
    out_file = fullfile(dir_name,[base_name,suffix,'.mat']);
    SPM_histogram = buildPyramidHis(idx_sig,pyramid_level,dic_wc);
    save(out_file,'SPM_histogram');
    spm_sig(i,:) = SPM_histogram;
end

end
