classdef CRISMdataMSLDEMprojView < handle
    % CRISMdataMSLDEMprojView
    %   Viewer for CRISM spectral image cube and its projected cubes 
    
    properties
        ENVIRasterMultviewObj
        ISVobj_proj
        isvimageObj_pff
        CRISMdataMSLDEMprojList
        CRISMdataMSLDEMprojElems
        obj_HSIviewPlot
        objSpecView
        
        MASTCAMview
    end
    
    methods
        function obj = CRISMdataMSLDEMprojView(crismdataMSLDEMprojObjList,varargin)
            % obj = CRISMdataMSLDEMprojView(raster_input,varargin)
            % USAGE
            %  
            
            % Store crismdataMSLDEMprojObj
            obj.CRISMdataMSLDEMprojList = crismdataMSLDEMprojObjList;
            
            obj.objSpecView = SpecView();
            
%             obj.objSpecView = SpecView('XLabel','Wavelength',...
%                     'XLim',SpecView_XLimMan,'YLim',SpecView_YLimMan);
            
            % Initialize ENVIRasterMultviewObj
            for i=1:length(crismdataMSLDEMprojObjList)
                crismdataMSLDEMprojObj = crismdataMSLDEMprojObjList(i);
                enviRasterViewObj_i = ENVIRasterMultview([],[], ...
                    'SpecView',obj.objSpecView, ...
                    'VARARGIN_IMAGESTACKVIEW',{'XY_COORDINATE_SYSTEM','IMAGEPIXELS','Ydir','reverse', ...
                    'IMAGE_CURSOR_FCN',@obj.image_BtnDwnFcn_ENVIRasterMultview_detectorimage,...
                    'IMAGE_WINDOWKEYPRESS_FCN',@obj.image_WindowKeyPressFcn_ENVIRasterMultview_detectorimage});
                
                for j=1:length(crismdataMSLDEMprojObj.CRISMdata)
                    crismdataObj_j = crismdataMSLDEMprojObj.CRISMdata(j);
                    rasterElem = ENVIRasterMultview_Rasterelem(crismdataObj_j);
                    rasterElem.ave_window = crismdataMSLDEMprojObj.ave_window;
                    enviRasterViewObj_i.add_RasterElem(rasterElem);
                    crismdataObj_j.set_rgb();
                    crism_rgb = crismdataObj_j.RGB.CData_Scaled;
                    enviRasterViewObj_i.obj_ISV.add_layer(crism_rgb,'name',num2str(j));
                end
                % enviRasterViewObj_i.obj_ISV.Update_ImageAxes_LimHomeAuto();
                % enviRasterViewObj_i.obj_ISV.Update_ImageAxes_LimHome();
                % enviRasterViewObj_i.obj_ISV.Update_axim_aspectR();
                enviRasterViewObj_i.obj_ISV.Restore_ImageAxes2LimHome();
                obj.ENVIRasterMultviewObj = [obj.ENVIRasterMultviewObj enviRasterViewObj_i];
                enviRasterViewObj_i.obj_ISV.fig.UserData.ENVIRasterMultviewObj  = enviRasterViewObj_i;
                enviRasterViewObj_i.obj_ISV.fig.UserData.CRISMdataMSLDEMprojObj = crismdataMSLDEMprojObj;
                crismdataMSLDEMprojObj.ENVIRasterMultviewObj = enviRasterViewObj_i;
            end
            
            % Initialize ISVobj_proj
            obj.ISVobj_proj = ImageStackView([], ...
                'IMAGE_CURSOR_FCN', @obj.image_BtnDwnFcn_ISVobj_proj,...
                'IMAGE_WINDOWKEYPRESS_FCN', @obj.image_WindowKeyPressFcn_ISVobj_proj,...
                'XY_COORDINATE_SYSTEM','LATLON');
            
           
            
        end
        
        %% Callback functions for the ENVIRasterMultView_detectorimage 
        function [out] = image_BtnDwnFcn_ENVIRasterMultview_detectorimage(obj,hObject,eventData)
            % DataTip is created as the same way in ImageStackView
            envirastermultviewObj = hObject.Parent.Parent.UserData.ENVIRasterMultviewObj;
            
            % Plot spectrum first onto envirastermultviewObj->SpecViewObj
            [out] = envirastermultviewObj.image_BtnDwnFcn_HSIview(hObject,eventData);
            
            % out.cursor_obj.DeleteFcn = @obj.image_cursor_delete_current;
            
            % Plot Pixel Footprint function to 
            crismdataMSLDEMprojObj = hObject.Parent.Parent.UserData.CRISMdataMSLDEMprojObj;
            obj.drawPFF(out.cursor_obj,crismdataMSLDEMprojObj);
            
        end
        
        function [out] = image_WindowKeyPressFcn_ENVIRasterMultview_detectorimage(obj,figObj,eventData)
            envirastermultviewObj = figObj.UserData.ENVIRasterMultviewObj;
            [out] = envirastermultviewObj.image_WindowKeyPressFcn_HSIview(figObj,eventData);
            if isfield(out,'cursor_obj') && ~isempty(out.cursor_obj)
                switch eventData.Key
                    case {'rightarrow','leftarrow','uparrow','downarrow'}
                        envirastermultviewObj.plot(out.cursor_obj);
                        % Plot Pixel Footprint function to 
                        crismdataMSLDEMprojObj = figObj.UserData.CRISMdataMSLDEMprojObj;
                        obj.drawPFF(out.cursor_obj,crismdataMSLDEMprojObj);
                end
            end
        end
        
        
        %% Callback functions for the ISVobj_proj
        function [out] = image_BtnDwnFcn_ISVobj_proj(obj,hObject,eventData)
            % DataTip is created as the same way in ImageStackView
            [out] = obj.ISVobj_proj.image_BtnDwnFcn(hObject,eventData);
            % out.cursor_obj.DeleteFcn = @obj.image_cursor_delete_current;
            x = out.cursor_obj.X; y = out.cursor_obj.Y;
            % 
            for i=1:length(obj.CRISMdataMSLDEMprojList)
                CRISMdataMSLDEMprojObj = obj.CRISMdataMSLDEMprojList(i);
                enviRasterViewObj_i = CRISMdataMSLDEMprojObj.ENVIRasterMultviewObj;
                switch upper(obj.ISVobj_proj.XY_COORDINATE_SYSTEM)
                     case 'NORTHEAST'
                         [sl_crm,pffcell,srange,lrange] = ...
                             CRISMdataMSLDEMprojObj.PFFonMSLDEM.getPFFbyNE( ...
                             x,y,'Threshold','MAX');
                     case {'PLANETOCENTRIC','LATLON'}
                         [sl_crm,pffcell,srange,lrange] = ...
                             CRISMdataMSLDEMprojObj.PFFonMSLDEM.getPFFbylatlon( ...
                             x,y,'Threshold','MAX');
                     case 'IMAGEPIXELS'
                         [sl_crm,pffcell,srange,lrange] = ...
                             CRISMdataMSLDEMprojObj.PFFonMSLDEM.getPFFbyMSLDEMxy( ...
                             x,y,'Threshold','MAX');
                end
                
                [cursor_obj_detectorimage] = enviRasterViewObj_i.obj_ISV.image_cursor_create(sl_crm(1),sl_crm(2));
                enviRasterViewObj_i.plot(cursor_obj_detectorimage);
                obj.drawPFF(cursor_obj_detectorimage,CRISMdataMSLDEMprojObj);
                cursor_obj_detectorimage.UserData.CRISMdataMSLDEMprojObj = CRISMdataMSLDEMprojObj;
                if isfield(out,'cursor_obj_detectorimage')
                    out.cursor_obj_detectorimage = [out.cursor_obj_detectorimage cursor_obj_detectorimage];
                else
                    out.cursor_obj_detectorimage = cursor_obj_detectorimage;
                end
                    
                
            end
            
            
            
        end
        
        function [out] = image_WindowKeyPressFcn_ISVobj_proj(obj,figobj,eventData)
            % [out] = obj.ISVobj_proj.ISVWindowKeyPressFcn(figobj,eventData);
            % if isfield(out,'cursor_obj') && ~isempty(out.cursor_obj)
            %     switch eventData.Key
            %         case {'rightarrow','leftarrow','uparrow','downarrow'}
            %             obj.plot(out.cursor_obj);
            %     end
            % end
        end
        
        function create_ax_pff(obj)
            obj.isvimageObj_pff = obj.ISVobj_proj.add_layer([],'name','PFF');
            obj.isvimageObj_pff.ax.NextPlot = 'add';
        end
        
        function drawPFF(obj,cursor_obj_detectorimage,crismdataMSLDEMprojObj)
             x_crm = cursor_obj_detectorimage.X;
             y_crm = cursor_obj_detectorimage.Y;
             switch upper(obj.ISVobj_proj.XY_COORDINATE_SYSTEM)
                 case 'NORTHEAST'
                     xy_coord = 'NE';
                 case {'PLANETOCENTRIC','LATLON'}
                     xy_coord = 'LATLON';
                 case 'IMAGEPIXELS'
                     xy_coord = 'PIXEL';
             end
             [pffclx,srange,lrange] = crismdataMSLDEMprojObj.PFFonMSLDEM.getPFFx(x_crm,y_crm, ...
                 'XY_COORDINATE',xy_coord,'AVERAGE_WINDOW',crismdataMSLDEMprojObj.ave_window);
             
             if isempty(obj.isvimageObj_pff)
                 obj.create_ax_pff();
             end
             
             % 
             update_finish = 0; 
             for i=1:length(cursor_obj_detectorimage.UserData.HSIviewPlot_obj.im_obj)
                 imObj = cursor_obj_detectorimage.UserData.HSIviewPlot_obj.im_obj(i);
                 if imObj.Parent == obj.isvimageObj_pff.ax
                     imObj.XData = srange;
                     imObj.YData = lrange;
                     imObj.CData = double(pffclx);
                     imObj.AlphaData = double(pffclx>0)*0.5;
                     update_finish = 1;
                     break;
                 end
             end
             if ~update_finish
                 imObj = imagesc(obj.isvimageObj_pff.ax,srange,lrange,pffclx,'AlphaData',double(pffclx>0)*0.5);
                     obj.isvimageObj_pff.imobj = [obj.isvimageObj_pff.imobj imObj];
                     cursor_obj_detectorimage.UserData.HSIviewPlot_obj.im_obj = ...
                            [cursor_obj_detectorimage.UserData.HSIviewPlot_obj.im_obj imObj];
             end
        end
        
        %% MASTCAM connection
        function add_mastcam(obj,MSTproj,varargin)
            mstview = MASTCAMMSIview_v2(varargin{:}); %,'Specview',obj.objSpecView);
            mstview.add_projection(MSTproj,'ISV_proj',obj.ISVobj_proj);
            mstview.objENVIRasterMultview.obj_ISV.custom_image_cursor_fcn = @(x,y) obj.image_BtnDwnFcn_MASTCAMView(x,y,mstview);
            obj.MASTCAMview = [obj.MASTCAMview mstview];
            for i=1:length(obj.ENVIRasterMultviewObj)
                obj.ENVIRasterMultviewObj(i).obj_ISV.custom_image_cursor_fcn = @obj.image_BtnDwnFcn_ENVIRasterMultview_detectorimage_wMST;
                obj.ENVIRasterMultviewObj(i).obj_ISV.custom_windowkeypress_fcn = @obj.image_WindowKeyPressFcn_ENVIRasterMultview_detectorimage_wMST;
            end
            obj.ISVobj_proj.custom_image_cursor_fcn = @obj.image_BtnDwnFcn_ISV_proj_wMST;
            
            
        end
        
        function image_BtnDwnFcn_ENVIRasterMultview_detectorimage_wMST(obj,axes_obj,eventData)
            
            % first perform default callback function
            [out] = obj.image_BtnDwnFcn_ENVIRasterMultview_detectorimage(axes_obj,eventData);
            
            % next perform projection onto MASTCAM image
            cursor_obj = out.cursor_obj;
            crismdataMSLDEMprojObj = axes_obj.Parent.Parent.UserData.CRISMdataMSLDEMprojObj;
            obj.drawPFFonMASTCAM(crismdataMSLDEMprojObj,cursor_obj);
            
            
        end
        
        function [out] = image_WindowKeyPressFcn_ENVIRasterMultview_detectorimage_wMST(obj,figobj,eventData)
            [out] = obj.image_WindowKeyPressFcn_ENVIRasterMultview_detectorimage(figobj,eventData);
            if isfield(out,'cursor_obj') && ~isempty(out.cursor_obj)
                switch eventData.Key
                    case {'rightarrow','leftarrow','uparrow','downarrow'}
                        cursor_obj = out.cursor_obj;
                        crismdataMSLDEMprojObj = figobj.UserData.CRISMdataMSLDEMprojObj;
                        obj.drawPFFonMASTCAM(crismdataMSLDEMprojObj,cursor_obj);
                end
            end
        end
        
        function drawPFFonMASTCAM(obj,crismdataMSLDEMprojObj,cursor_obj)
            % find MSTview that has the associated PFF
            x_crm = cursor_obj.X; y_crm = cursor_obj.Y;
            for i=1:length(obj.MASTCAMview)
                mstview = obj.MASTCAMview(i);
                mstID = mstview.MSTproj.identifier;
                for j=1:length(crismdataMSLDEMprojObj.PFFonMASTCAM)
                    crimPFFonMSTObj = crismdataMSLDEMprojObj.PFFonMASTCAM(j);
                    if strcmpi(mstID,crimPFFonMSTObj.targetID)
                        
                        [pffclx,srange,lrange] = crimPFFonMSTObj.getPFFx(x_crm,y_crm, ...
                            'AVERAGE_WINDOW',crismdataMSLDEMprojObj.ave_window);
                        
                        if isempty(mstview.objISVImage_MASTCAM_SelectMask)
                            mstview.create_ax_MASTCAM_SelectMask();
                        end
                        
                        update_finish = 0;
                        for k=1:length(cursor_obj.UserData.HSIviewPlot_obj.im_obj)
                            imObj = cursor_obj.UserData.HSIviewPlot_obj.im_obj(k);
                            if imObj.Parent == mstview.objISVImage_MASTCAM_SelectMask.ax
                                imObj.XData = srange;
                                imObj.YData = lrange;
                                imObj.CData = double(pffclx);
                                imObj.AlphaData = double(pffclx>0)*0.5;
                            end
                        end
                        if ~update_finish
                            imObj = imagesc(mstview.objISVImage_MASTCAM_SelectMask.ax,srange,lrange,pffclx,'AlphaData',double(pffclx>0)*0.5);
                            mstview.objISVImage_MASTCAM_SelectMask.imobj = ...
                                 [mstview.objISVImage_MASTCAM_SelectMask.imobj imObj];
                            cursor_obj.UserData.HSIviewPlot_obj.im_obj = ...
                                    [cursor_obj.UserData.HSIviewPlot_obj.im_obj imObj];
                        end
                        
                        % plot average spectrum
                        obj.plot_average_spectrum_onMST(mstview,cursor_obj,crimPFFonMSTObj,srange,lrange,pffclx);
                    end
                end
            end
            
            
        end
        
        function [] = plot_average_spectrum_onMST(obj,mstview,cursor_obj,crimPFFonMSTObj,srange,lrange,pff)
            % First get the pointer to HSIviewPlot object linked to the
            % cursor.
                
            % cla(obj.obj_SpecView.ax);
            % once the plot is performed, NextPlot property is always on.
            % The deletion of the plot is controlled by the cursor_obj. All
            % the plot should be linked to cursor obj and when it is
            % destroyed, plot is also destroed.
            % hold(obj.obj_SpecView.ax,'on');
            for i=1:mstview.objENVIRasterMultview.nRaster
                % convert (x,y) into (s,l) in the reference image
                % coordinate.
                [spc,wv,bdxes] = mstview.objENVIRasterMultview.RasterElems(i).Raster.get_spectrum_average(srange,lrange,pff);
                spcstr = 'Average CRISM';
                update_fin = 0;
                for j=1:length(cursor_obj.UserData.HSIviewPlot_obj.line_obj)
                    lineObj = cursor_obj.UserData.HSIviewPlot_obj.line_obj(j);
                    if lineObj.Parent == mstview.objENVIRasterMultview.obj_SpecView.ax ...
                            && isfield(lineObj.UserData,'Parent') && lineObj.UserData.Parent == crimPFFonMSTObj
                        lineObj.XData = wv;
                        lineObj.YData = spc;
                        lineObj.DisplayName = spcstr;
                        update_fin = 1;
                        break;
                    end
                end
                if ~update_fin
                    line_obj = mstview.objENVIRasterMultview.obj_SpecView.plot(...
                            [wv,spc,mstview.objENVIRasterMultview.RasterElems(i).varargin_plot,...
                             'DisplayName',spcstr ...
                            ], {'Band',bdxes});
                    % store line object into HSIviewPlot object.
                    line_obj.UserData.Parent = crimPFFonMSTObj;
                    cursor_obj.UserData.HSIviewPlot_obj.add_lineobj(line_obj);
                end
            end
            
            if ~isempty(spc)
                mstview.objENVIRasterMultview.obj_SpecView.set_xlim();
                if ~isempty(spc)
                    mstview.objENVIRasterMultview.obj_SpecView.set_ylim();
                end
            end
            
        end
        
        function image_BtnDwnFcn_ISV_proj_wMST(obj,axes_obj,eventData)
            
            % first perform default callback function
            [out] = image_BtnDwnFcn_ISVobj_proj(obj,axes_obj,eventData);
            
            % next perform projection onto MASTCAM image
            cursor_obj_detectorimage = out.cursor_obj_detectorimage;
            for i=1:length(cursor_obj_detectorimage)
                cursor_obj_detectorimage_i = cursor_obj_detectorimage(i);
                crismdataMSLDEMprojObj = cursor_obj_detectorimage_i.UserData.CRISMdataMSLDEMprojObj;
                obj.drawPFFonMASTCAM(crismdataMSLDEMprojObj,cursor_obj_detectorimage);
            end
            
            
        end
        
        function [out] = image_WindowKeyPressFcn_ISV_proj_wMST(obj,figobj,eventData)
            out = [];
        end
        
        function image_BtnDwnFcn_MASTCAMView(obj,axes_obj,eventData,mstview)
            
            % first perform default callback function
            [out] = mstview.ISV_MASTCAM_BtnDwnFcn(axes_obj,eventData);
            x_mst = out.cursor_obj.X; y_mst = out.cursor_obj.Y;
            
            mstID = mstview.MSTproj.identifier;
            for i=1:length(obj.CRISMdataMSLDEMprojList)
                crismdataMSLDEMprojObj = obj.CRISMdataMSLDEMprojList(i);
                enviRasterViewObj = crismdataMSLDEMprojObj.ENVIRasterMultviewObj;
                for j=1:length(crismdataMSLDEMprojObj.PFFonMASTCAM)
                    crimPFFonMSTObj = crismdataMSLDEMprojObj.PFFonMASTCAM(j);
                    if strcmpi(mstID,crimPFFonMSTObj.targetID)
                        
                        [sl_crm,pffcell,srange,lrange] = crimPFFonMSTObj.getPFFbyMASTCAMxy( ...
                            x_mst,y_mst,'Threshold','MAX');
                        if ~isempty(sl_crm)
                            [cursor_obj_detectorimage] = enviRasterViewObj.obj_ISV.image_cursor_create(sl_crm(1),sl_crm(2));
                            enviRasterViewObj.plot(cursor_obj_detectorimage);
                            obj.drawPFF(cursor_obj_detectorimage,crismdataMSLDEMprojObj);
                            
                            cursor_obj_detectorimage.UserData.CRISMdataMSLDEMprojObj = crismdataMSLDEMprojObj;
                        
                            if isfield(out,'cursor_obj_detectorimage')
                                out.cursor_obj_detectorimage = [out.cursor_obj_detectorimage cursor_obj_detectorimage];
                            else
                                out.cursor_obj_detectorimage = cursor_obj_detectorimage;
                            end
                            
                            obj.drawPFFonMASTCAM(crismdataMSLDEMprojObj,cursor_obj_detectorimage);
                            
                        end
                    end
                end
            end
            
            
        end
        
    end
end