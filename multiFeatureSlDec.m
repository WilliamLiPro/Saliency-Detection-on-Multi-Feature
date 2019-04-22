function [ sl_map ] = multiFeatureSlDec( multi_ft, ft_params, priorPara )
%multiFeatureSlDec 融合多特征的图像显著性检测
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

%fusion in frequency
dem=1*(deltar^(-2)+alphac*(1-gk.*gk));%分母
nm=zeros(nk,mk);%分子

for i=1:nf
    cur_w=ft_params{i}.weight;
    cur_convk=ft_params{i}.convk;
    
    dem=dem+cur_w;
    nm=nm+cur_w.*cur_convk.*ft_feature{i};
end

%result
ft_sl=nm./dem;
sl_map=ifft2(ft_sl);


%normalization
m_sl=max(max(sl_map));
if m_sl>1
    ratio=1/(1-exp(-m_sl));
    sl_map=ratio*(1-exp(-sl_map));
end
sl_map=imresize(sl_map,[size(multi_ft{1},1),size(multi_ft{1},2)]);
end

