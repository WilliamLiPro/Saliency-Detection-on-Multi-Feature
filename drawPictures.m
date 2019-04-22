%%  draw pictures
%comparison of input feature map
%comparison of saliency maps obtained from 6 contrast algorithms and the MF algorithm
%%	comparison of input feature map
feature_path=cell(4,1);
feature_path{1}='result_HS\';
feature_path{2}='result_CHS\';
feature_path{3}='result_RC\';
feature_path{4}='result_DRFI\';
gt_path='ground_truth_mask\';
im_path='images\';

im_n=length(multi_ft{1});

%feature
ft_image=cell(4,1);
for i=1:4
    ft_image{i}=imagePathRead(feature_path{i});
end

%ground truth
gt_image=imagePathRead(gt_path);
im_image=imagePathRead(im_path);

%draw image
fig_id=17;
im_in=im2double(imread([im_path,im_image{fig_id}]));
gt_in=im2double(imread([gt_path,gt_image{fig_id}]));
ft_im=cell(4,1);
for i=1:4
    ft_im{i}=im2double(imread([feature_path{i},ft_image{i}{fig_id}]));
end

[n,m,c]=size(im_in);
im_out=zeros(2*n,3*m,c);
im_out(1:n,1:m,:)=im_in;
im_out(1:n,m+1:2*m,:)=ft_im{1}(:,:,ones(c,1));
im_out(1:n,2*m+1:3*m,:)=ft_im{2}(:,:,ones(c,1));
im_out(n+1:2*n,1:m,:)=ft_im{3}(:,:,ones(c,1));
im_out(n+1:2*n,m+1:2*m,:)=ft_im{4}(:,:,ones(c,1));
im_out(n+1:2*n,2*m+1:3*m,:)=gt_in(:,:,ones(c,1));
figure(101);imshow(im_out,'Border','tight');

%%  Comparison of saliency maps obtained from 6 contrast algorithms and the MF algorithm
%path
compared_path=cell(6,1);
compared_path{1}='result_SR\';
compared_path{2}='result_IG\';
compared_path{3}='result_HS\';
compared_path{4}='result_CHS\';
compared_path{5}='result_RC\';
compared_path{6}='result_DRFI\';

fm_path='our_result_MF\heuristic\';

cm_im=cell(6,1);
for i=1:6
    cm_im{i}=imagePathRead(compared_path{i});
end

fm_im=imagePathRead(fm_path);

%image
fig_id=[9,15,21,51,200,205];
l_im=length(fig_id);
m=100;n=75;
im_out=zeros(l_im*n,9*m,3);

for i=1:length(fig_id)
    im_in=im2double(imread([im_path,im_image{fig_id(i)}]));
    im_in=imresize(im_in,[n,m]);
    gt_in=im2double(imread([gt_path,gt_image{fig_id(i)}]));
    gt_in=imresize(gt_in,[n,m]);
    
    im_out((i-1)*n+1:i*n,1:m,:)=im_in;
    im_out((i-1)*n+1:i*n,8*m+1:9*m,:)=gt_in(:,:,ones(c,1));
    
    im_fm=im2double(imread([fm_path,fm_im{fig_id(i)}]));
    im_fm=imresize(im_fm,[n,m]);
    
    im_out((i-1)*n+1:i*n,7*m+1:8*m,:)=im_fm(:,:,ones(c,1));
    
    for j=1:6
        im_in=im2double(imread([compared_path{j},cm_im{j}{fig_id(i)}]));
        im_in=imresize(im_in,[n,m]);
        
        im_out((i-1)*n+1:i*n,j*m+1:(j+1)*m,:)=im_in(:,:,ones(c,1));
    end
end
figure(102);imshow(im_out,'Border','tight');