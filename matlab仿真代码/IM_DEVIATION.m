function [x_mm,y_mm] = IM_DEVIATION(I)

%%
%��������
I_width = 1280;%���ؿ�
I_height = 960;%���ظ�


%%
%��Ե��⴦��

[m,n,o] = size(I);
cut_top = m*3/8 + 1;
cut_below = m*6/8;
I_cut = I(cut_top:cut_below,:,:);

I_gray = rgb2gray(I_cut);

%levelֵ�Ļ�ȡ
% level = graythresh(I_gray);

level = my_threshhold(I_gray);
%
I_BW = my_im2bw(I_gray,level+0.1);
h1 = ones(4,4)/16;
I_BW = imfilter(I_BW,h1);%��ֵ�˲�
I_BW = imfilter(I_BW,h1);

%%
%���ûҶȱ�Ե����û����±߽�Ӷ�ȥ�������²�ĵ������

I_gray_edge =edge(I_gray,'Canny',0.4);

y_gray = sum(I_gray_edge,2);
y_gray = my_smooth(y_gray,5);
y_gray = my_smooth(y_gray,5);

x_gray = sum(I_gray_edge,1);

x_gray =my_smooth(x_gray,5);

%��ȡ�Ҷȱ�Ե�������ϵĵ�һ��ֵ�����з�ֵ��ǰ����С�ķ�ֵ����Ϊ���ܵ��±�Ե�����ڶԶ�ֵ��Ե��������
[y_gray_pks,y_gray_locs] = findpeaks(y_gray);%��ȡȫ����ֵ
[b,i] = sort(y_gray_pks,'descend');%�Ӵ�С����
y_bottom = y_gray_locs(max(i(1:3)));%��ȡy���ֵ

[m,n] = size(I_BW);
I_BW(y_bottom+1:m,:) = 0;
I_BW(y_bottom,:) = 1;

%%
se=strel('rectangle',[25,25]);
I_BW=imclose(I_BW,se);%ͼ����࣬���ͼ��,������
se=strel('rectangle',[20,20]);
I_BW=imopen(I_BW,se);%������
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
I_BW = bwareaopen(I_BW,maxBC);%ȥ��С����

I_BW_edge = edge(I_BW,'Canny');

% y = sum(I_BW_edge,2);
% %smooth����
%y = my_smooth(y,7);
% % y = smooth(y,7);
% % y = smooth(y,7);
%smooth����
x = sum(I_BW_edge,1);
x = my_smooth(x,5);
%%
%�ж�����λ�õ�
%y���ж�����

[y_gray_pks,y_gray_locs] = findpeaks(y_gray);%��ȡȫ����ֵ
[b,i] = sort(y_gray_pks,'descend');%�Ӵ�С����
y_top = y_gray_locs(min(i(1:5)));%��ȡ�����ϱ߽�yֵ

y_center = round((y_top + y_bottom)/2);%�е�����
height = y_bottom - y_top;%�߶�

width_estimate = round(height*22/3);%Ԥ�����

[m,n] = size(I_BW_edge);
%�ж����ұ�Ե�Ƿ��ڵ�
if(x(2) == 0 & x(n-1)==0)%���Ҿ����ڵ�
    [x_pks,x_locs] = findpeaks(x);%��ȡȫ����ֵ
    [b,i] = sort(x_pks,'descend');%�Ӵ�С����
    x_left = x_locs(min(i(1:7)));%��ȡ�����ϱ߽�yֵ
    x_right = x_locs(max(i(1:7)));%��ȡ�����ϱ߽�yֵ
    x_center = round((x_left + x_right)/2);%����
    width = round(x_right - x_left);%���
    I_type = 1;
    
elseif(x(2) == 0 & x(n-1) ~=0)%�ұ߽类�ڵ�
    [x_pks,x_locs] = findpeaks(x);%��ȡȫ����ֵ
    [b,i] = sort(x_pks,'descend');%�Ӵ�С����
    x_left = x_locs(min(i(1:5)));%��ȡ������߽�xֵ
    x_right = x_left + width_estimate;%���ƻ����ұ߽�xֵ
    x_center = round((x_left + x_right)/2);%����
    width = width_estimate;%���
    I_type = 2;
    
elseif((x(2) ~= 0 & x(n-1) == 0))%��߽类�ڵ�
    [x_pks,x_locs] = findpeaks(x);%��ȡȫ����ֵ
    [b,i] = sort(x_pks,'descend');%�Ӵ�С����
    x_right = x_locs(max(i(1:5)));%��ȡ�����ұ߽�xֵ
    x_left = x_right - width_estimate;%���ƻ�����߽�xֵ
    x_center = round((x_left + x_right)/2);%����
    width = width_estimate;%���
    I_type = 3;
else
    [x_pks,x_locs] = findpeaks(x);%��ȡȫ����ֵ
    [b,i] = sort(x_pks,'descend');%�Ӵ�С����
    x_right = x_locs(max(i(1:5)));%��ȡ�����ұ߽�xֵ
    x_left = x_right - width_estimate;%���ƻ�����߽�xֵ
    x_center = round((x_left + x_right)/2);%����
    width = width_estimate;%���
    I_type = 0;
end

%%
%��ʾ������

%��ԭ�����и�ǰ����
[m,n,o] = size(I);
y_top = m*3/8 + y_top;
y_bottom = m*3/8 + y_bottom;
y_center = m*3/8 + y_center;
y_center = y_center + round(height*(1-105/135)*0.5);


%%
%x������ͼ�������Ҫ���Ӿ�ȷ�Ķ�λ

%��ȡ
I_gray = rgb2gray(I);
x_reloc_left = max(round(x_center - width/10),1);
x_reloc_right = min(round(x_center + width/10),n);
I_reloc = I_gray(y_top:y_bottom,x_reloc_left:x_reloc_right);

I_reloc_edge = edge(I_reloc,'canny',0.2);
%�ղ���
se=strel('rectangle',[15,15]);
I_reloc_edge=imclose(I_reloc_edge,se);%ͼ����࣬���ͼ��,������

se=strel('rectangle',[30,15]);
I_reloc_edge=imopen(I_reloc_edge,se);%������
[m,n] = size(I_reloc_edge);
I_reloc_edge(1,:) = 0;
I_reloc_edge(m,:) = 0;
I_reloc_edge(:,1) = 0;
I_reloc_edge(:,n) = 0;

I_reloc_edge = edge(I_reloc_edge,'canny');

%�ҵ�С��������ұ�Ե
x_reloc_edge = sum(I_reloc_edge,1);
x_reloc_edge = my_smooth(x_reloc_edge,5);
[x_reloc_pks,x_reloc_locs] = findpeaks(x_reloc_edge);%��ȡȫ����ֵ
[b,i] = sort(x_reloc_pks,'descend');%�Ӵ�С����
x_reloc_right2 = x_reloc_locs(max(i(1:2)));%��ȡ������߽�xֵ
x_reloc_left2 = x_reloc_locs(min(i(1:2)));%���ƻ����ұ߽�xֵ
x_center = round((x_reloc_left2 + x_reloc_right2)/2);%����
%��ԭx����
x_center = x_reloc_left + x_center;

%������
I_gray(y_center-1:y_center+1,:) = 256;
I_gray(:,x_center-1:x_center+1) = 256;
%��ͼ���е�
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



