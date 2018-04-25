%% 多特征融合的显著性检测算法
function salient_mp=multiFeatureSalientDetection(multi_ft)
%融合多特征的图像显著性检测
%根据频域方差计算最终的显著性检测结果
%输入：
%@multi_ft   多特征显著图及其频域的相对方差，为cell类型数据
%输出：
%@salient_mp 最终的显著图

% 1.频域变换
nf=length(multi_ft);
[on,om,~]=size(multi_ft{1}.image); %原始图片大小
spectralFt=cell(nf,1);

for i=1:nf
    [in,im]=size(multi_ft{i}.var);
    cur_im=imresize(multi_ft{i}.image(:,:,1),[in,im]);
    spectralFt{i}.image=dct2(cur_im);
    spectralFt{i}.invar=1./multi_ft{i}.var;  %方差的倒数
end

% 2.计算显著图
salient_mp=zeros(size(spectralFt{i}.image));
pm=salient_mp;

for i=1:nf
    salient_mp=salient_mp+spectralFt{i}.invar.*spectralFt{i}.image;
    pm=pm+spectralFt{i}.invar;
end

salient_mp=salient_mp./pm;
salient_mp=idct2(salient_mp);
salient_mp=abs(salient_mp);
salient_mp=imresize(salient_mp,[on,om]);
end
