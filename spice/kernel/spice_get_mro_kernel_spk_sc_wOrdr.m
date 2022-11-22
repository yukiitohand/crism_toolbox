function [fname_spk_sc_out,dirpath] = spice_get_mro_kernel_spk_sc_wOrdr(...
    strt_datetime, end_datetime,dirpath_opt,varargin)
% [fname_spk_sc_out,dirpath] = spice_get_mro_kernel_spk_sc_wOrdr(...
%     strt_datetime, end_datetime,dirpath_opt,varargin)
%  Get corresponding spk sc kernel in the NAIF archive repository with
%  given start datetime and end datetime with given order.
% INPUTS
%  strt_datetime: datetime object, date&time at the start
%  end_datetime : datetime object, date&time at the end
%  dirpath_opt: {'MRO','PDS'}
% OUTPUTS
%  fname_spk_sc_out: char/string selected filename of its cell array
%  dirpath       : directory path to the selected filename
% OPTIONAL Parameters
%  "KERNEL_ORDER" : ordr of the suffix of kernels. first one will be loaded
%    first.
%    (default) {'','ssd_mro95a','ssd_mro110c'}
%  "EXT"  : char/string, extension
%    files with this extension is returned. If empty, filename with no
%    extension is returned. If 'all', filename with any extension is
%    returned.
%    (default) 'bsp'
%  "SUFFIX" : char/string, suffix should be placed like below:
%          mro_sc_psp_080701_080707[SUFFIX].bc
%    (default) ''
%  ## Some downloading options 
%   Following options are for how to deal with downloading from the naif
%   archive server.
%  "DOWNLOAD", "DWLD" : {-1, 0, 1, 2}
%     if dwld>0, then this is passed to 'pds_downloader'
%     -1: show the list of file that match the input pattern.
%     (default) 0
%  "OVERWRITE": boolean, whether or not to overwrite the local files with
%    the files at the remote archive serve.
%
% Copyright (C) 2021 Yuki Itoh <yukiitohand@gmail.com>
%
krnl_ordr = {'','_ssd_mro95a','_ssd_mro110c'};
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    varargin_rmIdx = [];
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'KERNEL_ORDER'
                krnl_ordr = varargin{i+1};
                varargin_rmIdx = [varargin_rmIdx i i+1];
            case {'EXT','SUFFIX','DWLD','DOWNLOAD','OVERWRITE'}
            otherwise
                error('Unrecognized option: %s', varargin{i});   
        end
    end
    varargin_retIdx = setdiff(1:length(varargin),varargin_rmIdx);
    varargin = varargin(varargin_retIdx);
end
fname_spk_sc_out = [];
for i=1:length(krnl_ordr)
    suff = krnl_ordr{i};
    [fname_spk_sc_outi,dirpath] = spice_get_mro_kernel_spk_sc( ...
        strt_datetime, end_datetime,dirpath_opt,'suffix',suff,varargin{:});
    if isempty(fname_spk_sc_out)
        fname_spk_sc_out = fname_spk_sc_outi;
    else
        if ischar(fname_spk_sc_outi)
            fname_spk_sc_out = [fname_spk_sc_out {fname_spk_sc_outi}];
        elseif iscell(fname_spk_sc_outi)
            fname_spk_sc_out = [fname_spk_sc_out fname_spk_sc_outi];
        end
    end
end

end