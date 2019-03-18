function [bprms] = crismBandprmRead(imgfile,varargin)
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
cmpst.IRA = cat(3,bprms.R1330,bprms.R1330,bprms.R1330);
cmpst.FAL = cat(3,bprms.R2529,bprms.R1506,bprms.R1080);
cmpst.MAF = cat(3,bprms.OLINDEX3,bprms.LCPINDEX2,bprms.HCPINDEX2);
cmpst.HYD = cat(3,bprms.SINDEX2,bprms.BD2100_2,bprms.BD1900_2);
% cmpst.PHY = cat(3,bprms.D2300,bprms.D2200,bprms.BD1900r2);
cmpst.PHY = cat(3,bprms.D2300,bprms.D2200,bprms.BD1900R2);
cmpst.PFM = cat(3,bprms.BD2355,bprms.D2300,bprms.BD2290);
cmpst.PAL = cat(3,bprms.BD2210_2,bprms.BD2190,bprms.BD2165);
% cmpst.HYS = cat(3,bprms.MIN2250,bprms.BD2250,bprms.BD1900r2);
cmpst.HYS = cat(3,bprms.MIN2250,bprms.BD2250,bprms.BD1900R2);
cmpst.ICE = cat(3,bprms.BD1900_2,bprms.BD1500_2,bprms.BD1435);
cmpst.IC2 = cat(3,bprms.R3920,bprms.BD1500_2,bprms.BD1435);
% cmpst.CHL = cat(3,bprms.ISLOPE,bprms.BD3000,bprms.IRR2);
cmpst.CHL = cat(3,bprms.ISLOPE1,bprms.BD3000,bprms.IRR2);
% cmpst.CAR = cat(3,bprms.D2300,bprms.BD2500H2,bprms.BD1900_2);
cmpst.CAR = cat(3,bprms.D2300,bprms.BD2500_2,bprms.BD1900_2);
cmpst.CR2 = cat(3,bprms.MIN2295_2480,bprms.MIN2345_2537,bprms.CINDEX2);

bprms2 = [];
bprms2.bmaps = bprms;
bprms = bprms2;
bprms.cmpst = cmpst;
bprms.hdr = hsi.hdr;

end



