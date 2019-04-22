function curve=Mean_PR(curve)
% ����PR���ߵ�MAP,MAR
%���룺
%@curve         precision-recall����
%�����
%@curve         MAP,MAR

n=length(curve.precision);
curve.averP=sum((curve.precision+[curve.precision(2:n);curve.precision(n)]).*(curve.recall-[curve.recall(2:n);0]))/2;
curve.averR=curve.averP/max(curve.precision);
end