function im_name=imagePathRead(im_path)
% ��ȡָ���ļ����µ�ͬһ����ͼƬ
% ͼ�����ƶ�ȡ
im_type=['/*.jpg';'/*.png';'/*.bmp'];%   ��ȡͼƬ��ʽ

for i=1:3
    img_path_list = dir([im_path,im_type(i,:)]); %��ȡ���ļ���������jpg��ʽ��ͼ��
    img_num = length(img_path_list);        %��ȡͼ��������
    
    if img_num
        break;
    end
end

if img_num==0
    warning('�ļ��в�����ָ����ʽͼƬ');
    return;
end

im_name=cell(img_num,1);
for i=1:img_num
    im_name{i}=img_path_list(i).name;
end
end