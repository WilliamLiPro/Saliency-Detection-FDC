function im_lab=rgb2lab(im_rgb,nml)
%im_out=rgb2lab(im_in)
%RGB��ɫ�ռ�תLab�ռ�
%���룺
%@im_rgb RGBͼ��
%@nml    ��һ��ѡ��
%�����
%@im_lab Labͼ��
c=size(im_rgb,3);
if c~=3
    im_lab=im_rgb;
    return;
end

% ͼ���һ��
if strcmp(class(im_rgb),'uint8')
    im_db=double(im_rgb)/255;
else
    im_db=im_rgb;
end

% xyzɫ�ʿռ�
r=im_db(:,:,1);
g=im_db(:,:,2);
b=im_db(:,:,3);

X=(0.4124*r+0.3575*g+0.1805*b)/0.9504;
Y=(0.2126*r+0.7152*g+0.0722*b);
Z=(0.0193*r+0.1192*g+0.9505*b)/1.089;

% labɫ�ʿռ�
X=nolinerTrans(X);
Y=nolinerTrans(Y);
Z=nolinerTrans(Z);

if nml==1
    %��һ��
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
% XYZ��Lab�ռ�ķ����Էֶα任
r=(x<=(6/29)^3);
t=logical(1-r);

f=zeros(size(x));
f(r)=7.787*x(r)+0.1379; %f=(1/3)*(29/6)^2*t+4/29,t<=(6/29)^3
f(t)=(x(t)).^(1/3);     %f=t^(1/3),t>(6/29)^3
end