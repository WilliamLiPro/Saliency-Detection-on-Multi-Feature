function curve=PrecisionRecall(salient_path,gt_path)
% ���������Լ���Precision-recall����
%���룺
%@salient_path  ����õ�������ͼ·��
%@gt_path       ground truth·��
%���
%@curve         precision-recall����

salient_name=imagePathRead(salient_path);
gt_name=imagePathRead(gt_path);
im_n=length(salient_name);

precision=zeros(im_n,100);  %����ÿ��ͼ��� precision-recall
recall=zeros(im_n,100);
levels=[1:100]*2.56;    %��ֵ�仯

% 1.����ÿ��ͼ��� precision recall
for i=1:im_n
    % ��ȡground truth
    gt=imread(fullfile(gt_path,gt_name{i}));
    gt=gt(:,:,1);
    gt=gt>0;    %��ֵ��
    gt_cover=sum(gt(:));    %gt���
    
    % ��ȡsalient map
    salient_mp=imread(fullfile(salient_path,salient_name{i}));
    salient_mp=salient_mp(:,:,1);
    
    % ����precision-recall
    for k=1:100
        cur_sl=salient_mp>levels(k);    %��ֵ�ָ���ǰ��
        right=cur_sl.*gt;   %��ȷ������
        right_cover=sum(right(:));
        precision(i,k)=right_cover/sum(cur_sl(:));
        cur_recall=right_cover/gt_cover;
        recall(i,k)=cur_recall;
        
        if cur_recall==0    %�ٻ��ʵ���0����ֵ���ߣ�������
            break;
        end
    end
    
    if mod(i,10)==0
        disp(['ͼƬ���� ',num2str(i)]);
    end
end

% 2.�ں�ƽ�� precision recall
curve.precision=zeros(20,1);
precision_num=zeros(20,1);
curve.recall=[0.05:0.05:1];

for i=1:im_n
    for k=1:100
        re=ceil(recall(i,k)*20);   %�ٻ��ʶ�Ӧ������
        if re==0
            continue;
        end
        curve.precision(re)=curve.precision(re)+precision(i,k);
        precision_num(re)=precision_num(re)+1;
    end
end
curve.precision=curve.precision./precision_num;
end