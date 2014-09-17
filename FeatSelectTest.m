


% num_per_class = 15;
% valid_word_ids = featureSelection( wordsAll,labels,num_per_class);

clear;clc;
image_num = 8;
word_num = 5;
% wordFreqImage = randi(10,word_num,image_num);
% wordFreqImage = wordFreqImage - min(min(wordFreqImage))
% labels = randi(3,1,image_num)


wordFreqImage=[5     7     2     0     5     9     0     9
     4     3     6     2     9     0     3     1
     0     5     6     9     0     7     2     2
     3     1     7     1     4     8     8     1
     1     6     4     8     1     8     4     1]
labels = [3     2     2     1     3     2     2     2]

valid_word_ids = featureSelection(wordFreqImage,labels,1);

A = 1;
B = 5;
C = 0;
D = 2;
chi = image_num*(A*D-B*C)^2/((A+C)*(A+B)*(B+D)*(C+D));
