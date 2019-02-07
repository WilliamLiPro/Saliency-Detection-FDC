function pr=precisionRecall(im_in,gt)
% 计算单幅图像与基准图之间的Precision-recall曲线
%输入：
%@im_in     输入图像
%@gt        基准图像
%输出：
%@pr        precision-recall曲线

% 数据标准化
im_in=mat2gray(im_in);
gt=mat2gray(gt);

% 计算 precision-recall
cur_p=zeros(1,20);
cur_r=zeros(1,20);
for i=0.5:0.5:10
    cur_im=im_in*i;
    cur_im(cur_im>1)=1;
    
    cur_p=cur_im.*gt;
end
end