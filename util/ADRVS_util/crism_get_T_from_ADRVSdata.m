function [ T ] = crism_get_T_from_ADRVSdata( adrvsdata_obj,varargin )
% [ T ] = crism_get_T_from_ADRVSdata( adrvsdata_obj,varargin )
%   get transmission spectrum frame from ADRVSdata
%   INPUT
%    adrvsdata_obj: CRISMdata obj, ADR VS data
%   OUTPUT
%    T : transmission spectrum frame [1xSxL](S: samples, L: bands)
%   Optional parameters
%    'band_inverse': whether or not to invert bands or not
%                    (default) true
%    'MODE': specify how to deal with artifact. {'subtraction', 'none'}
%                (default) 'subtraction'
%    'ARTIFACT_IDX': specify which data is used as artifact {2,3}. 2: new
%                    Patrick C. McGuire method and 3: old Pelky method.
%                    (default) 2

mode_artifact = 'subtraction';
is_band_inverse = true;
artifact_idx = 2;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'BAND_INVERSE'
                is_band_inverse = varargin{i+1};
            case 'MODE'
                mode_artifact = varargin{i+1};
            case 'ARTIFACT_IDX'
                artifact_idx = varargin{i+1};
            otherwise
                error('Unrecognized option: %s', varargin{i});
        end
    end
end

if is_band_inverse
    imgvs = adrvsdata_obj.readimgi();
else
    imgvs = adrvsdata_obj.readimg();
end

switch lower(mode_artifact)
    case 'subtraction'
        T = imgvs(1,:,:) - imgvs(artifact_idx,:,:);
    case 'none'
        T = imgvs(1,:,:);
    otherwise
        error('Undefined mode %s.',mode_artifact);
end

end