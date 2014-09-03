lib_add = 'C:/Program Files/MATLAB/R2013a/lib_add';
vl_feat_setup = fullfile(lib_add,'vlfeat-0.9.18-bin/vlfeat-0.9.18/toolbox/vl_setup');
libsvm_path = fullfile(lib_add,'libsvm-3.18/matlab');
run(vl_feat_setup);
addpath(libsvm_path);