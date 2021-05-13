classdef CRISMdata_p2 < CRISMdata
    % data class for projected version of CRISMdata
    properties
        GLTdata = [];
        glt_x = [];
        glt_y = [];
    end
    
    methods
        function obj = CRISMdata_p2(basename,dirpath,varargin)
            obj@CRISMdata(basename,dirpath,varargin{:});
        end
        
        function loadGLT(obj,ddr_data)
            propGLT = ddr_data.prop;
            propGLT.product_type = 'GLT';
            propGLT.version = 2;
            basenameGLT = get_basenameOBS_fromProp(propGLT);
            % dir_info = get_dirpath_observation(basenameGLT);
            % dirpath_glt = dir_info.dirfullpath_local;
            obj.GLTdata = CRISMdata(basenameGLT,[]);
            if ~isempty(obj.GLTdata.imgpath)
                obj.GLTdata.readimg();
                obj.glt_x = obj.GLTdata.img(:,:,1);
                obj.glt_y = obj.GLTdata.img(:,:,2);
            else
                warning('GLT data cannot be found');
            end
            
        end
        
        
    end
end