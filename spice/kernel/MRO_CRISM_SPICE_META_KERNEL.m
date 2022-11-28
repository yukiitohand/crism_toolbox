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
        verbose
        unload_on_delete
    end
    
    methods
        function obj = MRO_CRISM_SPICE_META_KERNEL(DEdata,varargin)
            obj.verbose = true;
            obj.unload_on_delete = true;
            if (rem(length(varargin),2)==1)
                error('Optional parameters should always go by pairs');
            else
                for i=1:2:(length(varargin)-1)
                    switch upper(varargin{i})
                        case 'VERBOSE'
                            obj.verbose = varargin{i+1};
                        case 'UNLOAD_ON_DELETE'
                            obj.unload_on_delete = varargin{i+1};
                        otherwise
                            error('Unrecognized option: %s',varargin{i});
                    end
                end
            end
            spice_krnls = crism_organize_source_spice_kernel( ...
                DEdata.lbl.SOURCE_PRODUCT_ID);
            obj.DEdata = DEdata;
            obj.src    = spice_krnls;
            obj.set_default_diropt();
        end

        % furnshing and unloading of spice kernels.
        function furnsh(obj)
            obj.sclk.furnsh();
            for i=1:length(obj.fk)
                obj.fk(i).furnsh();
            end
            for i=1:length(obj.ik)
                obj.ik(i).furnsh();
            end
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
            obj.diropt = mro_crism_spicekrnl_get_diropt_default();
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
            obj.set_kernel_fk(obj.diropt.fk,'FileName',obj.src.fk,'VERBOSE',obj.verbose,varargin{:});
        end
        
        % ik
        function set_kernel_ik_default(obj,varargin)
            obj.set_kernel_ik(obj.diropt.ik,'FileName',obj.src.ik,'VERBOSE',obj.verbose,varargin{:});
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
                if ~isempty(regexpi(fname_spk,'^de\d+.*','once'))
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
            obj.sclk = MRO_CRISM_SPICE_KERNEL(fname_sclk_out,dirpath, ...
                'UNLOAD_ON_DELETE',obj.unload_on_delete,'verbose',obj.verbose);
            if obj.verbose
                fprintf('Selected %-30s in %s\n',obj.sclk.fname_krnl,dirpath);
            end
        end
        
        % fk
        function set_kernel_fk(obj,varargin)
            obj.fk = [];
            [fname_fk_out,dirpath] = spice_get_mro_kernel_fk(varargin{:},'ext','all');
            if iscell(dirpath)
                for i=1:length(dirpath)
                    obj.fk = [obj.fk MRO_CRISM_SPICE_KERNEL(fname_fk_out{i},dirpath{i}, ...
                        'UNLOAD_ON_DELETE',obj.unload_on_delete,'verbose',obj.verbose)];
                    if obj.verbose
                        fprintf('Selected %-30s in %s\n',fname_fk_out{i},dirpath{i});
                    end
                end
            else
                obj.fk = MRO_CRISM_SPICE_KERNEL(fname_fk_out,dirpath, ...
                    'UNLOAD_ON_DELETE',obj.unload_on_delete,'verbose',obj.verbose);
                if obj.verbose
                    fprintf('Selected %-30s in %s\n',obj.fk.fname_krnl,dirpath);
                end
            end
            
        end
        
        % ik
        function set_kernel_ik(obj,varargin)
            obj.ik = [];
            [fname_ik_out,dirpath] = spice_get_mro_crism_kernel_ik(varargin{:},'ext','all');
            if iscell(dirpath)
                for i=1:length(dirpath)
                    obj.ik = [obj.ik MRO_CRISM_SPICE_KERNEL(fname_ik_out{i},dirpath{i}, ...
                        'UNLOAD_ON_DELETE',obj.unload_on_delete,'verbose',obj.verbose)];
                    if obj.verbose
                        fprintf('Selected %-30s in %s\n',fname_ik_out{i},dirpath{i});
                    end
                end
            else
                obj.ik = MRO_CRISM_SPICE_KERNEL(fname_ik_out,dirpath, ...
                    'UNLOAD_ON_DELETE',obj.unload_on_delete,'verbose',obj.verbose);
                if obj.verbose
                    fprintf('Selected %-30s in %s\n',obj.ik.fname_krnl,dirpath);
                end
            end
        end
        
        % lsk
        function set_kernel_lsk(obj,varargin)
            [fname_lsk_out,dirpath] = spice_get_mro_kernel_lsk(varargin{:},'ext','all');
            obj.lsk = MRO_CRISM_SPICE_KERNEL(fname_lsk_out,dirpath, ...
                'UNLOAD_ON_DELETE',obj.unload_on_delete,'verbose',obj.verbose);
            if obj.verbose
                fprintf('Selected %-30s in %s\n',obj.lsk.fname_krnl,dirpath);
            end
        end
        
        % pck
        function set_kernel_pck(obj,varargin)
            [fname_pck_out,dirpath] = spice_get_mro_kernel_pck(varargin{:},'ext','all');
            obj.pck = MRO_CRISM_SPICE_KERNEL(fname_pck_out,dirpath, ...
                'UNLOAD_ON_DELETE',obj.unload_on_delete,'verbose',obj.verbose);
            if obj.verbose
                fprintf('Selected %-30s in %s\n',obj.pck.fname_krnl,dirpath);
            end
        end
        
        % spk de
        function set_kernel_spk_de(obj,varargin)
            [fname_spkde_out,dirpath] = spice_get_mro_kernel_spk_de(varargin{:},'ext','all');
            obj.spk_de = MRO_CRISM_SPICE_KERNEL(fname_spkde_out,dirpath, ...
                'UNLOAD_ON_DELETE',obj.unload_on_delete,'verbose',obj.verbose);
            if obj.verbose
                fprintf('Selected %-30s in %s\n',obj.spk_de.fname_krnl,dirpath);
            end
        end
        
        % spk sc
        function set_kernel_spk_sc(obj,varargin)
            [fname_spk_out,dirpath] = spice_get_mro_kernel_spk_sc_wOrdr(varargin{:},'ext','all');
            obj.spk_sc = MRO_CRISM_SPICE_KERNEL(fname_spk_out,dirpath,...
                'UNLOAD_ON_DELETE',obj.unload_on_delete,'verbose',obj.verbose);
            if obj.verbose
                if ischar(obj.spk_sc.fname_krnl)
                    fprintf('Selected %-30s in %s\n',obj.spk_sc.fname_krnl, dirpath);
                elseif iscell(obj.spk_sc.fname_krnl)
                    for i=1:length(obj.spk_sc.fname_krnl)
                        fprintf('Selected %-30s in %s\n',obj.spk_sc.fname_krnl{i},dirpath);
                    end
                end
            end
        end
        
        % ck sc
        function set_kernel_ck_sc(obj,varargin)
            [fname_ck_sc_out,dirpath] = spice_get_mro_kernel_ck_sc(varargin{:},'ext','all');
            obj.ck_sc = MRO_CRISM_SPICE_KERNEL(fname_ck_sc_out,dirpath, ...
                'UNLOAD_ON_DELETE',obj.unload_on_delete,'verbose',obj.verbose);
            if obj.verbose
                if ischar(obj.ck_sc.fname_krnl)
                    fprintf('Selected %-30s in %s\n',obj.ck_sc.fname_krnl,dirpath);
                elseif iscell(obj.ck_sc.fname_krnl)
                    for i=1:length(obj.ck_sc.fname_krnl)
                        fprintf('Selected %-30s in %s\n',obj.ck_sc.fname_krnl{i},dirpath);
                    end
                end
            end
        end
        
        % ck crism
        function set_kernel_ck_crism(obj,varargin)    
            [fname_ck_crism_out,dirpath] = spice_get_mro_kernel_ck_crism(varargin{:},'ext','all');
            obj.ck_crism = MRO_CRISM_SPICE_KERNEL(fname_ck_crism_out,dirpath, ...
                'UNLOAD_ON_DELETE',obj.unload_on_delete,'verbose',obj.verbose);
            if obj.verbose
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
end

