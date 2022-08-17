function [bprms] = crismBandprmReadVNIR(imgfile,varargin)
% [ bprms ] = crismBandprmRead( imgfile )
%   Read a band parameter map for crism images
%    Inputs
%      imgfile: filepath to the image file
%      hdrfile (optional): filepath to the header file
%    Outputs
%      bprms: struct of structs
%          fields: hdr,bmaps,cmpst
%             hdr: header information of the band parameter image.
%             bmaps: the original parameter maps.
%             cmpst: composite RGB color images.
%      of the image.
%   Usage
%     [ bprms ] = envireadx( imgfile )
%     [ bprms ] = envireadx( imgfile,hdrfile )

%     With hdrfile is unspecified, the path will be guessed.


% read hyperspectral image
[ hsi ] = envireadx( imgfile,varargin{:} );

hsi.img(hsi.img==hsi.hdr.data_ignore_value) = nan;
bprms = [];
cmpst = [];

if ~isfield(hsi.hdr,'band_names')
    error('"band_names" does not exist in the image. The input may not be the band parameter maps.');
end

for i=1:hsi.hdr.bands
    bprms.(hsi.hdr.band_names{i}) = hsi.img(:,:,i);
end

% cmpst.IRA = cat(3,bprms.R1300,bprms.R1300,bprms.R1300);
cmpst.TRU = cat(3,bprms.R600,bprms.R530,bprms.R440);
cmpst.VNA = cat(3,bprms.R770,bprms.R770,bprms.R770);
cmpst.FEM = cat(3,bprms.BD530_2,bprms.SH600_2,bprms.BDI1000VIS);
cmpst.FM2 = cat(3,bprms.BD530_2,bprms.BD920_2,bprms.BDI1000VIS);

bprms2 = [];
bprms2.bmaps = bprms;
bprms = bprms2;
bprms.cmpst = cmpst;
bprms.hdr = hsi.hdr;

end