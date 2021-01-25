classdef CRISMdata < ENVIRasterMultBand
    %CRISMdata class
    %   For any type of CRISM data (EDR,CDR,TRDR,TER,...)
    
    properties
        lblpath;
        tabpath;
        lbl;
        tab;
        hkt;
        ROWNUM_TABLE;
        wv;
        wa = [];
        BP = [];
        GP = [];
        BP1nan = [];
        GP1nan = [];
        is_wa_band_inverse = false;
        is_bp1nan_inverse  = false;
        is_gp1nan_inverse  = false;
        basenameHKT
        cdr;
        source_obs;
        basenamesCDR = [];
        basenames_SOURCE_OBS = [];
        dir_cdr = [];
        dir_SOURCE_OBS = [];
        isimg = false;
        istab = false;
        missing_constant_img = 65535;
        missing_constant_tab = 65535;
        atf = [];
        prop = [];
        data_type = [];
        yyyy_doy = '';
        dirname = '';
    end
    
    methods
        function obj = CRISMdata(basename,dirpath,varargin)
            % load property and find out the type of data from "basename"
            if ~isempty(getProp_basenameOBSERVATION(basename))
                prop = getProp_basenameOBSERVATION(basename);
                data_type = 'OBSERVATION';
            elseif ~isempty(getProp_basenameCDR4(basename))
                prop = getProp_basenameCDR4(basename);
                data_type = 'CDR4';
            elseif ~isempty(getProp_basenameCDR6(basename))
                prop = getProp_basenameCDR6(basename);
                data_type = 'CDR6';
            elseif ~isempty(getProp_basenameOTT(basename))
                prop = getProp_basenameOTT(basename);
                data_type = 'OTT';
            elseif ~isempty(getProp_basenameADRVS(basename))
                prop = getProp_basenameADRVS(basename);
                data_type = 'ADR_VS';
            end
            % find out yyyy_doy and dirname
            switch upper(data_type)
                case 'OBSERVATION'
                    [dirpath_guess,~,~,yyyy_doy,dirname] = get_dirpath_observation(basename);
                    prop.yyyy_doy = yyyy_doy;
                case {'CDR4','CDR6'}
                    [dirpath_guess,~,~,yyyy_doy,dirname] = get_dirpath_cdr(basename);
                case {'OTT'}
                    [dirpath_guess,~,~] = get_dirpath_ott();
                    yyyy_doy = '';
                    dirname = '';
                case {'ADR_VS'}
                    [dirpath_guess,~,dirname] = get_dirpath_adrvs(basename);
                    yyyy_doy = '';
                otherwise
                    error('Undefined data_type %s',data_type);
            end
            % get dirpath if not specified
            if isempty(dirpath)
                dirpath = dirpath_guess;
            end
            
            obj@ENVIRasterMultBand(basename,dirpath,varargin{:});
            [obj.lblpath] = guessCRISMLBLPATH(basename,dirpath,varargin{:});
            [obj.tabpath] = guessCRISMTABPATH(basename,dirpath,varargin{:});
            readlblhdr(obj);
            
            obj.prop = prop;
            obj.data_type = data_type;
            obj.yyyy_doy = yyyy_doy;
            obj.dirname = dirname;
            
            
        end
        
        function [img_flip] = img_flip_band(obj)
            if ~isempty(obj.img)
                img_flip = flip(obj.img,3);
            end
            if nargout < 1
                % flip boolean
                obj.img = img_flip;
                obj.is_img_band_inverse = logical(1-obj.is_img_band_inverse);
            end
        end
            
        
        function [] = readlblhdr(obj)
            if ~isempty(obj.lblpath)
                obj.lbl = pds3lblread(obj.lblpath);
                obj.hdr = crism_lbl2hdr(obj.lbl,...
                    'missing_constant',obj.missing_constant_img);
            elseif ~isempty(obj.hdrpath)
                obj.lbl = [];
                obj.hdr = envihdrreadx(obj.hdrpath);
            else
                obj.lbl = [];
                obj.hdr = [];
