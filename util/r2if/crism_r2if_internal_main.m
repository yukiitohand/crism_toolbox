function [out] = crism_r2if_internal_main(TRRRAdata,varargin)
% [out] = crism_r2if_internal_main(TRRRAdata,varargin)
%   convert radiance to I/F
%  Input Parameters
%   RDn: radiance cube [L x S x B]
%   SFdata: CRISMdata obj, CDR SF data
%   r : distance from the Sun (AU)
%  Output Parameters
%   out: struct, storing the result of r2if
%    IoF : I/F cube [L x S x B]
%    wa
%    sfimg
%    d_au
%    settings
%
%  Optional Parameters
%  ## PROCESSING OPTIONS  #------------------------------------------------
%   {'DDRDATA','DDR'} : CRISMDDRdata class obj associated with 
%      crism_data_obj, only valid with 'PHOTOMETRIC_CORRECTION' = true
%      (default) []
%   {'SFDATA'} : SFdata class obj associated with 
%      (default) []
%   {'DISTANCE_KM'} : distance in kilometers
%      (default) []
%   
%   # Image Options #------------------------------------------------------
%   {'CLIST'} : 1d array, sample indices to be processed
%      (default) ':'
%   {'LLIST'} : 1d array, line indices to be processed
%      (default) ':'
%   {'BLIST'} : 1d array, band indices to be processed
%      (default) ':'
%   {'BLIST_INVERSE'} : boolean,
%      whether or not the input BLIST is reversed or not.
%      (default) false

% ## PROCESSING OPTIONS #--------------------------------------------------
DEdata = [];
SFdata = [];
dst_km = [];


% # Image Options #--------------------------------------------------------
cList = ':';
lList = ':';
bList = ':';
bList_inverse = false;

% # Other Options #--------------------------------------------------------
verbose = true;

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})    
            % ## PROCESSING OPTIONS #--------------------------------------
            case {'DDRDATA','DDR','DEDATA'}
                DEdata = varargin{i+1};
            case 'SFDATA'
                SFdata = varargin{i+1};
            case 'DISTANCE_KM'
                dst_km = varargin{i+1};
            % # Image OPTIONS #--------------------------------------------
            case {'CLIST'}
                cList = varargin{i+1};
            case {'LLIST'}
                lList = varargin{i+1};
            case {'BLIST'}
                bList = varargin{i+1};
            case {'BLIST_INVERSE'}
                bList_inverse = varargin{i+1};
            
            % ## OTHER OPTIONS #-------------------------------------------
            case 'VERBOSE'
                verbose = varargin{i+1};
            otherwise
                error('Unrecognized option: %s',varargin{i});
        end
    end
end

% Flip bList if necessary
if ~strcmpi(bList,':') && bList_inverse
    if logical(bList)
        bList = flip(bList);
    elseif isnumeric(bList)
        bList = crism_data_obj.hdr.bands - bList + 1;
    else
        error('Something wrong with bList');
    end
end

if isempty(SFdata)
    TRRRAdata.load_basenamesCDR();
    % if isempty(TRRRAdata.basenamesCDR)
    %     TRRRAdata.load_basenamesCDR();
    % end
    if isempty(TRRRAdata.cdr) || ~isfield(TRRRAdata.cdr,'SF')
        TRRRAdata.readCDR('SF');
    end
    SFdata = TRRRAdata.cdr.SF;
end

if isempty(dst_km)
    if isempty(DEdata)
        [DEdata] = crism_get_associated_DDR(TRRRAdata);
    end
    d_km = DEdata.lbl.SOLAR_DISTANCE.value;
end

%% read base information
img = TRRRAdata.readimg();
if ~isfield(TRRRAdata.cdr,'WA')
    TRRRAdata.readCDR('WA');
end
WAdata = TRRRAdata.cdr.WA;
waimg  = WAdata.readimg();

sfimg = SFdata.readimg();
d_au  = km2au( d_km );

%% Computation
if strcmpi(cList,':') || lList~=':' || bList~=':'
    img   = img(lList,cList,bList);
    waimg = waimg(1,cList,bList);
    sfimg = sfimg(1,cList,bList);
end

IoF = pi .* (d_au.^2) ./ sfimg .* img;
% The below produces the exactly same as idl r2if_event.pro.
% IoF =  single(img) ./ (single(sfimg) ./ (single(d_au).^2) ./ single(pi));


%% Post processing
settings = [];
settings.DDR = DEdata;
settings.SF  = SFdata;

out = [];
out.IoF   = IoF;
out.wa    = waimg;
out.sfimg = sfimg;
out.d_au  = d_au;
out.settings = settings;

%%
end