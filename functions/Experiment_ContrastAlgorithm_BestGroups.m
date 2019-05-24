%%  Experiment of best color space and scale filter for contrast algorithm
% 为各个对比算法查找最优组合

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

feature=cell(7,1);
feature{1}='IS';%image signature
feature{2}='SR';
feature{3}='log';
feature{4}='HFT';
feature{5}='FSI';
feature{6}='SFT';
feature{7}='FAS';

scalefilter=cell(3,1);
scalefilter{1}='gaussLow';
scalefilter{2}='gaussBand';
scalefilter{3}='DOG';

%% 不同组合实验
% 生成文件夹
mkdir(result_path); %生成新文件夹
for i=1:4
    mkdir([result_path,feature{i}]);
    for j=1:3
        for k=1:3
            mkdir([result_path,feature{i},'\',colorspace{j},'-',scalefilter{k}]); %生成新文件夹
        end
    end
end

% 计算结果
disp(['组合实验，共包含图像 ',num2str(im_n)]);
for i=1:im_n
    disp(['第 ',num2str(i),' 幅图像 ']);
    
    im_in=imread((fullfile(im_path,im_name{i})));
    im_in=imresize(im_in,0.4);
    
    if i==1
        figure(102);
        im_handle=imshow(im_in,'Border','tight');
    else
        set(im_handle, 'CData', im_in);
    end
    
    for j=1:7
        params.ftPara.way=feature{j};
        for k=1:3
            params.colorSpace=colorspace{k};
            
            for l=1:3
                params.slPara.kernel=scalefilter{l};
                params.slPara.size=filter_size(l,:);
                
                switch j
                    case 5
                        [sl_map,salient_im,ft_map]=FrequencyAnalysisAndSpatialInfo(im_in,params);%FSI
                    case 6
                        [sl_map,salient_im,ft_map]=SpacialFrequencyTemporalAnalysis(im_in,params);%SFT
                    case 7
                        if k~=1
                            continue;
                        end
                        [sl_map,salient_im,ft_map]=AdaptiveChannelFusion(im_in,params);%FAS
                    otherwise
                        [sl_map,salient_im,ft_map]=FrequencyBasedSaliencyDetection(im_in,params);
                end
                
                if i==1
                    figure(101);
                    sl_handle=imshow(sl_map,'Border','tight');
                else
                    set(sl_handle, 'CData', sl_map);
                end
                drawnow;
                
                imwrite(sl_map,[result_path,feature{j},'\',colorspace{k},'-',scalefilter{l},'\',im_name{i}]);
            end
        end
    end
end

%%  结果统计
correlation=cell(7,3,3);      %图像相关性
precision_recall=cell(7,3,3); %PR曲线
roc_curve=cell(7,3,3);        %ROC曲线

disp('结果统计:计算相关分布,PR曲线,ROC曲线');

for i=1:7
    for j=1:3
        if i==7&&j~=1
            continue;
        end
        for k=1:3
            disp(['当前进度:',feature{i},'-',colorspace{j},'-',scalefilter{k}]);
            result_path_c=[result_path,feature{i},'\',colorspace{j},'-',scalefilter{k},'\'];
            
            %相关系数统计
            [correlation{i,j,k}.dsb,correlation{i,j,k}.cor,correlation{i,j,k}.cor_aver,correlation{i,j,k}.cor_std]=mapCorrelation(result_path_c,gt_path);
            
            %PR曲线统计
            [precision_recall{i,j,k}.p,precision_recall{i,j,k}.r,precision_recall{i,j,k}.p_aver,roc_curve{i,j,k}.tpr,roc_curve{i,j,k}.fpr,roc_curve{i,j,k}.auc]=precisionRecallandROC(result_path_c,gt_path);
        end
    end
end

figure(10);
% 相关性分布
for i=1:6
    subplot(3,7,i);
    plot(correlation{i,1,1}.cor,correlation{i,1,1}.dsb,correlation{i,1,2}.cor,correlation{i,1,2}.dsb,correlation{i,1,3}.cor,correlation{i,1,3}.dsb,...
        correlation{i,2,1}.cor,correlation{i,2,1}.dsb,correlation{i,2,2}.cor,correlation{i,2,2}.dsb,correlation{i,2,3}.cor,correlation{i,2,3}.dsb,...
        correlation{i,3,1}.cor,correlation{i,3,1}.dsb,correlation{i,3,2}.cor,correlation{i,3,2}.dsb,correlation{i,3,3}.cor,correlation{i,3,3}.dsb);
    legd=legend('RGB-GLP','RGB-GBP','RGB-DoG','Lab-GLP','Lab-GBP','Lab-DoG','HSV-GLP','HSV-GBP','HSV-DoG');
    set(legd,'FontSize',5);
    title('Correlation Distribution','FontSize',7);
    xlabel('Correlation Coefficient','FontSize',7);
    ylabel('Probability','FontSize',7);
end
subplot(3,7,7);
plot(correlation{7,1,1}.cor,correlation{7,1,1}.dsb,correlation{7,1,2}.cor,correlation{7,1,2}.dsb,correlation{7,1,3}.cor,correlation{7,1,3}.dsb);
legd=legend('GLP','GBP','DoG');
set(legd,'FontSize',5);
title('Correlation Distribution','FontSize',7);
xlabel('Correlation Coefficient','FontSize',7);
ylabel('Probability','FontSize',7);

% pr曲线
for i=1:6
    subplot(3,7,i+7);
    plot(precision_recall{i,1,1}.r,precision_recall{i,1,1}.p,precision_recall{i,1,2}.r,precision_recall{i,1,2}.p,precision_recall{i,1,3}.r,precision_recall{i,1,3}.p,...
        precision_recall{i,2,1}.r,precision_recall{i,2,1}.p,precision_recall{i,2,2}.r,precision_recall{i,2,2}.p,precision_recall{i,2,3}.r,precision_recall{i,2,3}.p,...
        precision_recall{i,3,1}.r,precision_recall{i,3,1}.p,precision_recall{i,3,2}.r,precision_recall{i,3,2}.p,precision_recall{i,3,3}.r,precision_recall{i,3,3}.p);
    axis([0,1,0,0.8]);
    legd=legend('RGB-GLP','RGB-GBP','RGB-DoG','Lab-GLP','Lab-GBP','Lab-DoG','HSV-GLP','HSV-GBP','HSV-DoG');
    set(legd,'FontSize',5);
    title('Precision-Recall','FontSize',7);
    xlabel('Recall','FontSize',7);
    ylabel('Precision','FontSize',7);
end
subplot(3,7,14);
plot(precision_recall{7,1,1}.r,precision_recall{7,1,1}.p,precision_recall{7,1,2}.r,precision_recall{7,1,2}.p,precision_recall{7,1,3}.r,precision_recall{7,1,3}.p);
legd=legend('GLP','GBP','DoG');
set(legd,'FontSize',5);
title('Precision-Recall','FontSize',7);
xlabel('Recall','FontSize',7);
ylabel('Precision','FontSize',7);


% roc曲线
for i=1:6
    subplot(3,7,i+14);
    plot(roc_curve{i,1,1}.fpr,roc_curve{i,1,1}.tpr,roc_curve{i,1,2}.fpr,roc_curve{i,1,2}.tpr,roc_curve{i,1,3}.fpr,roc_curve{i,1,3}.tpr,...
        roc_curve{i,2,1}.fpr,roc_curve{i,2,1}.tpr,roc_curve{i,2,2}.fpr,roc_curve{i,2,2}.tpr,roc_curve{i,2,3}.fpr,roc_curve{i,2,3}.tpr,...
        roc_curve{i,3,1}.fpr,roc_curve{i,3,1}.tpr,roc_curve{i,3,2}.fpr,roc_curve{i,3,2}.tpr,roc_curve{i,3,3}.fpr,roc_curve{i,3,3}.tpr);
    axis([0,1,0,1]);
    legd=legend('RGB-GLP','RGB-GBP','RGB-DoG','Lab-GLP','Lab-GBP','Lab-DoG','HSV-GLP','HSV-GBP','HSV-DoG');
    set(legd,'FontSize',5);
    title('ROC','FontSize',7);
    xlabel('FPR','FontSize',7);
    ylabel('TPR','FontSize',7);
end
subplot(3,7,21);
plot(roc_curve{7,1,1}.fpr,roc_curve{7,1,1}.tpr,roc_curve{7,1,2}.fpr,roc_curve{7,1,2}.tpr,roc_curve{7,1,3}.fpr,roc_curve{7,1,3}.tpr);
legd=legend('GLP','GBP','DoG');
set(legd,'FontSize',5);
title('ROC','FontSize',7);
xlabel('FPR','FontSize',7);
ylabel('TPR','FontSize',7);

%% 表格：各个方法的平均相关系数、平均精度与AUC对比
result_table=zeros(21,9);
for i=1:7
    for j=1:3
        if i==7&&j~=1
            continue;
        end
        for k=1:3
            index=(j-1)*3+k;
            
            %平均相关性
            result_table(i*3-2,index)=correlation{i,j,k}.cor_aver;
            
            %平均准确率
            result_table(i*3-1,index)=precision_recall{i,j,k}.p_aver;
            
            %AUC
            result_table(i*3,index)=roc_curve{i,j,k}.auc;
        end
    end
end