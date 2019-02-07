function im_name=imagePathRead(im_path)
% 读取指定文件夹下的同一类型图片
% 图像名称读取
im_type=['/*.jpg';'/*.png';'/*.bmp'];%   获取图片格式

for i=1:3
    img_path_list = dir([im_path,im_type(i,:)]); %获取该文件夹中所有jpg格式的图像
    img_num = length(img_path_list);        %获取图像总数量
    
    if img_num
        break;
    end
end

if img_num==0
    warning('文件夹不包含指定格式图片');
    return;
end

im_name=cell(img_num,1);
for i=1:img_num
    im_name{i}=img_path_list(i).name;
end
end