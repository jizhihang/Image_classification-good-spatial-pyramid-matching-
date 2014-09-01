function pyramid_bins = getBinsFromPyramidLevel( pyramid_level )
%GETBINSFROMPYRAMIDLEVEL Summary of this function goes here
%   Detailed explanation goes here

switch pyramid_level
    case 1
        pyramid = 1;
    case 2
        pyramid = [1 2];
    case 3
        pyramid = [1 2 4];
    case 4
        pyramid = [1 2 4 8];
    otherwise
        disp('Error.The level must be 1,2,3 or 4,please check it');
end
pyramid_bins = sum(pyramid.^2);

end

