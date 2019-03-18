function [ YXRef ] = mapRef2Target(y,x,LatLonTar,LatLonRef)
% [ YXRef ] = mapRef2Target(s,l,ddrTar,imgRef,ddrRef)
%   For given LatittudeTar(l,s) and LongitudeTar(l,s), return four closest pixels
%   of the reference image
%   Inputs
%     x: scalar, sample,
%     y: scalar, line
%     LatLonTar: [lines, samples, 2], 
%                LatLonTar(:,:,1) is the latitude map of the target image
%                LatLonTar(:,:,2) is the longitude map of the target image
%     LatLonRef: [lines, samples, 2], 
%                LatLonRef(:,:,1) is the lattitude map of the reference image
%                LatLonRef(:,:,2) is the longitude map of the reference image  
%     YXRef: [4 x 2], the XY coordinate of four surrounding points.

[lat] = LatLonTar(y,x,1); [lon] = LatLonTar(y,x,2);
ymax = size(LatLonRef,1); xmax = size(LatLonRef,2);

distMat = (LatLonRef(:,:,1)-lat).^2 + (LatLonRef(:,:,2)-lon).^2;

[distmin,yxmin] = min2d(distMat);

% try four surrounding unit polygons.


ymin = yxmin(1); xmin = yxmin(2);
fin = 0;
if xmin>1 && ymin>1
    % lowerleft
    yv = [LatLonRef(ymin,xmin,1) LatLonRef(ymin-1,xmin,1),...
          LatLonRef(ymin-1,xmin-1,1),LatLonRef(ymin,xmin-1,1),...
          LatLonRef(ymin,xmin,1)];
    xv = [LatLonRef(ymin,xmin,2) LatLonRef(ymin-1,xmin,2),...
          LatLonRef(ymin-1,xmin-1,2),LatLonRef(ymin,xmin-1,2),...
          LatLonRef(ymin,xmin,2)];
    in = inpolygon(lon,lat,xv,yv);
    if in
        fin=1; YXRef = [ymin xmin; ymin-1 xmin; ymin-1 xmin-1; ymin xmin-1];
    end
end

if ~fin && (xmin>1 && ymin<ymax)
    % upperleft
    yv = [LatLonRef(ymin,xmin,1) LatLonRef(ymin,xmin-1,1),...
          LatLonRef(ymin+1,xmin-1,1),LatLonRef(ymin+1,xmin,1),...
          LatLonRef(ymin,xmin,1)];
    xv = [LatLonRef(ymin,xmin,2) LatLonRef(ymin,xmin-1,2),...
          LatLonRef(ymin+1,xmin-1,2),LatLonRef(ymin+1,xmin,2),...
          LatLonRef(ymin,xmin,2)];
    in = inpolygon(lon,lat,xv,yv);
    if in
        fin=1; YXRef = [ymin xmin; ymin xmin-1; ymin+1 xmin-1; ymin+1 xmin];
    end
end

if ~fin && (xmin<xmax && ymin<ymax)
    % upperright
    yv = [LatLonRef(ymin,xmin,1) LatLonRef(ymin+1,xmin,1),...
          LatLonRef(ymin+1,xmin+1,1),LatLonRef(ymin,xmin+1,1),...
          LatLonRef(ymin,xmin,1)];
    xv = [LatLonRef(ymin,xmin,2) LatLonRef(ymin+1,xmin,2),...
          LatLonRef(ymin+1,xmin+1,2),LatLonRef(ymin,xmin+1,2),...
          LatLonRef(ymin,xmin,2)];
    in = inpolygon(lon,lat,xv,yv);
    if in
        fin=1; YXRef = [ymin xmin; ymin+1 xmin; ymin+1 xmin+1; ymin xmin+1];
    end
end

if ~fin && (xmin<xmax && ymin>1)
    % lowerright
    yv = [LatLonRef(ymin,xmin,1) LatLonRef(ymin,xmin+1,1),...
          LatLonRef(ymin-1,xmin+1,1),LatLonRef(ymin-1,xmin,1),...
          LatLonRef(ymin,xmin,1)];
    xv = [LatLonRef(ymin,xmin,2) LatLonRef(ymin,xmin+1,2),...
          LatLonRef(ymin-1,xmin+1,2),LatLonRef(ymin-1,xmin,2),...
          LatLonRef(ymin,xmin,2)];
    in = inpolygon(lon,lat,xv,yv);
    if in
        fin=1; YXRef = [ymin xmin; ymin xmin+1; ymin-1 xmin+1; ymin-1 xmin];
    end
end

if ~fin
    YXRef = [];
end
    
end

