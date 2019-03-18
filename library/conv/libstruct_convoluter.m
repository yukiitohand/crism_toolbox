function [A,option] = libstruct_convoluter(spclib,wv,methodid,varargin)
% [A,option] = libstruct_convoluter(spclib,wv,methodid,varargin)
%   Perform interpolation of the library formatted as a struct
%  Input Parameters
%    spclib  : spectral library, struct (length N)
%    wv      : queried wavelength (length L)
%    methodid:  method Id number
%               0 - interp1
%               1 - interpCRISMspc
%  Optional Parameters
%    'RETAINRATIO' : used for methodid, input to "interpCRISMspc.m"
%                    (default) 0.1
%    'SB'          : convolution filter used for the "interpCRISMspc.m"
%                    (default) 'none'
%    'XFIELDNAME'  : field name of x for which convolution is performed
%                    (default) 'wavelength'
%    'XMULT'       : multiplication factor for the original 'x' 
%                    (default) 1
%    'YFIELDNAME'  : field name of y for which convolution is performed
%                    (default) 'reflectance'
%    'BATCH'       : perform the convlution with batch or not
%                    (default) 0
%  Ouput Parameters
%    A  : convolved library matrix, L x N
%    option: information used for convolution

fldnm_x = 'wavelength';
fldnm_y = 'reflectance';
retainRatio = 0.1;
sb = 'none';
xmult = 1;
batch_opt = 0;
if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'RETAINRATIO'
                retainRatio = varargin{i+1};
            case 'SB'
                sb = varargin{i+1};
            case 'XFIELDNAME'
                fldnm_x = varargin{i+1};
            case 'XMULT'
                xmult = varargin{i+1};
            case 'YFIELDNAME'
                fldnm_y = varargin{i+1};
            case 'BATCH'
                batch_opt = varargin{i+1};
            otherwise
                % Hmmm, something wrong with the parameter string
                error(['Unrecognized option: ''' varargin{i} '''']);
        end
    end
end
if isempty(spclib)
    A = []; option = [];
else
    switch batch_opt
        case 0
            N = length(spclib); nB = length(wv);
            A = zeros(nB,N);
            for j=1:N
                rflspc = spclib(j).(fldnm_y);
                wvspc = spclib(j).(fldnm_x);
                valid_wv_idx = find(wvspc>1e-5);
                switch methodid
                    case 0
                        % 1d linear interpolation
                        [ rflspc_rsmp ] = interp1(wvspc(valid_wv_idx)*xmult,...
                                                  rflspc(valid_wv_idx),wv);
                    case 1
                        % convolution using CDR file
                        if strcmpi(sb,'none')
                            error('Please spcify "SB" for methodid=1')
                        end
                        [ rflspc_rsmp ] = interpCRISMspc_v2( wvspc(valid_wv_idx)*xmult,rflspc(valid_wv_idx),wv,sb,...
                                                                'RETAINRATIO',retainRatio);
                    otherwise
                        error('method %d is not defined');
                end
                A(:,j) = rflspc_rsmp;
            end
        case 1
            rflspcs = cat(2,spclib.(fldnm_y));
            wvspc = spclib(1).(fldnm_x);
            if size(rflspcs,1)~=size(wvspc,1)
                error('The shape of spclib.(%s) and spclib.(%s) must share the same 2nd-dim length',fldnm_y,fldnm_x);
            end
            valid_wv_idx = find(wvspc>1e-5);
            switch methodid
                case 0
                    error('The Batch option %d doesnt work with method interp1.',batch_opt);
                case 1
                    % convolution using CDR file
                    if strcmpi(sb,'none')
                        error('Please spcify "SB" for methodid=1')
                    end
                    [ rflspc_rsmp ] = interpCRISMspc_v2( wvspc(valid_wv_idx)*xmult,rflspcs(valid_wv_idx,:),wv,sb,...
                                                            'RETAINRATIO',retainRatio);
                otherwise
                    error('method %d is not defined');
            end
            A = rflspc_rsmp;
        otherwise
            error('The Batch option %d is not defined',batch_opt);
    end

    switch methodid
    case 0
        option.method = 'interp1';
    case 1
        option.method = 'interpCRISMspc';
        option.retainRatio = retainRatio;
    otherwise
        error('method %d is not defined');
    end
end
end