; $ID:	SCALLOPS_MAIN.PRO,	2023-10-23-12,	USER-KJWH	$
  PRO SCALLOPS_MAIN

;+
; NAME:
;   SCALLOPS_MAIN
;
; PURPOSE:
;   $PURPOSE$
;
; PROJECT:
;   SCALLOPS
;
; CALLING SEQUENCE:
;   Result = SCALLOPS_MAIN($Parameter1$, $Parameter2$, $Keyword=Keyword$, ...)
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
; Copyright (C) 2023, Department of Commerce, National Oceanic and Atmospheric Administration, National Marine Fisheries Service,
;   Northeast Fisheries Science Center, Narragansett Laboratory.
;   This software may be used, copied, or redistributed as long as it is not sold and this copyright notice is reproduced on each copy made.
;   This routine is provided AS IS without any express or implied warranties whatsoever.
;
; AUTHOR:
;   This program was written on October 23, 2023 by Kimberly J. W. Hyde, Northeast Fisheries Science Center | NOAA Fisheries | U.S. Department of Commerce, 28 Tarzwell Dr, Narragansett, RI 02882
;    
; MODIFICATION HISTORY:
;   Oct 23, 2023 - KJWH: Initial code written
;-
; ****************************************************************************************************
  ROUTINE_NAME = 'SCALLOPS_MAIN'
  COMPILE_OPT IDL3
  SL = PATH_SEP()
  
  PROJECT = 'SCALLOPS'
  VER = 'V2023'
  DIR_PROJECT = GET_PROJECT_DIR(PROJECT)
  VERSTR = PROJECT_VERSION_DEFAULT(PROJECT,VERSION=VER)
  
  ; ===> Manually adjust the ILLEX program steps as needed
  IF HAS(EXTRA,'DATA_EXTRACTS' )     THEN DATA_EXTRACTS = 1 ELSE DATA_EXTRACTS = 1
  IF HAS(EXTRA,'STACKED_TIMESERIES') THEN STACKED_TIMESERIES = 1 ELSE STACKED_TIMESERIES = 1
  IF HAS(EXTRA,'SUBAREA_MAP' )       THEN SUBAREA_MAP = 1 ELSE SUBAREA_MAP = 0
  IF HAS(EXTRA,'GIT_PUSH' )          THEN GIT_PUSH = 1 ELSE GIT_PUSH = 0
  
 ; STACKED_STATS_WRAPPER, 'OCCCI', PRODS='CHLOR_A-CCI', PERIODS='M4'
  
; STOP 
  IF KEYWORD_SET(DATA_EXTRACTS)      THEN PROJECT_SUBAREA_EXTRACT, VERSTR 
 ; IF KEYWORD_SET(STACKED_TIMESERIES) THEN PROJECT_STACKED_TIMESERIES_PLOT, VERSTR, BUFFER=1

  STOP
  IF KEYWORD_SET(SUBAREA_MAP) THEN BEGIN
    
    MAPS = 'MAB'
    PAL_LANDMASK,RR,GG,BB
    
    C = READ_SHPFILE('MAB_CANYONS', MAPP=MAPS)
    B = PLT_TOPO(MAPS, [-35,-80, -200], THICKS=THICKS, COLORS=COLORS) & BOK = WHERE(B EQ 1) 
    R = READ_SHPFILE('MAB_ESTIMATION_AREAS_2023_UTM18_PDT_NYB',MAPP=MAPS)
    TAGS = TAG_NAMES(R)
    TAGS = TAGS[WHERE(TAGS NE 'OUTLINE' AND TAGS NE 'MAPPED_IMAGE')]
    NTAGS = N_ELEMENTS(TAGS)
    
    IMG = READ_LANDMASK(MAPS)
    
    CLRS = BINDGEN(250)+1
    SC = SCALE([1,250],[0,NTAGS],INTERCEPT=INTERCEPT,SLOPE=SLOPE)
    CLRS = 0 > (CLRS-FLOAT(INTERCEPT))/FLOAT(SLOPE) < 250 
    
    FOR S=0, NTAGS-1 DO BEGIN
      IMG_SUBS = R.(S).SUBS
      IMG[IMG_SUBS] = CLRS[S]
    ENDFOR
    
   ; IMG[C.OUTLINE] = 253
    IMG[BOK] = 252
    
    WRITE_PNG,!S.SCALLOPS + 'MAB_ESTIMATION_AREAS.png', IMG, RR,GG,BB  
  ENDIF
  

END ; ***************** End of SCALLOPS_MAIN *****************
