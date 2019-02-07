%% ����ӦƵ��Աȶ���ǿ�������Լ�⺯��
function [sl_map,salient_im,ft_map]=AdaptiveContrastSalientDetection(im_in,params)
%AdaptiveContrastSalientDetection ����Ƶ��Աȶȷ���������Ŀ�����㷨
%ͨ��Ƶ��Աȶȷ�����ȡͼ������
%ʹ��DCT��FFT������������ͼ��
%   sign������
%   sigmod������
%   ���⻯�任
%
%ʹ��3�ֿ�ѡ���˲�������ǰ��ǿ��ͼ��
%   gauss��ͨ�˲���
%   ��˹��ͨ�˲���
%   DOG�˲���
%
%   �������Ϊ������������ͨ������ͼ��
%   @im_in      �����ͼ��
%   @params     ����Ŀ���������������ѡ�õ�Ƶ��任��DCT,FFT������������ͼ���˲�����������
%   �����
%   @sl_map     ����ͼ
%   @salient_im ����ͼ��Ĥ�µ�ԭͼ
%   @ft_map     ����ǿ��ͼ

im_in=im2double(im_in);

% ��ɫ�ռ�ѡ��
if ~isfield( params, 'colorSpace' )
    params.colorSpace=0;
end
im_in_use=colorSpace(im_in,params.colorSpace);

% ��������ǿ��ͼ
if ~isfield( params, 'ftPara' )
    params.ftPara='fft';
end
ft_map=featureMap(im_in_use,params.ftPara);

% ������Ļ�����
if ~isfield( params, 'centra' )
    params.centra=0;
end
ft_map=centralization(ft_map,params.centra);

% ���������ֲ�ͼ
if ~isfield( params, 'slPara' )
    params.slPara.kernel='gaussLow';
end
sl_map=salientMap(ft_map,params.slPara);

% �ں�ԭͼ��������������ǿ
[n,m,c]=size(im_in);
salient_im=zeros(n,m,c);
for i=1:c
    salient_im(:,:,i)=im_in(:,:,i).*sl_map;
end

end

%% ��ɫ�ռ�任����
function im_out=colorSpace(im_in,colorSpace)
% ��ͼ�������ɫ�ռ�任��Ĭ��ΪRGB
%   @im_in      ����ͼ��
%   @colorSpace Ŀ����ɫ�ռ�
%   @im_out     ���ͼ��

if ~exist( 'colorSpace', 'var' )
    colorSpace='rgb';
end

if strcmp(colorSpace,'lab')
    im_out=double(RGB2Lab(im_in,0))/255;
    im_out(:,:,2:3)=im_out(:,:,2:3)*4-2;
elseif strcmp(colorSpace,'xyz')
    cform=makecform('srgb2xyz');
    im_out=applycform(im_in,cform);
    im_out=im_out/100;  %��Χ��һ��
elseif strcmp(colorSpace,'hsv')
    im_out=rgb2hsv(im_in);
else
    im_out=im_in;
end
    
end

%% ͼ�����Ļ�
function im_out=centralization(im_in,centra)
% ʹ��cos����͹��ͼ����������
%   @im_in      ����ͼ��
%   @centra     �������ַ�ʽ
%   @im_out     ������ֵ�ͼ��

if centra==0
    im_out=im_in;
    return;
end

% 1.��������
[n,m,c]=size(im_in);
cn=(n+1)/2;
cm=(m+1)/2;
ly=([1:n]-cn)/n;
lx=([1:m]-cm)/m;

if strcmp(centra,'cos')             %cos����
    cosy=cos(ly*pi);
    cosx=cos(lx*pi);
    cover=cosy'*cosx;
elseif strcmp(centra,'binomial')    %����ʽ����
    ky=1-ly.*ly*2;
    kx=1-lx.*lx*2;
    cover=ky'*kx;
else
    im_out=im_in;
    return;
end

% ִ��ͼ������
im_out=im_in.*cover(:,:,ones(1,c));

