%% 自适应频域对比度增强法显著性检测函数
function [sl_map,salient_im,ft_map]=AdaptiveContrastSalientDetection(im_in,params)
%AdaptiveContrastSalientDetection 基于频域对比度分析的显著目标检测算法
%通过频域对比度分析提取图像特征
%使用DCT或FFT方法生成显著图：
%   sign函数；
%   sigmod函数；
%   均衡化变换
%
%使用3种可选的滤波器生成前景强度图：
%   gauss低通滤波器
%   高斯带通滤波器
%   DOG滤波器
%
%   输入可以为任意类型任意通道数的图像
%   @im_in      输入的图像
%   @params     显著目标检测参数，包括：选用的频域变换（DCT,FFT），生成显著图的滤波方法及参数
%   输出：
%   @sl_map     显著图
%   @salient_im 显著图掩膜下的原图
%   @ft_map     特征强度图

im_in=im2double(im_in);

% 颜色空间选择
if ~isfield( params, 'colorSpace' )
    params.colorSpace=0;
end
im_in_use=colorSpace(im_in,params.colorSpace);

% 计算特征强度图
if ~isfield( params, 'ftPara' )
    params.ftPara='fft';
end
ft_map=featureMap(im_in_use,params.ftPara);

% 添加中心化遮罩
if ~isfield( params, 'centra' )
    params.centra=0;
end
ft_map=centralization(ft_map,params.centra);

% 生成显著分布图
if ~isfield( params, 'slPara' )
    params.slPara.kernel='gaussLow';
end
sl_map=salientMap(ft_map,params.slPara);

% 融合原图生成显著区域增强
[n,m,c]=size(im_in);
salient_im=zeros(n,m,c);
for i=1:c
    salient_im(:,:,i)=im_in(:,:,i).*sl_map;
end

end

%% 颜色空间变换函数
function im_out=colorSpace(im_in,colorSpace)
% 对图像进行颜色空间变换，默认为RGB
%   @im_in      输入图像
%   @colorSpace 目标颜色空间
%   @im_out     输出图像

if ~exist( 'colorSpace', 'var' )
    colorSpace='rgb';
end

if strcmp(colorSpace,'lab')
    im_out=double(RGB2Lab(im_in,0))/255;
    im_out(:,:,2:3)=im_out(:,:,2:3)*4-2;
elseif strcmp(colorSpace,'xyz')
    cform=makecform('srgb2xyz');
    im_out=applycform(im_in,cform);
    im_out=im_out/100;  %范围归一化
elseif strcmp(colorSpace,'hsv')
    im_out=rgb2hsv(im_in);
else
    im_out=im_in;
end
    
end

%% 图像中心化
function im_out=centralization(im_in,centra)
% 使用cos遮罩凸显图像中心区域
%   @im_in      输入图像
%   @centra     中心遮罩方式
%   @im_out     添加遮罩的图像

if centra==0
    im_out=im_in;
    return;
end

% 1.计算遮罩
[n,m,c]=size(im_in);
cn=(n+1)/2;
cm=(m+1)/2;
ly=([1:n]-cn)/n;
lx=([1:m]-cm)/m;

if strcmp(centra,'cos')             %cos遮罩
    cosy=cos(ly*pi);
    cosx=cos(lx*pi);
    cover=cosy'*cosx;
elseif strcmp(centra,'binomial')    %二项式遮罩
    ky=1-ly.*ly*2;
    kx=1-lx.*lx*2;
    cover=ky'*kx;
else
    im_out=im_in;
    return;
end

% 执行图像遮罩
im_out=im_in.*cover(:,:,ones(1,c));

end

%% 频域对比度增强法生成特征图
%   FFT
%   DCT
function ft=featureMap(im_in,ft_param)
%   @im_in      输入的图像
%   @ft_param   选用的频域特征提取方法及参数
%   @ft         特征图

[n,m,c]=size(im_in);

% 生成背景遮罩
cn=(n+1)/2;
cm=(m+1)/2;
ly=([1:n]-cn)/n;
lx=([1:m]-cm)/m;

