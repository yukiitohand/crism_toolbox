classdef CRISMPFFonMASTCAM < handle
    % CRISMPFFonMSLDEM
    %   CLASS handling CRISM Pixel Footprint Function defined on MSLDEM
    %  
    
    properties
        basename
        dirpath
        PFFcell
        sample_offset % [L_crm x S_crm] (l,s) element is the sample offset of PFF at (s,l)
        line_offset   % [L_crm x S_crm] (l,s) element is the line offset of PFF at (s,l)
        samples       % [L_crm x S_crm] (l,s) element is the number of samples of PFF at (s,l)
        lines         % [L_crm x S_crm] (l,s) element is the number of lines of PFF at (s,l)
        mastcam2crism
        sourceID
        targetID
    end
    
    methods
        function obj = CRISMPFFonMASTCAM(basename,dirpath)
            %
%             obj.basename = basename;
%             obj.dirpath = dirpath;
%             
%             fpath = joinPath(save_dir,basename);
%             if ~exist(fpath,'file')
%                 error('%s does not exist.',fpath);
%             end
%             load(fpath,'smstofst','lmstofst','smplsmst','linesmst','pffcell','sourceID','targetID');
%             obj.sample_offset = smstofst;
%             obj.line_offset   = lmstofst;
%             obj.samples = smplsmst;
%             obj.lines   = linesmst;
%             obj.crism2mastcamPFF = pffcell;
        end
        
        function [pffcl,srange,lrange] = getPFF(obj,x_crm,y_crm)
            % [pffcl,srange,lrange] = getPFF(obj,x_crm,y_crm)
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
            pffcl = obj.PFFcell{y_crm,x_crm};
            
            % Set up their sample line range on MSLDEM
            if obj.samples(y_crm,x_crm)>0
                s1 = obj.sample_offset(y_crm,x_crm)+1;
                send = obj.sample_offset(y_crm,x_crm)+obj.samples(y_crm,x_crm);
                l1 = obj.line_offset(y_crm,x_crm)+1;
                lend = obj.line_offset(y_crm,x_crm)+obj.lines(y_crm,x_crm);
                srange = [s1 send];
                lrange = [l1 lend];
            else
                srange = []; lrange = [];
            end
            
            
        end
        
        function [pffclx,srange,lrange] = getPFFx(obj,x_crm,y_crm,varargin)
            [pffclx,srange,lrange] = crismPFFonMASTCAM_getPFFx(obj,x_crm,y_crm,varargin{:});
        end
        
        function [sl_crm,pffcell,srange,lrange,pffval] = getPFFbyMASTCAMxy(obj,x_mst,y_mst,varargin)
            % [sl_crm,pffcell,srange,lrange] = getPFFbyMASTCAMxy(obj,x_dem,y_dem)
            % [sl_crm,pffcell,srange,lrange] = getPFFbyMASTCAMxy(obj,x_dem,y_dem,varargin)
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
            %  "THRESHOLD": numeric or "MAX"
            %   the value of PFF larger than this is considered as valid.
            %   With "MAX", only the PFF with maximum reponse is retrieved.
            %     (default) 0.5
            [sl_crm,pffcell,srange,lrange,pffval] = mapper_mastcam2crism_get_crismFOVcell( ...
                x_mst,y_mst,obj,varargin{:});
        end
        
    end
end

