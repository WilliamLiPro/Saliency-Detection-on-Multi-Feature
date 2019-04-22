%% Test of saliency detection from dataset
% methods include: SR, IG

%%  load the dataset
im_path='images\';
gt_path='ground_truth_mask\';
% save_path='result_SR\'; 
save_path='result_IG\'; 

im_name=imagePathRead(im_path);
gt_name=imagePathRead(gt_path);
im_n=length(im_name);

%%  test
disp(['total number:',num2str(im_n)]);
for i=1:im_n
    if mod(i,10)==0
        disp(['current progress:',num2str(i)]);
    end
    
    % read image
    im_in=imread(fullfile(im_path,im_name{i}));
    
    % saliency detection
%     [ sl_map ] = spectralResidual( im_in );
    [ sl_map ] = frequencyTuned( im_in );
    
    % ±£´æÍ¼Ïñ
    imwrite(sl_map,fullfile(save_path,im_name{i}));
%     figure(9);imshow(sl_map);
end

disp(['finish, total number:',num2str(im_n)]);