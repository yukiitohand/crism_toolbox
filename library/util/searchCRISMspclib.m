function [spc] = searchCRISMspclib(spectrum_name,CRISMspclib,varargin)
% [spc] = searchCRISMspclib(spectrum_name,CRISMspclib,varargin)
%   search instances in CRISMspclib 
% Inputs:
%  spectrum_name: name of the spectrum to be searched
%  CRISMspclib: CRISM spectral library
%       CRISMspclib = 
%
%       struct with fields:
% 
%                           RT_resamp: [1×1 struct]
%                 all_sulfates_resamp: [1×1 struct]
%                              meteor: [1×1 struct]
%                           carbonate: [1×1 struct]
%                              inosil: [1×1 struct]
%                             nesosil: [1×1 struct]
%                            nitrates: [1×1 struct]
%                               oxide: [1×1 struct]
%                           phosphate: [1×1 struct]
%                            phylosil: [1×1 struct]
%                             sorosil: [1×1 struct]
%                             sulfate: [1×1 struct]
%                            tectosil: [1×1 struct]
%                                moon: [1×1 struct]
%                               rocks: [1×1 struct]
%                               synth: [1×1 struct]
%                      unconsolidated: [1×1 struct]
%  Each field has 
%         CRISMspclib.carbonate = 
% 
%                     struct with fields:
% 
%                                   hdr: [1×1 struct]
%                                   spc: [89×1501 double]
%                             subfolder: 'mineral/'
%
%  hdr needs to have the field "spectra_names"
% Outputs:
%   spc: array of struct, having information of the spectra
%   resIdx: corresponding indices

flds = fieldnames(CRISMspclib);
spc = [];
num_cum = 0; sz = 0;
for fldi=1:length(flds)
    fldnm = flds{fldi};
    sub_lib = CRISMspclib.(fldnm);
    idx = find(cellfun(@(x) strcmpi(x,spectrum_name),sub_lib.hdr.spectra_names));
    if ~isempty(idx)
        for i=1:length(idx)
            idx_cur = idx(i);
            i_cum = i + sz;
            spc(i_cum).wavelength = sub_lib.hdr.wavelength;
            spc(i_cum).reflectance = sub_lib.spc(idx_cur,:);
            spc(i_cum).sublib = fldnm;
            spc(i_cum).subfolder = sub_lib.subfolder;
            spc(i_cum).idx = idx_cur;
            spc(i_cum).idx_cum = num_cum + idx_cur;
            spc(i_cum).spectrum_name = spectrum_name;
        end
        sz = sz+length(idx);
    end
    num_cum = num_cum + sub_lib.hdr.lines;
end
    
    
end
