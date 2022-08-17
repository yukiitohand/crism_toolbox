function [img_corr,scale_factor] = crism_vscor_scaleatm_pcm(img,waimg,bandset_id,atmt)
% [img_corr,scale_factor] = crism_vscor_scaleatm_pcm(img,waimg,bandset_id,atmt)
%  Perform volcano scan correction for CRISM image. This is translated from
%  idl code:
%      CAT_ENVI/save_add/CAT_programs/Supplementals/scaleatm_pcm.pro
% Tile mode is not supported.
% 
% INPUTS
%   img: [L x S x B] CRISM I/F image to be corrected
%   waimg: [1 x S x B] wavelength frame associated to img/transmission 
%     Unit [nm]
%   bandset_id: {'mcg',0,'pel',1} identifier for the band selection to 
%     evaluate the scaling of transmission
%       'mcg',0 : McGuire (2007/1980)
%       'pel',1 : Pelky   (2011/1899)
%   atmt: [1 x S x B] image frame of transmission spectra 
% OUTPUTS
%   img_corr: [L x S x B] corrected CRISM I/F image cube
%   scale_factor: [L x S] scale factors of transmission used for the 
%     correction each spectrum
% 
% (c) 2021 Yuki Itoh

switch bandset_id
    case {'mcg',0}
        bi2007 = crism_lookupwv(2007,waimg);
        bi1980 = crism_lookupwv(1980,waimg);
        
        R2007 = hsi_slice_bandBycolumn(img,bi2007);
        R1980 = hsi_slice_bandBycolumn(img,bi1980);
        arg3  = R2007 ./ R1980;
        atmt2007 = hsi_slice_bandBycolumn(atmt,bi2007);
        atmt1980 = hsi_slice_bandBycolumn(atmt,bi1980);
        arg4  = atmt2007 ./ atmt1980;
        arg3(arg3<0) = nan;
        arg4(arg4<0) = nan;
        scale_factor = log(arg3) ./ log(arg4);
        
    case {'pel',1}
        % first two bands are for slope correction.
        bi1299 = crism_lookupwv(1299,waimg);
        bi2527 = crism_lookupwv(2527,waimg);
        bi2011 = crism_lookupwv(2011,waimg);
        bi1899 = crism_lookupwv(1899,waimg);
        
        R1299 = hsi_slice_bandBycolumn(img,bi1299);
        R2527 = hsi_slice_bandBycolumn(img,bi2527);
        R2011 = hsi_slice_bandBycolumn(img,bi2011);
        R1899 = hsi_slice_bandBycolumn(img,bi1899);
        
        slope = R1299./R2527;
        
        % Depth of CO2 band:
        arg = R2011 ./ R1899;
        
        % Slope corrected depth of CO2 band in observation
        wa2011 = hsi_slice_bandBycolumn(waimg,bi2011);
        wa1899 = hsi_slice_bandBycolumn(waimg,bi1899);
        wa1299 = hsi_slice_bandBycolumn(waimg,bi1299);
        wa2527 = hsi_slice_bandBycolumn(waimg,bi2527);
        alti = log(arg) + log(slope) .* ((wa2011-wa1899) ./ (wa2527-wa1299));
        
        % Depth of CO2 band in transmission spectra:
        atmt2011 = hsi_slice_bandBycolumn(atmt,bi2011);
        atmt1899 = hsi_slice_bandBycolumn(atmt,bi1899);
        arg2 = atmt2011 ./ atmt1899;
        
        % Find the scaling factor:
        % (slope corrected CO2 depth in obs/CO2 depth in transmission spectrum)
        scale_factor = alti./log(arg2);
              
    otherwise
        if isnumeric(bandset_id)
            bandset_id = num2str(bandset_id);
        end
        error('Undefined bandset_id %s',bandset_id);
end

% safeguarding.
scale_factor(isinf(scale_factor)) = nan;

% img_cor = img ./ (atmt.^scale_factor);
img_corr = img ./ exp(log(atmt).*scale_factor);


end

% [L,S,B] = size(img);
% switch bandset_id
%     case {'mcg',0}
%         bi2007 = crism_lookupwv(2007,waimg);
%         bi1980 = crism_lookupwv(1980,waimg);
%         tic;
%         scale_factor2 = nan(L,S);
%         for c=1:S
%             imc = squeeze(img(:,c,:));
%             % wac = squeeze(waimg(1,c,:));
%             atmtc = squeeze(atmt(1,c,:));
%             bi2007c = bi2007(c);
%             bi1980c = bi1980(c);
%             if ~isnan(bi2007c) && ~isnan(bi1980c)
%                 R2007c = imc(:,bi2007c);
%                 R1980c = imc(:,bi1980c);
% 
%                 arg3 = R2007c ./ R1980c;
%                 arg4 = atmtc(bi2007c) / atmtc(bi1980c);
% 
%                 expon = log(arg3) ./ log(arg4);
% 
%                 scale_factor2(:,c) = expon;
%             end
%             
%         end
%         toc;
%         
%     case {'pel',1}
%         % first two bands are for slope correction.
%         bi1299 = crism_lookupwv(1299,waimg);
%         bi2527 = crism_lookupwv(2527,waimg);
%         bi2011 = crism_lookupwv(2011,waimg);
%         bi1899 = crism_lookupwv(1899,waimg);
%         
%         
%         tic;
%         scale_factor2 = nan(L,S);
%         
%         for c=1:S
%             imc = squeeze(img(:,c,:));
%             wac = squeeze(waimg(1,c,:));
%             atmtc = squeeze(atmt(1,c,:));
%             bi1299c = bi1299(c);
%             bi2527c = bi2527(c);
%             bi2011c = bi2011(c);
%             bi1899c = bi1899(c);
%             
%             if ~isnan(bi2011c) && ~isnan(bi1899c)
% 
%                 % slope correction
%                 R1299 = imc(:,bi1299c);
%                 R2527 = imc(:,bi2527c);
%                 slope = R1299./R2527;
% 
%                 R2011 = imc(:,bi2011c);
%                 R1899 = imc(:,bi1899c);
% 
%                 % Depth of CO2 band:
%                 arg = R2011 ./ R1899;
% 
%                 % Slope corrected depth of CO2 band in observation
%                 alti = log(arg) + log(slope) .* ((wac(bi2011c)-wac(bi1899c)) ./ (wac(bi2527c)-wac(bi1299c)));
% 
%                 % Depth of CO2 band in transmission spectra:
%                 arg2 = atmtc(bi2011c) ./ atmtc(bi1899c);
% 
%                 % Find the scaling factor:
%                 % (slope corrected CO2 depth in obs/CO2 depth in transmission spectrum)
%                 expon = alti./log(arg2);
% 
%                 scale_factor2(:,c) = expon;
%             end
% 
%         end
%         toc;
%               
%     otherwise
%         if isnumeric(bandset_id)
%             bandset_id = num2str(bandset_id);
%         end
%         error('Undefined bandset_id %s',bandset_id);
% end
