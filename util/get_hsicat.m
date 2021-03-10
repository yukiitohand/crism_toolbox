function [hsicat] = get_hsicat(TRRdata,phot,atmt_src,bandset_id,enable_artifact)
% original competitorsx
% phot = 0; 
% atmt_src = 'trial'; %{'tbench','auto','user','default'}
% bandset_id = 'mcg'; %{'mcg','pel'}
% enable_artifact = 1;
acro_catatp = sprintf('phot%d_%s_%s_a%d',phot,atmt_src,bandset_id,enable_artifact);
suffix = ['_corr_' acro_catatp];
hsicat = CRISMdataCAT([TRRdata.basename suffix],TRRdata.dirpath);
rgb_cat = hsicat.lazyEnviReadRGBi([233,78,13]);

end
