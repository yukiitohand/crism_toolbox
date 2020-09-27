function [colsw] = crism_get_columns_sweetspot_wavelength(sensor_id,wv_bin_id)
% [colsw] = crism_get_columns_sweetspot_wavelength(sensor_id,wv_bin_id)
%  GET columns for calculating sweetspot wavelength.
%  INPUTS
%   sensor_id: 'L' or 'S'
%   wv_bin_id: binning id {0,1,2,3}
%  OUTPUTS
%   colsw: list of columns for sweetspot wavelength


if ~isnumeric(wv_bin_id)
    wv_bin_id = num2str(wv_bin_id);
end

switch upper(sensor_id)
    case 'L'
        switch wv_bin_id
            case 0
                colsw = 271:370;
            case 1
                colsw = 136:185;
            case 2
                colsw = 55:74; % 
            case 3
                colsw = 28:37;
            otherwise
                error('Undefined binning_id: %d',wv_bin_id);
        end
    case 'S'
        error('Not implemented yet');
    otherwise
        error('Undefined sensor_id %s',sensor_id);
end
        


end