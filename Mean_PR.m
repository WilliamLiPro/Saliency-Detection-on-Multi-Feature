function curve=Mean_PR(curve)
% 计算PR曲线的MAP,MAR
%输入：
%@curve         precision-recall曲线
%输出：
%@curve         MAP,MAR

n=length(curve.precision);
curve.averP=sum((curve.precision+[curve.precision(2:n);curve.precision(n)]).*(curve.recall-[curve.recall(2:n);0]))/2;
curve.averR=curve.averP/max(curve.precision);
end