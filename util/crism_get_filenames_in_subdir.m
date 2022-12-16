function [fnamelist,dir_local,cache_dir] = crism_get_filenames_in_subdir(subdir,index_cache_update)
global crism_env_vars
localrootDir   = crism_env_vars.localCRISM_PDSrootDir;
url_local_root = crism_env_vars.url_local_root;
if isfield(crism_env_vars,'dir_tmp')
    dir_tmp = crism_env_vars.dir_tmp;
else
    dir_tmp = [];
end
cache_dir = fullfile(dir_tmp,url_local_root,subdir);
dir_local = fullfile(localrootDir,url_local_root,subdir);
index_cache_fname = 'index.txt';
index_cache_fpath = fullfile(cache_dir,index_cache_fname);
if exist(index_cache_fpath,'file') && ~index_cache_update
    fid = fopen(index_cache_fpath,'r');
    fnamelist = textscan(fid,'%s');
    fclose(fid);
    fnamelist = reshape(fnamelist{1},1,[]);
else
    if exist(dir_local,'dir')
        filelist = dir(dir_local);
        fnamelist = {filelist.name};
        if ~isempty(dir_tmp)
            if ~exist(cache_dir,'dir'), mkdir(cache_dir); end
            fid = fopen(index_cache_fpath,'w');
            fprintf(fid,'%s\r\n',fnamelist{:});
            fclose(fid);
        end
    else
        fnamelist = {};
    end
end

end