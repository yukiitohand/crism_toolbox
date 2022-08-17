classdef CRISMdataMSLDEMproj < handle
    % CRISMdataMSLDEMproj
    %   CRISMdata projected onto MSLDEM grid.
    
    properties
        CRISMdata
        PFFonMSLDEM
        MSLDEMdata
        proj_info
        hdr
        
        ENVIRasterMultviewObj
        ave_window
        
        PFFonMASTCAM
    end
    
    methods
        function obj = CRISMdataMSLDEMproj(crismdataObj,crismPFFonMSLDEMobj)
            % obj = CRISMdataMSLDEMproj(crismdataObj,crismPFFonMSLDEMobj)
            %  
            obj.CRISMdata   = crismdataObj;
            obj.PFFonMSLDEM = crismPFFonMSLDEMobj;
            obj.MSLDEMdata  = crismPFFonMSLDEMobj.MSLDEMdata;
            obj.proj_info   = obj.MSLDEMdata.proj_info;
            obj.hdr         = obj.MSLDEMdata.hdr;
            obj.ave_window = [1 1];
        end
        
        
    end
end

