function [ rflspc_rsmp ] = interpCRISMspc_v2( wvspc,rflspc,wac,sbc,varargin )
%[ rflspc_rsmp ] = interpCRISMspc_v2( wvspc,rflspc,wac,sbc,varargin )
%   interpolate spectra to CRISM wavelength samples, version 2. The code is
%   significantly cleaned.
%
%   Input Parameters
%       wvspc  : [Lspc x 1], wavelength of spectra
%       rflspc : [Lspc x N], reflectance of the spectra
%       wac      : [L x 1], center of wavelength samples of the CRISM
%       sbc      : [L x 10], band-width information of CRISM
%   Output Parameters
%       rfl_spc_rsmp: [L x N], interpolated spectra
%   Optional Parameters
%       'MODE': {'SIMPLE','COMPLEX'}
%              (default) 'COMPLEX'
%       'RETAINRATIO': threshold for keeping valid bands
%                      (default) 0.9
%       'INTEREXTRAPOLATE': boolean, if we perfrom interpolation/extrapolation
%                           after covolution or not, (default) 0
%       'INTEREXTRAPOLATE_TOTALNUM': integer, maximum number of nans for
%       which interpolation/extrapolation will be performed or not.
%                       (default) 0
%       interpolation/extrapolation is performed.

%% optional parameters 
mode = 'COMPLEX';
retainratio = 0.9;
interextrapolate = false;
interextrapolate_ttln = 0;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'MODE'
                mode = upper(varargin{i+1});
            case 'RETAINRATIO'
                retainratio = varargin{i+1};
            case 'INTEREXTRAPOLATE'
                interextrapolate = varargin{i+1};
            case 'INTEREXTRAPOLATE_TOTALNUM'
                interextrapolate_ttln = varargin{i+1};
            otherwise
                error('Undefined option:%s.',upper(varargin{i}));
        end
    end
end

%% input check
if ~isvector(wvspc) || ~isnumeric(wvspc)
    error('"wvspc" must be a numeric vector');
end

if ~isvector(wac) || ~isnumeric(wac)
    error('"wac" must be a numeric vector');
end

if ~isnumeric(rflspc)
    error('"rflspc" must be numeric');
end

if ~isnumeric(sbc)
    error('"sbc" must be numeric');
end

Lspc = length(wvspc);
[Lspcy,N] = size(rflspc);

if Lspc~=Lspcy
    error('size of wvspc and rflspc does not match');
end

L = length(wac); [Lfwhm,nlayer] = size(sbc);
if L~=Lfwhm
     error('size of wac and sbc does not match');
end
if nlayer~=10
    error('something wrong with "sbc". Size is incorrect');
end

wvspc = wvspc(:); wac = wac(:);

%% actual interpolation

switch mode
    case 'SIMPLE'
        % this is just a simple gaussian convolution
        % using "wa" and the first layer in "sb"
        
        % /* Layer 0 of the cube gives the FWHM of a single Gaussian fitted         */
        % /* to the spectral profile.  This Gaussian may be                         */
        % /* useful as an approximation to f(lambda) when the details of the        */
        % /* spectral profile are not important.                                    */
        fwhm = sbc(:,1);
        [ rflspc_rsmp ] = interpGaussConv_v2( wvspc,rflspc,wac,fwhm,'RETAINRATIO',retainratio );
        
    case 'COMPLEX'
        
        % combination of three gaussians. See the information below from
        % the lbl file of CDR/SB.
        
        % /* The spectral profile equation is just the sum of 3 Gaussians:          */
        % /* f(lambda)=alpha1*exp(-gamma1*(lambda-lambda1)^2)                       */
        % /* +alpha2*exp(-gamma2*(lambda-lambda2)^2)                                */
        % /* +alpha3*exp(-gamma3*(lambda-lambda3)^2)                                */
        % /* The first Gaussian is for the main peak, the second to model the       */
        % /* asymmetric and double peaks seen in the data, and the third is a       */
        % /* wide shallow Gaussian to model enhanced wings seen in the data.        */
        % /* Layers 1,2,3,4,5,6,7,8,9 of the cube are are alpha1,gamma1,lambda1,    */
        % /* alpha2,gamma2,lambda2,alpha3,gamma3,lambda3 respectively.              */
        
        % /* The parameters alpha1,alpha2,alpha3 are defined such that the integral */
        % /* of f(lambda) is 1 with lambda given in nm.                             */
        alpha1 = sbc(:,2); gamma1 = sbc(:,3); lambda1 = sbc(:,4);
        alpha2 = sbc(:,5); gamma2 = sbc(:,6); lambda2 = sbc(:,7);
        alpha3 = sbc(:,8); gamma3 = sbc(:,9); lambda3 = sbc(:,10);
        
        gamma2sigma = @(g) sqrt(0.5./g);
        alpha2phi   = @(a,g) a .* sqrt(pi./g); 
        
        sigma1 = gamma2sigma(gamma1); phi1 = alpha2phi(alpha1,gamma1);
        sigma2 = gamma2sigma(gamma2); phi2 = alpha2phi(alpha2,gamma2);
        sigma3 = gamma2sigma(gamma3); phi3 = alpha2phi(alpha3,gamma3);
        
        
        wac_min = min(wac); wac_max = max(wac);
        wvspc_valid_idx = and(wvspc>(wac_min-200),wvspc<(wac_max)+200);
        wvspc_valid = wvspc(wvspc_valid_idx);
        rflspc_valid = rflspc(wvspc_valid_idx,:);
        rflspc_valid_isnotnan = ~isnan(rflspc_valid);
        
        rflspc_rsmp = nan([L,N]);
        if ~isempty(wvspc_valid)
            for i=1:L
                c1 = phi1(i)*normpdf_r(wvspc_valid,lambda1(i),sigma1(i),false);
                c2 = phi2(i)*normpdf_r(wvspc_valid,lambda2(i),sigma2(i),false);
                c3 = phi3(i)*normpdf_r(wvspc_valid,lambda3(i),sigma3(i),false);
                coeff = c1+c2+c3;
                Z = nansum( bsxfun(@times,coeff,rflspc_valid_isnotnan),1);
                valid_idx = Z > retainratio;
                rflspc_rsmp(i,valid_idx) = nansum(coeff.*rflspc_valid(:,valid_idx),1) ./ Z(:,valid_idx);
                % toc;
            end
        end
        
end

%% post interpolation/extrapolation added by Yuki 06/28/2017
if interextrapolate
    nanrflspc_rsmp = isnan(rflspc_rsmp);
     for i=1:size(rflspc_rsmp,2)
         if sum(nanrflspc_rsmp(:,i))<interextrapolate_ttln
             idx = ~nanrflspc_rsmp(:,i);
             idx_c = ~idx;
             rflspc_rsmp(idx_c,i) = interp1(wvspc(idx),rflspc_rsmp(idx,i),wvspc(idx_c),'linear','extrap');
         end
     end
end
                

end

