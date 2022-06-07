global LUT_OBSID2YYYY_DOY

flds = fields(LUT_OBSID2YYYY_DOY);

L = length(flds);
flds_char = cat(1,flds{:});
CRISM_INDEX_OBS_CLASS_TYPE = flds_char(:,1:3);
a = flds_char(:,4:11);
CRISM_INDEX_OBS_ID = int32(hex2dec(flds_char(:,4:11)));

CRISM_INDEX_YYYY_DOY = cellfun(@(x) LUT_OBSID2YYYY_DOY.(x),flds,'UniformOutput',false);
CRISM_INDEX_YYYY_DOY = cat(1,CRISM_INDEX_YYYY_DOY{:});
CRISM_INDEX_YYYY = int16(str2double(string(CRISM_INDEX_YYYY_DOY(:,1:4))));
CRISM_INDEX_DOY = int16(str2double(string(CRISM_INDEX_YYYY_DOY(:,6:8))));

save('CRISM_LUT_OBSID2YYYY_DOY_v2.mat','CRISM_INDEX_OBS_CLASS_TYPE','CRISM_INDEX_OBS_ID',...
    'CRISM_INDEX_YYYY','CRISM_INDEX_DOY','-v7');


