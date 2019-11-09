function [x_mm,y_mm] = IM_DEVIATION(I)

%%
%基本参数
I_width = 1280;%像素宽
I_height = 960;%像素高


%%
%边缘检测处理

[m,n,o] = size(I);
cut_top = m*3/8 + 1;
cut_below = m*6/8;
I_cut = I(cut_top:cut_below,:,:);

I_gray = rgb2gray(I_cut);

%level值的获取
% level = graythresh(I_gray);

level = my_threshhold(I_gray);
%
I_BW = my_im2bw(I_gray,level+0.1);
h1 = ones(4,4)/16;
I_BW = imfilter(I_BW,h1);%均值滤波
I_BW = imfilter(I_BW,h1);

%%
%利用灰度边缘检测获得货架下边界从而去除货架下侧的地面干扰

I_gray_edge =edge(I_gray,'Canny',0.4);

y_gray = sum(I_gray_edge,2);
y_gray = my_smooth(y_gray,5);
y_gray = my_smooth(y_gray,5);

x_gray = sum(I_gray_edge,1);

x_gray =my_smooth(x_gray,5);

%获取灰度边缘从下往上的第一个值在所有峰值中前二大小的峰值，作为货架的下边缘，用于对二值边缘的修正。
[y_gray_pks,y_gray_locs] = findpeaks(y_gray);%获取全部峰值
[b,i] = sort(y_gray_pks,'descend');%从大到小排列
y_bottom = y_gray_locs(max(i(1:3)));%获取y轴的值

[m,n] = size(I_BW);
I_BW(y_bottom+1:m,:) = 0;
I_BW(y_bottom,:) = 1;

%%
se=strel('rectangle',[25,25]);
I_BW=imclose(I_BW,se);%图像聚类，填充图像,闭运算
se=strel('rectangle',[20,20]);
I_BW=imopen(I_BW,se);%开运算
CC = bwlabel(I_BW);
temp_max_CC = max(max(CC));
temp_pixel_CC = zeros(1,temp_max_CC);
for i = 1:temp_max_CC
    temp_pixel_CC(1,i) = numel(find(CC == i));
end
% if (size(fieldnames(CC),1) == 5)
% temp_CC = CC.PixelIdxList;
% end
% [m,n] = size(temp_CC);
% temp = zeros(1,n);
% for i = 1:n
%     temp(1,i) = size( temp_CC{i},1);
% end
maxBC = round(max(temp_pixel_CC));
I_BW = bwareaopen(I_BW,maxBC);%去除小对象

I_BW_edge = edge(I_BW,'Canny');

% y = sum(I_BW_edge,2);
% %smooth函数
%y = my_smooth(y,7);
% % y = smooth(y,7);
% % y = smooth(y,7);
%smooth函数
x = sum(I_BW_edge,1);
x = my_smooth(x,5);
%%
%判断中心位置点
%y轴判断中心

[y_gray_pks,y_gray_locs] = findpeaks(y_gray);%获取全部峰值
[b,i] = sort(y_gray_pks,'descend');%从大到小排列
y_top = y_gray_locs(min(i(1:5)));%获取货架上边界y值

y_center = round((y_top + y_bottom)/2);%中点坐标
height = y_bottom - y_top;%高度

width_estimate = round(height*22/3);%预估宽度

[m,n] = size(I_BW_edge);
%判断左右边缘是否被遮挡
if(x(2) == 0 & x(n-1)==0)%左右均无遮挡
    [x_pks,x_locs] = findpeaks(x);%获取全部峰值
    [b,i] = sort(x_pks,'descend');%从大到小排列
    x_left = x_locs(min(i(1:7)));%获取货架上边界y值
    x_right = x_locs(max(i(1:7)));%获取货架上边界y值
    x_center = round((x_left + x_right)/2);%中心
    width = round(x_right - x_left);%宽度
    I_type = 1;
    
