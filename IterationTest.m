%iteration time test
%% get params
feature_path=cell(3,1);
feature_path{1}='result_CHS\';
feature_path{2}='result_RC\';
feature_path{3}='result_DRFI\';

multi_ft=cell(3,1);
im_name=cell(3,1);
for i=1:3
    im_name{i}=imagePathRead(feature_path{i});
end

fig_id=21;
for j=1:3
    multi_ft{j}=imread(fullfile(feature_path{j},im_name{j}{fig_id}));
end

cmp_path='cmp_curve.mat';
if exist(cmp_path,'file')
    load(cmp_path,'-mat');
else
    disp('error: 权重文件不存在');
end

%% newton
[ sl_map ,iter_errorn, time_tn] = multiFeatureSlDecNewton( multi_ft, ft_params, priorPara );

%% bfgs
[ sl_map ,iter_errorb, time_tb] = multiFeatureSlDecBFGS( multi_ft, ft_params, priorPara );

%% figures
figure(111);
hold off;
plot(time_tn,iter_errorn,'color',[0.6,0,1]);
hold on;
plot(time_tb,iter_errorb,'color',[0.9,0.6,0]);

xlabel('Time/s');
ylabel('Error');

legend('Newton','BFGS');