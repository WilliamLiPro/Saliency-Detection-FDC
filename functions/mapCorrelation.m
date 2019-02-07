%% 图像相关性分布计算
function [distrb,cor,cor_aver,cor_std]=mapCorrelation(im_path,gt_path)
%读取路径
im_name=imagePathRead(im_path);
gt_name=imagePathRead(gt_path);

%计算相关性
n=min(length(im_name),length(gt_name));
distrb=zeros(1,20);
for i=1:n
    %读取图像
    im_in=imread((fullfile(im_path,im_name{i})));
    gt=imread((fullfile(gt_path,gt_name{i})));
    
    if length(size(im_in))==3
        im_in=rgb2gray(im_in);
    end
    
    im_in=im2double(im_in);
    im_in=im_in/max(im_in(:));
    
    gt=im2double(gt);
    gt=imresize(gt,size(im_in));    %尺度相同
    
    %计算相关性
    q=picRelevance(im_in,gt);
    id=ceil(q*20);
    
    distrb(id)=distrb(id)+1;
end

distrb=distrb/n;
cor=0.05:0.05:1;
cor_aver=sum(distrb.*cor);
cor_std=sqrt(sum(distrb.*cor.^2)-cor_aver.^2);
end

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