function [CRISMspclib] = readCRISMspclib(varargin)
% [CRISMspclib] = readCRISMspclib(varargin)
% Usage
%   [CRISMspclib] = readCRISMspclib()
%   [CRISMspclib] = readCRISMspclib(pdir)
% pdir is the directory path that contains libraries.
% 

global crism_env_vars
localCATrootDir = crism_env_vars.localCATrootDir;

pdir = fullfile(localCATrootDir, 'CAT_ENVI','spec_lib','crism_resamp');

if length(varargin)>2
    error('Inputs must be length of 0 or 1.');
else
    if length(varargin)==1
        pdir = varargin{1};
        if ~exist(pdir,'dir')
            error('The input path is not a valid directory.');
        end
    end
end

CRISMspclib = [];

folders = dir(pdir);
for i=1:length(folders)
    fname = folders(i).name;
    if ~isempty(regexp(fname,'(.*)\.sli$','once'))
        fbase = regexp(fname,'(.*)\.sli$','tokens');
        fbase = fbase{1}{1};
        if exist([pdir fbase '.sli.hdr'],'file')
            fname_hdr = [fbase '.sli.hdr']; flg=1;
        elseif exist([pdir fbase '.hdr'],'file')
            fname_hdr = [fbase '.hdr']; flg=1;
        else
            flg=0;
        end
        
        if flg
            CRISMspclib.(fbase) = [];
            hdr_info = envihdrreadx([pdir fname_hdr]);
            spc = envidataread([pdir fbase '.sli'],hdr_info);
            CRISMspclib.(fbase).hdr = hdr_info;
            CRISMspclib.(fbase).spc = spc;
            CRISMspclib.(fbase).subfolder = '';
        end
    elseif folders(i).isdir
        if ~strcmp(fname,'.') && ~strcmp(fname,'..')
            spec_libsub = readCRISMspclib([pdir fname  '/']);
            field_names = fields(spec_libsub);
            for j=1:length(field_names)
                field = field_names{j};
                CRISMspclib.(field) = [];
                CRISMspclib.(field).hdr = spec_libsub.(field).hdr;
                CRISMspclib.(field).spc = spec_libsub.(field).spc;
                CRISMspclib.(field).subfolder = [spec_libsub.(field).subfolder fname '/'];
            end
%             spec_lib.(fname) = spec_libsub;
        end
    end
end

end


