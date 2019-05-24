%%  特征提取对比实验
%   包含4种特征:
%   sign
%   SR
%   log
%   SSS

%   实验使用Li Jian数据集
%   结果由特征图及其幅度谱展示

%%  读取路径
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

% 计算原图幅度谱
im_in_fra=zeros(size(im_in));
cform=makecform('srgb2lab');
im_lab=applycform(im_in,cform);
im_lab=mat2gray(im_lab);
for i=1:3
    cur_fft=fft2((im_lab(:,:,i)));
    im_in_fra(:,:,i)=fftshift(abs(cur_fft));
end

figure;imshow(im_in);   %原图
figure;imshow(log(im_in_fra/100+1));   %原图幅度谱

%%  设置显著性检测参数
params.centra='cos';                %中心化遮罩:cos
params.colorSpace='lab';
params.slPara.kernel='gaussLow';    %滤波：高斯低通
params.slPara.size=[0.1,0.7];      %目标尺寸范围 图像总体的0.1-0.7

ft_map=cell(4,1);

%%  实验：sign
params.ftPara.way='sign';
[sl_map,salient_im,ft_map{1}]=FrequencyBasedSaliencyDetection(im_in,params);

%%  实验：SR
params.ftPara.way='SR';
[sl_map,salient_im,ft_map{2}]=FrequencyBasedSaliencyDetection(im_in,params);

%%  实验：log
params.ftPara.way='log';
[sl_map,salient_im,ft_map{3}]=FrequencyBasedSaliencyDetection(im_in,params);

%%  实验：SSS
params.ftPara.way='SSS';
[sl_map,salient_im,ft_map{4}]=FrequencyBasedSaliencyDetection(im_in,params);

%%  绘图
for i=1:4
    % 计算特征图幅度谱
    ft_map{i}=ft_map{i}./max(ft_map{i}(:));
    ffta=fftshift(abs(fft2(ft_map{i})));
    
    figure;imshow(log(ffta/10+1));
    figure;imshow(ft_map{i});
    
    switch i
        case 1
            imwrite(ft_map{i},'E:\物体检测与识别\论文工作\显著性检测\频域法显著性检测核函数性能分析\实验结果\特征提取\sign特征图.jpg');
            imwrite(log(ffta/100+1),'E:\物体检测与识别\论文工作\显著性检测\频域法显著性检测核函数性能分析\实验结果\特征提取\sign特征幅度谱.jpg');
        case 2
            imwrite(ft_map{i},'E:\物体检测与识别\论文工作\显著性检测\频域法显著性检测核函数性能分析\实验结果\特征提取\FR特征图.jpg');
            imwrite(log(ffta/100+1),'E:\物体检测与识别\论文工作\显著性检测\频域法显著性检测核函数性能分析\实验结果\特征提取\FR特征幅度谱.jpg');
        case 3
            imwrite(ft_map{i},'E:\物体检测与识别\论文工作\显著性检测\频域法显著性检测核函数性能分析\实验结果\特征提取\log特征图.jpg');
            imwrite(log(ffta/100+1),'E:\物体检测与识别\论文工作\显著性检测\频域法显著性检测核函数性能分析\实验结果\特征提取\log特征幅度谱.jpg');
        case 4
            imwrite(ft_map{i},'E:\物体检测与识别\论文工作\显著性检测\频域法显著性检测核函数性能分析\实验结果\特征提取\SSS特征图.jpg');
            imwrite(log(ffta/100+1),'E:\物体检测与识别\论文工作\显著性检测\频域法显著性检测核函数性能分析\实验结果\特征提取\SSS特征幅度谱.jpg');
        otherwise
    end
end

%%  保存图像
imwrite(im_in,'E:\物体检测与识别\论文工作\显著性检测\频域法显著性检测核函数性能分析\实验结果\特征提取\原图.jpg');
imwrite(log(im_in_fra/100+1),'E:\物体检测与识别\论文工作\显著性检测\频域法显著性检测核函数性能分析\实验结果\特征提取\原图幅度谱.jpg');