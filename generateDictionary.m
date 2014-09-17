function dictionary = generateDictionary(database,dic_option)
% using k-means to generate the visual vocabulary for the image words
% @return dictionary : a k*f_dim matrix ,each row is a visual word

%---------------random select feature for training dictionary-------------%
if(~exist('dic_option','var'))
    dic_option.max_num = 100000;
    dic_option.dic_img_num = 50;
    dic_option.k = 200;
    dic_option.max_iters = 50;
end


if(~isfield(dic_option,'dic_img_num'))
    select_img_num = 50;
else
    select_img_num  = dic_option.dic_img_num;
end

if(~isfield(dic_option,'max_num'))
    features_per_img = 100000/select_img_num;
else
    features_per_img = dic_option.max_num/select_img_num;
end

if (~isfield(dic_option,'k'))
    k = 200;
else
    k = dic_option.k;
end

if (~isfield(dic_option,'max_iters'))
    max_iters = 100;
else
    max_iters = dic_option.max_iters;
end

features = [];  % here may get a index error
features_num = length(database.feature_path);

if(select_img_num>features_num)
    select_img_num = features_num;
    features_per_img = dic_option.max_num/select_img_num;
end

rnd_idx = randperm(features_num);   % random select image for feature dictionay
select_idx = rnd_idx(1:select_img_num);

for i = 1:select_img_num
    f_path = database.feature_path{select_idx(i)};
    load(f_path);
    select_num = floor(features_per_img);  % the selected features number in one image
    rnd_sel = randperm(size(feature.data,2));
    if(features_per_img>length(rnd_sel))
        select_num = length(rnd_sel);
    end
    sel_feature = feature.data(:,rnd_sel(1:select_num));
    features = [features,sel_feature];
end

%--------------use k-means for the dictionary training--------------------%
[num,~] = size(features);
features = double(features');   % every row as a data

if (~isfield(dic_option,'init_dic'))
    rnd_idx = randperm(size(features,1));
    centroids = features(rnd_idx(1:k),:);
else
    centroids = dic_option.init_dic;
end

k = size(centroids,1);

idx = zeros(num,1);
for i = 1:max_iters
    fprintf('K-means iteration %d/%d...\n',i,max_iters);
    idx = findClosestCentroids(features,centroids);
    centroids = computeCentroids(features,idx,k);
end

dictionary = centroids;

end