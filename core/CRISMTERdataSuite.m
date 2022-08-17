classdef CRISMTERdataSuite < handle
    % Collection of TERdata suite
    %   
    
    properties
        info;
        data;
    end
    
    methods
        function obj = CRISMTERdataSuite(crism_obs)
            TERIFdata = crism_obs.load_ter(crism_obs.info.basenameTERIF,crism_obs.info.dir_ter,'if');
            TERINdata = crism_obs.load_ter(crism_obs.info.basenameTERIN,crism_obs.info.dir_ter,'in');
            TERWVdata = crism_obs.load_ter(crism_obs.info.basenameTERWV,crism_obs.info.dir_ter,'wv');
            TERSRdata = crism_obs.load_ter(crism_obs.info.basenameTERIN,crism_obs.info.dir_ter,'sr');
            TERSUdata = crism_obs.load_ter(crism_obs.info.basenameTERIN,crism_obs.info.dir_ter,'su');
            obj.data.if = TERIFdata;
            obj.data.in = TERINdata;
            obj.data.wv = TERWVdata;
            obj.data.sr = TERSRdata;
            obj.data.su = TERSUdata;
        end
    end
end