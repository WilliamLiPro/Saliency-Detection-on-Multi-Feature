%% 启发式图像融合实验
% 基于频域方差融合

%% 读取图像
im_path=cell(6,1);      %path of original images
im_path{1}='saliencymaps\AC\';
im_path{2}='saliencymaps\GB\';
im_path{3}='saliencymaps\IG\';
im_path{4}='saliencymaps\IT\';
im_path{5}='saliencymaps\MZ\';
im_path{6}='saliencymaps\SR\';
gt_path='binarymasks';
save_path='result\heuristic\';  %result
multi_ft=cell(6,1);
%% 导入图片文件
im_name=imagePathRead(im_path{1});
gt_name=imagePathRead(gt_path);
im_n=length(im_name);

%% 设置参数
[n,m,~]=size(imread(fullfile(im_path{1},im_name{1})));
x=[1:m];
y=[1:n]';
%AC方差
kernel_y=0.5-0.7*exp(-y/40)+0.4*exp(-y/10);
kernel_x=0.5-0.7*exp(-x/40)+0.4*exp(-x/10);
multi_ft{1}.var=kernel_y*kernel_x;
%GB方差
kernel_y=1.1-exp(-[y-25].^2/(2*30^2));
kernel_x=1.1-exp(-[x-25].^2/(2*30^2));
multi_ft{2}.var=kernel_y*kernel_x;
%IG方差
kernel_y=0.4-0.4*exp(-y/60)+0.2*exp(-y);
kernel_x=0.4-0.4*exp(-x/60)+0.2*exp(-x);
multi_ft{3}.var=kernel_y*kernel_x;
%IT方差
kernel_y=1.5-1.3*exp(-[y-30].^2/(2*10^2));
kernel_x=1.5-1.3*exp(-[x-30].^2/(2*10^2));
multi_ft{4}.var=kernel_y*kernel_x;
%MZ方差
kernel_y=1-0.82*exp(-[y-50].^2/(2*20^2));
kernel_x=1-0.82*exp(-[x-50].^2/(2*20^2));
multi_ft{5}.var=kernel_y*kernel_x;
%SR方差
kernel_y=1.2*exp(-y/40)+0.05;
kernel_x=1.2*exp(-x/40)+0.05;
multi_ft{6}.var=kernel_y*kernel_x;

%% 融合显著性并计算各个图像显著图
disp('启发式融合算法');
precision=zeros(100,1);
recall=zeros(100,1);
levels=[1:100]*2.56;    %阈值变化

for i=1:im_n
    % 读取各个方法显著图
    for j=1:6
        multi_ft{j}.image=imread(fullfile(im_path{j},im_name{i}));
    end
    
    % 计算融合结果
    salient_mp=multiFeatureSalientDetection(multi_ft);
    
    % 保存图像
    imwrite(uint8(salient_mp),fullfile(save_path,im_name{i}));
end

%% 计算precision-recall
%对比算法
disp('PR曲线');
cmp_curve=cell(6,1);
for i=1:6
    disp(['对比算法PR曲线',num2str(i)]);
    cmp_curve{i}=PrecisionRecall(im_path{i},gt_path);
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

legend('h-MF','AC','GB','IG','IT','MZ','SR');

%%  统计结果
%准确率
for i=1:6
    result_table(1,i)=cmp_curve{i}.averP;
end
result_table(1,7)=re_curve.averP;

%召回率
for i=1:6
    result_table(2,i)=cmp_curve{i}.averR;
end
result_table(2,7)=re_curve.averR;

%F-measure
for i=1:7
    result_table(3,i)=2*result_table(1,i)*result_table(2,i)/(result_table(1,i)+result_table(2,i));
end