%                 fprintf('"%s" does not exist.\n',joinPath(dirpath_acro, [basename_acro '.LBL/HDR']));
            end
        end
        
        function [rownum_table] = read_ROWNUM_TABLE(obj)
            [ rownum_table ] = crismrownumtableread( obj.imgpath,obj.lbl );
            obj.ROWNUM_TABLE = rownum_table;
        end

        function [tab] = readTAB(obj)
            [ tab ] = crismTABread( obj.dirpath, obj.lbl );
            if isempty(tab)
                fprintf('no tab is found');
            end
            obj.tab = tab;
        end
        
        function [tab] = readTERWVTAB(obj)
            [ tab ] = crismTERWVTABread( obj.dirpath, obj.lbl );
            if isempty(tab)
                fprintf('no tab is found');
            end
            obj.tab = tab;
        end
        
        function [hkt] = readHKT(obj)
            [ hkt ] = crismHKTread( obj.dirpath, obj.lbl );
            if isempty(hkt)
                fprintf('no tab is found');
            end
            obj.hkt = hkt;
        end
        
        function [] = load_basenamesCDR(obj,varargin)
            if isempty(obj.lbl)
                error('no LBL file');
            end
            obj.basenamesCDR = readCDRnames_v2(obj.lbl);
            if ~isempty(obj.basenamesCDR)
                [obj.dir_cdr] = finddirdownloadCDR_v3(...
                    obj.basenamesCDR,varargin{:});
            end

        end
        
        function [cdr] = readCDR(obj,acro)
            if iscell(obj.basenamesCDR.(acro))
                % cdr = cell(1,length(obj.basenamesCDR.(acro)));
                cdr = CRISMdata.empty(0,0);
                for i=1:length(obj.basenamesCDR.(acro))
                    basename_acro = obj.basenamesCDR.(acro){i};
                    dirpath_acro = obj.dir_cdr.(acro){i};
                    data = CRISMdata(basename_acro,dirpath_acro);
                    % cdr{i} = data;
                    cdr = [cdr data];
                end
                obj.cdr.(acro) = cdr;
            else
                basename_acro = obj.basenamesCDR.(acro);
                dirpath_acro = obj.dir_cdr.(acro);
                data = CRISMdata(basename_acro,dirpath_acro);
                cdr = data;
                obj.cdr.(acro) = cdr;
            end 
        end
        
        function [] = load_basenames_SOURCE_OBS(obj,varargin)
            if isempty(obj.lbl)
                error('no LBL file');
            end
            [source_basenames] = read_SOURCE_OBS_basenames(obj.lbl);
            obj.basenames_SOURCE_OBS = source_basenames;
            obj.dir_SOURCE_OBS = finddirdownload_SOURCE_OBS(...
                obj.basenames_SOURCE_OBS,varargin{:});

        end
        
        function [source_obs] = read_SOURCE_OBS(obj,actID)
            if iscell(obj.basenames_SOURCE_OBS.(actID))
                %source_obs = cell(1,length(obj.basenames_SOURCE_OBS.(actID)));
                source_obs = CRISMdata.empty(0,0);
                for i=1:length(obj.basenames_SOURCE_OBS.(actID))
                    basename_acro = obj.basenames_SOURCE_OBS.(actID){i};
                    dirpath_acro = obj.dir_SOURCE_OBS.(actID){i};
                    data = CRISMdata(basename_acro,dirpath_acro);
                    %source_obs{i} = data;
                    source_obs = [source_obs data];
                end
                obj.source_obs.(actID) = source_obs;
            else
                basename_acro = obj.basenames_SOURCE_OBS.(actID);
                dirpath_acro = obj.dir_SOURCE_OBS.(actID);
                data = CRISMdata(basename_acro,dirpath_acro);
                source_obs = data;
                obj.source_obs.(actID) = source_obs;
            end 
        end
        
        function [sclk,p] = get_sclk_start(obj)
            sclkstr = obj.lbl.SPACECRAFT_CLOCK_START_COUNT;
            sclk = sscanf(sclkstr,'%d/%f');
            p = sclk(1);
            sclk = sclk(2);
        end
            
        function [sclk,p] = get_sclk_stop(obj)
            sclkstr = obj.lbl.SPACECRAFT_CLOCK_STOP_COUNT;
            sclk = sscanf(sclkstr,'%d/%f');
            p = sclk(1);
            sclk = sclk(2);
        end
        
        function [obs_id] = get_obsid(obj)
            obs_id = obj.lbl.OBSERVATION_ID(4:11);
        end
        function [obs_number] = get_obs_number(obj)
            obs_number = obj.lbl.MRO_OBSERVATION_NUMBER(4:5);
        end
        
        function [prop] = get_basenameProp(obj)
            prop = getProp_basenameOBSERVATION(obj.basename);
        end
        
        function [yyyy_doy] = get_YYYY_DOY(obj)
            obs_id = obj.get_obsid();
            yyyy_doy = searchOBSID2YYYY_DOY(obs_id);
        end
        
        function [atf] = readATF(obj,varargin)
            atf = [];
            prop = obj.get_basenameProp();
            [yyyy_doy] = obj.get_YYYY_DOY();
            [atf_parent] = crismCDRATFread(yyyy_doy,prop.sensor_id,varargin{:});
            prop.yyyy_doy = yyyy_doy;
            entry_atf = get_entryATF_fromProp(prop);
            [v,i] = searchby('SCENE_EDR_NAME',entry_atf,atf_parent.tab.data,'COMP_FUNC','regexpi');
            fldnms = fieldnames(v);
            for j=1:length(fldnms)
                fldnm = fldnms{j}; entry_atf = v.(fldnm);
                prop_atf = entryATF2prop(entry_atf);
                if isempty(prop_atf)
                    atf.(fldnm) = '';
                else
                    prop_atf.product_type = 'EDR';
                    basenamePtr = get_basenameOBS_fromProp(prop_atf);
                    [dirpath,remote_subdir] = get_dirpath_observation_fromProp(prop_atf,varargin{:});
                    basename = readDownloadBasename_v3(basenamePtr,dirpath,remote_subdir,varargin{:});
                    atf.(fldnm) = basename;
                end
            end
            obj.atf = atf;
        end
        
        function [wa] = readWA(obj,varargin)
            if isempty(obj.basenamesCDR) || isempty(obj.dir_cdr) 
                cdr_basename = readWASBbasename(obj.lbl);
                obj.basenamesCDR = cdr_basename;
                [obj.dir_cdr] = finddirdownloadCDR_v3(obj.basenamesCDR,varargin{:});
            end
            obj.readCDR('WA');
            wa = obj.cdr.WA.readimg();
            wa = squeeze(wa)';
            if nargout<1
                obj.wa = wa;
                obj.is_wa_band_inverse = false;
            end
        end
        
        function [wa] = readWAi(obj)
            wa = obj.readWA();
            wa = flip(wa,1);
            if nargout<1
                obj.wa = wa;
                obj.is_wa_band_inverse = true;
            end
        end
        function [] = show_SOURCE_PRODUCT_ID(obj)
            for i=1:length(obj.lbl.SOURCE_PRODUCT_ID)
                fprintf('%s\n',obj.lbl.SOURCE_PRODUCT_ID{i});
            end
        end
        
        function setBP1nan(obj,BP1nan,is_bp1nan_inverse)
            obj.BP1nan = BP1nan;
            obj.is_bp1nan_inverse = is_bp1nan_inverse;
        end
        
        function setGP1nan(obj,GP1nan,is_gp1nan_inverse)
            obj.GP1nan = GP1nan;
            obj.is_gp1nan_inverse = is_gp1nan_inverse;
        end
        
        function [] = loadBPGP1nan(obj)
            [BPdata1,BPdata2,BPdata_post] = load_BPdata(obj);
            BPall1nan = formatBP1nan(BPdata_post,'band_inverse',true);
            obj.is_bp1nan_inverse = true;
            obj.BP1nan = BPall1nan;
            GPall1nan = convertBP1nan2GP1nan(BPall1nan);
            obj.GP1nan = GPall1nan;
            obj.is_gp1nan_inverse = true;
        end
        
        function [] = download(obj,dwld,varargin)
            switch upper(obj.data_type)
                case 'OBSERVATION'
                    get_dirpath_observation(obj.basename,'Download',dwld,varargin{:});
                    if ~isempty(obj.lbl) && any(strcmpi(obj.prop.product_type,{'EDR','TRR'}))
                        if isempty(obj.basenameHKT)
                            obj.load_basenameHKT();
                        end
                        if ~isempty(obj.basenameHKT)
                            get_dirpath_observation(obj.basenameHKT,'Download',dwld,varargin{:});
                        end
                    end
                case {'CDR4','CDR6'}
                    get_dirpath_cdr(obj.basename,'Download',dwld,varargin{:});
                otherwise
                    error('Undefined data_type %s',obj.data_type);
            end
            get_dirpath_observation(obj.basename,'Download',dwld,varargin{:});
        end
        
        function load_basenameHKT(obj)
            [ obj.basenameHKT ] = get_basenameHKT( obj.lbl );
                
        end
        
        function delete(obj)
            % if ~isempty(obj.cdr)
            %     fldnms = fieldnames(obj.cdr);
            %     for i=1:length(fldnms)
            %         for j=1:length(obj.cdr.(fldnms{i}))
            %             delete(obj.cdr.(fldnms{i})(j));
            %         end
            %     end
            % end
        end
        
    end
    
end
