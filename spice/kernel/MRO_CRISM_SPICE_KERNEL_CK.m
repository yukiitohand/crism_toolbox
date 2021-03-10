classdef MRO_CRISM_SPICE_KERNEL_CK < handle
    % MRO_CRISM_SPICE_KERNEL_CK
    %   
    
    properties
        sc
        crism
    end
    
    methods
        function obj = MRO_CRISM_SPICE_KERNEL_CK(spkrnl_sc,spkrnl_crism)
            obj.crism = spkrnl_crism;
            obj.sc    = spkrnl_sc;
        end
        
        function furnsh(obj)
            obj.crism.furnsh();
            obj.sc.furnsh();
        end
        
        function unload(obj)
            obj.crism.unload();
            obj.sc.unload();
        end
        
    end
end