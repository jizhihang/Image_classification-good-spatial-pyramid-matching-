function idx_database = assignmentIndexFeature(database,data_dir,assignment_option)
% This function calculate the feature signature for the data

idx_database = database;
idx_database.idx_path = {};
suffix = assignment_option.suffix;
dictionary = assignment_option.dictionary;
num_vac = size(dictionary,1);

for i = 1:length(database.feature_path)
    feature_path = database.feature_path{i};
    load(feature_path);
    [dir_path,name,~] = fileparts(feature_path);
    idx_path = fullfile(dir_path,[name,'_',num2str(num_vac),suffix,'.mat']);
    idx_sig.x = feature.x;
    idx_sig.y = feature.y;
    idx_sig.width = feature.width;
    idx_sig.height = feature.height;
    idx = findClosestCentroids(double(feature.data'),dictionary);   % assignment the index for the feature
    idx_sig.data = idx;
    save(idx_path,'idx_sig');
    idx_database.idx_path = [idx_database.idx_path;idx_path];
end

end % end function
