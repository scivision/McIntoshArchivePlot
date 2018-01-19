pro plotfinal,crot=crot,dirname=dirname,scalecrop=scalecrop,dodisplay=dodisplay,dogrid=dogrid,doannot=doannot,highlat=highlat,plotext=plotext,choice=choice,charsize=charsize,charthick=charthick,fatfil=fatfil,fatsun=fatsun,jpeg=jpeg,polsun=polsun,verbose=verbose

; this code makes custom gif plots from input fits files given CROT number
;
; Sample call:  plotfinal,crot='1931'
;
; Keywords 
;	   CROT: Carrington rotation number
;		Default - 1931
;          DIRNAME: directory name if fits file not in local directory
;		Default-- unset
;	   SCALECROP:
; 		scaled pixel size (degrees)
; 		can be used to decrease resolution of plots
;		(not advised)
;		Default = 0.09
;	   DODISPLAY:
; 		whether to display on screen or just make gifs/jpegs
;		0: no display
;		1 display
;		Default -- 1
;	   DOGRID
; 		whether to plot a grid
;		0: no grid
;		1: grid
;		Default - 1
;	   DOANNOT
; 		whether to plot annotations
;		0: no annotations
;		1: minimal annotations
;		2: full annotations
;		Default - 2
;	   HIGHLAT
;		What to do above/below 70 degrees
; 		highlat 0 will plot all data at all latitudes
; 		highlat 1 will plot everything at high latitudes as yellow 
;			EXCEPT coronal holes
; 		highlat 2 will plot everything at high latitudes as yellow
;			EXCEPT coronal hole boundaries
; 		highlat 3 will plot everything at high latitudes as yellow 
;		Default - 2
;	  PLOTEXT
; 		Whether or not to plot the +/- 30 degrees extension to maps
;		0: no extension
;		1: extension
;		Default - 1
;	   CHOICE
; 		color table choice
; 		(see patmapcolortable.pro for choices)
;		Default 1 (unless POLSUN set, then 3)
;	   CHARSIZE
;		character size scaled to inverse of resolution
;		Default 1/scalecrop
;	   CHARTHICK
;		character size scaled to inverse of resolution
;		Default .75/scalecrop
;	   FATFIL
;		increase thickness of filaments
;		degrees thick
;		Default .5
;	   FATSUN
;		increase thickness of sunspot
;		degrees thick
;		Default 0 (no thickening)
;	   POLSUN
;		whether to distinguish negative/positive polarity
;		if set, will plot negative polarity sunspots as rose-colored, positive as orange
;		Default 0 (all sunspots will be orange)
;	   JPEG
;		save a jpeg as well as a gif
;		Only set up for GRIDANNOT plots
;		Default 0 (no)

!PATH=!PATH+':utils/'

default,crot,1931
default,scalecrop,0.09
scalecrop=float(scalecrop)
default,dodisplay,1
default,dogrid,1
default,doannot,2
default,highlat,2
default,plotext,1
default,charsize,1./scalecrop
default,charthick,.75/scalecrop
default,fatfil,.5
default,fatsun,0
default,polsun,0
default,jpeg,0
default,verbose,0
if polsun eq 0 then default,choice,1 else default,choice,3

;
; plotting set up

!p.charsize=charsize
!p.charthick=charthick

; set up name for output files

filename='CR'+strtrim(string(crot),2)

; set up name for input files

if crot ne 1503 then begin
  date=anytim(carr2ex(crot),/ccsds)
endif else date='1966-01-09T09:36:08.64'
yyyy=strmid(date,0,4)
mm=strmid(date,5,2)
dd=strmid(date,8,2)
hh=strmid(date,11,2)
mmin=strmid(date,14,2)
ss=strmid(date,17,2)

nameconvent='ptmc_compo_sm_'+yyyy+mm+dd+'_'+hh+mmin+ss+'_cr'+strtrim(string(crot),2)
if keyword_set(dirname) then nameconvent=dirname+'/'+nameconvent

;
; Read FITS file:
;
; First the main data/header--
; this is the cropped data that can be used for analysis

print,nameconvent

