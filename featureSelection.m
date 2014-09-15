function chi_square = featureSelection( wordsAll,labels )
% This is the visual feature selection using chi-square
% details at http://www.blogjava.net/zhenandaci/archive/2008/08/31/225966.html
% 
% @param wordsAll : a words_num X img_num matrix ,where each column is a
%                    representation for the image X in the feature space
%
% @param labels : a img_num X 1 vector to for the image labels
% @return chi_square : a words_num X class_num matrix ,the element (i,j) in
%                  this matrix is the chi-square value words(i) for class(j)

[words_num,~] = size(wordsAll);
label_id = unique(labels);
class_num = length(label_id);

boolArray = wordsAll>0;

chi_square = zeros(words_num,class_num);

for i = 1:class_num
    class_in_i_idx = labels==label_id(i);
    class_not_i_idx = labels~=label_id(i);
    for w = 1:words_num
        A_contain_w_in_class = sum(boolArray(w,class_in_i_idx));
        B_contain_w_not_in_class = sum(boolArray(w,class_not_i_idx));
        not_contain_w_array = [boolArray(1:w-1,:);boolArray(w+1:end,:)];
        C_not_contain_w_in_class = sum(sum(not_contain_w_array(:,class_in_i_idx)));
        D_not_contain_w_not_in_class = sum(sum(not_contain_w_array(:,class_not_i_idx)));
        % chi-square = (AD-BC)^2/((A+B)(C+D));
        chi_square(w,i) = (A_contain_w_in_class*D_not_contain_w_not_in_class-B_contain_w_not_in_class*C_not_contain_w_in_class)^2;
        chi_square(w,i) = chi_square(w,i)/((A_contain_w_in_class+B_contain_w_not_in_class)*(C_not_contain_w_in_class+D_not_contain_w_not_in_class));
    end
end

end

