function [ feature_para,priorPara ] = TrainSaliencyFusion2( feature_path,gt_path,gk )
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
for ii=1:nf
    im_name{ii}=imagePathRead(feature_path{ii});
end
gt_name=imagePathRead(gt_path);

lf=length(im_name{1});%训练样本个数

[nk,mk]=size(gk);

dim_s=nk*mk;%融合图的像素个数

% train conv params
convk=solveKernel();

% train other parameters
[deltar,alphac,fweight,convk]=solveParams(convk);

% output
feature_para=cell(nf,1);
for ii=1:nf
    feature_para{ii}.weight=fweight{ii};
    feature_para{ii}.convk=convk{ii};
end

priorPara.deltar=deltar;
priorPara.alphac=alphac;

    function convk=solveKernel()
        %solve the conv kernel
        matPara=cell(nf,nf);
        vecPara=cell(nf,1);
        
        for i=1:nf
            vecPara{i}=zeros(nk,mk);
            for j=1:nf
                matPara{i,j}=zeros(nk,mk);
            end
        end
        
        ftCur=cell(nf,1);
        
        disp(['training conv kernel, total number of images: ',num2str(lf)]);
        for i=1:lf
            if mod(i,10)==0
                disp(['current progress:',num2str(i),'/',num2str(lf)]);
            end
            
            % load ground truth
            gt_map0=imread([gt_path,gt_name{i}]);
            gt_mapr=imresize(gt_map0(:,:,1),[nk,mk]);
            gt_mapr=im2double(gt_mapr);
            
            gt_fft=fft2(gt_mapr);
            
            % load feature map
            for j=1:nf
                feature_map0=imread([feature_path{j},im_name{j}{i}]);
                feature_mapr=imresize(feature_map0(:,:,1),[nk,mk]);
                feature_mapr=im2double(feature_mapr);
                
                feature_fft=fft2(feature_mapr);
                ftCur{j}=feature_fft;
            end
            
            % estimate the params
            for j=1:nf
                conj_ft=conj(ftCur{j});
                vecPara{j}=vecPara{j}+conj_ft.*gt_fft;
                
                for k=1:nf
                    matPara{j,k}=matPara{j,k}+conj_ft.*ftCur{k};
                end
            end
        end
        
        %solve the linear function
        for i=1:nf-1
            for j=i+1:nf
                ratio=matPara{j,i}./matPara{i,i};
                
                vecPara{j}=vecPara{j}-ratio.*vecPara{i};
                matPara{j,i}=matPara{j,i}*0;
                for k=i+1:nf;
                    matPara{j,k}=matPara{j,k}-ratio.*matPara{i,k};
                end
            end
        end
        
        convk=cell(nf,1);
        
        convk{nf}=vecPara{nf}./matPara{nf,nf};
        for i=nf-1:-1:1
            for j=i+1:nf
                vecPara{nf}=vecPara{nf}-matPara{i,j}.*convk{j};
            end
            convk{i}=vecPara{i}./matPara{i,i};
        end
    end

    function [deltar,alphac,fweight,convk]=solveParams(convk)
        %solve params except for kernel
        % solve weight
        fweight=cell(nf,1);
        for i=1:nf
            m_conv=mean(mean(abs(convk{i})));
            fweight{i}=m_conv*ones(nk,mk);
        end
        
        % training parameters
        disp(['training prior parameters, total number of images: ',num2str(lf)]);
        
        deltar=0;
        alphac=0;
        
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
        end
        
        deltar=sqrt(deltar/(lf*dim_s));
        alphac=(lf*dim_s)/alphac;
        
        %normalization
        M=1/deltar^2+alphac*(1-gk.*gk);
        for i=1:nf
            M=M+fweight{i};
        end
        for i=1:nf
            convk{i}=convk{i}.*(M./fweight{i});
        end
    end
end

