
%% here is loop for the dictionary training
%------------------ get visual word class mat ----------------------------%
loop = 5;
% the following param should be initial in main
dic_dir; % the directory to store dictionary
data_dir; % the directory to store feature_mat and idx_mat
dictionary; % the initial dictionary for the k-means
visual_dic_size = dic_option.k;
feature_database = database;    % the feature database

for loop_i = 1:loop
    if(loop_i==1)
        suffix = '_idx';    % load the origin index mat
    else
        suffix = '_ridx';   % load the re-assign index mat
    end
    idx_database = retrievalDatabase(data_dir,suffix);    % the 
    idx_paths = idx_database.feature_path;
    idx_labels = idx_database.label;
    total_pic = length(idx_labels);
    wordsAll = zeros(visual_dic_size,total_pic);
    for i = 1:length(idx_paths)
        % here the image is a image that every feature is a dictionary word
        load(idx_paths{i});
        wordsFreq = hist(idx_sig.data,1:visual_dic_size);
        wordsAll(:,i) = wordsFreq';
    end

    %--------------- get the most salient visual word ------------------------%
    select_word_ids = featureSelection(wordsAll,idx_labels);
    select_word_data = dictionary(select_word_ids,:);

    %-------- re-train dictionary with the selected initial center -----------%
    fprintf('The dictionary re-training...\n');
    dic_option.max_num = 100000;
    dic_option.dic_img_num = 50;
    dic_option.init_dic = select_word_data;        % the initial dictionary
    dic_option.max_iters = 10;  
    dictionary = generateDictionary(feature_database,dic_option);
    visual_dic_size = size(dictionary,1);
    if(loop_i==loop) % write the finally dictionary out
        dic_path = fullfile(dic_dir,['re_',dataname,'_',num2str(dic_option.max_num),'_',num2str(visual_dic_size),feature_option.suffix,'.mat']);
        save(dic_path,'dictionary');
    end

    %---------- reassignment the feature to a visual words -------------------%
    fprintf('re-assignment index...\n');
    assignment_option.dictionary = dictionary;
    assignment_option.suffix = '_ridx';
    idx_database = assignmentIndexFeature(feature_database,data_dir,assignment_option);
end

select_word_ids = 1:length(select_word_ids);
