function [ sl_map ] = frequencyTuned( im_in )
%frequencyTuned ÆµÓòµ÷Ð³ÏÔÖøÐÔ¼ì²â
%   ¶àÍ¨µÀÆ×²Ð²îÏÔÖøÐÔ¼ì²â
%@im_in     ÊäÈëÍ¼Ïñ
%@sl_map    ÏÔÖøÍ¼

[n,m,c]=size(im_in);

%Lab space and average
im_use=im2double(im_in);
im_use=simpleRGB2Lab(im_use);
aver_im=mean(mean(im_use,1),2);

%features
gk=fspecial('gaussian',[5,1],2);
im_g=imfilter(im_use,gk);
im_g=imfilter(im_g,gk');

%saliency map
sl_map=zeros(n,m,c);
for i=1:c
    sl_map=im_g(:,:,i)-aver_im(i);
end
sl_map=sum(sl_map.^2,3);
sl_map=sqrt(sl_map);

sl_map=sl_map/max(max(sl_map));

[ns,ms]=size(sl_map);

if ns~=n||ms~=m
    sl_map=imresize(sl_map,[n,m]);
end

    function lab_im=simpleRGB2Lab(rgb_im)
        if c==1
            lab_im=rgb_im;
            return;
        end
        
        X=0.43*rgb_im(:,:,1)+0.37*rgb_im(:,:,2)+0.2*rgb_im(:,:,2);
        Y=0.2*rgb_im(:,:,1)+0.7*rgb_im(:,:,2)+0.1*rgb_im(:,:,2);
        Z=0.1*rgb_im(:,:,2)+0.9*rgb_im(:,:,2);
        
        X=XYZ2Lab(X);
        Y=XYZ2Lab(Y);
        Z=XYZ2Lab(Z);
        
        lab_im=zeros(n,m,c);
        lab_im(:,:,1)=1.16*Y-0.16;
        lab_im(:,:,2)=5*(X-Y);
        lab_im(:,:,3)=2*(Y-Z);
    end
    function lab=XYZ2Lab(xyz)
        big=xyz>0.0089;
        lab=xyz;
        lab(big)= sqrt(xyz(big));
        lab(~big)= xyz(~big).*xyz(~big)*7.787+0.1379;
    end
end
