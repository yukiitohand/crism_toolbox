# crism_toolbox
MRO CRISM data analysis toolkit

This toolbox is an MATLAB interface for handling MRO CRISM database([http://pds-geosciences.wustl.edu/missions/mro/crism.htm](http://pds-geosciences.wustl.edu/missions/mro/crism.htm)). You can download images into your local database organized in a same (or similar) way as the pds server. Resolving image locations and filenames can be simply done. You can directly work with PDS file without converting into CAT format. If you work on a large number of images given observation IDs, then this will be useful.

## Requirement
Some of my tooboxes are necessary.
* [https://github.com/yukiitohand/base](https://github.com/yukiitohand/base)
* [https://github.com/yukiitohand/envi](https://github.com/yukiitohand/envi)

## Installation
### Local directory setup
First you need to customize your setting/crismToolbox_default.json:
```json
{
    "localCRISM_PDSrootDir" : "",
    "localCATrootDir"       : "/../cat/CAT_v7_4/",
    "CAT_ver"               : "7.4",
    "local_fldsys"          : "pds_unified",
    "remote_fldsys"         : "pds_mro",
    "pds_unified_URL"       : "crism_pds_archive/",
    "pds_mro_URL"           : "pds-geosciences.wustl.edu/mro/",
    "LUT_OBSID2YYYY"        : "LUT_OBSID2YYYY_DOY.mat"
}
```
What you should specify is `localCRISM_PDSrootDir` where the local databse is created and `localCATrootDir` where CAT_ENVI/ is stored (like `[localCATrootDir]/CAT_ENVI/`). The others do not need to be changed unless you want a specific database structure. CAT Toolbox needs to be independently and manually downloaded and set up. CAT toolbox may not be necessary, but it is recommended to download it. With this setup, local database will be created at
```
[localCRISM_PDSrootDir]/crism_pds_archive/
```
More info at [crism_toolbox_json_moreinfo.md](https://github.com/yukiitohand/crism_toolbox/blob/master/crism_toolbox_json_moreinfo.md). If you opt to use a different remote server, please contact me.

### Add paths
Second, Add all the subfolders to matlab search paths.
```MATLAB
'crism_toolbox/',...
'crism_toolbox/base/',...
'crism_toolbox/base/atf_util/',...
'crism_toolbox/base/basename_util/',...
'crism_toolbox/base/connect/',...
'crism_toolbox/base/folder_resolver/',...
'crism_toolbox/base/lbl_util/',...
'crism_toolbox/base/readwrite/',...
'crism_toolbox/core/',...
'crism_toolbox/library/',...
'crism_toolbox/library/base/',...
'crism_toolbox/library/conv/',...
'crism_toolbox/library/folder_resolver/',...
'crism_toolbox/map/',...
'crism_toolbox/setting/',...
'crism_toolbox/util/',...
'crism_toolbox/util/ADRVS_util/',...
'crism_toolbox/util/BP_util/',...
'crism_toolbox/util/photocor/',...
```

### Final step
Finally, rename `setting/crismToolbox_default.json` to `setting/crismToolbox.json` and run 
```MATLAB
> crism_init
```
If you add `crism_init` in your MATLAB startup script, you do not need to run every time you start MATLAB.

## Downloading images
If you want to download a set of images of the given observation ID, 
```matlab
> crism_obs = CRISMObservation(obs_id,'sensor_id','L','DOWNLOAD_TER',2,'DOWNLOAD_MTRDR',2,'DOWNLOAD_TRRIF',2,...
'DOWNLOAD_TRRRA',2,'DOWNLOAD_EDRSCDF',2,'DOWNLOAD_DDR',2,'DOWNLOAD_EPF',2);
```
`obs_id` can be non-zero padded string. `CRISMObservation` internally resolve all the filenames and directory path of the images in the scene. Of course you do not need to set all the download options. Setting any download option to 2 actually download the image. if 1 is set, remote access is performed, but download is not performed. If set to 0, then no remote access is performed.


## Basic Operations
Reading the image can be performed as simply as
```matlab
> TRRIFdata = CRISMdata('HRL000040FF_07_IF183L_TRR3','');
```
The second input variable is actually supposed to be a directory path to the image file. If it's set empty, then it is estimated. Reading the image can be performed by
```MATLAB
> TRRIFdata.readimg();
```
or if you reverse the band
```MATLAB
> TRRIFdata.readimgi();
```
If you haven't downloaded, you can download the image to the local database by 
```MATLAB
> TRRIFdata.download(2);
```
## Tips
Maybe you want to start with a given observation ID, then start with
```matlab
> crism_obs = CRISMObservation(obs_id,'sensor_id','L');
```
Then following code allows you to get scene image.
```matlab
> crism_obs.load_default();
> TRRIFdata = crism_obs.data.if;
> TRRIFdata.readimg();
```

