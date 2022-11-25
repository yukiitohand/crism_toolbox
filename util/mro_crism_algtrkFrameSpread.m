function [algtrkfrsprd,xyz_iaumars,radii_out] = mro_crism_algtrkFrameSpread(DEdata,hkp_fpath,varargin)
% [algtrkfrsprd,xyz_iaumars] = mro_crism_algtrkFrameSpread(DEdata,hkp_fpath)
%  Calcuate Along Track Frame Spread which measures how smeared each frame 
%  is in the along track direction. In specific, how many meters the 
%  surface intercept of the boresight vector moved between the start and 
%  stop of the exposure of each frame. The surface intercept is obtained by
%  assuming 'Ellipsoid' shape of the Mars.
% INPUTS
%  DEdata: CRISMDDRdata class obj
%  hkp_fpath: file path to the house keeping table file.

if ~isa(DEdata,'CRISMDDRdata')
    error('DEdata must be an obj of class CRISMDDRdata');
end
if ~exist(hkp_fpath,'file')
    error('%s does not exist.',hkp_fpath);
end

radii_in = [];
ttp = {'start','mean','stop'};

if (rem(length(varargin),2)==1)
    error('Optional parameters should always go by pairs');
else
    for i=1:2:(length(varargin)-1)
        switch upper(varargin{i})
            case 'RADII'
                radii_in = varargin{i+1};
            case 'TTP'
                ttp = varargin{i+1};
            otherwise
                error('Unrecognized option: %s',varargin{i});
        end
    end
end

p = crism_lbl_get_sclk(DEdata.lbl);
sclkdec = crism_get_frame_sclkdec(hkp_fpath,ttp);
sclkch = crism_sclkdec2sclkch(sclkdec,p);
% rMars_m = 3396190; % meters
%% load SPICE KERNELs
spicekrnl_init;
tic;
SPICEMetaKrnlsObj = MRO_CRISM_SPICE_META_KERNEL(DEdata,'VERBOSE',0);
SPICEMetaKrnlsObj.set_defaut('dwld',0);
% SPICEMetaKrnlsObj.set_kernel_spk_sc_default('KERNEL_ORDER',{''});
SPICEMetaKrnlsObj.furnsh();
toc;

%% Get center latitude and longitde
if ~isempty(radii_in)
    [fpath_pck_mars_mod] = spice_pck_mars_overwrite_radii(radii_in);
    cspice_furnsh(fpath_pck_mars_mod);
end
%% SPICE SETUP
abcorr  =  'CN+S';
switch upper(DEdata.prop.sensor_id)
    case 'S'
        camera = 'MRO_CRISM_VNIR';
    case 'L'
        camera = 'MRO_CRISM_IR';
    otherwise
        error('Undefined sensor_id %s',DEdata.prop.sensor_id);
end
fixref  = 'IAU_MARS';
method  = 'Ellipsoid'; %'DSK/UNPRIORITIZED'; % or Ellipsoid
obsrvr  = 'MRO';
target  = 'Mars';
NCORNR  = 4;
SC      = -74999; % high precision sclkscet needs 999.
%
% Get the MRO CRISM IR camera ID code. Then look up the field of view (FOV)
% parameters.
%
[ camid, found ] = cspice_bodn2c( camera );
if ( ~found )
    error([ 'SPICE(NOTRANSLATION) ' ...
        'Could not find ID code for instrument %s.' ], ...
        camera);
end
%
% cspice_getfov will return the name of the camera-fixed frame in the 
% string 'dref', the camera boresight vector in the array 'bsight', and the
% FOV corner vectors in the array 'bounds'.
%
[shape, dref, bsight, cambounds] = cspice_getfov( camid, NCORNR);
%
%%
[L,N] = size(sclkch);
xyz_iaumars = nan(L,3,N);

for l=1:L
    % fprintf('Start processing for line=%d\n',l);
    for n=1:N
        % fprintf('j=%d\n',j);
        % tic;
        sclkch_ln = sclkch{l,n};
        %
        % SPICE part of the processing
        etrec = cspice_scs2e( SC, sclkch_ln );
        %
        % ----------- Boresight Surface Intercept -----------
        %
        % Retrieve the time, surface intercept point, and vector
        % from MRO to the boresight surface intercept point
        % in IAU_MARS coordinates.
        %
        % [ spoint, etemit, srfvec, found ] = ...
        %     cspice_sincpt( method, target, etrec, fixref, ...
        %                    abcorr, obsrvr, dref, bsight);
        [ spoint, etemit, srfvec, found ] = ...
            cspice_sincpt( method, target, etrec, fixref, ...
                           abcorr, obsrvr, dref, bsight);
        %
        % storing the result for combining FOV
        xyz_iaumars(l,:,n) = spoint;
    end
end

xyz_iaumars = xyz_iaumars * 1000; % Convert to the unit of meters.

% ALonG TRacK FRame SPReaD
idx_start = find(strcmpi(ttp,'start'),1);
idx_stop  = find(or(strcmpi(ttp,'stop'),strcmpi(ttp,'end')),1);
algtrkfrsprd = sqrt(sum((xyz_iaumars(:,:,idx_stop) - xyz_iaumars(:,:,idx_start)).^2,2));

radii_out = cspice_bodvrd( 'MARS', 'RADII', 3 )*1000;

tic;
% SPICEMetaKrnlsObj.unload();
cspice_kclear();
toc;
if ~isempty(radii_in)
    cspice_unload(fpath_pck_mars_mod);
end

end