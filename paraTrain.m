%% �������ѵ������
function vars=paraTrain(im_path,gt_path,seed)
%������С���˼���Ƶ�򷽲����
%����ͼ���һ����200*200�ߴ�
% ���룺
%@im_path   ��������ͼ��·��
%@gt_path   ground truth ·��
%@seed      �����ֵ
% �����
%@vars      �����㷨����

% 1.��ȡͼ������
n=length(im_path);
im_name=imagePathRead(im_path{1});
gt_name=imagePathRead(gt_path);

% 2.�����������
%������ʼ��
if iscell(seed)
    result=cell(n,1);
    sum_im=zeros(200,200);
    for i=1:n
        cur_im=1./seed{i};
        result{i}=cur_im(1:200,1:200);
        sum_im=sum_im+cur_im(1:200,1:200);
    end
    
    % ��һ��
    for i=1:n
        result{i}=result{i}./sum_im;
    end
else
    result=cell(n,1);
    for i=1:n
        result{i}=ones(200,200)/n;
    end
end

% ��ʾ���
max_iter=50;
ave_er=nan(max_iter,1);
showRessult(gt_path,gt_name,im_path,im_name,result,ave_er,4);
    
%�����Ż�
for iter=1:max_iter
    disp(['����������',num2str(iter)]);
    [gr,ave_er(iter)]=gradientSolver(gt_path,gt_name,im_path,im_name,result);
    
    ang=0;
    for i=1:n
        ang=max([ang,max(abs(gr{i}(:)))]);
    end
    
    for i=1:n
        result{i}=result{i}-(0.1/n/ang)*gr{i};
    end
    
    % ��ʾ���
    showRessult(gt_path,gt_name,im_path,im_name,result,ave_er,4);
end

vars=cell(n,1);
for i=1:n
    vars{i}=1./result{i};
end
end

function [gr,ave_er]=gradientSolver(gt_path,gt_name,im_path,im_name,vars)
% �����������vars���ݶ� �����Ժ���Ϊ�ضϺ�������������ֵ֮�����0����Ϊ0
% �������γ�����������ݶ�
%@gt_path GT·��
%@gt_name GT����
%@im_path ����ͼ·��
%@im_name ����ͼ����
%@vars    ������ǰֵ
% ���
%@gr      �ݶ�ͼ
%@ave_er  ƽ�����

% 1.���ݸ�������ʼ��
n=length(im_path);
m=length(gt_name);

gr=cell(n,1);
pic_gr=zeros(200,200);
for i=1:n
    gr{i}=zeros(200,200);
end

cur_est=zeros(200,200);
dct_im=cell(n,1);

% 2.�������
sp_num=100; %ÿ�����γ���100��ͼ��
randp=randperm(m);
image_id=randp(1:sp_num);

% 3.�����ݶ�
disp(['������ͼ����Ϊ ',num2str(sp_num)]);
ave_er=0;
for pic=1:sp_num
    if mod(pic,10)==0
        disp(['�Ѵ���ͼ����� ',num2str(pic)]);
    end
    
    %��ȡGT
    imid=image_id(pic);
    gt=imread(fullfile(gt_path,gt_name{imid}));
    gt=gt(:,:,1);
    gt=double(imresize(gt,[200,200]));
    
    % ��ǰ����ֵ
    cur_est(:)=0;
    for i=1:n
        cur_im=imread(fullfile(im_path{i},im_name{imid}));
        cur_im=cur_im(:,:,1);
        cur_im=imresize(cur_im,[200,200]);
        dct_im{i}=dct2(cur_im);
        
        cur_est=cur_est+(vars{i}.*dct_im{i});
    end
    
    cur_est=idct2(cur_est);
    
    %����������ݶ�
    pic_gr(:)=0;
    for r=1.4:0.4:9
        % ���
        d_im=r*cur_est-gt;
        d_im(logical((d_im>0).*(gt>200)))=0;    %���������ж���ȷʱ�����Ϊ0
%         d_im(logical((d_im<200).*(gt==0)))=0;   %�����������ж���ȷʱ�����Ϊ0
        d_im(d_im>255)=255;    %������Ϊ255
        
        ave_er=ave_er+mean(abs(d_im(:)));	%�ۻ����
        
        d_im=dct2(d_im);    %Ƶ��
        pic_gr=pic_gr+r*d_im;
    end
    
    for i=1:n
        gr{i}=gr{i}+pic_gr.*dct_im{i};
    end
end

% ���ݶȷ�Χ��һ����0-1;
for i=1:n
    gr{i}=gr{i}/(sp_num*10000^2*sum(1:20));
end
ave_er=ave_er/(sp_num*20);

end

function showRessult(gt_path,gt_name,im_path,im_name,result,ave_ers,im_id)
% ��ʾGT�͹���ֵ�ĶԱ�
n=length(im_path);

% 1.��ȡ����
gt=imread(fullfile(gt_path,gt_name{im_id}));
gt=gt(:,:,1);
gt=double(imresize(gt,[200,200]));

% 2.�������ֵ
est=zeros(200,200);
for i=1:n
    im_in=imread(fullfile(im_path{i},im_name{im_id}));
    im_in=im_in(:,:,1);
    im_in=imresize(im_in,[200,200]);
    
    est=est+dct2(im_in).*result{i};
end
est=idct2(est);

% 3.��ʾ����Ƚ�
figure(111);
imshow([gt,est]/256);
pause(0.1);

% 4.��ʾ���仯����
figure(112);
plot(ave_ers);
pause(0.1);
end

function im_name=imagePathRead(im_path)
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