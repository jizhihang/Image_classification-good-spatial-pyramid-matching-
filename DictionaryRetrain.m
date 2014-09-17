
feature_database = database;    % the feature database
idx_database = idx_database;    % the 

dic_dir = '';
data_dir = '';

idx_paths = idx_database.feature_path;
idx_labels = idx_database.label;
total_pic = length(idx_labels);
wordsAll = zeros(200,total_pic);
for i = 1:length(idx_paths)
    % here the image is a image that every feature is a dictionary word
    load(idx_paths{i});
    wordsFreq = hist(idx_sig.data,1:visual_dic_size);
    wordsAll(:,i) = wordsFreq';
end
select_word_ids = featureSelection(wordsAll,idx_labels,select_per_class);

fprintf('The dictionary re-training...\n');
dic_option.max_num = 100000;
dic_option.dic_img_num = 50;
dic_option.k = 200;
dic_option.init_dic = 1;        % the initial dictionary
dic_option.max_iters = 50;
dic_path = fullfile(dic_dir,[dataname,'_',num2str(dic_option.max_num),'_',num2str(dic_option.k),feature_option.suffix,'.mat']);
if ~isdir(dic_dir)
    mkdir(dic_dir);
end
dictionary = generateDictionary(feature_database,dic_option);
save(dic_path,'dictionary');

fprintf('re-assignment index...\n');
assignment_option.dictionary = dictionary;
assignment_option.suffix = '_ridx';
idx_database = assignmentIndexFeature(feature_database,data_dir,assignment_option);
