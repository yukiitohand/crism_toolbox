function [vsid_slct] = crism_vscor_get_vsid_from_obsinfo(obs_id,bandset_id)
% [vsid_slct] = crism_vscor_get_vsid_from_obsinfo(obs_id,bandset_id)
%  Get the observation ID of the ADR VS image pre-selected for the given
%  obs_id and for the bandset_id (McGuire or Pelky)
%  Information is loaded from
%   CAT_ENVI/aux_files/obs_info/crism_obs_info.txt
% INPUTS
%  obs_id: char, observation ID
%  bandset_id: {'mcg',0,'pel',1}
%   'mcg',0 : McGuire (2007/1980)
%   'pel',1 : Pelky   (2011/1899)
% OUTPUTS
%  vsid_slct : char, observation ID for the selected ADR VS data

[cataux_obsinfo] = crism_get_cataux_obsinfo(obs_id);
if ~isempty(cataux_obsinfo)
    switch bandset_id
        case {'mcg',0}
            vsid_slct = cataux_obsinfo.vsid_mcg;
        case {'pel',1}
            vsid_slct = cataux_obsinfo.vsid_pel;
        otherwise
            if isnumeric(bandset_id), bandset_id = num2str(bandset_id); end
            error('Undefined bandset_id %s',bandset_id);
    end
else
    vsid_slct = '';
end


end

