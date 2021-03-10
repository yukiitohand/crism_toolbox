function [sw,unit] = crism_get_sw(WAdata)
% [sw,unit] = crism_get_sw(WAdata)
%  Get sweet spot wavelength from wavelength frame WA data
%  INPUTS
%   WAdata: CRISMdata obj
%  OUTPUTS
%   sw: a column vector, sweetspot wavelength
%   unit: unit of the wavelength
%

SWdata = getSWBWfromWA(WAdata,'SW');
SWdata.readTAB();
rownumtbl_sw = [SWdata.tab.data.ROWNUM];
% Get ROWNUMTABLE
[rownum_table] = WAdata.read_ROWNUM_TABLE();

% Match band of the CRISM image with the SW table data
idxList = nan(1,length(rownum_table));
for i=1:length(rownum_table)
    idxList(i) = find(rownum_table(i)==rownumtbl_sw);
end
sw = [SWdata.tab.data(idxList).SAMPL_WAV]';

unit = SWdata.lbl.OBJECT_FILE.OBJECT_TABLE.OBJECT_COLUMN{2}.UNIT;

end