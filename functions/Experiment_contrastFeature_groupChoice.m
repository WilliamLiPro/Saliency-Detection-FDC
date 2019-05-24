%%  Experiment of best color space and scale filter for contrast salient detection 
% ΪƵ��Աȶ���ǿѡȡ����ɫ�ʿռ�ͳ߶��˲�

%%  ��ȡ·��
im_path='..\Li Jian\Images\';
gt_path='..\Li Jian\GT gray\';
result_path='..\Result\';

im_name=imagePathRead(im_path);
gt_name=imagePathRead(gt_path);
im_n=length(im_name);

%%  ���������Լ�����
params.centra='cos';                %���Ļ�����:cos
filter_size=[0.08,0.7;0.08,0.7;0.08,0.7]; %��ͬ������ϸ�ڳ߶ȷ�Χ

colorspace=cell(3,1);
colorspace{1}='rgb';
colorspace{2}='lab';
colorspace{3}='hsv';

params.ftPara='dct';    %Ƶ��Աȶ���ǿʹ��dct�任
params.alpha=0.001;     %���Ƶ��Ϣƽ����
params.beta=0.2;        %���Ƶ��Ϣƽ����

scalefilter=cell(3,1);
scalefilter{1}='gaussLow';
scalefilter{2}='gaussBand';
scalefilter{3}='DOG';

%% ��ͬ���ʵ��
% �����ļ���
mkdir(result_path); %�������ļ���
for i=1:3
    for j=1:3
        mkdir([result_path,colorspace{i},'-',scalefilter{j}]); %�������ļ���
    end
end

disp(['Ƶ��Աȶ���ǿ��������ѡȡ��������ͼ�� ',num2str(im_n)]);
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

%%  ���ͳ��
correlation=cell(3,3);      %ͼ�������
precision_recall=cell(3,3); %PR����
roc_curve=cell(3,3);        %ROC����

disp('���ͳ��:������طֲ�,PR����,ROC����');

for i=1:3
    for j=1:3
        disp(['��ǰ����:',colorspace{i},'-',scalefilter{j}]);
        result_path_c=[result_path,colorspace{i},'-',scalefilter{j},'\'];
        
        %���ϵ��ͳ��
        [correlation{i,j}.dsb,correlation{i,j}.cor,correlation{i,j}.cor_aver,correlation{i,j}.cor_std]=mapCorrelation(result_path_c,gt_path);
        
        %PR����ͳ��
        [precision_recall{i,j}.p,precision_recall{i,j}.r,precision_recall{i,j}.p_aver,roc_curve{i,j}.tpr,roc_curve{i,j}.fpr,roc_curve{i,j}.auc]=precisionRecallandROC(result_path_c,gt_path);
    end
end

%%  ��ͼ
% ����Էֲ�
figure(1);
plot(correlation{1,1}.cor,correlation{1,1}.dsb,correlation{1,2}.cor,correlation{1,2}.dsb,correlation{1,3}.cor,correlation{1,3}.dsb,...
    correlation{2,1}.cor,correlation{2,1}.dsb,correlation{2,2}.cor,correlation{2,2}.dsb,correlation{2,3}.cor,correlation{2,3}.dsb,...
    correlation{3,1}.cor,correlation{3,1}.dsb,correlation{3,2}.cor,correlation{3,2}.dsb,correlation{3,3}.cor,correlation{3,3}.dsb);
legend('RGB-GLP','RGB-GBP','RGB-DoG','Lab-GLP','Lab-GBP','Lab-DoG','HSV-GLP','HSV-GBP','HSV-DoG');
title('Correlation Coefficient Distribution');
xlabel('Correlation Coefficient');
ylabel('Probability');

% pr����
figure(2);
plot(precision_recall{1,1}.r,precision_recall{1,1}.p,precision_recall{1,2}.r,precision_recall{1,2}.p,precision_recall{1,3}.r,precision_recall{1,3}.p,...
    precision_recall{2,1}.r,precision_recall{2,1}.p,precision_recall{2,2}.r,precision_recall{2,2}.p,precision_recall{2,3}.r,precision_recall{2,3}.p,...
    precision_recall{3,1}.r,precision_recall{3,1}.p,precision_recall{3,2}.r,precision_recall{3,2}.p,precision_recall{3,3}.r,precision_recall{3,3}.p);
axis([0,1,0,0.8]);
legend('RGB-GLP','RGB-GBP','RGB-DoG','Lab-GLP','Lab-GBP','Lab-DoG','HSV-GLP','HSV-GBP','HSV-DoG');
title('Precision-Recall');
xlabel('Recall');
ylabel('Precision');

% roc����
figure(3);
plot(roc_curve{1,1}.fpr,roc_curve{1,1}.tpr,roc_curve{1,2}.fpr,roc_curve{1,2}.tpr,roc_curve{1,3}.fpr,roc_curve{1,3}.tpr,...
    roc_curve{2,1}.fpr,roc_curve{2,1}.tpr,roc_curve{2,2}.fpr,roc_curve{2,2}.tpr,roc_curve{2,3}.fpr,roc_curve{2,3}.tpr,...
    roc_curve{3,1}.fpr,roc_curve{3,1}.tpr,roc_curve{3,2}.fpr,roc_curve{3,2}.tpr,roc_curve{3,3}.fpr,roc_curve{3,3}.tpr);
axis([0,1,0,1]);
legend('RGB-GLP','RGB-GBP','RGB-DoG','Lab-GLP','Lab-GBP','Lab-DoG','HSV-GLP','HSV-GBP','HSV-DoG');
title('ROC');
xlabel('FPR');
ylabel('TPR');

%% ��񣺸���������ƽ�����ϵ����ƽ��������AUC�Ա�
result_table=zeros(3,9);
for i=1:3
    for j=1:3
        index=(i-1)*3+j;
        
        %ƽ�������
        result_table(1,index)=correlation{i,j}.cor_aver;
        
        %ƽ��׼ȷ��
        result_table(2,index)=precision_recall{i,j}.p_aver;
        
        %AUC
        result_table(3,index)=roc_curve{i,j}.auc;
    end
end