if file_exist(nameconvent+'_l3.fits') then fnameuse=nameconvent+'_l3.fits' else begin
  if file_exist(nameconvent+'_l3.fits.gz') then fnameuse=nameconvent+'_l3.fits.gz'  else begin
   print,'Neither '+nameconvent+'_l3.fits nor '+nameconvent+'_l3.fits.gz exist.'
   goto,abort
  endelse
endelse

print,fnameuse

mreadfits,fnameuse,header,image

;
; now the auxiliary fits files
; containing full image (including extension)
; longitude, and latitude
;
; these can be used to generate the various plot versions
;

fits_read,fnameuse,finalimage_save,exten_no=1
fits_read,fnameuse,longitude,exten_no=2
fits_read,fnameuse,latitude,exten_no=3
fits_read,fnameuse,polarity,exten_no=4

;
; load the colortable

patmapcolortable,r,g,b,choice=choice

; 
; get info from header
; and make grid
;

dimx=header.fullax1
dimy=header.fullax2

xgrid=intarr(dimx,dimy)
ygrid=intarr(dimx,dimy)
for j = 0,dimy-1 do xgrid(0:dimx-1,j)=dindgen(dimx)
for i =0,dimx-1 do ygrid(i,0:dimy-1)=dindgen(dimy)

pixsizex=1./header.cdelt1
pixsizey=1./header.cdelt2

finalimage=finalimage_save

;
; show sunspot polarity if POLSUN set
;

if polsun eq 1 then begin
 test = where(finalimage eq 10 and polarity eq -1)
 if min(test) ne -1 then finalimage(test)=14
endif

;
; if highlat nonzero then above 70 force missing
;

if highlat ne 0 then begin
 if highlat eq 1 then begin
   test=where((ygrid le latitude(20) or ygrid ge latitude(160)) and finalimage ne 0 and finalimage ne 12 and finalimage ne 2 and finalimage ne 5 and finalimage ne 3 and finalimage ne 6)
    finalimage(test)=11
 endif
 if highlat eq 2 then begin
   test=where((ygrid le latitude(20) or ygrid ge latitude(160)) and finalimage ne 0 and finalimage ne 12 and finalimage ne 2 and finalimage ne 5)
    finalimage(test)=11
 endif
 if highlat eq 3 then begin
   test=where((ygrid le latitude(20) or ygrid ge latitude(160)) and finalimage ne 0 and finalimage ne 12)
    finalimage(test)=11
 endif
endif

; 
; get rid of extension if plotext=0
;

if plotext eq 0 then begin
 test = where(xgrid lt longitude(30) or xgrid gt longitude(390))
 finalimage(test)=0
;
; 0 longitude
;
  finalimage(longitude(30)-round(pixsizex/2.):longitude(30)+round(pixsizex/2.),latitude(0):latitude(180))=1
;
; 360 longitude
;
  finalimage(longitude(390)-round(pixsizex/2.):longitude(390)+round(pixsizex/2.),latitude(0):latitude(180))=1
endif 

; make filaments fat

finalimageold=finalimage

if fatfil ne 0 then begin
 steplat=fix(fatfil*pixsizey)
 for i = 0,dimx-1 do begin
  for j = steplat,dimy-steplat-1 do begin
   if finalimageold(i,j) eq 9 then begin
    for k = 1,steplat-1 do begin
     finalimage(i,j-k)=9
     finalimage(i,j+k)=9
    endfor
   endif
  endfor
 endfor
endif
if fatsun ne 0 then begin
 steplat=fix(fatsun*pixsizey)
 steplon=fix(fatsun*pixsizex)
 for i = steplon,dimx-steplon-1 do begin
  for j = steplat,dimy-steplat-1 do begin
   if finalimageold(i,j) eq 10 then begin
    for k = 1,steplat-1 do begin
     finalimage(i,j-k)=10
     finalimage(i,j+k)=10
    endfor
    for k = 1,steplon-1 do begin
     finalimage(i-k,j)=10
     finalimage(i+k,j)=10
    endfor
   endif
   if finalimageold(i,j) eq 14 then begin
    for k = 1,steplat-1 do begin
     finalimage(i,j-k)=14
     finalimage(i,j+k)=14
    endfor
    for k = 1,steplon-1 do begin
     finalimage(i-k,j)=14
     finalimage(i+k,j)=14
    endfor
   endif
  endfor
 endfor
endif

; add grid 

