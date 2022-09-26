classdef CRISMDDRdata < CRISMdata
    %UNTITLED8 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ddr
    end
    
    methods 
        function [obj] = CRISMDDRdata(basename,dirpath)
            obj@CRISMdata(basename,dirpath,'OBSERVATION');
        end
        function [ddr] = readimg(obj,varargin)
            img1 = readimg@CRISMdata(obj,varargin{:});
            % img1 = envidataread_v2(obj.imgpath,obj.hdr);
            img1(img1==obj.missing_constant_img) = nan;
            
            bandnames = obj.hdr.band_names;
            for i=1:length(bandnames)
                bandname = bandnames{i};
                bandname = strsplit(bandname,',');
                fld = strtrim(bandname{1});
                if length(bandname)>1
                    unit = strtrim(bandname{2});
                end
                fld = strrep(fld,' ','_');
                ddr.(fld).img = img1(:,:,i);
                ddr.(fld).unit = unit;
            end
            
            if nargout<1
                obj.ddr = ddr;
            end
            
        end
    end
end