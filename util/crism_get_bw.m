function [bw,unit] = crism_get_bw(WAdata)
% [bw,unit] = crism_get_sw(WAdata)
%  Get wavelength fwhm from wavelength frame WA data
%  INPUTS
%   WAdata: CRISMdata obj
%  OUTPUTS
%   bw: a column vector, fwhm
%   unit: string
%

BWdata = getSWBWfromWA(WAdata,'BW');
BWdata.readTAB();
rownumtbl_sw = [BWdata.tab.data.ROWNUM];
% Get ROWNUMTABLE
[rownum_table] = WAdata.read_ROWNUM_TABLE();

% Match band of the CRISM image with the SW table data
idxList = nan(1,length(rownum_table));
for i=1:length(rownum_table)
    idxList(i) = find(rownum_table(i)==rownumtbl_sw);
end
bw = [BWdata.tab.data(idxList).SAMPL_FWHM]';

unit = SWdata.lbl.OBJECT_FILE.OBJECT_TABLE.OBJECT_COLUMN{2}.UNIT;

end