function [A] = convCRISMspclib_v3(CRISMspclib,lib_list,wac,sbc,varargin)
%  [A] = convCRISMspclib_v3(spec_lib,lib_list,wac,sbc,varargin)
%     convolute spec_lib spectra into the specified CRISM wavelength
%     samples
%   Input Parameters
%       CRISMspclib: struct, CRISM spectral library
%       lib_list: str or cell, list of library names to be convolved
%             'all', or select from the list below:
%                'RT_resamp', 'all_sulfates_resamp','meteor','carbonate',...
%                'inosil','nesosil','nitrates','oxide','phosphate',...
%                'phylosil','sorosil','sulfate','tectosil','moon',...
%                'rocks','synth','unconsolidated' 

%       wac: [L,1], numeric array, wavelength centers for each band
%       sbc: [L 10], band width information
%   Optional Parameters
%       'MODE': passed to interpCRISMspc.m
%       'RETAINRATIO': passed to interpCRISMspc.m
%       'INTEREXTRAPOLATE': passed to interpCRISMspc.m
%       'INTEREXTRAPOLATE_TOTALNUM': passed to interpCRISMspc.m
%         
%   Output Parameters
%       A: [L x N], matrix of convolved spectra



if ischar(lib_list)
    if strcmpi(lib_list,'all')
        lib_list = fields(CRISMspclib);
    else
        lib_list = {lib_list};
    end
end

A = [];
for i=1:length(lib_list)
    lib = lib_list{i};
    if isfield(CRISMspclib,lib)
        wvspc = CRISMspclib.(lib).hdr.wavelength(:);
        if strcmpi(CRISMspclib.(lib).hdr.wavelength_units,'microns')
            % convert to nanometers
            wvspc = wvspc*1000;
        end
        rflspc = CRISMspclib.(lib).spc';
        rflspc(rflspc<1e-10) = nan;
        [ rflspc_rsmp ] = interpCRISMspc_v2( wvspc,rflspc,wac,sbc,varargin{:} );
        A = [A rflspc_rsmp];
    else
        warning('Input library "%s" does not exist. Skipped.',lib);
    end
end

end