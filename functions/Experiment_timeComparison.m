%%  Experiment of comparing the elapsed time of each algorithm
% �Աȸ����㷨�ĺ�ʱ

%%  ��ȡ·��
im_path='E:\Dataset\����Ŀ����\Li Jian\Images\';
gt_path='E:\Dataset\����Ŀ����\Li Jian\GT gray\';
result_path='E:\��������ʶ��\���Ĺ���\�����Լ��\Ƶ�������Լ��˺������ܷ���\ʵ����\��ʱ�Ա�ʵ��\';

im_name=imagePathRead(im_path);
gt_name=imagePathRead(gt_path);
im_n=length(im_name);

%%  ���������Լ�����
params.centra='cos';                %���Ļ�����:cos

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

filter_size=[0.1,0.7]; %��ͬ������ϸ�ڳ߶ȷ�Χ

% proposed algorithm
pp_params.centra='cos';                %���Ļ�����:cos
pp_params.ftPara='fft';
pp_params.colorSpace='lab';
pp_params.slPara.kernel='DOG';

if ~exist('time_table','var')
    time_table=zeros(5,2);
end
%% Proposed algorithm
disp(['Ƶ��Աȶ���ǿ�������նԱ�ʵ�飬������ͼ�� ',num2str(im_n)]);

cur_time=zeros(1,im_n);
for i=1:im_n
    disp(['�� ',num2str(i),' ��ͼ�� ']);
    
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
    
    pp_params.slPara.size=filter_size;    %��ͬ���˲��ߴ�
    
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

% �����ֵ�뷽��
time_table(5,1)=mean(cur_time); %��ֵ
time_table(5,2)=std(cur_time);  %����

%% �Ա��㷨ʵ��
% ������
disp(['�Ա��㷨��������ͼ�� ',num2str(im_n)]);

cur_time=zeros(4,im_n);
for i=1:im_n
    disp(['�� ',num2str(i),' ��ͼ�� ']);
    
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

% �����ֵ�뷽��
for i=1:4
    time_table(i,1)=mean(cur_time(i,:)); %��ֵ
    time_table(i,2)=std(cur_time(i,:));  %����
end

%% ʱ��תΪms
time_table=time_table*1000;