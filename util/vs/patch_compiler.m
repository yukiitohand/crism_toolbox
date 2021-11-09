
dirpath_toolbox = '/Users/yukiitoh/src/matlab/toolbox/';

pds3_toolbox_path  = joinPath(dirpath_toolbox, 'pds3_toolbox/');
crism_toolbox_path = joinPath(dirpath_toolbox, 'crism_toolbox/');

pds3_toolbox_mex_include_path = joinPath(pds3_toolbox_path, 'mex_include');
crism_toolbox_mex_include_path  = joinPath(crism_toolbox_path,  'mex_include');

% switch computer
%     case 'MACI64'
%         out_dir = joinPath(crism_toolbox_path,'mex_build','./maci64/');
%     case 'GLNXA64'
%         out_dir = joinPath(crism_toolbox_path,'mex_build','./glnxa64/');
%     case 'PCWIN64'
%         out_dir = joinPath(crism_toolbox_path,'mex_build','./pcwin64/');
%     otherwise
%         error('Undefined computer type %s.\n',computer);
% end

out_dir = '/Users/yukiitoh/src/matlab/toolbox/crism_toolbox/util/vs/';
filepath = '/Users/yukiitoh/src/matlab/toolbox/crism_toolbox/util/vs/crism_vscor_patch_vs_artifact_v2_internal_mex.c';
mex(filepath, '-R2018a', ['-I' pds3_toolbox_mex_include_path], ...
        ['-I' crism_toolbox_mex_include_path], ...
        '-outdir',out_dir);