cosy=cos(ly*pi);
cosx=cos(lx*pi);
cover=cosy'*cosx; %背景遮罩

% 计算频谱图
fq=cell(c,1);
for i=1:c
    if strcmp(ft_param,'fft')
        fq_c=fft2(im_in(:,:,i).*cover);  %图像
        bk=abs(fft2(im_in(:,:,i).*cover));   %背景强度谱
    else
        fq_c=dct2(im_in(:,:,i).*cover);
        bk=abs(dct2(im_in(:,:,i).*cover));   %背景强度谱
    end
%     fq_c(1:2,1:2)=fq_c(1:2,1:2).*(1-abs(fq_c(1:2,1:2))./bk(1:2,1:2));%背景先验：抑制背景频段
    fq{i}=fq_c;     
%     fq{i}=fq_c;
end

%频域遮罩滤波
kernelF=adaptiveKernel(fq,ft_param);

% 计算各个通道特征图
for i=1:c 
    %频域特征
    fq{i}=fq{i}.*kernelF;
    
    %空间特征
    if strcmp(ft_param,'fft')
        msg_mat=ifft2(fq{i});
    else
        msg_mat=idct2(fq{i});
    end
    
    ft_channel=msg_mat.*msg_mat; %特征图
    weight=(std(ft_channel(:))/mean(ft_channel(:))+0.000000001)^8;   %通道权重
    
    % 加权
    if i==1
        ft=ft_channel;
        sum_weight=weight;
    else
        ft=ft+ft_channel;
        sum_weight=sum_weight+weight;
    end
end

ft=ft/sum_weight;
end

%生成频域特征滤波器
function kernelF=adaptiveKernel(fq,ft_param)
%   输入：
%   @fq 频谱
%   @ft_param 频域变换方式
%   输出：
%   @kernelF 特征滤波器

% 生成坐标
c=length(fq);
[n,m]=size(fq{1});
x=0:m-1;
y=0:n-1;
if strcmp(ft_param,'fft')   %对称化
    cx=floor(m/2);
    cy=floor(n/2);
    
    x(m:-1:m-cx+1)=x(2:cx+1);
    y(n:-1:n-cy+1)=x(2:cy+1);
end
% x=x.^2;
% y=y.^2;
y=y';

% 自适应参数
e_fq=abs(fq{1});  %能量谱
for i=2:c
    e_fq=e_fq+abs(fq{i});
end
% e_fq=fq.*conj(fq);  %幅度谱

