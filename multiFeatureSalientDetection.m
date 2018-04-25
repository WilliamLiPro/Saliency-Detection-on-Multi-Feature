%% �������ںϵ������Լ���㷨
function salient_mp=multiFeatureSalientDetection(multi_ft)
%�ں϶�������ͼ�������Լ��
%����Ƶ�򷽲�������յ������Լ����
%���룺
%@multi_ft   ����������ͼ����Ƶ�����Է��Ϊcell��������
%�����
%@salient_mp ���յ�����ͼ

% 1.Ƶ��任
nf=length(multi_ft);
[on,om,~]=size(multi_ft{1}.image); %ԭʼͼƬ��С
spectralFt=cell(nf,1);

for i=1:nf
    [in,im]=size(multi_ft{i}.var);
    cur_im=imresize(multi_ft{i}.image(:,:,1),[in,im]);
    spectralFt{i}.image=dct2(cur_im);
    spectralFt{i}.invar=1./multi_ft{i}.var;  %����ĵ���
end

% 2.��������ͼ
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
