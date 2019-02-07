function pr=precisionRecall(im_in,gt)
% ���㵥��ͼ�����׼ͼ֮���Precision-recall����
%���룺
%@im_in     ����ͼ��
%@gt        ��׼ͼ��
%�����
%@pr        precision-recall����

% ���ݱ�׼��
im_in=mat2gray(im_in);
gt=mat2gray(gt);

% ���� precision-recall
cur_p=zeros(1,20);
cur_r=zeros(1,20);
for i=0.5:0.5:10
    cur_im=im_in*i;
    cur_im(cur_im>1)=1;
    
    cur_p=cur_im.*gt;
end
end