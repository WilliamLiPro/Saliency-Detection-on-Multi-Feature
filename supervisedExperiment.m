%% 有监督图像融合实验
% 基于频域方差融合

%% 读取图像
im_path=cell(6,1);
im_path{1}='saliencymaps\AC\';
im_path{2}='saliencymaps\GB\';
im_path{3}='saliencymaps\IG\';
im_path{4}='saliencymaps\IT\';
im_path{5}='saliencymaps\MZ\';
im_path{6}='saliencymaps\SR\';
gt_path='binarymasks\';
save_path='有监督\';
multi_ft=cell(6,1);
%% 导入图片文件
im_name=imagePathRead(im_path{1});
gt_name=imagePathRead(gt_path);
im_n=length(im_name);

%% 设置参数
[n,m,~]=size(imread(fullfile(im_path{1},im_name{1})));
x=[1:m];
y=[1:n]';
vars=cell(6,1);
%AC方差
kernel_y=0.6-0.8*exp(-y/40)+0.4*exp(-y/10);
kernel_x=0.6-0.8*exp(-x/40)+0.4*exp(-x/10);
vars{1}=kernel_y*kernel_x;
%GB方差
kernel_y=1.1-exp(-[y-25].^2/(2*30^2));
kernel_x=1.1-exp(-[x-25].^2/(2*30^2));
vars{2}=kernel_y*kernel_x;
%IG方差
kernel_y=0.5-0.5*exp(-y/80);
kernel_x=0.5-0.5*exp(-x/80);
vars{3}=kernel_y*kernel_x;
%IT方差
kernel_y=1.5-1.3*exp(-[y-30].^2/(2*10^2));
kernel_x=1.5-1.3*exp(-[x-30].^2/(2*10^2));
vars{4}=kernel_y*kernel_x;
%MZ方差
kernel_y=1.15-exp(-[y-50].^2/(2*20^2));
kernel_x=1.15-exp(-[x-50].^2/(2*20^2));
vars{5}=kernel_y*kernel_x;
%SR方差
kernel_y=1.2*exp(-y/40)+0.05;
kernel_x=1.2*exp(-x/40)+0.05;
vars{6}=kernel_y*kernel_x;

%% 参数有监督学习
tic;
vars=paraTrain(im_path,gt_path,vars);
for i=1:6
    multi_ft{i}.var=vars{i};
end
report.trainTimeTotal=toc;
report.trainTimePerPic=report.trainTimeTotal/im_n;

disp(['训练耗时 ',num2str(report.trainTimeTotal),' s']);

%% 融合显著性并计算各个图像显著图
precision=zeros(100,1);
recall=zeros(100,1);
levels=[1:100]*2.56;    %阈值变化

test_t=zeros(im_n,1);

for i=1:im_n
    % 读取各个方法显著图
    for j=1:6
        multi_ft{j}.image=imread(fullfile(im_path{j},im_name{i}));
    end
    
    % 计算融合结果
    tic;
    salient_mp=multiFeatureSalientDetection(multi_ft);
    test_t(i)=toc;
    
    % 保存图像
    imwrite(uint8(salient_mp),fullfile(save_path,im_name{i}));
end

report.testTimeTotal=sum(test_t);
report.testTimePerPic=mean(test_t);
report.testTimeStd=std(test_t);

%% 计算precision-recall
%对比算法
cmp_path='cmp_curve.mat';
if exist(cmp_path,'file')
    load(cmp_path,'-mat');
else
    cmp_curve=cell(6,1);
    for i=1:6
        cmp_curve{i}=PrecisionRecall(im_path{i},gt_path);
    end
    save('cmp_curve.mat',cmp_curve);
end

%融合结果
re_curve=PrecisionRecall(save_path,gt_path);

%%  绘图
figure;
hold off;
plot(re_curve.recall,re_curve.precision,'k');
hold on;
for i=1:6
    colr=[max(i/4-0.5,0),max(1-abs(i-3.5)/4,0),max(1.1-i/4,0)];
    plot(cmp_curve{i}.recall,cmp_curve{i}.precision,'color',colr);
end
grid on;
xlabel('Recall');
ylabel('Precision');