function [plgn_lonx,plgn_latx] = crism_ddr_get_surrounding_polygon(...
    crismDDRdata,valid_lines,valid_samples,varargin)
% [polygon_lon,polygon_lat] = crism_ddr_get_surrounding_polygon(...
%     crismDDRdata,valid_lines,valid_samples,varargin)
% INPUTS
%   crismDDRdata: CRISM DDR data
%   valid_lines : vector, indicates valid lines to be considered.
%   valid_columns: vector, indicates valid columns to be considered.
% OUTPUTS
%   polygon_lon : a row vector, longitude of the polygon vertexes.
%   polygon_lat : a row vector, latitude of the polygon vertexes.
% OPTIONAL Parameters
%   'MARGIN' : scalar, coefficients for how far the image border is drawn
%   from the edge center pixels with resepect to the distance between the
%   edge pixels and the next edge pixels.
%   (default) 0.5


mrgn = 0.5;
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'MARGIN'
                mrgn = varargin{i+1};
            otherwise
                error('Unrecognized option: %s', varargin{i});
        end
    end
end

if isempty(crismDDRdata.ddr), crismDDRdata.readimg(); end

latMap = crismDDRdata.ddr.Latitude.img;
lonMap = crismDDRdata.ddr.Longitude.img;

% Only takes the valid lines and columns
latMap = latMap(valid_lines,valid_samples);
lonMap = lonMap(valid_lines,valid_samples);

% make sure the first line is the northest and last line is the southest.
% for each column evaluate the value of latMap(1,:)-latMap(*,:) is looking
% at the same direction as latMap(1,:)-latMap(end,:), assuming that
% latMap(1,:)-latMap(end,:) is always alighed with the general direction of
% the image. Same test is performed for the last line, too.
isEdge_lat1 = all((latMap(1,:) - latMap(2:end,:)) .* (latMap(1,:) - latMap(end,:))>0,1);
isEdge_latEnd = all((latMap(end,:) - latMap(1:end-1,:)) .* (latMap(end,:) - latMap(1:end-1,:))>0,1);

if any(~isEdge_lat1)
    warning('The first line is not necessarily at the edge. This function may not be working.');
end

if any(~isEdge_latEnd)
    warning('The last line is not necessarily at the edge. This function may not be working.');
end



% function to divide externally dividing point
% A point that externally divides x and y with m:(1+m) 
%               x                     y
%  |____________|_____________________|
%   \          / \                   /
%    `-- m ---'   `-----  1  -------'
func_extdiv = @(x,y,m) (1+m).*x - m.*y;

% borders are obtained by externally dividing point.
uppr_brdr_lat = func_extdiv(latMap(1,:),latMap(2,:),mrgn);
uppr_brdr_lon = func_extdiv(lonMap(1,:),lonMap(2,:),mrgn);
% uppr_brdr_lat = (3*latMap(1,:) - latMap(2,:)) / 2;
% uppr_brdr_lon = (3*lonMap(1,:) - lonMap(2,:)) / 2;

lft_brdr_lat = func_extdiv(latMap(:,1),latMap(:,2),mrgn);
lft_brdr_lon = func_extdiv(lonMap(:,1),lonMap(:,2),mrgn);
% lft_brdr_lat = (3*latMap(:,1) - latMap(:,2)) / 2;
% lft_brdr_lon = (3*lonMap(:,1) - lonMap(:,2)) / 2;

btm_brdr_lat = func_extdiv(latMap(end,:),latMap(end-1,:),mrgn);
btm_brdr_lon = func_extdiv(lonMap(end,:),lonMap(end-1,:),mrgn);
% btm_brdr_lat = (3*latMap(end,:) - latMap(end-1,:)) / 2;
% btm_brdr_lon = (3*lonMap(end,:) - lonMap(end-1,:)) / 2;

rght_brdr_lat = func_extdiv(latMap(:,end),latMap(:,end-1),mrgn);
rght_brdr_lon = func_extdiv(lonMap(:,end),lonMap(:,end-1),mrgn);
% rght_brdr_lat = (3*latMap(:,end) - latMap(:,end-1)) / 2;
% rght_brdr_lon = (3*lonMap(:,end) - lonMap(:,end-1)) / 2;




%% Get four vertex points
% first get upper left corner
[a1,c1] = get_2dline_param(uppr_brdr_lon(1),uppr_brdr_lat(1),uppr_brdr_lon(2),uppr_brdr_lat(2));
[a2,c2] = get_2dline_param(lft_brdr_lon(1),lft_brdr_lat(1),lft_brdr_lon(2),lft_brdr_lat(2));
[ul_lon,ul_lat] = get_intersect_line2d(a1,c1,a2,c2);

% lower left
[a1,c1] = get_2dline_param(lft_brdr_lon(end),lft_brdr_lat(end),lft_brdr_lon(end-1),lft_brdr_lat(end-1));
[a2,c2] = get_2dline_param(btm_brdr_lon(1),btm_brdr_lat(1),btm_brdr_lon(2),btm_brdr_lat(2));
[ll_lon,ll_lat] = get_intersect_line2d(a1,c1,a2,c2);

% lower right
[a1,c1] = get_2dline_param(rght_brdr_lon(end),rght_brdr_lat(end),rght_brdr_lon(end-1),rght_brdr_lat(end-1));
[a2,c2] = get_2dline_param(btm_brdr_lon(end),btm_brdr_lat(end),btm_brdr_lon(end-1),btm_brdr_lat(end-1));
[lr_lon,lr_lat] = get_intersect_line2d(a1,c1,a2,c2);

% upper right
[a1,c1] = get_2dline_param(uppr_brdr_lon(end),uppr_brdr_lat(end),uppr_brdr_lon(end-1),uppr_brdr_lat(end-1));
[a2,c2] = get_2dline_param(rght_brdr_lon(1),rght_brdr_lat(1),rght_brdr_lon(2),rght_brdr_lat(2));
[ur_lon,ur_lat] = get_intersect_line2d(a1,c1,a2,c2);

%% Connect all the surrounding vertexes
plgn_lonx = [ul_lon lft_brdr_lon' ll_lon btm_brdr_lon lr_lon flip(rght_brdr_lon,1)' ur_lon flip(uppr_brdr_lon,2)];
plgn_latx = [ul_lat lft_brdr_lat' ll_lat btm_brdr_lat lr_lat flip(rght_brdr_lat,1)' ur_lat flip(uppr_brdr_lat,2)];




end