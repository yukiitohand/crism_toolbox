classdef CRISMMTRDRdataSuite < handle
    % Collection of TERdata suite
    %   
    
    properties
        info;
        data;
    end
    
    methods
        function obj = CRISMMTRDRdataSuite(crism_obs)
            MTRIFdata = crism_obs.load_mtr(crism_obs.info.basenameMTRIF,crism_obs.info.dir_mtrdr,'if');
            MTRINdata = crism_obs.load_mtr(crism_obs.info.basenameMTRIN,crism_obs.info.dir_mtrdr,'in');
            MTRWVdata = crism_obs.load_mtr(crism_obs.info.basenameMTRWV,crism_obs.info.dir_mtrdr,'wv');
            MTRSRdata = crism_obs.load_mtr(crism_obs.info.basenameMTRIN,crism_obs.info.dir_mtrdr,'sr');
            MTRSUdata = crism_obs.load_mtr(crism_obs.info.basenameMTRIN,crism_obs.info.dir_mtrdr,'su');
            MTRDEdata = crism_obs.load_mtrde(crism_obs.info.basenameMTRDE,crism_obs.info.dir_mtrdr,'de');
            obj.data.if = MTRIFdata;
            obj.data.in = MTRINdata;
            obj.data.wv = MTRWVdata;
            obj.data.sr = MTRSRdata;
            obj.data.su = MTRSUdata;
            obj.data.de = MTRDEdata;
        end
    end
end