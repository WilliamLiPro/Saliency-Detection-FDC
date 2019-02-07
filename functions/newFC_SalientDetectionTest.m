%%  ��Ƶ��Աȶȷ����Ժ���

function [sl_map,salient_im,ft_map]=newFC_SalientDetectionTest(im_in,params)
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
ft_map=featureMap(im_in_use,params.ftPara,params.alpha,params.beta);

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
    cform=makecform('srgb2lab');
    im_out=applycform(im_in,cform);
    im_out=im_out/100;  %��Χ��һ��
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
function ft=featureMap(im_in,ft_param,pAlpha,pBeta)
%   @im_in      �����ͼ��
%   @ft_param   ѡ�õ�Ƶ��������ȡ����������
%   @palpha     ��Ƶϵ��,ԽС��Ƶ�ź�Խ��
%   @pBeta      ��Ƶϵ��,Խ���ֵԽ�����ڵ�Ƶ
%   @ft         ����ͼ

[n,m,c]=size(im_in);

if pBeta<2*pAlpha
    pBeta=2*pAlpha;
end

% ����Ƶ��Ȩֵ
x=[0:m-1];
y=[0:n-1];
if strcmp(ft_param,'fft')   %�Գƻ�
    cx=floor(m/2);
    cy=floor(n/2);
    
    x(m:-1:m-cx+1)=x(2:cx+1);
    y(n:-1:n-cy+1)=x(2:cy+1);
end
y2=y.^2;
x2=x.^2;
input=y2(ones(length(x2),1),:)'+x2(ones(length(y2),1),:);
kernelF=1./sqrt(input*pAlpha+1)-1./sqrt(input*pBeta+1);

% �߶����飺Ŀ�곤��Ȳ���̫��
rxy=(y(ones(length(x),1),:)'+2)./(x(ones(length(y),1),:)+2);
sm=rxy<1;
rxy(sm)=1./rxy(sm);
presize=exp(-rxy.^2/50);   %��׼�1:5
kernelF=kernelF.*presize;
        
% �������ͨ������ͼ
for i=1:c
    %�任��Ƶ��
    if strcmp(ft_param,'fft')
        fq=fft2(im_in(:,:,i));
    else
        fq=dct2(im_in(:,:,i));
    end
    
    %Ƶ������
    fq=fq.*kernelF;
    
    %�ռ�����
    if strcmp(ft_param,'fft')
        msg_mat=ifft2(fq);
    else
        msg_mat=idct2(fq);
    end
    
    ft_channel=msg_mat.*msg_mat; %����ͼ
    weight=(std(ft_channel(:))/mean(ft_channel(:))+0.000000001)^4;   %ͨ��Ȩ��
    
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