function Ft=gaussianFilterFq(rh,n,m)
%obtain the gaussian filter in frequency domain

% coordinate
[xx,yy,cx,cy]=axisFrequency(n,m);

% standard deviation
if length(rh)==2
    dtx=rh(1)^2;
    dty=rh(2)^2;
else
    dtx=rh(1)^2;
    dty=dtx;
end

% gaussian filter
kxx=exp(-xx.^2*dtx/2);
kyy=exp(-yy.^2*dty/2);

% kx
kxh=2*kxx(1:2:2*cx+1);
kxh(1:cx)=kxh(1:cx)+kxx(2:2:2*cx);
kxh(2:cx+1)=kxh(2:cx+1)+kxx(2:2:2*cx);
kxh(1)=kxh(1)+kxx(2);
kxh(cx+1)=kxh(cx+1)+kxx(2*cx);
kxh=0.25*kxh;

kx=zeros(1,m);
kx(1:cx+1)=kxh;
kx(m:-1:m-cx+1)=kxh(2:cx+1);

% ky
kyh=2*kyy(1:2:2*cy+1);
kyh(1:cy)=kyh(1:cy)+kyy(2:2:2*cy);
kyh(2:cy+1)=kyh(2:cy+1)+kyy(2:2:2*cy);
kyh(1)=kyh(1)+kyy(2);
kyh(cy+1)=kyh(cy+1)+kyy(2*cy);
kyh=0.25*kyh;

ky=zeros(1,n);
ky(1:cy+1)=kyh;
ky(n:-1:n-cy+1)=kyh(2:cy+1);

% filter
Ft=ky'*kx;
end

function [xx,yy,cx,cy]=axisFrequency(n,m)
%create axis map in frequency
cx=floor(m/2);

xx=0:0.5:m-1;
xx(2*m+1:-1:2*(m-cx)+3)=1:0.5:cx;

cy=floor(n/2);

yy=0:0.5:n-1;
yy(2*n+1:-1:2*(n-cy)+3)=1:0.5:cy;
end