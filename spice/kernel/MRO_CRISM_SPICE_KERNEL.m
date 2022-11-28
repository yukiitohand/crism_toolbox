classdef MRO_CRISM_SPICE_KERNEL < handle
    % MRO_CRISM_SPICE_KERNEL
    %   
    
    properties
        fname_krnl
        fname_lbl
        dirpath
        furnshed = false;
        verbose;
        unload_on_delete
    end
    
    methods
        function obj = MRO_CRISM_SPICE_KERNEL(fname,dirpath,varargin)
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
            obj.dirpath = dirpath;
            if ischar(fname)
                [~,bname,ext] = fileparts(fname);
                if isempty(fname)
                    
                else
                    switch ext
                        case '.lbl'
                            if exist(joinPath(dirpath,fname),'file')
                                obj.fname_lbl = fname;
                            end
                        otherwise
                            if exist(joinPath(dirpath,fname),'file')
                                obj.fname_krnl = fname;
                            end
                    end
                end
            elseif iscell(fname)
                for i=1:length(fname)
                    fname_i = fname{i};
                    [~,bname,ext] = fileparts(fname_i);
                    if isempty(fname_i)
                    else
                        switch ext
                            case '.lbl'
                                if exist(joinPath(dirpath,fname_i),'file')
                                    if isempty(obj.fname_lbl)
                                        obj.fname_lbl = fname_i;
                                    else
                                        obj.fname_lbl = [obj.fname_lbl, {fname_i}];
                                    end
                                end
                            otherwise
                                if exist(joinPath(dirpath,fname_i),'file')
                                    if isempty(obj.fname_krnl)
                                        obj.fname_krnl = fname_i;
                                    else
                                        obj.fname_krnl = [obj.fname_krnl, {fname_i}];
                                    end
                                end
                        end

                    end
                    
                end
            else
                error('Input is invalid');
            end
            
        end
        
        function furnsh(obj)
            % Following kernel is loaded.
            if ischar(obj.fname_krnl)
                krnlpath = joinPath(obj.dirpath,obj.fname_krnl);
                if obj.verbose, fprintf('Furnshing %s\n',krnlpath); end
                cspice_furnsh(krnlpath);
            elseif iscell(obj.fname_krnl)
                for i=1:length(obj.fname_krnl)
                    krnlpath = joinPath(obj.dirpath,obj.fname_krnl{i});
                    if obj.verbose, fprintf('Furnshing %s\n',krnlpath); end
                    cspice_furnsh(krnlpath);
                end
            end
            obj.furnshed = 1;
        end
        
        function unload(obj,varargin)
            if isempty(varargin)
                force = false;
            else
                force = varargin{1};
            end
            if obj.furnshed || force
                if ischar(obj.fname_krnl)
                    krnlpath = joinPath(obj.dirpath,obj.fname_krnl);
                    if obj.verbose, fprintf('Unloading %s\n',krnlpath); end
                    cspice_unload(krnlpath);
                elseif iscell(obj.fname_krnl)
                    for i=1:length(obj.fname_krnl)
                        krnlpath = joinPath(obj.dirpath,obj.fname_krnl{i});
                        if obj.verbose, fprintf('Unloading %s\n',krnlpath); end
                        cspice_unload(krnlpath);
                    end
                end
                obj.furnshed = 0;
            end
        end
        
        function delete(obj)
            if obj.unload_on_delete
                obj.unload();
                if obj.verbose
                    if ischar(obj.fname_krnl)
                        krnlpath = joinPath(obj.dirpath,obj.fname_krnl);
                         fprintf('Unsetting %s\n',krnlpath);
                    elseif iscell(obj.fname_krnl)
                        for i=1:length(obj.fname_krnl)
                            krnlpath = joinPath(obj.dirpath,obj.fname_krnl{i});
                            fprintf('Unsetting %s\n',krnlpath);
                        end
                    end
                end
            end
        end
        
    end
end