% gk=[1,2,4,2,1]/10;%滤波处理
% e_fq=filter2(gk,e_fq);
% e_fq=filter2(gk',e_fq);
% e_fq(1,1:m)=0;%均值置0
% e_fq(1:n,1)=0;%均值置0

if strcmp(ft_param,'fft')
    %低频
    l_fq=[e_fq(2:11,2:11),e_fq(2:11,m-9:m);e_fq(n-9:n,2:11),e_fq(n-9:n,m-9:m)];    %目标最小尺寸是图像的1/20
    lpx=[x(2:11),x(m-9:m)];
    lpy=[y(2:11);y(n-9:n)];
    
    %高频
    h_fq=e_fq(27:n-25,27:m-25);
    hpx=x(27:m-25);
    hpy=y(27:n-25);
else
    %低频
    l_fq=e_fq(2:21,2:21);          %目标最小尺寸是图像的1/20
    lpx=x(2:21);
    lpy=y(2:21);
    
    h_fq=e_fq(51:n,51:m);
    hpx=x(51:m);
    hpy=y(51:n);
end

l_fq=l_fq.^4;
h_fq=h_fq.^4;

lfx=sum(l_fq,1)+0.0001;
lfy=sum(l_fq,2)+0.0001;
ax=sum(lfx.*lpx)/sum(lfx);    %起始频率
ax=ax^2/3;
ay=sum(lfy.*lpy)/sum(lfy);
ay=ay^2/3;

hfx=sum(h_fq,1)+0.0001;
hfy=sum(h_fq,2)+0.0001;
bx=sum(hfx.*hpx)/sum(hfx);    %终止频率
bx=bx^2/3;
by=sum(hfy.*hpy)/sum(hfy);
by=by^2/3;

ax=1;ay=1;
bx=100000;
by=bx;

% 滤波器
x=x.*x;
y=y.*y;
kernelF=1./sqrt((y/by+1)*(x/bx+1))-1./sqrt((y/ay+1)*(x/ax+1));
end

%% 使用几种可选的滤波器生成显著图：
%   gauss低通滤波器
%   高斯差分带通滤波器
%   
function sl_map=salientMap(ft_map,sl_param)
%   @ft_map     特征图
%   @sl_param   选用的滤波器方法及参数
%   @sl_map     显著图

if ~isfield( sl_param, 'kernel' )
    sl_param.kernel='gaussLow';
elseif isempty(sl_param.kernel)
    sl_param.kernel='gaussLow';
end

if ~isfield( sl_param, 'size' )
    sl_param.size=[0.1,0.5];
elseif isempty(sl_param.size)
    sl_param.size=[0.1,0.5];
end

% 计算特征图DCT
ft_F=dct2(ft_map);

% 生成滤波器
[n,m]=size(ft_F);
kernel=sl_param.kernel;
if strcmp(kernel,'gaussLow')
    fq=1./min(sl_param.size);	%目标尺寸对应截止频率
    kernelF=gaussFilterFq([n,m],[0,0],[fq,fq]);
elseif strcmp(kernel,'gaussBand')
    fq=(1./sl_param.size(1)+1./sl_param.size(2))/2;	%目标尺寸对应截止频率
    df=abs(1./sl_param.size(1)-1./sl_param.size(2));
    kernelF=gaussFilterFq([n,m],[fq,fq],[df,df]);
elseif strcmp(kernel,'DOG')
    fq=1./sl_param.size;        %频率范围
    ef=max(fq);  %截止频率
    sf=min(fq);                 %起始频率
    kernelF=gaussFilterFq([n,m],[0,0],[ef,ef])-gaussFilterFq([n,m],[0,0],[sf,sf]);
elseif strcmp(kernel,'biasBand')
    %根据频率范围计算参数
    fq=1./sl_param.size;    %频率范围
    fq_min=min(fq);fq_max=max(fq);
    b=log(0.1)/(2*fq_min*log(fq_max/(2*fq_min))-fq_max+2*fq_min); %顶点值的0.1
    a=2*b*fq_min;   %顶点前一半
    
    kernelF=biasBandFq([n,m],a,b);
else
    
end

% 获得显著图
sl_map=idct2(ft_F.*kernelF);

% 归一化
sl_map=sl_map./max(sl_map(:));
end

function kernelF=gaussFilterFq(filter_sz,u0,delta)
% 生成DCT变换的2维频域高斯滤波器
%   @filter_sz  滤波器尺寸，格式为[height,width]
%   @u0         均值，格式为[u0_y,u0_x]
%   @delta      标准差，格式为[delta_y,delta_x]

dx=[1:filter_sz(2)]-u0(2);
dy=[1:filter_sz(1)]-u0(1);
delta=2*delta.^2;

kx=exp(-dx.*dx/delta(2));
ky=exp(-dy.*dy/delta(1));
kernelF=ky'*kx;
end

function kernelF=biasBandFq(filter_sz,a,b)
% 生成DCT变换的2维频域x^a*exp(-b*x)滤波器
%   @filter_sz  滤波器尺寸，格式为[height,width]
%   @a          次幂参数
%   @b      	指数参数

x=[0:filter_sz(2)-1];
y=[0:filter_sz(1)-1];

max_num=(a/b)^a*exp(-a);
kx=x.^a.*exp(-b*x)/max_num;
ky=y.^a.*exp(-b*y)/max_num;
kernelF=ky'*kx;
end 