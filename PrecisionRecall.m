function curve=PrecisionRecall(salient_path,gt_path)
% 计算显著性检测的Precision-recall曲线
%输入：
%@salient_path  计算得到的显著图路径
%@gt_path       ground truth路径
%输出
%@curve         precision-recall曲线

salient_name=imagePathRead(salient_path);
gt_name=imagePathRead(gt_path);
im_n=length(salient_name);

precision=zeros(im_n,100);  %保存每幅图像的 precision-recall
recall=zeros(im_n,100);
levels=[1:100]*2.56;    %阈值变化

% 1.计算每幅图像的 precision recall
for i=1:im_n
    % 读取ground truth
    gt=imread(fullfile(gt_path,gt_name{i}));
    gt=gt(:,:,1);
    gt=gt>0;    %二值化
    gt_cover=sum(gt(:));    %gt面积
    
    % 读取salient map
    salient_mp=imread(fullfile(salient_path,salient_name{i}));
    salient_mp=salient_mp(:,:,1);
    
    % 计算precision-recall
    for k=1:100
        cur_sl=salient_mp>levels(k);    %阈值分割后的前景
        right=cur_sl.*gt;   %正确的区域
        right_cover=sum(right(:));
        precision(i,k)=right_cover/sum(cur_sl(:));
        cur_recall=right_cover/gt_cover;
        recall(i,k)=cur_recall;
        
        if cur_recall==0    %召回率等于0，阈值过高，无意义
            break;
        end
    end
    
    if mod(i,10)==0
        disp(['图片个数 ',num2str(i)]);
    end
end

% 2.融合平均 precision recall
curve.precision=zeros(20,1);
precision_num=zeros(20,1);
curve.recall=[0.05:0.05:1];

for i=1:im_n
    for k=1:100
        re=ceil(recall(i,k)*20);   %召回率对应的坐标
        if re==0
            continue;
        end
        curve.precision(re)=curve.precision(re)+precision(i,k);
        precision_num(re)=precision_num(re)+1;
    end
end
curve.precision=curve.precision./precision_num;
end