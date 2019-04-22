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

precision=zeros(51,1);  %����ÿ��ͼ��� precision-recall
recall=zeros(51,1);
levels=[0:0.02:1];    %��ֵ�仯

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
    salient_mp=double(salient_mp)/double(max(salient_mp(:)));  %��һ��
    
    [ng,mg]=size(gt);
    [ns,ms]=size(salient_mp);
    if ng~=ns||mg~=ms
        salient_mp=imresize(salient_mp,[ng,mg]);
    end
    
    % ����precision-recall
    for k=1:51
        cur_sl=salient_mp>=levels(k);    %��ֵ�ָ���ǰ��
        right=cur_sl.*gt;   %��ȷ������
        
        sl_cover=sum(cur_sl(:));
        right_cover=sum(right(:));
        if sl_cover==0
            cur_precision=1;
        else
            cur_precision=right_cover/sl_cover;
        end
        
        cur_recall=right_cover/gt_cover;
        
        precision(k)=precision(k)+cur_precision;
        recall(k)=recall(k)+cur_recall;
    end
    
    if mod(i,10)==0
        disp(['ͼƬ���� ',num2str(i)]);
    end
end

% 2.�ں�ƽ�� precision recall
curve.precision=precision/im_n;
curve.recall=recall/im_n;

curve=Mean_PR(curve);
end