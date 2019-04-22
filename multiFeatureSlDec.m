function [ sl_map ] = multiFeatureSlDec( multi_ft, ft_params, priorPara )
%multiFeatureSlDec �ں϶�������ͼ�������Լ��
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

%fusion in frequency
dem=1*(deltar^(-2)+alphac*(1-gk.*gk));%��ĸ
nm=zeros(nk,mk);%����

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

