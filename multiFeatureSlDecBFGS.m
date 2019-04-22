function [ sl_map ,iter_error, time_t] = multiFeatureSlDecBFGS( multi_ft, ft_params, priorPara )
%multiFeatureSlDec �ں϶�������ͼ�������Լ�⣬ʹ��BFGS�����
%   �˴���ʾ��ϸ˵��
%���룺
%@multi_ft      ����������ͼ��Ϊcell��������
%@ft_params     �������ںϲ�����Ϊcell��������
%@priorPara     �������
%�����
%@sl_map        ���յ�����ͼ

%parameters
deltar=priorPara.deltar;
alphac=priorPara.alphac;
gk=priorPara.gk;

%fft
nf=length(multi_ft);%��������
[nk,mk]=size(gk);

ft_feature=cell(nf,1);
for i=1:nf
    ft_c=im2double(multi_ft{i});
    f_use=imresize(ft_c,[nk,mk]);%�ߴ��һ��
    ft_feature{i}=fft2(f_use);
end

%iteration
time_t=zeros(100,1);
iter_error=zeros(100,1);

sl_map0=zeros(nk,mk);
er0=epsino(sl_map0);
hMat=ones(nk,mk);

tic;
for i=1:100
    sl_map=sl_map0-0.1*er0.*hMat;
    er=epsino(sl_map);
    
    ds=sl_map-sl_map0;
    dy=er-er0;
    
    hMat=hessian(ds,dy);
    
    sl_map0=sl_map;
    er0=er;
    
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

    function hMat=hessian(ds,dy)
        %error function of estimation
        hMat=ds./dy;
    end
end