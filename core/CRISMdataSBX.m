classdef CRISMdataSBX < CRISMdata
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        lbspath
        lbs
        CRISMdata_parent;
    end
    
    methods
        function obj = CRISMdataSBX(basename,dirpath,varargin)
            obj@CRISMdata(basename,dirpath,varargin{:});
            
            if isempty(obj.hdr)
                obj.lbspath = crism_guessLBSPATH(basename,dirpath,varargin{:});
                obs.readlbshdr();
            end
            
            if ~isempty(obj.hdrpath)
                hdr = envihdrreadx2(obj.hdrpath);
                obj.hdr = hdr;
            end
        end

        function [] = readlbshdr(obj)
            if ~isempty(obj.lbspath)
                obj.lbs = crismlbsread(obj.lbspath);
                obj.hdr = crism_lbs2hdr(obj.lbs,'missing_constant',obj.missing_constant_img);                 
            elseif ~isempty(obj.hdrpath)
                obj.lbs = [];
                obj.hdr = envihdrreadx2(obj.hdrpath);
            else
                obj.lbs = [];
                obj.hdr = [];
            end
        end
        
        function obj = readCRISMdata_parent(obj,basename_ascend,dirpath_ascend,varargin)
            if isempty(basename_ascend)
                basename_ascend = crism_get_basenameOBS_fromProp(obj.prop);
            end
            obj.CRISMdata_parent = CRISMdata(basename_ascend,dirpath_ascend,varargin{:});
        end
        
        function [] = load_basenamesCDR_fromCRISMdata_parent(obj,varargin)
            if isempty(obj.CRISMdata_parent)
                fprintf('perform readCRISMdata_parent...\n');
                obj.readCRISMdata_parent('','');
            end
            obj.CRISMdata_parent.load_basenamesCDR(varargin{:});
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