if dogrid eq 1 then begin

 if plotext eq 1 then begin
  lonmin=0
  lonmax=420
 endif else begin
  lonmin=30
  lonmax=390
 endelse

 imageregrid=finalimage

 for lat=20.,160.,10. do imageregrid(longitude(lonmin)+round(pixsizex/2.):longitude(lonmax)-round(pixsizex/2.),latitude(lat)-round(pixsizey/10.):latitude(lat)+round(pixsizey/10.))=1
 for lon=lonmin+10.,lonmax-10.,10. do imageregrid(longitude(lon)-round(pixsizex/10.):longitude(lon)+round(pixsizex/10.),latitude(20)+round(pixsizey/2.):latitude(160)-round(pixsizey/2.))=1
;
; equator
;
 imageregrid(longitude(lonmin)+round(pixsizex/2.):longitude(lonmax)-round(pixsizex/2.),latitude(90)-round(pixsizey/4.):latitude(90)+round(pixsizey/4.))=1

;
; 180 longitude
;
 imageregrid(longitude(210)-round(pixsizex/4.):longitude(210)+round(pixsizex/4.),latitude(0)+round(pixsizey/2.):latitude(180)+round(pixsizey/2.))=1

;
; make outer boundary black
;

 test=where(imageregrid eq 12)
 imageregrid(test)=1

endif

;
; now crop and scale
;

if plotext eq 0 then begin
 finalimage_crop=finalimage[longitude[30]:longitude[390],latitude[0]:latitude[180]] 
 if dogrid eq 1 then imageregrid_crop=imageregrid[longitude[30]:longitude[390],latitude[0]:latitude[180]] 
 dimxscale=361/scalecrop
endif else begin
 finalimage_crop=finalimage[longitude[0]:longitude[420],latitude[0]:latitude[180]] 
 if dogrid eq 1 then imageregrid_crop=imageregrid[longitude[0]:longitude[420],latitude[0]:latitude[180]] 
 dimxscale=421/scalecrop
endelse

dimyscale=181/scalecrop

sizecrop=size(finalimage_crop)
cropx=sizecrop(1)
cropy=sizecrop(2)
scalingx=dimxscale/cropx
scalingy=dimyscale/cropy
if scalingx lt .99 or scalingy lt .99 or scalingx gt 1.02 or scalingy gt 1.02 then begin
 if verbose eq 1 then begin
  print,'new x=',dimxscale
  print,'old x=',cropx
  print,'new y=',dimyscale
  print,'old y=',cropy
  print,scalingx,scalingy
 endif
endif
if scalingx lt .95 or scalingy lt .95 then printf,-2,'WARNING: Interpolated image lower resolution than original'

finalimage_scale=congrid(finalimage_crop,dimxscale,dimyscale)

if dogrid eq 1 then imageregrid_scale=congrid(imageregrid_crop,dimxscale,dimyscale)

;
; make nogridannot plots
;

if dogrid eq 0 then begin

 if plotext eq 1 and highlat eq 0 then write_gif,filename+'_final_nogridannot.gif',finalimage_scale,r,g,b 
 if plotext eq 0 and highlat eq 0 then write_gif,filename+'_final_nogridannot_noext.gif',finalimage_scale,r,g,b 
 if plotext eq 1 and highlat eq 1 then write_gif,filename+'_final_nogridannot_miss_ch.gif',finalimage_scale,r,g,b 
 if plotext eq 0 and highlat eq 1 then write_gif,filename+'_final_nogridannot_noext_miss_ch.gif',finalimage_scale,r,g,b
 if plotext eq 1 and highlat eq 2 then write_gif,filename+'_final_nogridannot_miss_chbound.gif',finalimage_scale,r,g,b 
 if plotext eq 0 and highlat eq 2 then write_gif,filename+'_final_nogridannot_noext_miss_chbound.gif',finalimage_scale,r,g,b
 if plotext eq 1 and highlat eq 3 then write_gif,filename+'_final_nogridannot_miss.gif',finalimage_scale,r,g,b 
 if plotext eq 0 and highlat eq 3 then write_gif,filename+'_final_nogridannot_noext_miss.gif',finalimage_scale,r,g,b

 if dodisplay eq 1 then begin
  device,decomposed=0
  window,0,xs=dimxscale*scalecrop*2,ys=dimyscale*scalecrop*2
  tvlct,r,g,b
  tv,congrid(finalimage_scale,dimxscale*scalecrop*2,dimyscale*scalecrop*2)
 endif