end

%% Ƶ��Աȶ���ǿ����������ͼ
%   FFT
%   DCT
function ft=featureMap(im_in,ft_param)
%   @im_in      �����ͼ��
%   @ft_param   ѡ�õ�Ƶ��������ȡ����������
%   @ft         ����ͼ

[n,m,c]=size(im_in);

% ���ɱ�������
cn=(n+1)/2;
cm=(m+1)/2;
ly=([1:n]-cn)/n;
lx=([1:m]-cm)/m;

cosy=cos(ly*pi);
cosx=cos(lx*pi);
cover=cosy'*cosx; %��������

% ����Ƶ��ͼ
fq=cell(c,1);
for i=1:c
    if strcmp(ft_param,'fft')
        fq_c=fft2(im_in(:,:,i).*cover);  %ͼ��
        bk=abs(fft2(im_in(:,:,i).*cover));   %����ǿ����
    else
        fq_c=dct2(im_in(:,:,i).*cover);
        bk=abs(dct2(im_in(:,:,i).*cover));   %����ǿ����
    end
%     fq_c(1:2,1:2)=fq_c(1:2,1:2).*(1-abs(fq_c(1:2,1:2))./bk(1:2,1:2));%�������飺���Ʊ���Ƶ��
    fq{i}=fq_c;     
%     fq{i}=fq_c;
end

%Ƶ�������˲�
kernelF=adaptiveKernel(fq,ft_param);

% �������ͨ������ͼ
for i=1:c 
    %Ƶ������
    fq{i}=fq{i}.*kernelF;
    
    %�ռ�����
    if strcmp(ft_param,'fft')
        msg_mat=ifft2(fq{i});
    else
        msg_mat=idct2(fq{i});
    end
    
    ft_channel=msg_mat.*msg_mat; %����ͼ
    weight=(std(ft_channel(:))/mean(ft_channel(:))+0.000000001)^8;   %ͨ��Ȩ��
    
    % ��Ȩ
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

%����Ƶ�������˲���
function kernelF=adaptiveKernel(fq,ft_param)
%   ���룺
%   @fq Ƶ��
%   @ft_param Ƶ��任��ʽ
%   �����
%   @kernelF �����˲���

% ��������
c=length(fq);
[n,m]=size(fq{1});
x=0:m-1;
y=0:n-1;
if strcmp(ft_param,'fft')   %�Գƻ�
    cx=floor(m/2);
    cy=floor(n/2);
    
    x(m:-1:m-cx+1)=x(2:cx+1);
    y(n:-1:n-cy+1)=x(2:cy+1);
end
% x=x.^2;
% y=y.^2;
y=y';

% ����Ӧ����
e_fq=abs(fq{1});  %������
for i=2:c
    e_fq=e_fq+abs(fq{i});
end
% e_fq=fq.*conj(fq);  %������

