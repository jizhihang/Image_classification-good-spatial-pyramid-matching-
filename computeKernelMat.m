function kernel_mat = computeKernelMat(data1,data2)
% This function compute the mercer kernel value for the data
% param data1 : n x dim data matrix
% param data2 : m x dim data matrix

[feature_num_1,dim_1] = size(data1);
[feature_num_2,dim_2] = size(data2);

kernel_mat = zeros(feature_num_1,feature_num_2);
if dim_1 ~= dim_2
    disp('Error for kernel matrix!The dimension not match!');
    return;
end

for i = 1:feature_num_1
    for j = 1:feature_num_2
        kernel_mat(i,j) = sum(min(data1(i,:),data2(j,:)));
    end
end

end