%%  Experiment of best color space and scale filter for contrast salient detection 
% 为频域对比度增强选取最优色彩空间和尺度滤波

%%  读取路径
im_path='..\Li Jian\Images\';
gt_path='..\Li Jian\GT gray\';
result_path='..\Result\';

im_name=imagePathRead(im_path);
gt_name=imagePathRead(gt_path);
im_n=length(im_name);

%%  设置显著性检测参数
params.centra='cos';                %中心化遮罩:cos
filter_size=[0.08,0.7;0.08,0.7;0.08,0.7]; %不同方法的细节尺度范围

colorspace=cell(3,1);
colorspace{1}='rgb';
colorspace{2}='lab';
colorspace{3}='hsv';

params.ftPara='dct';    %频域对比度增强使用dct变换
params.alpha=0.001;     %最低频信息平方数
params.beta=0.2;        %最高频信息平方数

scalefilter=cell(3,1);
scalefilter{1}='gaussLow';
scalefilter{2}='gaussBand';
scalefilter{3}='DOG';

%% 不同组合实验
% 生成文件夹
mkdir(result_path); %生成新文件夹
for i=1:3
    for j=1:3
        mkdir([result_path,colorspace{i},'-',scalefilter{j}]); %生成新文件夹
    end
end

disp(['频域对比度增强的最佳组合选取，共包含图像 ',num2str(im_n)]);
for i=1:im_n
    im_in=imread((fullfile(im_path,im_name{i})));
    im_in=imresize(im_in,0.4);
    
    if i==1
        figure(102);
        im_handle=imshow(im_in);
    else
        try
            set(im_handle, 'CData', im_in);
        catch
            return
        end
    end
    
    for j=1:3
        params.colorSpace=colorspace{j};
        
        for k=1:3
            params.slPara.kernel=scalefilter{k};
            params.slPara.size=filter_size(k,:);
            
            [sl_map,salient_im,ft_map]=AdaptiveContrastSalientDetection(im_in,params);
            
            if i==1
                figure(101);
                sl_handle=imshow(sl_map);
            else
                try
                    set(sl_handle, 'CData', sl_map);
                catch
                    return
                end
            end
            
            drawnow;
            
            imwrite(sl_map,[result_path,colorspace{j},'-',scalefilter{k},'\',im_name{i}]);
        end
    end
end

%%  结果统计
correlation=cell(3,3);      %图像相关性
precision_recall=cell(3,3); %PR曲线
roc_curve=cell(3,3);        %ROC曲线

disp('结果统计:计算相关分布,PR曲线,ROC曲线');

for i=1:3
    for j=1:3
        disp(['当前进度:',colorspace{i},'-',scalefilter{j}]);
        result_path_c=[result_path,colorspace{i},'-',scalefilter{j},'\'];
        
        %相关系数统计
        [correlation{i,j}.dsb,correlation{i,j}.cor,correlation{i,j}.cor_aver,correlation{i,j}.cor_std]=mapCorrelation(result_path_c,gt_path);
        
        %PR曲线统计
        [precision_recall{i,j}.p,precision_recall{i,j}.r,precision_recall{i,j}.p_aver,roc_curve{i,j}.tpr,roc_curve{i,j}.fpr,roc_curve{i,j}.auc]=precisionRecallandROC(result_path_c,gt_path);
    end
end

%%  绘图
% 相关性分布
figure(1);
plot(correlation{1,1}.cor,correlation{1,1}.dsb,correlation{1,2}.cor,correlation{1,2}.dsb,correlation{1,3}.cor,correlation{1,3}.dsb,...
    correlation{2,1}.cor,correlation{2,1}.dsb,correlation{2,2}.cor,correlation{2,2}.dsb,correlation{2,3}.cor,correlation{2,3}.dsb,...
    correlation{3,1}.cor,correlation{3,1}.dsb,correlation{3,2}.cor,correlation{3,2}.dsb,correlation{3,3}.cor,correlation{3,3}.dsb);
legend('RGB-GLP','RGB-GBP','RGB-DoG','Lab-GLP','Lab-GBP','Lab-DoG','HSV-GLP','HSV-GBP','HSV-DoG');
title('Correlation Coefficient Distribution');
xlabel('Correlation Coefficient');
ylabel('Probability');

% pr曲线
figure(2);
plot(precision_recall{1,1}.r,precision_recall{1,1}.p,precision_recall{1,2}.r,precision_recall{1,2}.p,precision_recall{1,3}.r,precision_recall{1,3}.p,...
    precision_recall{2,1}.r,precision_recall{2,1}.p,precision_recall{2,2}.r,precision_recall{2,2}.p,precision_recall{2,3}.r,precision_recall{2,3}.p,...
    precision_recall{3,1}.r,precision_recall{3,1}.p,precision_recall{3,2}.r,precision_recall{3,2}.p,precision_recall{3,3}.r,precision_recall{3,3}.p);
axis([0,1,0,0.8]);
legend('RGB-GLP','RGB-GBP','RGB-DoG','Lab-GLP','Lab-GBP','Lab-DoG','HSV-GLP','HSV-GBP','HSV-DoG');
title('Precision-Recall');
xlabel('Recall');
ylabel('Precision');

% roc曲线
figure(3);
plot(roc_curve{1,1}.fpr,roc_curve{1,1}.tpr,roc_curve{1,2}.fpr,roc_curve{1,2}.tpr,roc_curve{1,3}.fpr,roc_curve{1,3}.tpr,...
    roc_curve{2,1}.fpr,roc_curve{2,1}.tpr,roc_curve{2,2}.fpr,roc_curve{2,2}.tpr,roc_curve{2,3}.fpr,roc_curve{2,3}.tpr,...
    roc_curve{3,1}.fpr,roc_curve{3,1}.tpr,roc_curve{3,2}.fpr,roc_curve{3,2}.tpr,roc_curve{3,3}.fpr,roc_curve{3,3}.tpr);
axis([0,1,0,1]);
legend('RGB-GLP','RGB-GBP','RGB-DoG','Lab-GLP','Lab-GBP','Lab-DoG','HSV-GLP','HSV-GBP','HSV-DoG');
title('ROC');
xlabel('FPR');
ylabel('TPR');

%% 表格：各个方法的平均相关系数、平均精度与AUC对比
result_table=zeros(3,9);
for i=1:3
    for j=1:3
        index=(i-1)*3+j;
        
        %平均相关性
        result_table(1,index)=correlation{i,j}.cor_aver;
        
        %平均准确率
        result_table(2,index)=precision_recall{i,j}.p_aver;
        
        %AUC
        result_table(3,index)=roc_curve{i,j}.auc;
    end
end