endif
;
; now more grid and annot
;

if dogrid eq 1 then begin

;
; we will be adding white space for annotations
; (space will be there even if annotations are not)
;

 padx=2*fix(50/scalecrop)
 pady=2*fix(70/scalecrop)

 dimxscalepad=dimxscale+padx
 dimyscalepad=dimyscale+pady

 imageregrid_scalepad=bytarr(dimxscalepad,dimyscalepad)
 for i = 0,dimxscale-1 do begin
   for j = 0,dimyscale-1 do begin
    imageregrid_scalepad(i+padx/2,j+pady/2)=imageregrid_scale(i,j)
   endfor
 endfor

;
; if plotting extended map indicate real boundaries
; of carrington rotation
;

 long0=(padx/2 + (30-lonmin)/scalecrop)/dimxscalepad
 long180=long0 + 180/scalecrop/dimxscalepad
 long360=long0 + 360/scalecrop/dimxscalepad
 longmin=padx/2/dimxscalepad 
 longmax=longmin+lonmax/scalecrop/dimxscalepad
 lat0=pady/2/dimyscalepad
 lat90=lat0+90/scalecrop/dimyscalepad
 lat180=lat0+180/scalecrop/dimyscalepad

 if plotext eq 1 then begin
;
; 0 longitude
;
  imageregrid_scalepad(long0*dimxscalepad-round(0.5/scalecrop):long0*dimxscalepad+round(0.5/scalecrop),lat0*dimyscalepad-round(8./scalecrop):lat180*dimyscalepad+round(8./scalecrop))=1
;
; 360 longitude
;
  imageregrid_scalepad(long360*dimxscalepad-round(0.5/scalecrop):long360*dimxscalepad+round(0.5/scalecrop),lat0*dimyscalepad-round(8./scalecrop):lat180*dimyscalepad+round(8./scalecrop))=1
 endif

 imageuse=imageregrid_scalepad
 thisDevice = !D.Name

 if doannot ne 0 then begin
  set_plot,'z'
  device,set_resolution=[dimxscalepad,dimyscalepad]
  tvlct,r,g,b
  tv,imageuse

  xyouts,0.5,0.82,filename,charsize=charsize,charthick=charthick,color=1,alignment=.5

  xyouts,long0,0.15,'0',charsize=charsize*2./3.,charthick=charthick,color=1,alignment=.5
  xyouts,long180,0.16,'180',charsize=charsize*2./3.,charthick=charthick,color=1,alignment=.5
  xyouts,long360,0.15,'360',charsize=charsize*2./3.,charthick=charthick,color=1,alignment=.5
  xyouts,(longmin-.025),(lat0-.01),'-90',charsize=charsize*2./3.,charthick=charthick,color=1,alignment=.5
  xyouts,(longmin-.02),(lat90-.01),'0',charsize=charsize*2./3.,charthick=charthick,color=1,alignment=.5
  xyouts,(longmin-.02),(lat180-.01),'90',charsize=charsize*2./3.,charthick=charthick,color=1,alignment=.5

