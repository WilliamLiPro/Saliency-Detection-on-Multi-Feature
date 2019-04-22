function [ sl_map ] = spectralResidual( im_in )
%spectralResidual Æ×²Ğ²î·¨ÏÔÖøĞÔ¼ì²â
%   ¶àÍ¨µÀÆ×²Ğ²îÏÔÖøĞÔ¼ì²â
%@im_in     ÊäÈëÍ¼Ïñ
%@sl_map    ÏÔÖøÍ¼

[n_i,m_i,~]=size(im_in);
im_in=imresize(im_in,0.2);
[n,m,c]=size(im_in);

%fft
ft_im=zeros(n,m,c);
for i=1:c
    ft_im(:,:,i)=fft2(im_in(:,:,i));
end

%feature in frequency
Af=abs(ft_im);
Lf=log(Af);
Lf=fftshift(Lf);

h=fspecial('average',[3,1]);
Rf=imfilter(Lf,h,'replicate');
Rf=imfilter(Rf,h','replicate');

Rf=exp(Lf-Rf).*(ft_im./Af);
Rf=fftshift(Rf);

%ifft
feat=zeros(n,m,c);
for i=1:c
    feat(:,:,i)=ifft2(Rf(:,:,i));
end

sl_map=sum(feat.*conj(feat),3);

%gaussian filtering
gk=fspecial('gaussian',[7,1],1);
sl_map=imfilter(sl_map,gk);
sl_map=imfilter(sl_map,gk');
sl_map=sl_map/max(max(sl_map));

sl_map=imresize(sl_map,[n_i,m_i]);
end