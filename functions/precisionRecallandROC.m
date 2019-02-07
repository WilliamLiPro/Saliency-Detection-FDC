%%  ͼ��PR���߼���
function [p,r,paver,tpr,fpr,auc]=precisionRecallandROC(im_path,gt_path)
%��ȡ·��
im_name=imagePathRead(im_path);
gt_name=imagePathRead(gt_path);

%ͳ��PR����
n=min(length(im_name),length(gt_name));

thresholds=[0:0.02:0.98];
p=zeros(50,1);  %p-r
r=p;
tpr=p;  %roc
fpr=r;

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
    
    gt_num=sum(gt(:));                  % real positive
    real_ng=size(gt,1)*size(gt,2)-gt_num;   %real negative
    
    %����pr��ROC
    for j=1:50
        thr=thresholds(j);
        
        im_bool=im_in>=thr;  %Ԥ��ǰ��
        
        its=double(im_bool).*gt;    %Ԥ����ȷ��ǰ����Ȩ
        sum_it=sum(its(:));
        
        %pr
        im_false=sum(im_bool(:))-sum_it;       %��Ԥ��Ԥ�������Ŀ
        im_num=im_false+sum_it;             % �ܵ�ǰ����Ȩ(false positive + true positive)
        
        if im_num>0;            %׼ȷ��
            cur_p=sum_it/im_num;
        else
            cur_p=1;
        end
        
        cur_r=sum_it/gt_num;    %�ٻ���
        
        p(j)=p(j)+cur_p;
        r(j)=r(j)+cur_r;
        
        %roc
        tp=cur_r;               %��������ȷ�ʵ������ٻ���
        fp=im_false/real_ng;    %�����������ʵ��ڴ����ٻ���
        
        tpr(j)=tpr(j)+tp;
        fpr(j)=fpr(j)+fp;
    end
end

p=p/n;
r=r/n;

tpr=tpr/n;
fpr=fpr/n;

paver=sum(p.*(r-[r(2:50);0]));  %ƽ������
auc=sum(tpr.*(fpr-[fpr(2:50);0]));  %AUCֵ
end