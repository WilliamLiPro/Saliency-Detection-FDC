%%  Experiment of comparing the elapsed time of each algorithm
% 对比各个算法的耗时

%%  读取路径
im_path='E:\Dataset\显著目标检测\Li Jian\Images\';
gt_path='E:\Dataset\显著目标检测\Li Jian\GT gray\';
result_path='E:\物体检测与识别\论文工作\显著性检测\频域法显著性检测核函数性能分析\实验结果\耗时对比实验\';

im_name=imagePathRead(im_path);
gt_name=imagePathRead(gt_path);
im_n=length(im_name);

%%  设置显著性检测参数
params.centra='cos';                %中心化遮罩:cos

feature=cell(4,1);
feature{1}='sign';
feature{2}='SR';
feature{3}='log';
feature{4}='SSS';

colorspace=cell(4,1);
colorspace{1}='lab';
colorspace{2}='hsv';
colorspace{3}='hsv';
colorspace{4}='lab';

scalefilter=cell(4,1);
scalefilter{1}='gaussLow';
scalefilter{2}='DOG';
scalefilter{3}='gaussLow';
scalefilter{4}='gaussLow';

filter_size=[0.1,0.7]; %不同方法的细节尺度范围

% proposed algorithm
pp_params.centra='cos';                %中心化遮罩:cos
pp_params.ftPara='fft';
pp_params.colorSpace='lab';
pp_params.slPara.kernel='DOG';

if ~exist('time_table','var')
    time_table=zeros(5,2);
end
%% Proposed algorithm
disp(['频域对比度增强法的最终对比实验，共包含图像 ',num2str(im_n)]);

cur_time=zeros(1,im_n);
for i=1:im_n
    disp(['第 ',num2str(i),' 幅图像 ']);
    
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
    
    pp_params.slPara.size=filter_size;    %不同的滤波尺寸
    
    tic;
    [sl_map,salient_im,ft_map]=AdaptiveContrastSalientDetection(im_in,pp_params);
    cur_time(i)=toc;
    
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
end

% 计算均值与方差
time_table(5,1)=mean(cur_time); %均值
time_table(5,2)=std(cur_time);  %方差

%% 对比算法实验
% 计算结果
disp(['对比算法，共包含图像 ',num2str(im_n)]);

cur_time=zeros(4,im_n);
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
            
        params.slPara.size=filter_size;
        
        tic;
        [sl_map,salient_im,ft_map]=FrequencyBasedSaliencyDetection(im_in,params);
        cur_time(j,i)=toc;
        
        if i==1
            figure(101);
            sl_handle=imshow(sl_map,'Border','tight');
        else
            set(sl_handle, 'CData', sl_map);
        end
        drawnow;
    end
end

% 计算均值与方差
for i=1:4
    time_table(i,1)=mean(cur_time(i,:)); %均值
    time_table(i,2)=std(cur_time(i,:));  %方差
end

%% 时间转为ms
time_table=time_table*1000;