;
; additional annotations
;

  if doannot eq 2 then begin

   xyouts,0.5,0.95,'McIntosh Archive Synoptic Map',charsize=charsize*2./3.,charthick=charthick,color=1,alignment=.5

   bangstart=header.B0
   bangstart=round(bangstart*100.)/100.
   datestop=anytim(carr2ex(crot+1.),/ccsds)
   bangend=pb0r(datestop)
   bangend=round(bangend[1]*100.)/100.

   xyouts,0.8,0.9,'Start date (longitude=360):'+strtrim(strmid(date,0,19),2),charsize=charsize/2.,charthick=charthick,color=1,alignment=.5
   xyouts,0.2,0.9,'End date (longitude=0):'+strtrim(strmid(datestop,0,19),2),charsize=charsize/2.,charthick=charthick,color=1,alignment=.5
   xyouts,0.8,0.85,'B angle start date '+strmid(strtrim(string(bangstart),2),0,5),charsize=charsize*7./12.,charthick=charthick,color=1,alignment=.5
   xyouts,0.2,0.85,'B angle end date '+strmid(strtrim(string(bangend),2),0,5),charsize=charsize*7./12.,charthick=charthick,color=1,alignment=.5

   testmissing=where(imageuse eq 11)
   if highlat eq 0 and min(testmissing) ne -1 then begin
    if verbose eq 1 then begin
     print,'*************************************'
     print,'*************************************'
     print,'*************************************'
     print,'**************missing data***********'
     print,crot
     print,'*************************************'
     print,'*************************************'
     print,'*************************************'
     print,'*************************************'
     print,'*************************************'
     print,'*************************************'
    endif
   endif
   if polsun eq 0 then begin
    if min(testmissing) ne -1 then begin
     colorbar,ncolors=9,position=[0.14,0.07,0.725,0.12],bottom=2,minor=0,major=0,color=0,ticklen=0.
     colorbar,ncolors=1,position=[0.724,0.07,0.79,0.12],bottom=13,minor=0,major=0,color=0,ticklen=0.
     colorbar,ncolors=1,position=[0.79,0.07,0.855,0.12],bottom=11,minor=0,major=0,color=0,ticklen=0.
     if plotext eq 1 then xyouts,0.5,0.13,'           pos. CH               pos. pol.               neg. CH               neg. pol.         PIL         filament       sunspot      plage group     missing       ',charsize=charsize/3.,charthick=charthick,color=1,alignment=.5 $
         else xyouts,0.5,0.13,'                  pos. CH            pos. pol.             neg. CH          neg. pol.       PIL         filament     sunspot    plage group   missing             ',charsize=charsize/3.,charthick=charthick,color=1,alignment=.5 
    endif else begin
     colorbar,ncolors=9,position=[0.15,0.07,0.775,0.12],bottom=2,minor=0,major=0,color=0,ticklen=0.
     colorbar,ncolors=1,position=[0.775,0.07,0.84,0.12],bottom=13,minor=0,major=0,color=0,ticklen=0.
     if plotext eq 1 then xyouts,0.5,0.13,'               pos. CH               pos. pol.                 neg. CH               neg. pol.           PIL           filament         sunspot      plage group      ',charsize=charsize/3.,charthick=charthick,color=1,alignment=.5 $
       else xyouts,0.5,0.13,'                      pos. CH             pos. pol.              neg. CH             neg. pol.        PIL         filament      sunspot     plage group               ',charsize=charsize/3.,charthick=charthick,color=1,alignment=.5 
    endelse   
   endif else begin
    if min(testmissing) ne -1 then begin
     colorbar,ncolors=9,position=[0.12,0.07,0.705,0.12],bottom=2,minor=0,major=0,color=0,ticklen=0.
     colorbar,ncolors=1,position=[0.7,0.07,0.765,0.12],bottom=14,minor=0,major=0,color=0,ticklen=0.
     colorbar,ncolors=1,position=[0.76,0.07,0.825,0.12],bottom=13,minor=0,major=0,color=0,ticklen=0.
     colorbar,ncolors=1,position=[0.82,0.07,0.885,0.12],bottom=11,minor=0,major=0,color=0,ticklen=0.
     if plotext eq 1 then xyouts,0.5,0.13,'                            pos. CH              pos. pol.              neg. CH              neg. pol.          PIL         filament     sunspot-pos sunspot-neg  plage group    missing                    ',charsize=charsize/3.,charthick=charthick,color=1,alignment=.5 $
         else xyouts,0.5,0.13,'                pos. CH            pos. pol.            neg. CH            neg. pol.       PIL        filament  sunspot-pos sunspot-neg plage group  missing         ',charsize=charsize/3.,charthick=charthick,color=1,alignment=.5 
    endif else begin
     colorbar,ncolors=9,position=[0.13,0.07,0.755,0.12],bottom=2,minor=0,major=0,color=0,ticklen=0.
     colorbar,ncolors=1,position=[0.75,0.07,0.815,0.12],bottom=14,minor=0,major=0,color=0,ticklen=0.
     colorbar,ncolors=1,position=[0.81,0.07,0.875,0.12],bottom=13,minor=0,major=0,color=0,ticklen=0.
     if plotext eq 1 then xyouts,0.5,0.13,'                      pos. CH                pos. pol.                neg. CH                neg. pol.          PIL           filament     sunspot-pos  sunspot-neg  plage group           ',charsize=charsize/3.,charthick=charthick,color=1,alignment=.5 $
       else xyouts,0.5,0.13,'                   pos. CH             pos. pol.             neg. CH              neg. pol.        PIL         filament   sunspot-pos sunspot-neg plage group        ',charsize=charsize/3.,charthick=charthick,color=1,alignment=.5 
    endelse   
   endelse
  endif
  imageregrid_annot=tvrd()
  imageuse=imageregrid_annot
 endif

 if jpeg eq 1 then begin
   tvlct,red,green,blue,/get
   ISize = size(imageuse)
   imagejpeg = bytarr(3,ISize(1),ISize(2))
   imagejpeg(0,*,*) = red(imageuse)
   imagejpeg(1,*,*) = green(imageuse)
   imagejpeg(2,*,*) = blue(imageuse)
 endif

 set_plot,thisDevice

