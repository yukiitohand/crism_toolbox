function [inImage] = gltEquiRectangular_getImageRegion(lats,lons,pgon_lonx,pgon_latx,varargin)
% [inImage] = gltEquiRectangular_getImageRegion(crism_glt_map,lats,lons,polygon_lonx,polygon_latx)
%   Get a mask for indicating pixels are inside the image or not.
%  INPUTS
%    lats   : L-length vector, lattitude in degree for each line of glt_map
%    lons   : S-length vector, longitude in degree for each sample of
%             glt_map
%    pgon_latx : latitude of the vertices of polygon of the border of the 
%                image, expressed in latitude
%    pgon_lonx : latitude of the vertices of polygon of the border of the 
%                image, expressed in longitude
%  OUTPUTS
%    inImage: [L x S] boolean
%  OPTIONAL Parameters
%    "GLT"  : [L x S x 2] geographic lookup table (the first page [:,:,1] 
%             is the corresponding x coordinate value and the second one
%             [:,:,2] is y coordinate.
%    "PROC_MODE": {'EXHAUSTIVE','OnlyEdgePixels'}
%       Processing mode: exhaustive - evaluate all the pixels using
%       interior.
%      

% [L,S] = size(glt_map);
% 
% inImage = false(L,S);

PROC_MODE = 'Exhaustive';
glt_map = [];
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'PROC_MODE'
                PROC_MODE = varargin{i+1};
            case 'GLT'
                glt_map = varargin{i+1};
            otherwise
                error('Unrecognized option: %s', varargin{i});
        end
    end
end

L = length(lats); S = length(lons);
inImage = false(L,S);
pgon = polyshape(pgon_lonx,pgon_latx);

switch upper(PROC_MODE)
    case 'EXHAUSTIVE'
        tic;
        xv = pgon.Vertices(:,1); yv = pgon.Vertices(:,2);
        % trim the outside of the rectangle minimally enclosing the polygon
        min_xv = min(xv); max_xv = max(xv);
        min_yv = min(yv); max_yv = max(yv);
        lonvldidx = and(lons>min_xv,lons<max_xv);
        latvldidx = and(lats>min_yv,lats<max_yv);
        lats_vld = lats(latvldidx); lons_vld = lons(lonvldidx);
        % only perform test inside the rectangle
        Svld = length(lons_vld); Lvld = length(lats_vld);
        inImage_vld = false(Lvld,Svld);
        for s=1:Svld
            % Looks like inpolygon is more accurate than isinterior
            inImage_vld(:,s) = inpolygon(repmat(lons_vld(s),Lvld,1),lats_vld,xv,yv);
        end
        inImage(latvldidx,lonvldidx) = inImage_vld;
        toc;
    case 'ONLYEDGEPIXELS'
        if isempty(glt_map)
            error('PROC_MODE %s requrires a valid parameter "GLT"',PROC_MODE);
        end
        error('PROC_MODE %s is future implementation.',PROC_MODE);
        
    otherwise
        error('Undefined PROC_MODE %s',PROC_MODE);
end

end