% gk=[1,2,4,2,1]/10;%�˲�����
% e_fq=filter2(gk,e_fq);
% e_fq=filter2(gk',e_fq);
% e_fq(1,1:m)=0;%��ֵ��0
% e_fq(1:n,1)=0;%��ֵ��0

if strcmp(ft_param,'fft')
    %��Ƶ
    l_fq=[e_fq(2:11,2:11),e_fq(2:11,m-9:m);e_fq(n-9:n,2:11),e_fq(n-9:n,m-9:m)];    %Ŀ����С�ߴ���ͼ���1/20
    lpx=[x(2:11),x(m-9:m)];
    lpy=[y(2:11);y(n-9:n)];
    
    %��Ƶ
    h_fq=e_fq(27:n-25,27:m-25);
    hpx=x(27:m-25);
    hpy=y(27:n-25);
else
    %��Ƶ
    l_fq=e_fq(2:21,2:21);          %Ŀ����С�ߴ���ͼ���1/20
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
ax=sum(lfx.*lpx)/sum(lfx);    %��ʼƵ��
ax=ax^2/3;
ay=sum(lfy.*lpy)/sum(lfy);
ay=ay^2/3;

hfx=sum(h_fq,1)+0.0001;
hfy=sum(h_fq,2)+0.0001;
bx=sum(hfx.*hpx)/sum(hfx);    %��ֹƵ��
bx=bx^2/3;
by=sum(hfy.*hpy)/sum(hfy);
by=by^2/3;

ax=1;ay=1;
bx=100000;
by=bx;

% �˲���
x=x.*x;
y=y.*y;
kernelF=1./sqrt((y/by+1)*(x/bx+1))-1./sqrt((y/ay+1)*(x/ax+1));
end

%% ʹ�ü��ֿ�ѡ���˲�����������ͼ��
%   gauss��ͨ�˲���
%   ��˹��ִ�ͨ�˲���
%   
function sl_map=salientMap(ft_map,sl_param)
%   @ft_map     ����ͼ
%   @sl_param   ѡ�õ��˲�������������
%   @sl_map     ����ͼ

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

% ��������ͼDCT
ft_F=dct2(ft_map);

% �����˲���
[n,m]=size(ft_F);
kernel=sl_param.kernel;
if strcmp(kernel,'gaussLow')
    fq=1./min(sl_param.size);	%Ŀ��ߴ��Ӧ��ֹƵ��
    kernelF=gaussFilterFq([n,m],[0,0],[fq,fq]);
elseif strcmp(kernel,'gaussBand')
    fq=(1./sl_param.size(1)+1./sl_param.size(2))/2;	%Ŀ��ߴ��Ӧ��ֹƵ��
    df=abs(1./sl_param.size(1)-1./sl_param.size(2));
    kernelF=gaussFilterFq([n,m],[fq,fq],[df,df]);
elseif strcmp(kernel,'DOG')
    fq=1./sl_param.size;        %Ƶ�ʷ�Χ
    ef=max(fq);  %��ֹƵ��
    sf=min(fq);                 %��ʼƵ��
    kernelF=gaussFilterFq([n,m],[0,0],[ef,ef])-gaussFilterFq([n,m],[0,0],[sf,sf]);
elseif strcmp(kernel,'biasBand')
    %����Ƶ�ʷ�Χ�������
    fq=1./sl_param.size;    %Ƶ�ʷ�Χ
    fq_min=min(fq);fq_max=max(fq);
    b=log(0.1)/(2*fq_min*log(fq_max/(2*fq_min))-fq_max+2*fq_min); %����ֵ��0.1
    a=2*b*fq_min;   %����ǰһ��
    
    kernelF=biasBandFq([n,m],a,b);
else
    
end

% �������ͼ
sl_map=idct2(ft_F.*kernelF);

% ��һ��
sl_map=sl_map./max(sl_map(:));
end

function kernelF=gaussFilterFq(filter_sz,u0,delta)
% ����DCT�任��2άƵ���˹�˲���
%   @filter_sz  �˲����ߴ磬��ʽΪ[height,width]
%   @u0         ��ֵ����ʽΪ[u0_y,u0_x]
%   @delta      ��׼���ʽΪ[delta_y,delta_x]

dx=[1:filter_sz(2)]-u0(2);
dy=[1:filter_sz(1)]-u0(1);
delta=2*delta.^2;

kx=exp(-dx.*dx/delta(2));
ky=exp(-dy.*dy/delta(1));
kernelF=ky'*kx;
end

function kernelF=biasBandFq(filter_sz,a,b)
% ����DCT�任��2άƵ��x^a*exp(-b*x)�˲���
%   @filter_sz  �˲����ߴ磬��ʽΪ[height,width]
%   @a          ���ݲ���
%   @b      	ָ������

x=[0:filter_sz(2)-1];
y=[0:filter_sz(1)-1];

max_num=(a/b)^a*exp(-a);
kx=x.^a.*exp(-b*x)/max_num;
ky=y.^a.*exp(-b*y)/max_num;
kernelF=ky'*kx;
end 