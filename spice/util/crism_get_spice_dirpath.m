function [dirpath] = crism_get_spice_dirpath(kernel_name,varargin)

global mro_crism_spicekrnl_env_vars
% global crism_env_vars

% pdir = '/Volumes/LaCie5TB/data/naif.jpl.nasa.gov/pub/naif/MRO/kernels/';
pdir = joinPath(mro_crism_spicekrnl_env_vars.local_SPICEkernel_archive_rootDir, ...
    mro_crism_spicekrnl_env_vars.crismlnx_URL, ...
    mro_crism_spicekrnl_env_vars.NAIF_MROSPICE_subdir);
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'PDIR'
                pdir = varargin{i+1};
            
            otherwise
                error('Unrecognized option: %s',varargin{i});   
        end
    end
end

[fldr] = crism_get_spice_folder(kernel_name);

dirpath = joinPath(pdir,fldr);

end