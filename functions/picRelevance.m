function rela=picRelevance(im1,im2)
% ��������ͼ��֮��������
%���룺
%@im1       ����ͼ��
%@im1       ��׼ͼ��
%�����
%@rela      �����

% ���ݱ�׼��
im1=mat2gray(im1);
im2=mat2gray(im2);

% ���������
re_im=im1.*im2;
rela=sum(re_im(:))/sqrt((sum(im1(:).^2)*sum(im2(:).^2)));
end