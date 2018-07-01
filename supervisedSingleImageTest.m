%% ��һͼ��������ں������Լ�����
% ����Ƶ�򷽲��ں�
% ����Ϊ�мලѧϰ

%% ��ȡͼ��
im_name='0_11_11313.jpg';gt_name='0_11_11313.bmp';
im_path=cell(6,1);
im_path{1}='saliencymaps\AC\';
im_path{2}='saliencymaps\GB\';
im_path{3}='saliencymaps\IG\';
im_path{4}='saliencymaps\IT\';
im_path{5}='saliencymaps\MZ\';
im_path{6}='saliencymaps\SR\';
gt_path='binarymasks';

multi_ft=cell(6,1);
for i=1:6
    multi_ft{i}.image=imread(fullfile(im_path{i},im_name));
end

%% ������ֵ
[n,m,~]=size(imread(fullfile(im_path{1},im_name)));
x=[1:m];
y=[1:n]';
vars=cell(6,1);
%AC����
kernel_y=0.6-0.8*exp(-y/40)+0.4*exp(-y/10);
kernel_x=0.6-0.8*exp(-x/40)+0.4*exp(-x/10);
vars{1}=kernel_y*kernel_x;
%GB����
kernel_y=1.1-exp(-[y-25].^2/(2*30^2));
kernel_x=1.1-exp(-[x-25].^2/(2*30^2));
vars{2}=kernel_y*kernel_x;
%IG����
kernel_y=0.5-0.5*exp(-y/80);
kernel_x=0.5-0.5*exp(-x/80);
vars{3}=kernel_y*kernel_x;
%IT����
kernel_y=1.5-1.3*exp(-[y-30].^2/(2*10^2));
kernel_x=1.5-1.3*exp(-[x-30].^2/(2*10^2));
vars{4}=kernel_y*kernel_x;
%MZ����
kernel_y=1.15-exp(-[y-50].^2/(2*20^2));
kernel_x=1.15-exp(-[x-50].^2/(2*20^2));
vars{5}=kernel_y*kernel_x;
%SR����
kernel_y=1.2*exp(-y/40)+0.05;
kernel_x=1.2*exp(-x/40)+0.05;
vars{6}=kernel_y*kernel_x;

%% ����ѧϰ
vars=paraTrain(im_path,gt_path,vars);
%%
for i=1:6
    multi_ft{i}.var=vars{i};
end

%% �ں�������
salient_mp=multiFeatureSalientDetection(multi_ft);
figure(1);imshow(salient_mp/256);
figure(2);imshow(salient_mp/256>0.4);

%% ����precision-recall
% ��ȡground truth
gt=imread(fullfile(gt_path,gt_name));
gt=gt(:,:,1);
gt=gt>0;    %��ֵ��
gt_cover=sum(gt(:));    %gt���

% ��ȡͼ��
img=cell(7,1);
for i=1:6
    img{i}=multi_ft{i}.image(:,:,1);
end
img{7}=salient_mp;

% ����precision-recall
precision=zeros(7,100);
recall=zeros(7,100);
levels=[1:100]*2.56;    %��ֵ�仯
for i=1:7
    for k=1:100
        cur_sl=img{i}>levels(k);    %��ֵ�ָ���ǰ��
        right=cur_sl.*gt;   %��ȷ������
        right_cover=sum(right(:));
        precision(i,k)=right_cover/sum(cur_sl(:));
        recall(i,k)=right_cover/gt_cover;
    end
end

%%  ��ͼ
figure(3);
hold off;
for i=1:6
    if i==2
        hold on;
    end
    colr=[max(i/4-0.5,0),max(1-abs(i-3.5)/4,0),max(1.1-i/4,0)];
    plot(recall(i,:),precision(i,:),'color',colr);
end

plot(recall(7,:),precision(7,:),'k');