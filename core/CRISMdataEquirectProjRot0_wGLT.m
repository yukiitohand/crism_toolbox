classdef CRISMdataEquirectProjRot0_wGLT < ENVIRasterMultBandEquirectProjRot0_wGLT
    % ENVIRasterMultBandEquirectProjRot0_wGLT
    %   Combine HSIdata with GLTdata
    %  Properties
    %   RGBProjImage: class object of RGBImage
    %   ENVIRaster: class object of HSI
    %   GLTdata: class object of HSI
    
    properties
        
    end
    
    methods
        function obj = CRISMdataEquirectProjRot0_wGLT(objRaster,...
                objGLT,varargin)
            obj@ENVIRasterMultBandEquirectProjRot0_wGLT(...
                objRaster,objGLT,varargin{:});
            
            if ~isa(obj.RasterSource,'CRISMdata')
                error('RasterSource needs to be a object of CRISMdata');
            end
        end
        
        
        function [spc,wv,bdxes,xf,yf] = get_spectrum(obj,s,l,varargin)
            ave_wndw_domain = 'PROJECTIVE';
            if (rem(length(varargin),2)==1)
                error('Optional parameters should always go by pairs');
            else
                varargin_rmIdx = [];
                for n=1:2:(length(varargin)-1)
                    switch upper(varargin{n})                        
                        case 'AVERAGE_WINDOW_DOMAIN'
                            ave_wndw_domain = varargin{n+1};
                            varargin_rmIdx = [varargin_rmIdx n n+1];
                    end
                end
                varargin_retIdx = setdiff(1:length(varargin),varargin_rmIdx);
                varargin = varargin(varargin_retIdx);
            end
            
            switch upper(ave_wndw_domain)
                case 'PROJECTIVE'
                    xf = obj.GLTdata.img(l,s,1);
                    yf = obj.GLTdata.img(l,s,2);
                    if obj.isValid_sampleline(xf,yf)
                        [spc,wv,bdxes] = ...
                            get_spectrum_CRISMdataEquirectProjRot0_wGLT(...
                            obj,s,l,varargin{:});
                    else
                        spc = []; wv = []; bdxes = [];
                    end
                case 'SOURCE'
                    xf = obj.GLTdata.img(l,s,1);
                    yf = obj.GLTdata.img(l,s,2);
                    if obj.isValid_sampleline(xf,yf)
                        [spc,wv,bdxes] = ...
                            obj.RasterSource.get_spectrum(s,l,varargin{:});
                    else
                        spc = []; wv = []; bdxes = [];
                    end
                otherwise
                    error('Undefined AVERAGE_DOMAIN %s',ave_wndw_domain);
            end
            
        end
        
    end
end