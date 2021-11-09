function [suffix] = crism_vscor_get_suffix(varargin)
% [suffix] = crism_vscor_get_suffix(varargin)
%  Get suffix of vscor processing
%  OUTPUTS
%   suffix: char
%  Optional Parameters
%   {'ARTIFACT_PRE'} : {false, 'mcg', 'pel'}
%     This option is created by Yuki.
%     whether or not to apply artifact beforehand. Recommend this to use
%     without artifact correction since the component is applied in a
%     different way.
%     false : do not apply
%     'mcg' : subtract mcg artifact from the transmission before scale_atmt
%     'pel' : subtract mcg artifact from the transmission before scale_atmt
%     (default) false
%   {'PHOTOMETRIC_CORRECTION','PHC'} : boolean
%      (default) false
%   'PHC_ANGLE_TOPO' : char, {'AREOID','MOLA'}
%      the topography on which emission angles are defined
%      (default) 'AREOID'
%   {'ATMT_SRC_OPT','ATMT_SRC'} : char, 
%      {'trial','user'} potential future support:{'auto',tbench','default'}
%      (default) 'trial'
%   'BANDSET_ID' : str, {'pel','mcg',0,1}
%       'mcg',0 : McGuire (2007/1980)
%       'pel',1 : Pelky   (2011/1899)
%      (default) 'mcg'
%   {'ARTIFACT_CORRECTION','ART','ENABLE_ARTIFACT'}: boolean
%      (default) true
%   'ATMT_VSID': char, only valid with 'ATMT_SRC_OPT'='user'
%      (default) ''
%   {'DDRDATA','DDR'} : CRISMDDRdata class obj associated with 
%      crism_data_obj, only valid with 'PHOTOMETRIC_CORRECTION' = true
%      (default) []
artifact_pre = false;
phot       = false;   % boolean
opt_incang = 'AREOID';% {'AREOID','MOLA'}
atmt_src   = 'trial'; % {'trial','user','auto',tbench','default'}
bandset_id = 'mcg';   % {'pel','mcg',0,1}
enable_artifact = true; % boolean
atmt_vsid  = '';
DEdata    = [];

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'ARTIFACT_PRE'
                artifact_pre = varargin{i+1};
            case {'PHOTOMETRIC_CORRECTION','PHC'}
                phot = varargin{i+1};
            case {'PHC_ANGLE_TOPO'}
                opt_incang = varargin{i+1};
            case {'ATMT_SRC_OPT','ATMT_SRC'}
                atmt_src = varargin{i+1};
            case 'BANDSET_ID'
                bandset_id = varargin{i+1};
            case {'ARTIFACT_CORRECTION','ART','ENABLE_ARTIFACT'}
                enable_artifact = varargin{i+1};
            case 'ATMT_VSID'
                atmt_vsid = varargin{i+1};
            case {'DDRDATA','DDR','DEDATA'}
                DEdata = varargin{i+1};
            otherwise
                error('Unrecognized option: %s',varargin{i});
        end
    end
end
if artifact_pre
    suffix = sprintf('corr_phot%d_%s_%s_a%d_ap%s',phot,atmt_src, ...
        bandset_id,enable_artifact,artifact_pre);
else
    suffix = sprintf('corr_phot%d_%s_%s_a%d',phot,atmt_src, ...
        bandset_id,enable_artifact);
end

end