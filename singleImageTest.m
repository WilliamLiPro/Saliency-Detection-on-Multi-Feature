%% Single image test
% 基于频域方差融合

%% load the path of image
feature_path=cell(3,1);
feature_path{1}='result_CHS\';
feature_path{2}='result_RC\';
feature_path{3}='result_DRFI\';
gt_path='ground_truth_mask\';
save_path='our_result_MF\heuristic\';  %result

multi_ft=cell(3,1);
im_name=cell(3,1);
for i=1:3
    im_name{i}=imagePathRead(feature_path{i});
end
im_n=length(im_name{1});

%% setting params
gn=100;gm=100;
rh=0.05;
gk=gaussianFilterFq(rh,gn,gm);%表示紧凑性的高斯滤波核

% prior params
priorPara.deltar=50;
priorPara.alphac=0.012;
priorPara.gk=gk;

% fusion params
x=0:99;
x(100:-1:51)=1:50;

ft_params=cell(3,1);

%CHS
ft_params{1}.weight=0.35*ones(gn,gm);
wx=exp(-x.^2/4000);
ft_params{1}.convk=wx'*wx;

%RC
ft_params{2}.weight=0.2*ones(gn,gm);
wx=exp(-x.^2/400);
ft_params{2}.convk=wx'*wx;

%DRFI
ft_params{3}.weight=0.45*ones(gn,gm);
wx=exp(-x.^2/5000);
ft_params{3}.convk=wx'*wx;

%% feature fusion
%read the feature map
im_id=26;
for j=1:3
    multi_ft{j}=imread(fullfile(feature_path{j},im_name{j}{im_id}));
end

% fusion
salient_mp=multiFeatureSlDec( multi_ft, ft_params, priorPara );
figure;imshow(salient_mp);title('fusion result');
figure;imshow([multi_ft{1},multi_ft{2},multi_ft{3}]);title('feature maps');