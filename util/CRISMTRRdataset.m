classdef CRISMTRRdataset < dynamicprops
    % SABCONDdataset
    %   Container for the output of the sabcond correction. 
    
    properties
        basename_trr3if
        dirpath
        trr3if
        trr3ra
        trr3raif
        trrbif
        trrcif
        trrdif
        catif
        catraif
        data_prop_names
    end
    
    methods
        function obj = CRISMTRRdataset(basename_trr3if,dirpath,varargin)
            % Constructor
            global crism_env_vars
            pdirpath_trrx = crism_env_vars.dir_YUK;
            if (rem(length(varargin),2)==1)
                error('Optional parameters should always go by pairs');
            else
                for i=1:2:(length(varargin)-1)
                    switch upper(varargin{i})
                        case 'PDIRPATH_TRRX'
                            pdirpath_trrx = varargin{i+1};
                        otherwise
                            error('Unrecognized option: %s',varargin{i});
                    end
                end
            end
            
            % Error handling
            prop_trr3if = crism_getProp_basenameOBSERVATION(basename_trr3if);
            if isempty(prop_trr3if)
                error('Input basename_trr3if %s is invalid',basename_trr3if);
            elseif ~strcmpi(prop_trr3if.activity_id,'IF')
                error('Input basename_trr3if %s is not for I/F',basename_trr3if);
            end
            
            TRR3IFdata = CRISMdata(basename_trr3if,dirpath);
            TRR3IFdata.load_basenamesCDR();
            % In case dirpath is guessed
            obj.basename_trr3if = TRR3IFdata.basename;
            obj.dirpath = TRR3IFdata.dirpath;
            obj.trr3if = TRR3IFdata;
            
            % Stock different kinds of processed images
            % RA and RA_IF
            prop_ra = TRR3IFdata.prop;
            prop_ra.activity_id = 'RA';
            basename_ra = crism_get_basenameOBS_fromProp(prop_ra);
            obj.append('trr3ra',basename_ra,TRR3IFdata.dirpath);
            obj.appendCAT('trr3raif',basename_ra,TRR3IFdata.dirpath,'IF');
            
            % trrb trrc trrd I/F
            dir_trrx = joinPath(pdirpath_trrx, TRR3IFdata.yyyy_doy, TRR3IFdata.dirname);
            [basename_trrbif] = crism_get_TRRXbasename(TRR3IFdata,'B');
            obj.append('trrbif',basename_trrbif,dir_trrx);
            [basename_trrcif] = crism_get_TRRXbasename(TRR3IFdata,'C');
            obj.append('trrcif',basename_trrcif,dir_trrx);
            [basename_trrdif] = crism_get_TRRXbasename(TRR3IFdata,'D');
            obj.append('trrdif',basename_trrdif,dir_trrx);
            
            % CAT corrected images
            phot = 0; atmt_src = 'trial'; bandset_id = 'mcg'; enable_artifact = 1;
            acro_catatp = sprintf('corr_phot%d_%s_%s_a%d',phot,atmt_src,bandset_id,enable_artifact);
            obj.appendCAT('catif',TRR3IFdata.basename,TRR3IFdata.dirpath,acro_catatp);
            obj.appendCAT('catraif',[basename_ra '_IF'],TRR3IFdata.dirpath,acro_catatp);

        end
        
        function append(obj,propName,bname,dirpath)
            if exist(joinPath(dirpath,[bname '.LBL']),'file')
                if ~isprop(obj,propName)
                    addprop(obj,propName);
                end
                obj.(propName) = CRISMdata(bname,dirpath);
                if ~isempty(obj.(propName).lblpath)
                    obj.(propName).readWAi();
                end
                obj.append_data_prop_name(propName);
            end
            
        end
        
        function appendCAT(obj,propName,bname,dirpath,suffix_a)
            if isempty(suffix_a)
                basename_a = bname;
            else
                basename_a = [bname '_' suffix_a];
            end
            if exist(joinPath(dirpath,[basename_a '.img']),'file') && (exist(joinPath(dirpath,[basename_a '.hdr']),'file') || exist(joinPath(dirpath,[basename_a '.img.hdr']),'file'))
                if ~isprop(obj,propName)
                    addprop(obj,propName);
                end
                obj.(propName) = CRISMdataCAT(basename_a,dirpath);
                if ~isempty(obj.(propName).imgpath)
                    obj.(propName).readWAi_fromCRISMdata_parent();
                end
                obj.append_data_prop_name(propName);
            end
            
        end
        
        function append_data_prop_name(obj,propName)
            if isempty(obj.data_prop_names)
                obj.data_prop_names = {propName};
            else
                obj.data_prop_names = [obj.data_prop_names {propName}];
            end
        end
        
        function [] = load_BP(obj,propNames,BPoption)
            [BPdata1,BPdata2,BPdata_post] = load_BPdata(TRRIFdata);
            BPall1nan = formatBP1nan(BPdata_post,'band_inverse',1);
            GPall1nan = convertBP1nan2GP1nan(BPall1nan);
            for i=1:length(propNames)
                propName = propNames{i};
                obj.(propName).setBP1nan(BPall1nan,1);
            end
        end
        
        function delete(obj)
            for i=1:length(obj.data_prop_names)
                obj.delete_HSI(obj.data_prop_names{i});
            end
        end
        
        function delete_HSI(obj,prop)
            if ~isempty(obj.(prop)) && isvalid(obj.(prop))
                delete(obj.(prop));
            end
        end
    end
end