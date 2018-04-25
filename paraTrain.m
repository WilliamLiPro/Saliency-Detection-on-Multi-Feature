%% 方差参数训练函数
function vars=paraTrain(im_path,gt_path,seed)
%采用最小二乘计算频域方差参数
%所有图像归一化到200*200尺寸
% 输入：
%@im_path   各类显著图像路径
%@gt_path   ground truth 路径
%@seed      方差初值
% 输出：
%@vars      各类算法方差

% 1.读取图像名称
n=length(im_path);
im_name=imagePathRead(im_path{1});
gt_name=imagePathRead(gt_path);

% 2.迭代计算参数
%参数初始化
if iscell(seed)
    result=cell(n,1);
    sum_im=zeros(200,200);
    for i=1:n
        cur_im=1./seed{i};
        result{i}=cur_im(1:200,1:200);
        sum_im=sum_im+cur_im(1:200,1:200);
    end
    
    % 归一化
    for i=1:n
        result{i}=result{i}./sum_im;
    end
else
    result=cell(n,1);
    for i=1:n
        result{i}=ones(200,200)/n;
    end
end

% 显示结果
max_iter=50;
ave_er=nan(max_iter,1);
showRessult(gt_path,gt_name,im_path,im_name,result,ave_er,4);
    
%迭代优化
for iter=1:max_iter
    disp(['迭代次数：',num2str(iter)]);
    [gr,ave_er(iter)]=gradientSolver(gt_path,gt_name,im_path,im_name,result);
    
    ang=0;
    for i=1:n
        ang=max([ang,max(abs(gr{i}(:)))]);
    end
    
    for i=1:n
        result{i}=result{i}-(0.1/n/ang)*gr{i};
    end
    
    % 显示结果
    showRessult(gt_path,gt_name,im_path,im_name,result,ave_er,4);
end

vars=cell(n,1);
for i=1:n
    vars{i}=1./result{i};
end
end

function [gr,ave_er]=gradientSolver(gt_path,gt_name,im_path,im_name,vars)
% 计算待求解参数vars的梯度 非线性函数为截断函数：估计与真值之差大于0的置为0
% 采用批次抽样计算随机梯度
%@gt_path GT路径
%@gt_name GT名称
%@im_path 显著图路径
%@im_name 显著图名称
%@vars    参数当前值
% 输出
%@gr      梯度图
%@ave_er  平均误差

% 1.数据个数及初始化
n=length(im_path);
m=length(gt_name);

gr=cell(n,1);
pic_gr=zeros(200,200);
for i=1:n
    gr{i}=zeros(200,200);
end

cur_est=zeros(200,200);
dct_im=cell(n,1);

% 2.随机抽样
sp_num=100; %每个批次抽样100幅图像
randp=randperm(m);
image_id=randp(1:sp_num);

% 3.计算梯度
disp(['本批次图像数为 ',num2str(sp_num)]);
ave_er=0;
for pic=1:sp_num
    if mod(pic,10)==0
        disp(['已处理图像个数 ',num2str(pic)]);
    end
    
    %读取GT
    imid=image_id(pic);
    gt=imread(fullfile(gt_path,gt_name{imid}));
    gt=gt(:,:,1);
    gt=double(imresize(gt,[200,200]));
    
    % 当前估计值
    cur_est(:)=0;
    for i=1:n
        cur_im=imread(fullfile(im_path{i},im_name{imid}));
        cur_im=cur_im(:,:,1);
        cur_im=imresize(cur_im,[200,200]);
        dct_im{i}=dct2(cur_im);
        
        cur_est=cur_est+(vars{i}.*dct_im{i});
    end
    
    cur_est=idct2(cur_est);
    
    %计算误差与梯度
    pic_gr(:)=0;
    for r=1.4:0.4:9
        % 误差
        d_im=r*cur_est-gt;
        d_im(logical((d_im>0).*(gt>200)))=0;    %当显著性判断正确时，误差为0
%         d_im(logical((d_im<200).*(gt==0)))=0;   %当非显著性判断正确时，误差为0
        d_im(d_im>255)=255;    %误差最大为255
        
        ave_er=ave_er+mean(abs(d_im(:)));	%累积误差
        
        d_im=dct2(d_im);    %频域
        pic_gr=pic_gr+r*d_im;
    end
    
    for i=1:n
        gr{i}=gr{i}+pic_gr.*dct_im{i};
    end
end

% 将梯度范围归一化到0-1;
for i=1:n
    gr{i}=gr{i}/(sp_num*10000^2*sum(1:20));
end
ave_er=ave_er/(sp_num*20);

end

function showRessult(gt_path,gt_name,im_path,im_name,result,ave_ers,im_id)
% 显示GT和估计值的对比
n=length(im_path);

% 1.读取数据
gt=imread(fullfile(gt_path,gt_name{im_id}));
gt=gt(:,:,1);
gt=double(imresize(gt,[200,200]));

% 2.计算估计值
est=zeros(200,200);
for i=1:n
    im_in=imread(fullfile(im_path{i},im_name{im_id}));
    im_in=im_in(:,:,1);
    im_in=imresize(im_in,[200,200]);
    
    est=est+dct2(im_in).*result{i};
end
est=idct2(est);

% 3.显示结果比较
figure(111);
imshow([gt,est]/256);
pause(0.1);

% 4.显示误差变化曲线
figure(112);
plot(ave_ers);
pause(0.1);
end

function im_name=imagePathRead(im_path)
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