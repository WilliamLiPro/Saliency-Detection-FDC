%%  contrast experiment of visual saliency detection
%   Test dataset is 'Li Jian'
%   3 kinds of Statistics are taken into consideration:
%   1. Correlation between ground truth and result
%   2. Mean Average Precision
%   3. AUC

%%  addpath
addpath('functions');
im_path='Li Jian\Images\';
gt_path='Li Jian\GT gray\';

result_path='Result\';

im_name=imagePathRead(im_path);
gt_name=imagePathRead(gt_path);
im_n=length(im_name);

%%  Setting Params
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

filter_size=[0.02,0.4;0.04,0.4;0.06,0.5;0.1,0.7;0.15,0.7]; %different scale filter

% proposed algorithm
pp_params.centra='cos';                %centralization tyoe:cos
pp_params.colorSpace='lab';
pp_params.slPara.kernel='DOG';

%% Proposed algorithm
mkdir(result_path); %new dir
mkdir([result_path,'proposed']);

for i=1:5
    mkdir([result_path,'proposed\',num2str(i)]);
end

disp(['Contrast enhancement feature, image number ',num2str(im_n)]);
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
        pp_params.slPara.size=filter_size(j,:);    %different filter scale
        
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

%% contrast algorithm
% new dir
for i=1:4
    mkdir([result_path,feature{i}]);
    for j=1:5
        mkdir([result_path,feature{i},'\',num2str(j)]); %new dir
    end
end

% result
disp(['contrast algorithm, image number ',num2str(im_n)]);
for i=1:im_n
    disp(['saliency processed ',num2str(i)]);
    
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

%%  Statistics of result
ACC=zeros(5,5);      %Average Correlation
MAP=zeros(5,5);      %MAP
AUC=zeros(5,5);      %AUC

disp('Statistics of results: Correlation,MAP,AUC');

for i=1:4
    for j=1:5
        disp(['Current progress:',feature{i},'-',num2str(j)]);
        result_path_c=[result_path,feature{i},'\',num2str(j),'\'];
        
        %correlation
        [~,~,ACC(i,j),~]=mapCorrelation(result_path_c,gt_path);
        
        %Precision-Recall curve
        [~,~,MAP(i,j),~,~,AUC(i,j)]=precisionRecallandROC(result_path_c,gt_path);
    end
end

for j=1:5
    disp(['Current progress:','proposed-',num2str(j)]);
    result_path_c=[result_path,'proposed\',num2str(j),'\'];
    
    %correlation
    [~,~,ACC(5,j),~]=mapCorrelation(result_path_c,gt_path);
    
    %Precision-Recall curve
    [~,~,MAP(5,j),~,~,AUC(5,j)]=precisionRecallandROC(result_path_c,gt_path);
end

%% Draw figures: bar
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

%%  Report
result_table=zeros(5,15);
for i=1:5
    result_table(:,i*3-2)=ACC(:,i);
    result_table(:,i*3-1)=MAP(:,i);
    result_table(:,i*3)=AUC(:,i);
end