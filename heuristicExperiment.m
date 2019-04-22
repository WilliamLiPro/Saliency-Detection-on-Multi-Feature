%% ����ʽͼ���ں�ʵ��
% ����Ƶ�򷽲��ں�

%% ��ȡͼ��
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

%% ���ò���
gn=100;gm=100;
rh=0.05;
gk=gaussianFilterFq(rh,gn,gm);%��ʾ�����Եĸ�˹�˲���

% �������
priorPara.deltar=50;
priorPara.alphac=0.012;
priorPara.gk=gk;

% �ںϲ���
x=0:99;
x(100:-1:51)=1:50;

ft_params=cell(3,1);

%CHS����
ft_params{1}.weight=0.35*ones(gn,gm);
wx=exp(-x.^2/4000);
ft_params{1}.convk=wx'*wx;

%RC����
ft_params{2}.weight=0.2*ones(gn,gm);
wx=exp(-x.^2/400);
ft_params{2}.convk=wx'*wx;

%DRFI����
ft_params{3}.weight=0.45*ones(gn,gm);
wx=exp(-x.^2/5000);
ft_params{3}.convk=wx'*wx;

%% �ں������Բ��������ͼ������ͼ
disp(['feature fusion: image number',num2str(im_n)]);
    
test_t=zeros(im_n,1);
for i=1:im_n
    if mod(i,10)==0
        disp(['current progress:',num2str(i),'/',num2str(im_n)]);
    end
    
    % ��ȡ������������ͼ
    for j=1:3
        multi_ft{j}=imread(fullfile(feature_path{j},im_name{j}{i}));
    end
    
    % �����ںϽ��
    tic;
    salient_mp=multiFeatureSlDec( multi_ft, ft_params, priorPara );
    test_t(i)=toc;
    
    % ����ͼ��
    imwrite(salient_mp,fullfile(save_path,im_name{3}{i}));
end

report.testTimeTotal=sum(test_t);
report.testTimePerPic=mean(test_t);
report.testTimeStd=std(test_t);

%% ����precision-recall
disp(['calculate precision-recall']);

compared_path=cell(6,1);
compared_path{1}='result_SR\';
compared_path{2}='result_IG\';
compared_path{3}='result_HS\';
compared_path{4}='result_CHS\';
compared_path{5}='result_RC\';
compared_path{6}='result_DRFI\';

precision=zeros(100,1);
recall=zeros(100,1);
levels=[1:100]*2.56;    %��ֵ�仯

%�Ա��㷨
cmp_path='cmp_curve.mat';
if exist(cmp_path,'file')
    load(cmp_path,'-mat');
else
    cmp_curve=cell(6,1);
    for i=1:6
        disp(compared_path{i});
        cmp_curve{i}=PrecisionRecall(compared_path{i},gt_path);
    end
end

%�ںϽ��
disp(save_path);
re_curve_sup=PrecisionRecall(save_path,gt_path);

%%  ��ͼ
figure;
hold off;
plot(re_curve_sup.recall,re_curve_sup.precision,'color',[0.6,0,1]);
hold on;
for i=1:6
    colr=[max(i/4-0.5,0),max(1-abs(i-3.5)/4,0),max(1.1-i/4,0)];
    plot(cmp_curve{i}.recall,cmp_curve{i}.precision,'color',colr);
end
grid on;
xlabel('Recall');
ylabel('Precision');
axis([0,1,0,1]);

legend('h-MF','SR','IG','HS','CHS','RC','DRFI');

%%  ͳ�ƽ��
for i=1:6
    result_table(1,i)=cmp_curve{i}.averP;
end
result_table(1,7)=re_curve_sup.averP;

%�ٻ���
for i=1:6
    result_table(2,i)=cmp_curve{i}.averR;
end
result_table(2,7)=re_curve_sup.averR;

%F-measure
for i=1:7
    result_table(3,i)=2*result_table(1,i)*result_table(2,i)/(result_table(1,i)+result_table(2,i));
end