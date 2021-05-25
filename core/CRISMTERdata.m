classdef CRISMTERdata < CRISMdata
    % CRISM TERdata
    %   
    
    properties
        
    end
    
    methods
        function obj = CRISMTERdata(basename,dirpath,varargin)
            obj@CRISMdata(basename,dirpath,varargin{:});
            
            if ~strcmpi(obj.data_type,'OBSERVATION')
                error('Something wrong with basename');
            end

            % perform readlblhdr again to load a correct header
            % information.
            readlblhdr(obj);
            
        end
        
        function [] = readlblhdr(obj)
            % TER image has both lbl and hdr
            obj.lbl = pds3lblread(obj.lblpath);
            p = crism_getProp_basenameOBSERVATION(obj.basename);
            if ~strcmpi(p.activity_id,'WV')
                obj.hdr = envihdrreadx(obj.hdrpath);
                obj.is_hdr_band_inverse = false;
            else
                %obj.hdr = extract_imghdr_from_lbl(obj.lbl);
            end
        end
        
    end
end

