; https://hesperia.gsfc.nasa.gov/ssw/soho/mdi/idl_old/gen/ys_util/fmt_tag.pro

function fmt_tag,dsize
;
;+
; NAME:
;	FMT_TAG
;
; PURPOSE:
;	Converts a data structure (as represented by the IDL SIZE
;	its to string representation for dynamic structure building 
;
; CALLING SEQUENCE:
;	user_value = FMT_TAG( SIZE (data_structure))  
;
; INPUTS:
;	DSIZE - size vector for desired data structure 
;
; RETURN VALUE:
;	Character string representing data structure
;
; EXAMPLES:
;	if user variable X was created by: FINDGEN(2,3,4,5), then 
;       then FMT_TAG(SIZE(X)) returns string 'FLTARR(2, 3, 4, 5)'
;
; FILE I/O:
;	NONE
;
; COMMON BLOCKS;
;	NONE
;
; RESTRICTIONS:
;	Structures not yet implemented
;
; MODIFICATION HISTORY:
;	Version 1 - SLF, 3/5/91
;-
;
; define string arrays for each data type - need slightly different
; syntax for scalers, arrays, and structures
scalers=["''",'0B','0','0L','0.0','0.0D','complex(0.,0.)', $
          "''",'{dummy,']
;
arrays=['','bytarr(','intarr(','lonarr(','fltarr(', $
            'double(fltarr(', 'complex(fltarr(','strarr(','{dummy,']
;
close_par=['',')',')',')',')','))','))',')','']
;
type_pt = n_elements(dsize)-2		; data type loc in size(data)
dtype = dsize(type_pt)			; data type ( 0-8 )
;
; for scalers and structures, select entry from scaler array
;
if dsize(0) eq 0 or dtype eq 8 then substring = scalers(dtype) $
   else begin ; for other arrays, construct array declaration string
;
      dimensions=dsize(1:type_pt-1)
      fmt = '(' + string(dsize(0)) +    '(i6,:,","))'
      dimen_list = strcompress(string(dimensions,format=fmt))
      substring=arrays(dtype) + dimen_list + $
             close_par(dtype)
   endelse
;
return,substring
end
