function [pos_mro_wrt_mars,rotate] = spice_get_pos_rotmat( ...
    SC,method,target,fixref,abcorr,obsrvr,dref,bsight,sclkch)

etrec = cspice_scs2e( SC, sclkch );
%
% ----------- Boresight Surface Intercept -----------
%
% Retrieve the time, surface intercept point, and vector
% from MRO to the boresight surface intercept point
% in IAU_MARS coordinates.
%
[ spoint, etemit, srfvec, found ] = ...
    cspice_sincpt( method, target, etrec ,  fixref, ...
                   abcorr, obsrvr, dref, bsight);
%
% assumed etemit is approximately same.
%
% ------ 1st Boundary FOV Surface Intercept (cspice_surfpt) -----
% 
% Find the rotation matrix from the ray's reference
% frame at the time the photons were received (etrec)
% to IAU_MARS at the time the photons were emitted
% (etemit).
%
[rotate] = cspice_pxfrm2( dref, 'IAU_MARS', etrec, etemit );
%
% Find the position of the center of Mars with respect
% to MRO.  The position of the observer with respect
% to Mars is required for the call to 'cspice_surfpt'.  Note:
% the apparent position of MRO with respect to Mars is
% not the same as the negative of Mars with respect to MRO.
%
pos_mro_wrt_mars = spoint - srfvec;
pos_mro_wrt_mars = pos_mro_wrt_mars*1000;

end