function [img_aligned,wa_aligned] = crism_alignVNIR2SWIR(CRISMdataSobj,CRISMdataLobj,varargin)
% [img_aligned,wa_aligned] = crism_alignVNIR2SWIR(CRISMdataSobj,CRISMdataLobj,varargin)
%   align a CRISM VNIR image to CRISM IR image detector space using CDR CM data.
%  Input Parameters
%   CRISMdataSobj: VNIR CRISMdata obj
%   CRISMdataLobj: IR CRISMdata obj
%  Output Parameters
%   img_aligned: VNIR image aligned to IR CRISMdata detector space.

% load CDR CMdata
[CMdataL] = crism_findCMdatafromCRISMdata(CRISMdataLobj);
[CMdataS] = crism_findCMdatafromCRISMdata(CRISMdataSobj);

% read CDR DM data
DMdataL = CRISMdataLobj.readCDR('DM');
DMdataL.readimgi();
DMmaskL = (DMdataL.img==1);
DMdataS = CRISMdataSobj.readCDR('DM');
DMdataS.readimgi();
DMmaskS = (DMdataS.img==1);

% read images
%CRISMdataSobj.readimg();
CMdataL.readimgi();
CMdataS.readimg();

% read WA file
CRISMdataSobj.readCDR('WA');
CRISMdataSobj.cdr.WA.readimg();

% perform the alignment of the image
[img_aligned] = crism_alignImagewithCM(CRISMdataSobj.img,CMdataS.img,CMdataL.img,DMmaskS,DMmaskL);
% perform the alignment of the wavelength
[wa_aligned] = crism_alignImagewithCM(CRISMdataSobj.cdr.WA.img,CMdataS.img,CMdataL.img,DMmaskS,DMmaskL);


end

