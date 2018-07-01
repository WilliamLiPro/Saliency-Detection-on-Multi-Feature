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

precision=zeros(50,1);  %保存每幅图像的 precision-recall
recall=zeros(50,1);
levels=[0:0.02:0.98];    %阈值变化

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
    salient_mp=double(salient_mp)/double(max(salient_mp(:)));  %归一化
    
    % 计算precision-recall
    for k=1:50
        cur_sl=salient_mp>=levels(k);    %阈值分割后的前景
        right=cur_sl.*gt;   %正确的区域
        
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
        disp(['图片个数 ',num2str(i)]);
    end
end

% 2.融合平均 precision recall
curve.precision=precision/im_n;
curve.recall=recall/im_n;
curve.averP=sum(curve.precision.*(curve.recall-[curve.recall(2:50);0]));
curve.averR=curve.averP/max(curve.precision);
end