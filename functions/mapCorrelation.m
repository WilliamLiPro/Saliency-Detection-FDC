%% ͼ������Էֲ�����
function [distrb,cor,cor_aver,cor_std]=mapCorrelation(im_path,gt_path)
%��ȡ·��
im_name=imagePathRead(im_path);
gt_name=imagePathRead(gt_path);

%���������
n=min(length(im_name),length(gt_name));
distrb=zeros(1,20);
for i=1:n
    %��ȡͼ��
    im_in=imread((fullfile(im_path,im_name{i})));
    gt=imread((fullfile(gt_path,gt_name{i})));
    
    if length(size(im_in))==3
        im_in=rgb2gray(im_in);
    end
    
    im_in=im2double(im_in);
    im_in=im_in/max(im_in(:));
    
    gt=im2double(gt);
    gt=imresize(gt,size(im_in));    %�߶���ͬ
    
    %���������
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
% ��������ͼ��֮��������
%���룺
%@im1       ����ͼ��
%@im1       ��׼ͼ��
%�����
%@rela      �����

% ���ݱ�׼��
im1=mat2gray(im1);
im2=mat2gray(im2);

% ���������
re_im=im1.*im2;
rela=sum(re_im(:))/sqrt((sum(im1(:).^2)*sum(im2(:).^2)));
end