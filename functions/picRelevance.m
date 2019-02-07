function rela=picRelevance(im1,im2)
% 计算两个图像之间的相关性
%输入：
%@im1       输入图像
%@im1       基准图像
%输出：
%@rela      相关性

% 数据标准化
im1=mat2gray(im1);
im2=mat2gray(im2);

% 计算相关性
re_im=im1.*im2;
rela=sum(re_im(:))/sqrt((sum(im1(:).^2)*sum(im2(:).^2)));
end