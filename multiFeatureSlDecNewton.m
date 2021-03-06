function [ sl_map ,iter_error, time_t] = multiFeatureSlDecNewton( multi_ft, ft_params, priorPara )
%multiFeatureSlDec 融合多特征的图像显著性检测，使用Newton法求解
%   此处显示详细说明
%输入：
%@multi_ft      多特征显著图，为cell类型数据
%@ft_params     多特征融合参数，为cell类型数据
%@priorPara     先验参数
%输出：
%@sl_map        最终的显著图

%parameters
deltar=priorPara.deltar;
alphac=priorPara.alphac;
gk=priorPara.gk;

%fft
nf=length(multi_ft);%特征个数
[nk,mk]=size(gk);

ft_feature=cell(nf,1);
for i=1:nf
    ft_c=im2double(multi_ft{i});
    f_use=imresize(ft_c,[nk,mk]);%尺寸归一化
    ft_feature{i}=fft2(f_use);
end

%iteration
time_t=zeros(100,1);
iter_error=zeros(100,1);

sl_map=zeros(nk,mk);

tic;
for i=1:100
    er=epsino(sl_map);
    hMat=hessian(sl_map);
    
    sl_map=sl_map-0.1*er./hMat;
    
    time_t(i)=toc;
    iter_error(i)=sum(sum(abs(er)));
end

%normalization
m_sl=max(max(sl_map));
if m_sl>1
    ratio=1/(1-exp(-m_sl));
    sl_map=ratio*(1-exp(-sl_map));
end
sl_map=imresize(sl_map,[size(multi_ft{1},1),size(multi_ft{1},2)]);

    function er=epsino(sl_map)
        %error function of estimation
        er=-(alphac-1);
        
        for j=1:nf
            cur_w=ft_params{j}.weight;
            cur_convk=ft_params{j}.convk;
            
            er=er+cur_w.*(sl_map-cur_convk.*ft_feature{j}).*sl_map;
        end
    end

    function hMat=hessian(sl_map)
        %error function of estimation
        hMat=zeros(nk,mk);
        
        for j=1:nf
            cur_w=ft_params{j}.weight;
            cur_convk=ft_params{j}.convk;
            
            hMat=hMat+cur_w.*(2*sl_map-cur_convk.*ft_feature{j});
        end
    end
end