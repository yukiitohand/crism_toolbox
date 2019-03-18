# crism_toolbox
MRO CRISM data analysis toolkit

This toolbox serves as an MATLAB interface for handling MRO CRISM database([http://pds-geosciences.wustl.edu/missions/mro/crism.htm](http://pds-geosciences.wustl.edu/missions/mro/crism.htm)). You can download images into your local database organized in a same (or similar) way as the pds server. Resolving image locations and filenames can be simply done. You can directly work with PDS file without converting into CAT format.

## Requirement
Some of my tooboxes are necessary.
* [https://github.com/yukiitohand/base](https://github.com/yukiitohand/base)
* [https://github.com/yukiitohand/envi](https://github.com/yukiitohand/envi)

## Installation
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
What you should specify is `localCRISM_PDSrootDir` where the local databse is created and `localCATrootDir` where CAT_ENVI/ is stored. The others do not need to be changed unless you want to a specific database structure. CAT Toolbox needs to be independently and manually downloaded and set up. CAT toolbox may not be necessary, but it is recommended to download it. If you opt to use a different remote server, please contact me. With this setup, local database will be created at
```
[localCRISM_PDSrootDir]/crism_pds_archive/
```
Some more information for the setup file.
* `localCRISM_PDSrootDir`: root directory path for which the database will be downloaded.
* `lovcalCATrootDir`     : directory path for which CAT_ENVI is stored.
* `CAT_ver`              : version of the CAT
* `local_fldsys`         : database system (`'pds_mro'` and `'pds_unified'` is supported now)
* `remote_fldsys`        : database system (`'pds_mro'` is supported)
* `pds_unified_URL`      : root directory name or path for the folder system `'pds_unified'`
* `pds_mro_URL`          : root directory name or path for the folder system `'pds_mro'`
* `LUT_OBSID2YYYY`       : the name of the mat file for which yyyy_doy look up table is stored. The table comes with the toolbox, so you do not need to change.

Second, rename setting/crismToolbox_default.json to setting/crismToolbox.json. and run 
```MATLAB
> crism_setup
```

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

