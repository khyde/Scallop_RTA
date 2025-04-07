; $ID:	SCALLOPS_SHAPEFILE.PRO,	2024-07-15-16,	USER-KJWH	$
  PRO SCALLOPS_SHAPEFILE

;+
; NAME:
;   SCALLOPS_SHAPEFILE
;
; PURPOSE:
;   $PURPOSE$
;
; PROJECT:
;   SCALLOPS
;
; CALLING SEQUENCE:
;   SCALLOPS_SHAPEFILE,$Parameter1$, $Parameter2$, $Keyword=Keyword$, ....
;
; REQUIRED INPUTS:
;   Parm1.......... Describe the positional input parameters here. 
;
; OPTIONAL INPUTS:
;   Parm2.......... Describe optional inputs here. If none, delete this section.
;
; KEYWORD PARAMETERS:
;   KEY1........... Document keyword parameters like this. Note that the keyword is shown in ALL CAPS!
;
; OUTPUTS:
;   OUTPUT.......... Describe the output of this program or function
;
; OPTIONAL OUTPUTS:
;   None
;
; COMMON BLOCKS: 
;   None
;
; SIDE EFFECTS:  
;   None
;
; RESTRICTIONS:  
;   None
;
; EXAMPLE:
; 
;
; NOTES:
;   $Citations or any other useful notes$
;   
; COPYRIGHT: 
; Copyright (C) 2024, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on July 15, 2024 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Jul 15, 2024 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'SCALLOPS_SHAPEFILE'
  COMPILE_OPT IDL3
  SL = PATH_SEP()
    
  SHAPESIN = ['MAB_ALL','MAB_2024','GB_2024','MAB_2022']
  FOR S=0, N_ELEMENTS(SHAPESIN)-1 DO BEGIN
    CASE SHAPESIN[S] OF
      'MAB_2022': BEGIN 
        SHAPEIN = 'MAB_Scallop_Estimation_Areas_2022_UTM18_PDT_ET'
        SHAPEOUT = 'MAB_Scallop_Estimation_Areas_2022_80meters'
       END
       'MAB_2024': BEGIN
         SHAPEIN = 'Scallop_2024_MAB_Est_Areas_SAMS_CASA_UTM18_EDAB'
         SHAPEOUT = 'Scallop_2024_MAB_Est_Areas_SAMS_CASA_UTM18_EDAB_80meters'
       END
       'GB_2024': BEGIN
         SHAPEIN = 'Scallop_2024_GB_Est_Areas_SAMS_CASA_UTM19_EDAB'
         SHAPEOUT = 'Scallop_2024_GB_Est_Areas_SAMS_CASA_UTM19_EDAB_80meters'
       END 
       'MAB_ALL': BEGIN
         SHAPEIN = 'Scallop_2024_MAB_Est_Areas_SAMS_CASA_UTM18_EDAB'
         SHAPEOUT = 'Scallop_2024_MAB_Total_Area_80meters'
       END  
    ENDCASE
  
    SUBAREAFILE = !S.SCALLOPS + 'SUBAREAS' + SL + SHAPEOUT + '.SAV'
  
    AMAP = 'GS1'
    DEPTH = -80
    
    ; ===> Create the new shapefile
    IF KEYWORD_SET(OVERWRITE) OR ~FILE_TEST(SUBAREAFILE) THEN BEGIN
  
      SHAPES = READ_SHPFILE(SHAPEIN,MAPP=AMAP)
      SUBS = STRUCT_COPY(SHAPES,TAGNAMES=['OUTLINE','MAPPED_IMAGE'],/REMOVE)
      TAGS = TAG_NAMES(SUBS)   
  
      MS = MAPS_SIZE(AMAP, PX=PX, PY=PY)
      LMASK = READ_LANDMASK(AMAP,/STRUCT)
      
      ; ===> Get bathymetry information and subset the isobath
      BATHY = READ_BATHY(AMAP)
         
      ; ===> Create a blank output map and make sure then land and coast line pixels are masked
      FIMG =  MAPS_BLANK(AMAP, FILL=0) ; Make a blank "final" image
      FIMG[LMASK.LAND] = 0
      FIMG[LMASK.COAST] = 0
      FIMG[WHERE(BATHY GT 80)] = 0
  
      SUBAREA_CODES = []
      SUBAREA_NAMES = []
      SUBTITLES     = []
      COUNTER = 1
      FOR T=0, N_ELEMENTS(TAGS)-1 DO BEGIN
        TEMPCODE = 100
        ALT80 = 1
        AGT80 = 2
        ASUBAREA_CODES = [ALT80,AGT80]
        ASUBAREA_NAMES = ['MAB_LT80','MAB_GT80']
        ASUBTITLES = ['MAB Scallop Estimation Area at 80 meters depth or less','MAB Scallop Estimation Area greater than 80 meters depth']
         
        ; ===> Make a temporary image file and fill in the subarea pixels
        BIMG = MAPS_BLANK(AMAP, FILL=0)
        BIMG[SUBS.(T).SUBS] = TEMPCODE
        
        OK = WHERE(BATHY LE 80 AND BIMG EQ TEMPCODE,COUNT)
        IF COUNT GT 0 THEN BEGIN
          ; ===> Create the "subarea" information for the save file (needed to convert to a shapefile)
          IF SHAPESIN[S] EQ 'MAB_ALL' THEN FIMG[OK] = ALT80 ELSE BEGIN
            FIMG[OK] = COUNTER
            NCODE = COUNTER
            SUBAREA_CODES = [SUBAREA_CODES, NCODE]
            SUBAREA_NAMES = [SUBAREA_NAMES,TAGS[T] + '_LT80']
            SUBTITLES = [SUBTITLES, 'MAB Scallop Estimation Area '+TAGS[T] + ' at 80 meters depth or less']
            COUNTER = COUNTER + 1
          ENDELSE  
          
        ENDIF  
  
        ; ===> Make a temporary image file and fill in the subarea pixels
        BIMG = MAPS_BLANK(AMAP, FILL=0)
        BIMG[SUBS.(T).SUBS] = TEMPCODE
        
        OK = WHERE(BATHY GT 80 AND BIMG EQ TEMPCODE,COUNT)
        IF COUNT GT 0 THEN BEGIN
          ; ===> Create the "subarea" information for the save file (needed to convert to a shapefile)
          IF SHAPESIN[S] EQ 'MAB_ALL' THEN FIMG[OK] = AGT80 ELSE BEGIN
            NCODE = COUNTER
            FIMG[OK] = NCODE
            SUBAREA_CODES = [SUBAREA_CODES, NCODE]
            SUBAREA_NAMES = [SUBAREA_NAMES,TAGS[T] + '_GT80']
            SUBTITLES = [SUBTITLES, 'MAB Scallop Estimation Area '+TAGS[T] + ' greater than 80 meters depth']
            COUNTER = COUNTER+1
          ENDELSE  
        ENDIF  
        
      ENDFOR ; TAGS
  
      IF SHAPESIN[S] EQ 'MAB_ALL' THEN BEGIN
        SUBAREA_CODES = ASUBAREA_CODES
        SUBAREA_NAMES = ASUBAREA_NAMES
        SUBTITLES     = ASUBTITLES
      ENDIF ELSE BEGIN
        SRT = SORT(SUBAREA_CODES)
        SUBAREA_CODES = SUBAREA_CODES[SRT]
        SUBAREA_NAMES = SUBAREA_NAMES[SRT]
        SUBTITLES     = SUBTITLES[SRT]
      ENDELSE  
      
  
      ; ===> Create the subarea .SAV
      STRUCT_WRITE, FIMG, FILE=SUBAREAFILE, PROD='SUBAREA', SUBAREA_CODE=SUBAREA_CODES,SUBAREA_NAME=SUBAREA_NAMES, MAP=AMAP, OVERWRITE=OVERWRITE, SUBAREA_TITLE=SUBTITLES 
    ENDIF
    
    ; Convert the subarea .SAV to a shapefile
    SUBAREAS_IMAGE_2SHP, SUBAREAFILE, SHPFILE=SHPFILE, REGION='NORTHEAST_SHELF', DIR_OUT=[], OVERWRITE=OVERWRITE, VERBOSE=VERBOSE
  
    ; ===> Read the shapefile to test it and create the output png files
    STRUCT = READ_SHPFILE(SHAPEOUT, MAPP='NES')
  
    
  ENDFOR  


END ; ***************** End of SCALLOPS_SHAPEFILE *****************
