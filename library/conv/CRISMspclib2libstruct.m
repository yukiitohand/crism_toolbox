function [infoA] = CRISMspclib2libstruct(CRISMspclib,lib_list)
% [infoA] = CRISMspclib2libstruct(CRISMspclib,lib_list)
%   Reorganize CRISM
%   Input Parameters
%       CRISMspclib: struct, CRISM spectral library
%       lib_list: str or cell, list of library names to be convolved
%             'all', or select from the list below:
%                'RT_resamp', 'all_sulfates_resamp','meteor','carbonate',...
%                'inosil','nesosil','nitrates','oxide','phosphate',...
%                'phylosil','sorosil','sulfate','tectosil','moon',...
%                'rocks','synth','unconsolidated' 
%         
%   Output Parameters
%       infoA: struct having three fields 
%              {'spc_name','lib_name','subfolder','spclib'}



if ischar(lib_list)
    if strcmpi(lib_list,'all')
        lib_list = fields(CRISMspclib);
    else
        lib_list = {lib_list};
    end
end

infoA = struct('spc_name',[],'lib_name',[],'subfolder',[]);
cumj = 0;
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
        for j=1:CRISMspclib.(lib).hdr.lines
            infoA(cumj+j).reflectance = rflspc(:,j);
            infoA(cumj+j).wavelength = wvspc;
            infoA(cumj+j).subindex = j;
            infoA(cumj+j).cumindex = cumj+j;
            infoA(cumj+j).spc_name = CRISMspclib.(lib).hdr.spectra_names{j};
            infoA(cumj+j).lib_name = lib;
            infoA(cumj+j).subfolder = CRISMspclib.(lib).subfolder;
            infoA(cumj+j).spclib = 'CRISM spectral library';
        end
        cumj = cumj + CRISMspclib.(lib).hdr.lines;
    else
        warning('Input library "%s" does not exist. Skipped.',lib);
    end
end

end