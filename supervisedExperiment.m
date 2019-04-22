%% 有监督图像融合实验
% 基于频域方差融合

%% 读取图像
feature_path=cell(3,1);
feature_path{1}='result_CHS\';
feature_path{2}='result_RC\';
feature_path{3}='result_DRFI\';
gt_path='ground_truth_mask\';
save_path='our_result_MF\supervised\';  %result

multi_ft=cell(3,1);
im_name=cell(3,1);
for i=1:3
    im_name{i}=imagePathRead(feature_path{i});
end
im_n=length(im_name{1});

%% 设置参数
gn=100;gm=100;
rh=0.05;
gk=gaussianFilterFq(rh,gn,gm);%表示紧凑性的高斯滤波核

%% 参数有监督学习
tic;
[ft_params,priorPara]=TrainSaliencyFusion2( feature_path,gt_path,priorPara.gk );
priorPara.gk=gk;

report.trainTimeTotal=toc;
report.trainTimePerPic=report.trainTimeTotal/im_n;

disp(['训练耗时 ',num2str(report.trainTimeTotal),' s']);

%% 融合显著性并计算各个图像显著图
disp(['feature fusion: image number',num2str(im_n)]);
    
test_t=zeros(im_n,1);
for i=1:im_n
    if mod(i,10)==0
        disp(['current progress:',num2str(i),'/',num2str(im_n)]);
    end
    
    % 读取各个方法显著图
    for j=1:3
        multi_ft{j}=imread(fullfile(feature_path{j},im_name{j}{i}));
    end
    
    % 计算融合结果
    tic;
    salient_mp=multiFeatureSlDec( multi_ft, ft_params, priorPara );
    test_t(i)=toc;
    
    % 保存图像
    imwrite(salient_mp,fullfile(save_path,im_name{3}{i}));
end

report.testTimeTotal=sum(test_t);
report.testTimePerPic=mean(test_t);
report.testTimeStd=std(test_t);

%% 计算precision-recall
disp(['calculate precision-recall']);

compared_path=cell(6,1);
compared_path{1}='result_SR\';
compared_path{2}='result_IG\';
compared_path{3}='result_HS\';
compared_path{4}='result_CHS\';
compared_path{5}='result_RC\';
compared_path{6}='result_DRFI\';

precision=zeros(100,1);
recall=zeros(100,1);
levels=[1:100]*2.56;    %阈值变化

%对比算法
cmp_path='cmp_curve.mat';
if exist(cmp_path,'file')
    load(cmp_path,'-mat');
else
    cmp_curve=cell(6,1);
    for i=1:6
        disp(compared_path{i});
        cmp_curve{i}=PrecisionRecall(compared_path{i},gt_path);
    end
end

%融合结果
disp(save_path);
re_curve_sup=PrecisionRecall(save_path,gt_path);

%%  绘图
figure;
hold off;
plot(re_curve_sup.recall,re_curve_sup.precision,'color',[0.6,0,1]);
hold on;
for i=1:6
    colr=[max(i/4-0.5,0),max(1-abs(i-3.5)/4,0),max(1.1-i/4,0)];
    plot(cmp_curve{i}.recall,cmp_curve{i}.precision,'color',colr);
end
grid on;
xlabel('Recall');
ylabel('Precision');
axis([0,1,0,1]);

legend('sup-MF','SR','IG','HS','CHS','RC','DRFI');

%%  统计结果
for i=1:6
    result_table(1,i)=cmp_curve{i}.averP;
end
result_table(1,7)=re_curve_sup.averP;

%召回率
for i=1:6
    result_table(2,i)=cmp_curve{i}.averR;
end
result_table(2,7)=re_curve_sup.averR;

%F-measure
for i=1:7
    result_table(3,i)=2*result_table(1,i)*result_table(2,i)/(result_table(1,i)+result_table(2,i));
end