elseif(x(2) == 0 & x(n-1) ~=0)%右边界被遮挡
    [x_pks,x_locs] = findpeaks(x);%获取全部峰值
    [b,i] = sort(x_pks,'descend');%从大到小排列
    x_left = x_locs(min(i(1:5)));%获取货架左边界x值
    x_right = x_left + width_estimate;%估计货架右边界x值
    x_center = round((x_left + x_right)/2);%中心
    width = width_estimate;%宽度
    I_type = 2;
    
elseif((x(2) ~= 0 & x(n-1) == 0))%左边界被遮挡
    [x_pks,x_locs] = findpeaks(x);%获取全部峰值
    [b,i] = sort(x_pks,'descend');%从大到小排列
    x_right = x_locs(max(i(1:5)));%获取货架右边界x值
    x_left = x_right - width_estimate;%估计货架左边界x值
    x_center = round((x_left + x_right)/2);%中心
    width = width_estimate;%宽度
    I_type = 3;
else
    [x_pks,x_locs] = findpeaks(x);%获取全部峰值
    [b,i] = sort(x_pks,'descend');%从大到小排列
    x_right = x_locs(max(i(1:5)));%获取货架右边界x值
    x_left = x_right - width_estimate;%估计货架左边界x值
    x_center = round((x_left + x_right)/2);%中心
    width = width_estimate;%宽度
    I_type = 0;
end

%%
%显示坐标轴

%还原坐标切割前坐标
[m,n,o] = size(I);
y_top = m*3/8 + y_top;
y_bottom = m*3/8 + y_bottom;
y_center = m*3/8 + y_center;
y_center = y_center + round(height*(1-105/135)*0.5);


%%
%x轴由于图像畸变需要更加精确的定位

%截取
I_gray = rgb2gray(I);
x_reloc_left = max(round(x_center - width/10),1);
x_reloc_right = min(round(x_center + width/10),n);
I_reloc = I_gray(y_top:y_bottom,x_reloc_left:x_reloc_right);

I_reloc_edge = edge(I_reloc,'canny',0.2);
%闭操作
se=strel('rectangle',[15,15]);
I_reloc_edge=imclose(I_reloc_edge,se);%图像聚类，填充图像,闭运算

se=strel('rectangle',[30,15]);
I_reloc_edge=imopen(I_reloc_edge,se);%开运算
[m,n] = size(I_reloc_edge);
I_reloc_edge(1,:) = 0;
I_reloc_edge(m,:) = 0;
I_reloc_edge(:,1) = 0;
I_reloc_edge(:,n) = 0;

I_reloc_edge = edge(I_reloc_edge,'canny');

%找到小方块的左右边缘
x_reloc_edge = sum(I_reloc_edge,1);
x_reloc_edge = my_smooth(x_reloc_edge,5);
[x_reloc_pks,x_reloc_locs] = findpeaks(x_reloc_edge);%获取全部峰值
[b,i] = sort(x_reloc_pks,'descend');%从大到小排列
x_reloc_right2 = x_reloc_locs(max(i(1:2)));%获取货架左边界x值
x_reloc_left2 = x_reloc_locs(min(i(1:2)));%估计货架右边界x值
x_center = round((x_reloc_left2 + x_reloc_right2)/2);%中心
%还原x坐标
x_center = x_reloc_left + x_center;

%画坐标
I_gray(y_center-1:y_center+1,:) = 256;
I_gray(:,x_center-1:x_center+1) = 256;
%画图像中点
I_gray(I_height/2-1:I_height/2+2,I_width/2-1:I_width/2+2) = 256;

x_pixel = I_width/2 - x_center;
y_pixel = I_height/2 - y_center;

switch I_type
    case 1
        x_mm = 1100.0 * x_pixel / width;
    case 2 
        x_mm = 550.0 * x_pixel / (x_center - x_left);
    case 3
        x_mm = 550.0 * x_pixel / (x_right - x_center);
    otherwise
        x_mm =0;
end
y_mm = -150.0 * y_pixel / height;

end



