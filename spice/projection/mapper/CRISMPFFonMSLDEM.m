classdef CRISMPFFonMSLDEM < handle
    % CRISMPFFonMSLDEM
    %   CLASS handling CRISM Pixel Footprint Function defined on MSLDEM
    %  
    
    properties
        basename_com
        dirpath
        sample_offset % [L_crm x S_crm] (l,s) element is the sample offset of PFF at (s,l)
        line_offset   % [L_crm x S_crm] (l,s) element is the line offset of PFF at (s,l)
        samples       % [L_crm x S_crm] (l,s) element is the number of samples of PFF at (s,l)
        lines         % [L_crm x S_crm] (l,s) element is the number of lines of PFF at (s,l)
        MSLDEMdata
        proj_info
    end
    
    methods
        function obj = CRISMPFFonMSLDEM(basename_com,dirpath,MSLDEMdata)
            %
            obj.basename_com = basename_com;
            obj.dirpath      = dirpath;
            obj.MSLDEMdata   = MSLDEMdata;
            obj.proj_info    = obj.MSLDEMdata.proj_info;
            
            
            fname_meta = sprintf('%s_SLM.mat',basename_com);
            fpath = joinPath(dirpath,fname_meta);
            if ~exist(fpath,'file')
                error('%s does not exist.',fpath);
            end
            load(fpath,'crismPxl_lofst','crismPxl_sofst','crismPxl_smpls','crismPxl_lines');
            obj.sample_offset = crismPxl_sofst;
            obj.line_offset   = crismPxl_lofst;
            obj.samples = crismPxl_smpls;
            obj.lines   = crismPxl_lines;
            
        end
        
        function [pffcl,srange,lrange] = getPFF(obj,x_crm,y_crm,varargin)
            % [pffcl,srange,lrange] = getPFF(obj,x_crm,y_crm)
            % [pffcl,srange,lrange] = getPFF(obj,x_crm,y_crm,xy_coord)
            %   xy_coord can be {'NE','LATLON'}
            %  Get PFF for the given CRISM pixel (x_crm,y_crm)
            % INPUTS
            %  x_crm: sample index of the crism image for which footprint are read
            %  y_crm: line index of the crism image for which footprint are read
            % OUTPUTS
            %  pffcl: cell array of the PFF at (x_crm,y_crm)
            %  srange: [1x2], the sample range of the PFF in the MSLDEM pixel coordinate
            %  lrange: [1x2], the line range of the PFF in the MSLDEM pixel coordinate
            % 
            
            % Read the file to get PFF at (x_crm,y_crm)
            bname = sprintf('%s_l%03d',obj.basename_com,y_crm);
            fpath = joinPath(obj.dirpath,[bname '.mat']);
            load(fpath,'crism_FOVcell_lcomb');
            pffcl = crism_FOVcell_lcomb{x_crm};
            
            % Set up their sample line range on MSLDEM
            if obj.samples(y_crm,x_crm)>0
                s1 = obj.sample_offset(y_crm,x_crm)+1;
                send = obj.sample_offset(y_crm,x_crm)+obj.samples(y_crm,x_crm);
                l1 = obj.line_offset(y_crm,x_crm)+1;
                lend = obj.line_offset(y_crm,x_crm)+obj.lines(y_crm,x_crm);
                srange = [s1 send];
                lrange = [l1 lend];

                if ~isempty(varargin)
                    xy_coord = varargin{1};
                    switch upper(xy_coord)
                        case 'PIXEL'
                        case 'NE'
                            srange = obj.MSLDEMdata.easting(double(srange));
                            lrange = obj.MSLDEMdata.northing(double(lrange));
                        case 'LATLON'
                            srange = obj.MSLDEMdata.longitude(double(srange));
                            lrange = obj.MSLDEMdata.latitude(double(lrange));
                        otherwise
                            error('Undefined xy_coord %s',xy_coord);
                    end
                end
            else
                srange = []; lrange = [];
            end
            
        end
        
        function [pffclx,srange,lrange] = getPFFx(obj,x_crm,y_crm,varargin)
            [pffclx,srange,lrange] = crismPFFonMSLDEM_getPFFx(obj,x_crm,y_crm,varargin{:});
        end
        
        function [pffcelll,srange,lrange] = getPFFl(obj,y_crm)
            % [pffcl,srange,lrange] = getPFF(obj,y_crm)
            % Get PFF for the given CRISM line.
            % INPUTS
            %  y_crm: line index of the crism image for which footprint are read
            % OUTPUTS
            %  pffcelll: cell array of the PFF
            %  srange: [#columns,2], each row is the sample range of the PFF
            %  in the MSLDEM pixel coordinate
            %  lrange: [#columns,2], each row is the line range of the PFF
            %  in the MSLDEM pixel coordinate
            
            % Read the file to get PFF at (x_crm,y_crm)
            bname = sprintf('%s_l%03d',obj.basename_com,y_crm);
            fpath = joinPath(obj.dirpath,[bname '.mat']);
            load(fpath,'crism_FOVcell_lcomb');
            pffcelll = crism_FOVcell_lcomb;
            
            % Set up their sample line range on MSLDEM
            s1 = obj.sample_offset(y_crm,:)+1;
            send = obj.sample_offset(y_crm,:)+obj.samples(y_crm,:);
            l1 = obj.line_offset(y_crm,:)+1;
            lend = obj.line_offset(y_crm,:)+obj.lines(y_crm,:);
            srange = [s1 send];
            lrange = [l1 lend];
            
        end
        
        function [sl_crm,pffcell,srange,lrange] = getPFFbyMSLDEMxy(obj,x_dem,y_dem,varargin)
            % [sl_crm,pffcell,srange,lrange] = getPFFbyMSLDEMxy(obj,x_dem,y_dem)
            % [sl_crm,pffcell,srange,lrange] = getPFFbyMSLDEMxy(obj,x_dem,y_dem,varargin)
            % Get PFF that has valid values at (x_dem,y_dem) in the MSLDEM
            % pixel coordinate system.
            % INPUTS
            %  x_dem: sample index of the MSLDEM image for which footprint is obtained.
            %  y_dem: line index of the MSLDEM image for which footprint is obtained.
            % OUTPUTS
            %  sl_crm: [* x 2] sample and line in CRISM image coordinate
            %  pffcell: cell array of PFF corresponding to each row of
            %  sl_crm
            %  srange: [#columns,2], each row is the sample range of the PFF
            %  in the MSLDEM coordinate (can be 'NE','LATLON','PIXEL')
            %  lrange: [#columns,2], each row is the line range of the PFF
            %  in the MSLDEM coordinate (can be 'NE','LATLON','PIXEL')
            % OPTIONAL Parameters
            %  "XY_COORDINATE" {'NE','LATLON','PIXEL'}
            %     (default) 'PIXEL'
            %  "THRESHOLD": numeric or "MAX"
            %   the value of PFF larger than this is considered as valid.
            %   With "MAX", only the PFF with maximum reponse is retrieved.
            %     (default) 0.5
            [sl_crm,pffcell,srange,lrange] = mapper_msldem2crism_get_crismFOVcell( ...
                x_dem,y_dem,obj,varargin{:});
        end
        
        function [sl_crm,pffcell,srange,lrange] = getPFFbylatlon(obj,lon,lat,varargin)
            x_dem = round(obj.MSLDEMdata.lon2x(lon));
            y_dem = round(obj.MSLDEMdata.lat2y(lat));
            [sl_crm,pffcell,srange,lrange] = getPFFbyMSLDEMxy(obj, ...
                x_dem,y_dem,'XY_COORDINATE','LATLON',varargin{:});
        end
        function [sl_crm,pffcell,srange,lrange] = getPFFbyNE(obj,easting,northing,varargin)
            x_dem = round(obj.MSLDEMdata.easting2x(easting));
            y_dem = round(obj.MSLDEMdata.northing2y(northing));
            [sl_crm,pffcell,srange,lrange] = getPFFbyMSLDEMxy(obj, ...
                x_dem,y_dem,'XY_COORDINATE','NE',varargin{:});
        end
        
        function [msldemc_hdr,msldemc_imFOVres,msldemc_imFOVsmpl,msldemc_imFOVline] ...
                = getGLT(obj,line_offset,Nlines)
            [msldemc_hdr,msldemc_imFOVres,msldemc_imFOVsmpl,msldemc_imFOVline] ...
                = crism_combine_FOVcell_PSF_multiPxl_v3(  ...
                obj.basename, obj.dirpath, line_offset, Nlines, ...
                obj.sample_ofst, obj.samples, obj.line_offset, obj.lines);
        end
        
    end
end

