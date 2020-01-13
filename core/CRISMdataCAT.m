classdef CRISMdataCAT < CRISMdata
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        CRISMdata_parent = [];
    end
    
    methods
        function obj = CRISMdataCAT(basename,dirpath,varargin)
            obj@CRISMdata(basename,dirpath,varargin{:});
        end
        
        function obj = readCRISMdata_parent(obj,basename_ascend,dirpath_ascend,varargin)
            if isempty(basename_ascend)
                basename_ascend = get_basenameOBS_fromProp(obj.prop);
            end
            obj.CRISMdata_parent = CRISMdata(basename_ascend,dirpath_ascend,varargin{:});
        end
        
        function [] = load_basenamesCDR_fromCRISMdata_parent(obj,varargin)
            if isempty(obj.CRISMdata_parent)
                fprintf('perform readCRISMdata_parent...\n');
                obj.readCRISMdata_parent('','');
            end
            obj.load_basenamesCDR(obj.CRISMdata_parent,varargin{:});
        end
        
        function [wa] = readWA_fromCRISMdata_parent(obj,varargin)
            if isempty(obj.CRISMdata_parent)
                fprintf('perform readCRISMdata_parent...\n');
                obj.readCRISMdata_parent('','');
            end
            wa = obj.CRISMdata_parent.readWA(varargin{:});
            if nargout<1
                obj.wa = wa;
            end
        end
        
        function [wa] = readWAi_fromCRISMdata_parent(obj,varargin)
            if isempty(obj.CRISMdata_parent)
                %fprintf('perform readCRISMdata_parent...\n');
                obj.readCRISMdata_parent('','');
            end
            wa = obj.CRISMdata_parent.readWAi(varargin{:});
            if nargout < 1
                obj.wa = wa;
                obj.is_wa_band_inverse = true;
            end
        end
        
        function [] = loadBPGP1nan_fromCRISMdata_parent(obj)
            obj.CRISMdata_parent.loadBPGP1nan();
            obj.is_bp1nan_inverse = obj.CRISMdata_parent.is_bp1nan_inverse;
            obj.BP1nan = obj.CRISMdata_parent.BP1nan;
            obj.GP1nan = obj.CRISMdata_parent.GP1nan;
            obj.is_gp1nan_inverse = obj.CRISMdata_parent.is_gp1nan_inverse;
        end
    end
end

