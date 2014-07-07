function database =  calculateImageFeature(image_dir,data_dir,feature_option)
fprintf('extracting feature for the image...\n');

subfolders = dir(image_dir);

database.class_name = {};
database.label = [];
% database.img_path = {};
database.feature_path = {};
database.num_class = 0;

suffix = feature_option.suffix;

for c = 1:length(subfolders),
    class_name = subfolders(c).name;
    if ~strcmp(class_name,'.') & ~strcmp(class_name,'..')   % the folder is real image folder
        database.num_class = database.num_class + 1;
        database.class_name{database.num_class} = class_name;

        images = dir(fullfile(image_dir,class_name,'*.jpg'));
        c_num = length(images);

        database.label = [database.label;ones(c_num,1)*database.num_class];

        feature_dir = fullfile(data_dir,class_name);
        if ~isdir(feature_dir),
            mkdir(feature_dir);
        end

        for i = 1:c_num,
            img_path = fullfile(image_dir,class_name,images(i).name);
            image = imread(img_path);
            if ndims(image) ==3,
                image = im2single(rgb2gray(image));
            else
                image = im2single(image);
            end
            [im_h,im_w] = size(image);
            if max(im_h,im_w) > feature_option.max_size,
                image = imresize(image,feature_option.max_size/max(im_h,im_w),'bicubic');
                [im_h,im_w] = size(image);
            end
            [position,des] = vl_dsift(image,'step',3);
            feature.x = position(1,:);
            feature.y = position(2,:);
            feature.data = des;
            feature.width = im_w;
            feature.height = im_h;
            
            [~,img_name,~] = fileparts(images(i).name);
            feature_path = fullfile(feature_dir,[img_name,suffix,'.mat']);
            save(feature_path,'feature');
            database.feature_path = [database.feature_path;feature_path];
%             database.img_path = [database.img_path;img_path];
        end
    end
end

end % end function
