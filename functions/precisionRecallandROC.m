%%  图像PR曲线计算
function [p,r,paver,tpr,fpr,auc]=precisionRecallandROC(im_path,gt_path)
%读取路径
im_name=imagePathRead(im_path);
gt_name=imagePathRead(gt_path);

%统计PR曲线
n=min(length(im_name),length(gt_name));

thresholds=[0:0.02:0.98];
p=zeros(50,1);  %p-r
r=p;
tpr=p;  %roc
fpr=r;

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
    
    gt_num=sum(gt(:));                  % real positive
    real_ng=size(gt,1)*size(gt,2)-gt_num;   %real negative
    
    %计算pr与ROC
    for j=1:50
        thr=thresholds(j);
        
        im_bool=im_in>=thr;  %预测前景
        
        its=double(im_bool).*gt;    %预测正确的前景加权
        sum_it=sum(its(:));
        
        %pr
        im_false=sum(im_bool(:))-sum_it;       %正预测预测错误数目
        im_num=im_false+sum_it;             % 总的前景加权(false positive + true positive)
        
        if im_num>0;            %准确率
            cur_p=sum_it/im_num;
        else
            cur_p=1;
        end
        
        cur_r=sum_it/gt_num;    %召回率
        
        p(j)=p(j)+cur_p;
        r(j)=r(j)+cur_r;
        
        %roc
        tp=cur_r;               %正样本正确率等于正召回率
        fp=im_false/real_ng;    %正样本错误率等于错误召回率
        
        tpr(j)=tpr(j)+tp;
        fpr(j)=fpr(j)+fp;
    end
end

p=p/n;
r=r/n;

tpr=tpr/n;
fpr=fpr/n;

paver=sum(p.*(r-[r(2:50);0]));  %平均精度
auc=sum(tpr.*(fpr-[fpr(2:50);0]));  %AUC值
end