%%  3��Ƶ���˲����Ա�ʵ��
%   ��˹��ͨ
%   ��˹��ͨ
%   DOG�˲�

%%  1.�˲��˶Ա�
x=0:100;
gauss_low=exp(-x.^2/400);
gauss_band=exp(-(x-20).^2/400);
dog=exp(-x.^2/800)-exp(-x.^2/100);

figure(1);plot(x,gauss_low,'color',[0.9,0.6,0.1]);
figure(2);plot(x,gauss_band,'color',[0.6,0.9,0.1]);
figure(3);plot(x,dog,'color',[0.6,0.1,0.9]);

%%  2.�˲�����Ա�
%% ��ȡͼƬ
im_path='..\Li Jian\Images\';
im_name=imagePathRead(im_path);

pic_id=14;

im_in=imread((fullfile(im_path,im_name{pic_id})));
im_in=imresize(im_in,0.2);

imwrite(im_in,'..\result\Image.jpg');

%% ���ò���
params.centra='cos';                %���Ļ�����:cos
params.colorSpace='lab';
params.slPara.size=[0.1,0.7];      %Ŀ��ߴ緶Χ ͼ�������0.1-0.7
params.ftPara.way='SSS';

%% ��˹��ͨ�˲�
params.slPara.kernel='gaussLow';
[sl_map,salient_im,ft_map]=FrequencyBasedSaliencyDetection(im_in,params);
ft_map=ft_map./max(ft_map(:));
imwrite(ft_map,'..\result\feature_Map.jpg');
imwrite(sl_map,'..\result\gauss_low.jpg');

%%  ��˹��ͨ
params.slPara.kernel='gaussBand';
params.slPara.size=[0.1,0.6];
[sl_map,salient_im,ft_map]=FrequencyBasedSaliencyDetection(im_in,params);
imwrite(sl_map,'..\result\gauss_band.jpg');

%%  ��˹���
params.slPara.size=[0.05,0.6];
params.slPara.kernel='DOG';
[sl_map,salient_im,ft_map]=FrequencyBasedSaliencyDetection(im_in,params);
imwrite(sl_map,'..\result\DoG.jpg');