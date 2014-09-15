data_dir = 'data/scene_categories';
suffix = 'dsift_200_idx';
fprintf('retrival the database %s...\n',suffix);

subfolders = dir(data_dir);
database.class_name = {};
database.label = [];
% database.img_path = {};
database.feature_path = {};
database.num_class = 0;
for c = 1:length(subfolders),
    class_name = subfolders(c).name;
    if ~strcmp(class_name,'.') & ~strcmp(class_name,'..'),
        database.num_class = database.num_class+1;
        database.class_name{database.num_class} = class_name;
        feature_path = dir(fullfile(data_dir,class_name,['*' suffix '.mat']));
        c_num = length(feature_path);
        database.label = [database.label;ones(c_num,1)*database.num_class];
        for i = 1:c_num
            f_path = fullfile(data_dir,class_name,feature_path(i).name);
            database.feature_path = [database.feature_path;f_path];
        end
    end
end

% 
idx_paths = database.feature_path;
labels = database.label;
total_pic = length(labels);
wordsAll = zeros(200,total_pic);
 
for i = 1:length(idx_paths)
    % here the image is a image that every feature is a dictionary word
    load(idx_paths{i});
    wordsFreq = hist(idx_sig.data,1:200);
    wordsAll(:,i) = wordsFreq';
end

chi_square = featureSelection(wordsAll,labels);



