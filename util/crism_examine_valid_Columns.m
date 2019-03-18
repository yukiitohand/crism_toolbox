function [valid_samples] = crism_examine_valid_Columns(RAdata)
% [valid_lines,valid_samples] = crism_examine_valid_Columns(RAdata)
% examine valid samples from Detector mask
% Input parameters
%    RAdata: RA crism data
% Output parameters
%    valid_columns: boolean, ith element is true if the columns is scene
%                   pixel.

% examine valid columns from the detector mask
if isempty(RAdata.basenamesCDR), RAdata.load_basenamesCDR(); end
if ~isfield(RAdata.cdr,'DM'), RAdata.readCDR('DM'); end
DMdata = RAdata.cdr.DM;
DMdata.readimgi();
dm = squeeze(DMdata.img);
switch RAdata.prop.sensor_id
    case 'L'
        valid_samples = (dm(:,300)==1);
    case 'S'
        valid_samples = (dm(:,50)==1);
end
% vs_idx = find(valid_samples);

end