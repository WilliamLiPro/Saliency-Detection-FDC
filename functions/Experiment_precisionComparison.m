%%  Experiment of comparing the precision of each algorithm
% 对比各个算法的精度
% 使用5种不同标准差的尺度滤波

%%  读取路径
im_path='..\Li Jian\Images\';
gt_path='..\Li Jian\GT gray\';
result_path='..\Result\';

im_name=imagePathRead(im_path);
gt_name=imagePathRead(gt_path);
im_n=length(im_name);

%%  设置显著性检测参数
params.centra='cos';                %中心化遮罩:cos

feature=cell(7,1);
feature{1}='IS';%image signature
feature{2}='SR';
feature{3}='log';
feature{4}='HFT';
feature{5}='FSI';
feature{6}='SFT';
feature{7}='FAS';

colorspace=cell(7,1);
colorspace{1}='lab';
colorspace{2}='hsv';
colorspace{3}='rgb';
colorspace{4}='lab';
colorspace{5}='lab';
colorspace{6}='lab';
colorspace{7}='lab';

scalefilter=cell(7,1);
scalefilter{1}='gaussLow';
scalefilter{2}='DOG';
scalefilter{3}='gaussLow';
scalefilter{4}='gaussLow';
scalefilter{5}='gaussLow';
scalefilter{6}='DOG';
scalefilter{7}='gaussLow';

filter_size=[0.02,0.4;0.04,0.4;0.06,0.5;0.1,0.7;0.15,0.7]; %不同方法的细节尺度范围

% proposed algorithm
pp_params.centra='cos';                %中心化遮罩:cos
pp_params.colorSpace='lab';
pp_params.slPara.kernel='DOG';

%% Proposed algorithm
mkdir(result_path); %生成新文件夹
mkdir([result_path,'proposed']);

for i=1:5
    mkdir([result_path,'proposed\',num2str(i)]);
end

disp(['频域对比度增强法的最终对比实验，共包含图像 ',num2str(im_n)]);
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
    
    for j=1:5
        pp_params.slPara.size=filter_size(j,:);    %不同的滤波尺寸
        
        [sl_map,salient_im,ft_map]=AdaptiveContrastSalientDetection(im_in,pp_params);
        
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
        
        imwrite(sl_map,[result_path,'proposed\',num2str(j),'\',im_name{i}]);
    end
end

%% 对比算法实验
% 生成文件夹
for i=1:4
    mkdir([result_path,feature{i}]);
    for j=1:5
        mkdir([result_path,feature{i},'\',num2str(j)]); %生成新文件夹
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
    
    for j=1:4
        params.ftPara.way=feature{j};
        params.colorSpace=colorspace{j};
        params.slPara.kernel=scalefilter{j};
            
        for k=1:5
            params.slPara.size=filter_size(k,:);
            
            [sl_map,salient_im,ft_map]=FrequencyBasedSaliencyDetection(im_in,params);
            
            if i==1
                figure(101);
                sl_handle=imshow(sl_map,'Border','tight');
            else
                set(sl_handle, 'CData', sl_map);
            end
            drawnow;
            
            imwrite(sl_map,[result_path,feature{j},'\',num2str(k),'\',im_name{i}]);
        end
    end
end

%%  结果统计
ACC=zeros(5,5);      %Average Correlation
MAP=zeros(5,5);      %MAP
AUC=zeros(5,5);      %AUC

disp('结果统计:计算相关系数,MAP,AUC');

for i=1:4
    for j=1:5
        disp(['当前进度:',feature{i},'-',num2str(j)]);
        result_path_c=[result_path,feature{i},'\',num2str(j),'\'];
        
        %相关系数统计
        [~,~,ACC(i,j),~]=mapCorrelation(result_path_c,gt_path);
        
        %PR曲线统计
        [~,~,MAP(i,j),~,~,AUC(i,j)]=precisionRecallandROC(result_path_c,gt_path);
    end
end

for j=1:5
    disp(['当前进度:','proposed-',num2str(j)]);
    result_path_c=[result_path,'proposed\',num2str(j),'\'];
    
    %相关系数统计
    [~,~,ACC(5,j),~]=mapCorrelation(result_path_c,gt_path);
    
    %PR曲线统计
    [~,~,MAP(5,j),~,~,AUC(5,j)]=precisionRecallandROC(result_path_c,gt_path);
end

%% 绘图：绘制柱状图
%ACC
figure(1);flag_b1=bar(ACC');
axis([0.5,8,0.4,0.9]);
set(gca,'XGrid','off');
set(gca,'XTickLabel',{'{0.02,0.4}','{0.04,0.4}','{0.06,0.5}','{0.1,0.7}','{0.15,0.7}'});
xlabel('Standard deviation of filters');
ylabel('ACC');

legend('Sign','SR','Log','SSS','Proposed');

%MAP
figure(2);flag_b2=bar(MAP');
axis([0.5,8,0.25,0.6]);
set(gca,'XGrid','off');
set(gca,'XTickLabel',{'{0.02,0.4}','{0.04,0.4}','{0.06,0.5}','{0.1,0.7}','{0.15,0.7}'});
xlabel('Standard deviation of filters');
ylabel('MAP');

legend('Sign','SR','Log','SSS','Proposed');

%AUC
figure(3);flag_b3=bar(AUC');
axis([0.5,8,0.7,0.95]);
set(gca,'XGrid','off');
set(gca,'XTickLabel',{'{0.02,0.4}','{0.04,0.4}','{0.06,0.5}','{0.1,0.7}','{0.15,0.7}'});
xlabel('Standard deviation of filters');
ylabel('AUC');

legend('Sign','SR','Log','SSS','Proposed');

%%  统计结果
result_table=zeros(5,15);
for i=1:5
    result_table(:,i*3-2)=ACC(:,i);
    result_table(:,i*3-1)=MAP(:,i);
    result_table(:,i*3)=AUC(:,i);
end