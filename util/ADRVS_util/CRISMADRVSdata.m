classdef CRISMADRVSdata < CRISMdata
    % CRISMADRVSdata
    %   inherent from CRISMdata
    % additional properties are added
    %   is_icy
    %   is_dusty
    %   no_v2
    %   low_noise
    
    %   trans
    %   art
    
    properties
        vsid
        binning
        wavelength_filter
        is_icy
        is_dusty
        no_v2
        lownoise
        trans
        art_mcg
        art_pel
        % following properties are prepared for future implementation
        sclk_source 
        % sclk of the source image read from
        % CAT_ENVI/aux_files/obs_info/crism_obs_info.txt
        bench_temp
        % bench_temp of the source image read from
        % CAT_ENVI/aux_files/obs_info/crism_obs_info.txt
        spshift
    end
    
    methods 
        function [obj] = CRISMADRVSdata(basename,dirpath)
            obj@CRISMdata(basename,dirpath);
            
            obj.vsid     = obj.prop.obs_id_short;
            obj.binning  = obj.prop.binning;
            obj.wavelength_filter = obj.prop.wavelength_filter;
            
            obj.is_icy   = crism_adrvs_is_icy(obj.vsid);
            obj.is_dusty = crism_adrvs_is_dusty(obj.vsid);
            obj.lownoise = crism_adrvs_is_lownoise(obj.vsid);
            obj.no_v2    = crism_adrvs_is_no_v2(obj.vsid);

            cataux_obsinfo  = crism_get_cataux_obsinfo(obj.vsid);
            obj.bench_temp  = cataux_obsinfo.bench_temp;
            obj.sclk_source = cataux_obsinfo.sclk;
            
        end
        function [] = load_data(obj,varargin)
            band_inverse = false;
            varargin_readimg = {};
            if (rem(length(varargin),2)==1)
                error('Optional parameters should always go by pairs');
            else
                for i=1:2:(length(varargin)-1)
                    switch upper(varargin{i})
                        case 'BAND_INVERSE'
                            band_inverse = varargin{i+1};
                        case {'PRECISION','REPLACE_DATA_IGNORE_VALUE','REPVAL_DATA_IGNORE_VALUE'}
                            varargin_readimg = [varargin_readimg varargin([i i+1])];
                        otherwise
                            error('Unrecognized option: %s',varargin{i});
                    end
                end
            end
            
            switch band_inverse
                case 0
                    img = obj.readimg(varargin_readimg{:});
                case 1
                    img = obj.readimgi(varargin_readimg{:});
                otherwise
                    error('Invalid BAND_INVERSE=%d',band_inverse);
            end
            
            % Layer 0: Image
            % Layer 1: artifact correction components associated with
            %          McGuire correction
            % Layer 2: artifact correction components associated with
            %          Pelky correction
            obj.trans   = img(1,:,:);
            obj.art_mcg = img(2,:,:);
            obj.art_pel = img(3,:,:);
            
            % [interp_bands] = obj.get_artifact_interp_bands('BAND_INVERSE',band_inverse);            
            
            % art_mcg_invalid = or(~(abs(obj.art_mcg)>1e-23),art_valid);
            % obj.art_mcg(art_mcg_invalid) = nan;
            
            % art_pel_invalid = or(~(abs(obj.art_pel)>1e-23),art_valid);
            % obj.art_pel(art_pel_invalid) = nan;
            
        end
        
        function [interp_bands] = get_artifact_interp_bands(obj,varargin)
            band_inverse = false;
            if (rem(length(varargin),2)==1)
                error('Optional parameters should always go by pairs');
            else
                for i=1:2:(length(varargin)-1)
                    switch upper(varargin{i})
                        case 'BAND_INVERSE'
                            band_inverse = varargin{i+1};
                        otherwise
                            error('Unrecognized option: %s',varargin{i});
                    end
                end
            end
            % First read wavelength frame file
            if isempty(obj.basenamesCDR)
                obj.load_basenamesCDR();
            end
            if isempty(obj.cdr) || ~isfield(obj.cdr,'WA')
                obj.readCDR('WA');
            end
            WAdata = obj.cdr.WA;
            switch band_inverse
                case 0
                    WAdata.readimg();
                case 1
                    WAdata.readimgi();
                otherwise
                    error('Invalid BAND_INVERSE=%d',band_inverse);
            end
            
            % 
            [interp_wave]  = crism_adrvs_artifact_interp_wave();
            [interp_bands] = crism_lookupwv(interp_wave,WAdata.img);
            interp_bands   = sort(interp_bands,1);
        end
        
    end
end