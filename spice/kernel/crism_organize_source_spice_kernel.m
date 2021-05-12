function [src_krnl] = crism_organize_source_spice_kernel(source_kernel_ids)

% mro_crm_ck_ptrn = 'spck_(?<yyyy>\d{4})_(?<doy>\d{3})_r_1.bc';
% mro_sc_ck_ptrn  = 'mro_sc_psp_(?<yymmdd_start>\d{6})_(?<yymmdd_end>\d{6}).bc';
% de_ptrn         = 'de\d{3}.bsp';

src_krnl = [];
for i=1:length(source_kernel_ids)
    kernel_fname = source_kernel_ids{i};
    [~,~,ext] = fileparts(kernel_fname);
    ext = ext(2:end);
    switch lower(ext)
        case {'tsc'}
            dirname = 'sclk';
        case {'tf'}
            dirname = 'fk';
        case {'ti'}
            dirname = 'ik';
        case {'tls'}
            dirname = 'lsk';
        case {'tpc'}
            dirname = 'pck';
        case {'bc'}
            dirname = 'ck';
            % if regexpi(kernel_fname,mro_sc_ck_ptrn,'ONCE')
            %     dirname = 'ck';
            % elseif regexpi(kernel_fname,mro_crm_ck_ptrn,'ONCE')
            %     dirname = 'ck';
            % end
        case {'bsp'}
            dirname = 'spk';
            % if any(strcmpi(kernel_fname,{'mro_cruise.bsp', ...
            %         'mro_ab.bsp', 'mro_psp.bsp', 'mro_psp_rec.bsp'}))
            %     dirname = 'spk';
            % elseif regexpi(kernel_fname,de_ptrn,'ONCE')
            %     dirname = 'spk';
            % end    
        otherwise
            error('Unknown extension %s',ext);
    end
    if ~isfield(src_krnl,dirname)
        src_krnl.(dirname) = kernel_fname;
    else
        src_krnl.(dirname) = [src_krnl.(dirname) {kernel_fname}];
    end
    
end

    

end