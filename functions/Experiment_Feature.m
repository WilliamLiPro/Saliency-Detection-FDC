%%  ������ȡ�Ա�ʵ��
%   ����4������:
%   sign
%   SR
%   log
%   SSS

%   ʵ��ʹ��Li Jian���ݼ�
%   ���������ͼ���������չʾ

%%  ��ȡ·��
im_path='..\Li Jian\Images\';
gt_path='..\Li Jian\GT gray\';

im_name=imagePathRead(im_path);
gt_name=imagePathRead(gt_path);

pic_id=181;

im_in=imread((fullfile(im_path,im_name{pic_id})));
im_in=imresize(im_in,0.2);
gt=imread((fullfile(gt_path,gt_name{pic_id})));
gt=imresize(gt,0.2);
gt=mat2gray(gt);

% ����ԭͼ������
im_in_fra=zeros(size(im_in));
cform=makecform('srgb2lab');
im_lab=applycform(im_in,cform);
im_lab=mat2gray(im_lab);
for i=1:3
    cur_fft=fft2((im_lab(:,:,i)));
    im_in_fra(:,:,i)=fftshift(abs(cur_fft));
end

figure;imshow(im_in);   %ԭͼ
figure;imshow(log(im_in_fra/100+1));   %ԭͼ������

%%  ���������Լ�����
params.centra='cos';                %���Ļ�����:cos
params.colorSpace='lab';
params.slPara.kernel='gaussLow';    %�˲�����˹��ͨ
params.slPara.size=[0.1,0.7];      %Ŀ��ߴ緶Χ ͼ�������0.1-0.7

ft_map=cell(4,1);

%%  ʵ�飺sign
params.ftPara.way='sign';
[sl_map,salient_im,ft_map{1}]=FrequencyBasedSaliencyDetection(im_in,params);

%%  ʵ�飺SR
params.ftPara.way='SR';
[sl_map,salient_im,ft_map{2}]=FrequencyBasedSaliencyDetection(im_in,params);

%%  ʵ�飺log
params.ftPara.way='log';
[sl_map,salient_im,ft_map{3}]=FrequencyBasedSaliencyDetection(im_in,params);

%%  ʵ�飺SSS
params.ftPara.way='SSS';
[sl_map,salient_im,ft_map{4}]=FrequencyBasedSaliencyDetection(im_in,params);

%%  ��ͼ
for i=1:4
    % ��������ͼ������
    ft_map{i}=ft_map{i}./max(ft_map{i}(:));
    ffta=fftshift(abs(fft2(ft_map{i})));
    
    figure;imshow(log(ffta/10+1));
    figure;imshow(ft_map{i});
    
    switch i
        case 1
            imwrite(ft_map{i},'E:\��������ʶ��\���Ĺ���\�����Լ��\Ƶ�������Լ��˺������ܷ���\ʵ����\������ȡ\sign����ͼ.jpg');
            imwrite(log(ffta/100+1),'E:\��������ʶ��\���Ĺ���\�����Լ��\Ƶ�������Լ��˺������ܷ���\ʵ����\������ȡ\sign����������.jpg');
        case 2
            imwrite(ft_map{i},'E:\��������ʶ��\���Ĺ���\�����Լ��\Ƶ�������Լ��˺������ܷ���\ʵ����\������ȡ\FR����ͼ.jpg');
            imwrite(log(ffta/100+1),'E:\��������ʶ��\���Ĺ���\�����Լ��\Ƶ�������Լ��˺������ܷ���\ʵ����\������ȡ\FR����������.jpg');
        case 3
            imwrite(ft_map{i},'E:\��������ʶ��\���Ĺ���\�����Լ��\Ƶ�������Լ��˺������ܷ���\ʵ����\������ȡ\log����ͼ.jpg');
            imwrite(log(ffta/100+1),'E:\��������ʶ��\���Ĺ���\�����Լ��\Ƶ�������Լ��˺������ܷ���\ʵ����\������ȡ\log����������.jpg');
        case 4
            imwrite(ft_map{i},'E:\��������ʶ��\���Ĺ���\�����Լ��\Ƶ�������Լ��˺������ܷ���\ʵ����\������ȡ\SSS����ͼ.jpg');
            imwrite(log(ffta/100+1),'E:\��������ʶ��\���Ĺ���\�����Լ��\Ƶ�������Լ��˺������ܷ���\ʵ����\������ȡ\SSS����������.jpg');
        otherwise
    end
end

%%  ����ͼ��
imwrite(im_in,'E:\��������ʶ��\���Ĺ���\�����Լ��\Ƶ�������Լ��˺������ܷ���\ʵ����\������ȡ\ԭͼ.jpg');
imwrite(log(im_in_fra/100+1),'E:\��������ʶ��\���Ĺ���\�����Լ��\Ƶ�������Լ��˺������ܷ���\ʵ����\������ȡ\ԭͼ������.jpg');