classdef MRO_CRISM_SPICE_KERNEL_SPK < handle
    % MRO_CRISM_SPICE_KERNEL_SPK
    %   
    
    properties
        planets
        spacecraft
    end
    
    methods
        function obj = MRO_CRISM_SPICE_KERNEL_SPK(spkrnl_sc,spkrnl_p)
            obj.planets  = spkrnl_p;
            obj.spacecraft  = spkrnl_sc;
        end
        
        function furnsh(obj)
            obj.planets.furnsh();
            obj.spacecraft.furnsh();
        end
        
        function unload(obj)
            obj.planets.unload();
            obj.spacecraft.unload();
        end
        
    end
end