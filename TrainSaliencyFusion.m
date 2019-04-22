function [ feature_para,priorPara ] = TrainSaliencyFusion( feature_path,gt_path,gk )
%TrainSaliencyFusion Function for training the Saliency Fusion
%   The training goal is the maximum likelihood estimation 
%   (for maximum the mean average precision, we have to use the gradient 
%   descent because of its nonlinearity)
%
%input of function:
%@feature_path  the path of fusion features
%@gt_path       the path of ground truth
%@gk            the gaussian kernel for testing compactness
%
%output of function:
%@feature_para  parameters of each feature
%@priorPara     parameters of prior knowledge

% Initialization
nf=length(feature_path);%特征个数
im_name=cell(nf,1);
for i=1:nf
    im_name{i}=imagePathRead(feature_path{i});
end
gt_name=imagePathRead(gt_path);

lf=length(im_name{1});%训练样本个数

[nk,mk]=size(gk);

dim_s=nk*mk;%融合图的像素个数

deltar=0;%parameters of prior knowledge
alphac=0;

fweight=cell(nf,1);%parameters of each feature
for i=1:nf
    fweight{i}=zeros(nk,mk);
end

fconvk=fweight;
fconvk_m=fconvk;%计算convk的分母

% training parameters
disp(['training prior parameters, total number of images: ',num2str(lf)]);

for i=1:lf
    if mod(i,10)==0
        disp(['current progress:',num2str(i),'/',num2str(lf)]);
    end
    
    % load ground truth
    gt_map0=imread([gt_path,gt_name{i}]);
    gt_mapr=imresize(gt_map0(:,:,1),[nk,mk]);
    gt_mapr=im2double(gt_mapr);
    
    gt_fft=fft2(gt_mapr);
    Ggt_map=gt_fft.*gk;
    
    % prior knowledge estimation
    E_gt_map=sum(sum(gt_fft.*conj(gt_fft)));
    E_Ggt_map=sum(sum(Ggt_map.*conj(Ggt_map)));
    
    deltar=deltar+E_gt_map;
    alphac=alphac+(E_gt_map-E_Ggt_map);
    
    for j=1:nf
        % load feature map
        feature_map0=imread([feature_path{j},im_name{j}{i}]);
        feature_mapr=imresize(feature_map0(:,:,1),[nk,mk]);
        feature_mapr=im2double(feature_mapr);
        
        feature_fft=fft2(feature_mapr);
        conj_ft_fft=conj(feature_fft);
        
        % feature parameters estimation (MLE, not max MAP)
        fconvk{j}=fconvk{j}+gt_fft.*conj_ft_fft;
        fconvk_m{j}=fconvk_m{j}+feature_fft.*conj_ft_fft;
    end
end

deltar=sqrt(deltar/(lf*dim_s));
alphac=(lf*dim_s)/alphac;

for j=1:nf
    fconvk{j}=fconvk{j}./fconvk_m{j};
end

%train parameters: the weight
disp(['training weight, total number of images: ',num2str(lf)]);
for i=1:lf
    if mod(i,10)==0
        disp(['current progress:',num2str(i),'/',num2str(lf)]);
    end
    
    % load ground truth
    gt_map0=imread([gt_path,gt_name{i}]);
    gt_mapr=imresize(gt_map0(:,:,1),[nk,mk]);
    gt_mapr=im2double(gt_mapr);
    
    gt_fft=fft2(gt_mapr);
    
    for j=1:nf
        % load feature map
        feature_map0=imread([feature_path{j},im_name{j}{i}]);
        feature_mapr=imresize(feature_map0(:,:,1),[nk,mk]);
        feature_mapr=im2double(feature_mapr);
        
        feature_fft=fft2(feature_mapr);
        
        % estimate the weight
        delta_ft=gt_fft-feature_fft.*fconvk{j};
        fweight{j}=fweight{j}+delta_ft.*conj(delta_ft);
    end
end

for j=1:nf
    fweight{j}=lf./fweight{j};
end

% output
feature_para=cell(nf,1);
for j=1:nf
    feature_para{j}.weight=fweight{j};
    feature_para{j}.convk=fconvk{j};
end

priorPara.deltar=deltar;
priorPara.alphac=alphac;
end

