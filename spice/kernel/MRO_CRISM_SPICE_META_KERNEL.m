classdef MRO_CRISM_SPICE_META_KERNEL < handle
    % MRO_CRISM_SPICE_META_KERNEL
    %   
    
    properties
        sclk
        fk
        ik
        lsk
        pck
        spk_de
        spk_sc
        ck_sc
        ck_crism
        src
        DEdata
        diropt
    end
    
    methods
        function obj = MRO_CRISM_SPICE_META_KERNEL(DEdata)
            spice_krnls = crism_organize_source_spice_kernel( ...
                DEdata.lbl.SOURCE_PRODUCT_ID);
            obj.DEdata = DEdata;
            obj.src    = spice_krnls;
            obj.set_default_diropt();
        end

        % furnshing and unloading of spice kernels.
        function furnsh(obj)
            obj.sclk.furnsh();
            obj.fk.furnsh();
            obj.ik.furnsh();
            obj.lsk.furnsh();
            obj.pck.furnsh();
            obj.spk_de.furnsh();
            obj.spk_sc.furnsh();
            obj.ck_sc.furnsh();
            obj.ck_crism.furnsh();
        end
        function unload(obj,varargin)
            obj.sclk.unload(varargin{:});
            obj.fk.unload(varargin{:});
            obj.ik.unload(varargin{:});
            obj.lsk.unload(varargin{:});
            obj.pck.unload(varargin{:});
            obj.spk_de.unload(varargin{:});
            obj.spk_sc.unload(varargin{:});
            obj.ck_sc.unload(varargin{:});
            obj.ck_crism.unload(varargin{:});
        end
        
        %% 
        %==================================================================
        % default kernel loading methods
        function set_default_diropt(obj)
            global spicekrnl_env_vars
            switch lower(spicekrnl_env_vars.local_fldsys)
                case 'crismlnx'
                    obj.diropt.sclk = 'NAIF';
                    obj.diropt.fk   = 'NAIF';
                    obj.diropt.ik   = 'NAIF';
                    obj.diropt.lsk  = 'NAIF';
                    obj.diropt.pck  = 'NAIF';
                    obj.diropt.spk_de   = 'CRISM';
                    obj.diropt.spk_sc   = 'NAIF';
                    obj.diropt.ck_sc    = 'NAIF';
                    obj.diropt.ck_crism = 'NAIF';
                case 'naif'
                    obj.diropt.sclk = 'PDS';
                    obj.diropt.fk   = 'PDS';
                    obj.diropt.ik   = 'PDS';
                    obj.diropt.lsk  = 'PDS';
                    obj.diropt.pck  = 'PDS';
                    obj.diropt.spk_de   = 'PDS';
                    obj.diropt.spk_sc   = 'PDS';
                    obj.diropt.ck_sc    = 'PDS';
                    obj.diropt.ck_crism = 'PDS';
                otherwise
                    error('Undefined folder system: %s',spicekrnl_env_vars.local_fldsys);
            end
        end


        function set_defaut(obj,varargin)
            obj.set_kernel_sclk_default(varargin{:});
            obj.set_kernel_fk_default(varargin{:});
            obj.set_kernel_ik_default(varargin{:});
            obj.set_kernel_lsk_default(varargin{:});
            obj.set_kernel_pck_default(varargin{:});
            obj.set_kernel_spk_de_default(varargin{:});
            obj.set_kernel_spk_sc_default(varargin{:});
            obj.set_kernel_ck_sc_default(varargin{:});
            obj.set_kernel_ck_crism_default(varargin{:});
        end
        
        % sclk
        function set_kernel_sclk_default(obj,varargin)
            obj.set_kernel_sclk(obj.diropt.sclk,'FileName',obj.src.sclk,varargin{:});
        end
        
        % fk
        function set_kernel_fk_default(obj,varargin)
            for i=1:length(obj.src.fk)
                fname_fk = obj.src.fk{i};
                if strcmpi(fname_fk,'MRO_CRISM_FK_0000_000_N_01.TF')
                    fprintf('MRO_CRISM_FK_0000_000_N_01.TF is skipped.\n');
                else
                    obj.set_kernel_fk(obj.diropt.fk,'FileName',fname_fk,varargin{:});
                end
            end
        end
        
        % ik
        function set_kernel_ik_default(obj,varargin)
            if ischar(obj.src.ik)
                fname_ik = obj.src.ik;
                if strcmpi(fname_ik,'MRO_CRISM_IK_0000_000_N_10.TI')
                    fprintf('MRO_CRISM_IK_0000_000_N_10.TI is skipped.\n');
                end
                obj.set_kernel_ik(obj.diropt.ik,varargin{:});
            else
                error('The number of ik kernel is more than one');
            end
        end
        
        % lsk
        function set_kernel_lsk_default(obj,varargin)
            obj.set_kernel_lsk(obj.diropt.lsk,'FileName',obj.src.lsk,varargin{:});
        end
        
        % pck
        function set_kernel_pck_default(obj,varargin)
            obj.set_kernel_pck(obj.diropt.pck,'FileName',obj.src.pck,varargin{:});
        end
        
        % spk de
        function set_kernel_spk_de_default(obj,varargin)
            fname_spk_de = [];
            for i=1:length(obj.src.spk)
                fname_spk = obj.src.spk{i};
                if ~isempty(regexpi(fname_spk,'de\d+.*','once'))
                    if isempty(fname_spk_de)
                        fname_spk_de = fname_spk;
                    else
                        fname_spk_de = [fname_spk_de fname_spk];
                    end
                end
            end
            if ischar(fname_spk_de)
                obj.set_kernel_spk_de(obj.diropt.spk_de,'FileName',fname_spk_de,varargin{:});
            else
                error('Multiple spk de files are detected');
            end
        end
        
        % spk sc
        function set_kernel_spk_sc_default(obj,varargin)
            strt_time = datetime(obj.DEdata.lbl.START_TIME, ...
                'InputFormat','yyyy-MM-dd''T''HH:mm:ss.SSS');
            end_time = datetime(obj.DEdata.lbl.STOP_TIME, ...
                'InputFormat','yyyy-MM-dd''T''HH:mm:ss.SSS');
            obj.set_kernel_spk_sc(strt_time, end_time,obj.diropt.spk_sc,varargin{:});
        end
        
        % ck sc
        function set_kernel_ck_sc_default(obj,varargin)
            obj.set_kernel_ck_sc(obj.src.ck,obj.diropt.ck_sc,varargin{:});
        end
        
        % ck crism
        function set_kernel_ck_crism_default(obj,varargin)
            obj.set_kernel_ck_crism(obj.src.ck,obj.diropt.ck_crism,varargin{:});
        end
        
        %% 
        %==================================================================
        % base kernel loading methods
        
        % sclk
        function set_kernel_sclk(obj,varargin)
            [fname_sclk_out,dirpath] = spice_get_mro_kernel_sclk( ...
                varargin{:},'ext','all');
            obj.sclk = MRO_CRISM_SPICE_KERNEL(fname_sclk_out,dirpath);
            fprintf('Selected %-30s in %s\n',obj.sclk.fname_krnl,dirpath);
        end
        
        % fk
        function set_kernel_fk(obj,varargin)
            [fname_fk_out,dirpath] = spice_get_mro_kernel_fk(varargin{:},'ext','all');
            obj.fk = MRO_CRISM_SPICE_KERNEL(fname_fk_out,dirpath);
            fprintf('Selected %-30s in %s\n',obj.fk.fname_krnl,dirpath);
        end
        
        % ik
        function set_kernel_ik(obj,varargin)
            [fname_ik_out,dirpath] = spice_get_mro_crism_kernel_ik(varargin{:},'ext','all');
            obj.ik = MRO_CRISM_SPICE_KERNEL(fname_ik_out,dirpath);
            fprintf('Selected %-30s in %s\n',obj.ik.fname_krnl,dirpath);
        end
        
        % lsk
        function set_kernel_lsk(obj,varargin)
            [fname_lsk_out,dirpath] = spice_get_mro_kernel_lsk(varargin{:},'ext','all');
            obj.lsk = MRO_CRISM_SPICE_KERNEL(fname_lsk_out,dirpath);
            fprintf('Selected %-30s in %s\n',obj.lsk.fname_krnl,dirpath);
        end
        
        % pck
        function set_kernel_pck(obj,varargin)
            [fname_pck_out,dirpath] = spice_get_mro_kernel_pck(varargin{:},'ext','all');
            obj.pck = MRO_CRISM_SPICE_KERNEL(fname_pck_out,dirpath);
            fprintf('Selected %-30s in %s\n',obj.pck.fname_krnl,dirpath);
        end
        
        % spk de
        function set_kernel_spk_de(obj,varargin)
            [fname_spkde_out,dirpath] = spice_get_mro_kernel_spk_de(varargin{:},'ext','all');
            obj.spk_de = MRO_CRISM_SPICE_KERNEL(fname_spkde_out,dirpath);
            fprintf('Selected %-30s in %s\n',obj.spk_de.fname_krnl,dirpath);
        end
        
        % spk sc
        function set_kernel_spk_sc(obj,varargin)
            [fname_spk_out,dirpath] = spice_get_mro_kernel_spk_sc_wOrdr(varargin{:},'ext','all');
            obj.spk_sc = MRO_CRISM_SPICE_KERNEL(fname_spk_out,dirpath);
            if ischar(obj.spk_sc.fname_krnl)
                fprintf('Selected %-30s in %s\n',obj.spk_sc.fname_krnl, dirpath);
            elseif iscell(obj.spk_sc.fname_krnl)
                for i=1:length(obj.spk_sc.fname_krnl)
                    fprintf('Selected %-30s in %s\n',obj.spk_sc.fname_krnl{i},dirpath);
                end
            end
                
        end
        
        % ck sc
        function set_kernel_ck_sc(obj,varargin)
            [fname_ck_sc_out,dirpath] = spice_get_mro_kernel_ck_sc(varargin{:},'ext','all');
            obj.ck_sc = MRO_CRISM_SPICE_KERNEL(fname_ck_sc_out,dirpath);
            if ischar(obj.ck_sc.fname_krnl)
                fprintf('Selected %-30s in %s\n',obj.ck_sc.fname_krnl,dirpath);
            elseif iscell(obj.ck_sc.fname_krnl)
                for i=1:length(obj.ck_sc.fname_krnl)
                    fprintf('Selected %-30s in %s\n',obj.ck_sc.fname_krnl{i},dirpath);
                end
            end
        end
        
        % ck crism
        function set_kernel_ck_crism(obj,varargin)    
            [fname_ck_crism_out,dirpath] = spice_get_mro_kernel_ck_crism(varargin{:},'ext','all');
            obj.ck_crism = MRO_CRISM_SPICE_KERNEL(fname_ck_crism_out,dirpath);
            if ischar(obj.ck_crism.fname_krnl)
                fprintf('Selected %-30s in %s\n',obj.ck_crism.fname_krnl, dirpath);
            elseif iscell(obj.ck_crism.fname_krnl)
                for i=1:length(obj.ck_crism.fname_krnl)
                    fprintf('Selected %-30s in %s\n',obj.ck_crism.fname_krnl{i}, dirpath);
                end
            end
        end
        
    end
end

