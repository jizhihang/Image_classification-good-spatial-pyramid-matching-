function database = retrievalDatabase( data_dir ,suffix)
%RETRIEVALFEATUREDATABASE retrieval the mat database with the suffix 
%   this function saw a data_dir as the feature dir
%   each subfolder in data_dir is one class of feature 
%   the data is stored in the 'suffix.mat' file

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

end

