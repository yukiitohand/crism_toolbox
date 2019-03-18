classdef CRISMObservation < handle
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        info;
        data;
    end
    
    methods
        function obj = CRISMObservation(obs_id,varargin)
            [ obs_info ] = get_crism_obs_info(obs_id,varargin{:});
            obj.info = obs_info;
        end
        function load_default(obj)
            obj.load_data(obj.info.basenameIF,obj.info.dir_trdr,'if');
            obj.load_data(obj.info.basenameRA,obj.info.dir_trdr,'ra');
            obj.load_data(obj.info.basenameSC,obj.info.dir_edr,'sc');
            obj.load_ddr(obj.info.basenameDDR,obj.info.dir_ddr,'ddr');
            if ~isempty(obj.info.basenameTERIF)
                obj.load_data(obj.info.basenameTERIF,obj.info.dir_ter,'terif');
            end
        end
        function [crismdata_obj] = load_data(obj,basename,dirpath,acro)
            crismdata_obj = CRISMdata(basename,dirpath);
            obj.data.(acro) = crismdata_obj;    
        end
        
        function load_ddr(obj,basename,dirpath,acro)
            img = CRISMDDRdata(basename,dirpath);
            obj.data.(acro) = img;    
        end
        
        function [TERdata] = load_ter(obj,basename,dirpath,acro)
            TERdata = CRISMTERdata(basename,dirpath);
            if nargout < 1
                obj.data.(acro) = TERdata;
            end
        end
        
        function [MTRdata] = load_mtr(obj,basename,dirpath,acro)
            [MTRdata] = obj.load_ter(basename,dirpath,acro);
            if nargout < 1
                obj.data.(acro) = MTRdata;
            end
        end
        
        function [MTRDEdata] = load_mtrde(obj,basename,dirpath,acro)
            MTRDEdata = CRISMMTRDEdata(basename,dirpath);
            if nargout < 1
                obj.data.(acro) = MTRDEdata;
            end 
        end
        
        function [dirs,files]=list_dir(obj,dir_acro,varargin)
            switch dir_acro
                case 'trdr'
                    dirpath = obj.info.dir_trdr;
                case 'edr'
                    dirpath = obj.info.dir_edr;
                case 'ter'
                    dirpath = obj.info.dir_ter;
                case 'ddr'
                    dirpath = obj.info.dir_ddr;
                otherwise
                    dirpath = dir_acro;
                    if ~exist(dirpath,'dir')
                        error('%s does not exist.', dirpath);
                    end
            end
            [ dirs,files ] = list_dir( dirpath,varargin );
        end
        
        function [atf] = readATF(obj,varargin)
            [atf] = crismCDRATFread(obj.info.yyyy_doy,obj.info.sensor_id,varargin{:});
        end
        
    end
end