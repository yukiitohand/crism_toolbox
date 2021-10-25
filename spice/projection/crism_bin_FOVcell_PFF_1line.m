function [crism_FOVcell_lbin,crismPxl_sofst_lbin,crismPxl_smpls_lbin, ...
    crismPxl_lofst_lbin, crismPxl_lines_lbin] ...
    = crism_bin_FOVcell_PFF_1line(binx,crism_FOVcell_l, ...
    crismPxl_sofst_l,crismPxl_smpls_l,crismPxl_lofst_l,crismPxl_lines_l)
% [crism_FOVcell_lbin,crismPxl_sofst_lbin,crismPxl_smpls_lbin, ...
%     crismPxl_lofst_lbin, crismPxl_lines_lbin] ...
%     = crism_bin_FOVcell_PFF_1line(binning_id,crism_FOVcell_l, ...
%     crismPxl_sofst_l,crismPxl_smpls_l,crismPxl_lofst_l,crismPxl_lines_l)
% Bin a CRISM FOV cell array of [1 x 640] size to [1 x 640/binx]
%  INPUTS
%    binx: pixel averaging width
%    crism_FOVcell_l : [1 x 640] cell array, Pixel response function is
%                     stored
%    crismPxl_sofst_l: [1 x 640] array, sample offsets for the elements of
%                     crism_FOVcell_l
%    crismPxl_smpls_l: [1 x 640] array, samples for the elements of crism_FOVcell_l
%    crismPxl_lofst_l: [1 x 640] array, line offsets for the elements of
%                     crism_FOVcell_l
%    crismPxl_lines_l: [1 x 640] array, lines for the elements of crism_FOVcell_l
%  OUTPUTS
%    crism_FOVcell_lbin : [1 x (640/binx)] cell array, Pixel response function of binned pixels
%    crismPxl_sofst_lbin: [1 x (640/binx)] array, sample offsets for the elements of
%                        crism_FOVcell_lbin
%    crismPxl_smpls_lbin: [1 x (640/binx)] array, samples for the elements of
%                        crism_FOVcell_lbin
%    crismPxl_lofst_lbin: [1 x (640/binx)] array, line offsets for the elements of
%                        crism_FOVcell_lbin
%    crismPxl_lines_lbin: [1 x (640/binx)] array, lines for the elements of
%                        crism_FOVcell_lbin
%   binx = 1 (binning_id=0), 2 (binning_id=1), 5 (binning_id=2), 10 (binning_id=3)

%% INPUT check
if ~any(binx==[1 2 5 10])
    error('binx should be [1 2 5 10].');
end

[N,nC] = size(crism_FOVcell_l);
if nC~=640
    error('Input cell array needs 640 columns');
end
if N~=1
    error('Input cell array needs 1 row.');
end

validateattributes(crismPxl_sofst_l,{'int32'},{'size',[1 640]});
validateattributes(crismPxl_smpls_l,{'int32'},{'size',[1 640]});
validateattributes(crismPxl_lofst_l,{'int32'},{'size',[1 640]});
validateattributes(crismPxl_lines_l,{'int32'},{'size',[1 640]});

%%
% [binx] = crism_get_binx(binning_id);
switch binx
    case 1 % No binning
        % with binx==1 no need to further bin the image...
        crism_FOVcell_lbin  = crism_FOVcell_l;
        crismPxl_sofst_lbin = crismPxl_sofst_l;
        crismPxl_smpls_lbin = crismPxl_smpls_l;
        crismPxl_lofst_lbin = crismPxl_lofst_l;
        crismPxl_lines_lbin = crismPxl_lines_l;
    otherwise % with binning
        % [N,nC] = size(crism_FOVcell_l);
        nCbin  = nC / binx;
        Nbin   = binx * N;
        crism_FOVcell_l  = reshape(crism_FOVcell_l ,Nbin,nCbin);
        crismPxl_sofst_l = reshape(crismPxl_sofst_l,Nbin,nCbin);
        crismPxl_smpls_l = reshape(crismPxl_smpls_l,Nbin,nCbin);
        crismPxl_lofst_l = reshape(crismPxl_lofst_l,Nbin,nCbin);
        crismPxl_lines_l = reshape(crismPxl_lines_l,Nbin,nCbin);
        
        [crism_FOVcell_lbin,crismPxl_sofst_lbin,crismPxl_smpls_lbin, ...
            crismPxl_lofst_lbin, crismPxl_lines_lbin] ...
            = crism_combine_FOVcell_PSF_1expo_v3_mex( ...
                crism_FOVcell_l,  ... 0
                crismPxl_sofst_l, ... 1
                crismPxl_smpls_l, ... 2
                crismPxl_lofst_l, ... 3
                crismPxl_lines_l  ... 4
            );
end


end