function im_lab=rgb2lab(im_rgb,nml)
%im_out=rgb2lab(im_in)
%RGB颜色空间转Lab空间
%输入：
%@im_rgb RGB图像
%@nml    归一化选项
%输出：
%@im_lab Lab图像
c=size(im_rgb,3);
if c~=3
    im_lab=im_rgb;
    return;
end

% 图像归一化
if strcmp(class(im_rgb),'uint8')
    im_db=double(im_rgb)/255;
else
    im_db=im_rgb;
end

% xyz色彩空间
r=im_db(:,:,1);
g=im_db(:,:,2);
b=im_db(:,:,3);

X=(0.4124*r+0.3575*g+0.1805*b)/0.9504;
Y=(0.2126*r+0.7152*g+0.0722*b);
Z=(0.0193*r+0.1192*g+0.9505*b)/1.089;

% lab色彩空间
X=nolinerTrans(X);
Y=nolinerTrans(Y);
Z=nolinerTrans(Z);

if nml==1
    %归一化
    L=1.16*Y-0.16;
    a=5*(X-Y);
    b=2*(Y-Z);
else
    L=116*Y-16;
    a=500*(X-Y);
    b=200*(Y-Z);
end

im_lab=cat(3,L,a,b);
end

function f=nolinerTrans(x)
% XYZ到Lab空间的非线性分段变换
r=(x<=(6/29)^3);
t=logical(1-r);

f=zeros(size(x));
f(r)=7.787*x(r)+0.1379; %f=(1/3)*(29/6)^2*t+4/29,t<=(6/29)^3
f(t)=(x(t)).^(1/3);     %f=t^(1/3),t>(6/29)^3
end