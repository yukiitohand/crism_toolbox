function [msldemc_hdr,msldemc_imFOVres,msldemc_imFOVsmpl,msldemc_imFOVline] ...
    = crism_combine_FOVcell_PSF_multiPxl_v3( ...
    fname_top,dirpath, line_offset, Nlines, ...
    crismPxl_sofst, crismPxl_smpls, crismPxl_lofst,crismPxl_lines)
%  * Combine the FOVcells of the lines given by the user. The range of lines 
%  * are specified by two variables line_offset and Nl. Nl is the number of 
%  * lines. It will read lines 
%  * [line_offset, line_offset+1, ..., line_offset+Nl-1]
%  * 
%  * INPUTS:
%  * 0 fname_top         char*
%  * 1 dirpath           char* 
%  * 2 line_offset       int32 scalar,
%  * 3 Nl                int32 scalar, number of lines
%  * 4 crismPxl_sofst    int32 [L x Ncrism]
%  * 5 crismPxl_smpls    int32 [L x Ncrism]
%  * 6 crismPxl_lofst    int32 [L x Ncrism]
%  * 7 crismPxl_lofst    int32 [L x Ncrism]
% 
%  * Note: L is the total number of lines.
%  * 
%  * OUTPUTS:
%  * 0 msldemc_hdr         : struct, subimage information
%  * 1 msldemc_imFOVres    : double [msldemc_lines x msldemc_samples]
%  * 2 msldemc_imFOVsample : int16 [msldemc_lines x msldemc_samples]
%  * 3 msldemc_imFOVline   : int16 [msldemc_lines x msldemc_samples]

[L,Ncrism] = size(crismPxl_sofst);

l1 = line_offset+1; lend = line_offset+Nlines;
if l1<1 || lend>L
    error('Input line offset and Nl are out of the range');
end


%% first decide the msldemc_hdr
s_min = min(crismPxl_sofst(l1:lend,:),[],'all');
send_mat = crismPxl_sofst + crismPxl_smpls;
s_max = max(send_mat(l1:lend,:),[],'all');


l_min = min(crismPxl_lofst(l1:lend,:),[],'all');
lend_mat = crismPxl_lofst + crismPxl_lines;
l_max = max(lend_mat(l1:lend,:),[],'all');

msldemc_hdr = [];
msldemc_hdr.sample_offset = s_min;
msldemc_hdr.line_offset = l_min;
msldemc_hdr.samples = s_max - s_min;
msldemc_hdr.lines   = l_max - l_min;

%%
crismPxl_sofstc = crismPxl_sofst - msldemc_hdr.sample_offset;
crismPxl_lofstc = crismPxl_lofst - msldemc_hdr.line_offset;

if strcmpi(dirpath(end),'/')
    dirpath_noslash = dirpath(1:end-1);
else
    dirpath_noslash = dirpath;
end

[msldemc_imFOVres,msldemc_imFOVsmpl,msldemc_imFOVline] = ...
    crism_combine_FOVcell_PSF_multiPxl_mex( ...
        fname_top       , ... 0
        dirpath_noslash , ... 1
        line_offset     , ... 2
        Nlines          , ... 3
        crismPxl_sofstc , ... 4
        crismPxl_smpls  , ... 5
        crismPxl_lofstc , ... 6
        crismPxl_lines  , ... 7
        msldemc_hdr       ... 8
    );

%%
% for l=l1:lend
%     bname = sprintf('%s_l%03d',fname_top,l);
%     fpath = joinPath(dirpath,[bname '.mat']);
%     load(fpath,'crism_FOVcell_lcomb');
%     for xi=1:Ncrism
%         ss1 = crismPxl_sofst(l,xi); ssend = send_mat(l,xi);
%         ll1 = crismPxl_lofst(l,xi); llend = lend_mat(l,xi);
%         pff_lxi = crism_FOVcell_lcomb{xi};
%         
%         % crop the images
%         msldemc_imFOVres_crop  = msldemc_imFOVres(ll1:llend,ss1:ssend);
%         msldemc_imFOVsmpl_crop = msldemc_imFOVsmpl(ll1:llend,ss1:ssend);
%         msldemc_imFOVline_crop = msldemc_imFOVline(ll1:llend,ss1:ssend);
%         
%         % evaluate the cropped images
%         flg = (pff_lxi > msldemc_imFOVres_crop);
%         msldemc_imFOVres_crop(flg)  = pff_lxi(flg);
%         msldemc_imFOVsmpl_crop(flg) = xi;
%         msldemc_imFOVline_crop(flg) = l;
%         
%         % Update the images
%         msldemc_imFOVres(ll1:llend,ss1:ssend)  = msldemc_imFOVres_crop;
%         msldemc_imFOVsmpl(ll1:llend,ss1:ssend) = msldemc_imFOVsmpl_crop;
%         msldemc_imFOVline(ll1:llend,ss1:ssend) = msldemc_imFOVline_crop;
%     end
% end


end
