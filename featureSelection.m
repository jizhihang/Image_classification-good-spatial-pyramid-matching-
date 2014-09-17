function valid_word_ids = featureSelection( wordsAll,labels,num_per_class)
% This is the visual feature selection using chi-square
% details at http://www.blogjava.net/zhenandaci/archive/2008/08/31/225966.html
% 
% 
% @param wordsAll : a words_num X img_num matrix ,where each column is a
%                    representation for the image X in the feature space
% @param labels : a img_num X 1 vector to for the image labels
% @param num_per_class : the select number for per class
%
% @return valid_word_ids : a n X 1 vector contains the id for the right words

[words_num,img_num] = size(wordsAll);
label_id = unique(labels);
class_num = length(label_id);
boolArray = wordsAll>0;

% ------- choose the class related visual words by chi-square-------------%
% the element (i,j) in this matrix is the chi-square value words(i) for class(j)
chi_square = zeros(words_num,class_num);
for i = 1:class_num
    class_in_i_idx = labels==label_id(i);
    class_not_i_idx = labels~=label_id(i);
    class_i_num = sum(class_in_i_idx);
    class_not_i_num = sum(class_not_i_idx);
    for w = 1:words_num
        contain_w = boolArray(w,:);
        n_contain_w = sum(contain_w);
        if(n_contain_w==0 || n_contain_w==img_num) % if the word appear in every image
            chi_square(w,i) = 0;
        else
            A_contain_w_in_class = sum(contain_w(class_in_i_idx));
            B_contain_w_not_in_class = sum(contain_w(class_not_i_idx));
            not_contain_w = ~contain_w;
            C_not_contain_w_in_class = sum(not_contain_w(class_in_i_idx));
            D_not_contain_w_not_in_class = sum(not_contain_w(class_not_i_idx));
            % chi-square = N*(AD-BC)^2/((A+B)(C+D)(A+C)(B+D));
            chi_square(w,i) = img_num*(A_contain_w_in_class*D_not_contain_w_not_in_class-B_contain_w_not_in_class*C_not_contain_w_in_class)^2;        
            chi_square(w,i) = chi_square(w,i)/((A_contain_w_in_class+B_contain_w_not_in_class)*(C_not_contain_w_in_class+D_not_contain_w_not_in_class)*class_i_num*class_not_i_num);
        end
    end
end
min(chi_square)
max(chi_square)
disp('debug');
[~,word_idx] = sort(chi_square,'descend');
select_words = word_idx(1:num_per_class,:);
chi_square_ids = unique(select_words);


% ------------ choose the global visual words by info gain ---------------%
info_gain = zeros(words_num,1);
% the info gain IG(term) = H(C)-H(C|T);
% H(C) is the entropy of the system
% H(C|T) is the condition entroy with the term T
H_class = computeEntropy(labels);
prob_words = sum(boolArray,2)/img_num;
prob_not_words = 1-prob_words;
for w = 1:words_num
    prob_w = prob_words(w);
    prob_not_w = prob_not_words(w);
    w_bool = boolArray(w,:);
    labels_with_w = labels(w_bool);
    labels_not_w = labels(~w_bool);
    entropy_with_w = computeEntropy(labels_with_w);
    entropy_not_w = computeEntropy(labels_not_w);
    condition_entropy = prob_w*entropy_with_w+prob_not_w*entropy_not_w;
    info_gain(w) = H_class-condition_entropy;
end
num_total = sum(info_gain>0.1);
[~,info_gain_ids] = sort(info_gain,'descend');
info_gain_ids = info_gain_ids(1:num_total);

valid_word_ids = unique([info_gain_ids;chi_square_ids]);

end

function entropy = computeEntropy(labels)
    if ~isrow(labels) && ~iscolumn(labels),
        fprintf('error input for entropy calculating in featureSelection!');
    elseif isempty(labels),
        entropy = 0;
    else
        table = tabulate(labels);
        prob = table(:,3)/100;
        select = prob~=0;
        prob = prob(select);
        entropy = -sum(prob.*log2(prob));
    end
end