; highlat 0 will keep everything as is (no yellow)
; highlat 1 will plot everything but coronal holes as yellow (default)
; highlat 2 will plot everything but coronal hole boundaries as yellow
; highlat 3 will plot everything above 70 as yellow 

 if doannot ne 0 then begin
  if plotext eq 1 and highlat eq 0 then  write_gif,filename+'_final_gridannot.gif',imageuse,r,g,b 
  if plotext eq 1 and highlat eq 0 and jpeg eq 1 then begin
     write_jpeg,filename+'_final_gridannot.jpeg',imagejpeg,/true,quality=100
  endif
  if plotext eq 0 and highlat eq 0 then write_gif,filename+'_final_gridannot_noext.gif',imageuse,r,g,b 
  if plotext eq 1 and highlat eq 1 then write_gif,filename+'_final_gridannot_miss_ch.gif',imageuse,r,g,b 
  if plotext eq 0 and highlat eq 1 then write_gif,filename+'_final_gridannot_noext_miss_ch.gif',imageuse,r,g,b
  if plotext eq 1 and highlat eq 2 then write_gif,filename+'_final_gridannot_miss_chbound.gif',imageuse,r,g,b 
  if plotext eq 0 and highlat eq 2 then write_gif,filename+'_final_gridannot_noext_miss_chbound.gif',imageuse,r,g,b
  if plotext eq 1 and highlat eq 3 then write_gif,filename+'_final_gridannot_miss.gif',imageuse,r,g,b 
  if plotext eq 0 and highlat eq 3 then write_gif,filename+'_final_gridannot_noext_miss.gif',imageuse,r,g,b
 endif else begin
  if plotext eq 1 and highlat eq 0 then  write_gif,filename+'_final_gridnoannot.gif',imageuse,r,g,b 
  if plotext eq 1 and highlat eq 0 and jpeg eq 1 then begin
     write_jpeg,filename+'_final_gridnoannot.jpeg',imagejpeg,/true,quality=100
  endif
  if plotext eq 0 and highlat eq 0 then write_gif,filename+'_final_gridnoannot_noext.gif',imageuse,r,g,b 
  if plotext eq 1 and highlat eq 1 then write_gif,filename+'_final_gridnoannot_miss_ch.gif',imageuse,r,g,b 
  if plotext eq 0 and highlat eq 1 then write_gif,filename+'_final_gridnoannot_noext_miss_ch.gif',imageuse,r,g,b
  if plotext eq 1 and highlat eq 2 then write_gif,filename+'_final_gridnoannot_miss_chbound.gif',imageuse,r,g,b 
  if plotext eq 0 and highlat eq 2 then write_gif,filename+'_final_gridnoannot_noext_miss_chbound.gif',imageuse,r,g,b
  if plotext eq 1 and highlat eq 3 then write_gif,filename+'_final_gridnoannot_miss.gif',imageuse,r,g,b 
 endelse

; display it
 if dodisplay eq 1 then begin
  device,decomposed=0
  window,1,xs=dimxscalepad*scalecrop*2,ys=dimyscalepad*scalecrop*2
  tvlct,r,g,b
  tv,congrid(imageuse,dimxscalepad*scalecrop*2,dimyscalepad*scalecrop*2)
 endif

endif

abort:
end

