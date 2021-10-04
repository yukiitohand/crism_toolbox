classdef CRISMdataMSLDEMprojViewPlot < handle
    % CRISMdataMSLDEMprojViewPlot class
    %   Internal class for handling the plot. Mainly used for linking the
    %   spectral plot with image cursors in the ImageStackView
    
    properties
        cursor_obj
        line_obj
        im_obj
        pff_imObj_ISV_proj
        pff_imObj_MASTCAMview
    end
    
    methods
        function obj = CRISMdataMSLDEMprojViewPlot()
        end
        
        function add_imobj(obj,imobj)
            if isempty(obj.im_obj)
                obj.im_obj = imobj;
            else
                obj.im_obj = [obj.im_obj imobj];
            end
        end
        
        function add_lineobj(obj,lineobj)
            if isempty(obj.line_obj)
                obj.line_obj = lineobj;
            else
                obj.line_obj = [obj.line_obj lineobj];
            end
        end
        
        function delete(obj)
            for i=1:length(obj.line_obj)
                delete(obj.line_obj(i));
            end
            for i=1:length(obj.im_obj)
                delete(obj.im_obj(i));
            end
        end
    end
end