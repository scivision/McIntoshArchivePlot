pro patmapcolortable,r,g,b,choice=choice

!PATH=!PATH+':utils/'

; choice 0 -- original color table
; choice 1 -- custom 1
; choice 2 -- custom 2
; choice 3 -- custom 3

default,choice,0
;
; levelthree uses 1

;
; make color table
;

; Change all r,g,b tables to 0's
r=bytarr(256)
g=bytarr(256)
b=bytarr(256)

if choice eq 0 then begin

; first color is white=0 from CR####_orig.gif
 r(0)=255
 g(0)=255
 b(0)=255

; Second color is black=1 from CR####_orig.gif (no need to assign r,g,b(1)=0, since all 0's)

; 3rd color is navy for pos CH bndry
 b(2)=128

; 4th color is blue for pos CH
 b(3)=255

; 5th color is light cyan for positive polarity
 r(4)=224
 g(4)=255
 b(4)=255

; 6th color is magenta for neg CH bndry
 r(5)=255
 b(5)=255

; 7th color is red for neg CH
 r(6)=255

; 8th color is silver for negative polarity
 r(7)=192
 g(7)=192
 b(7)=192

; 9th color is dark green for NL or PIL line 
 r(8)=52
 g(8)=90
 b(8)=15

; 10th color is bright green for filaments (ie, solid NL or PIL are near filaments)
 g(9)=255

; 11th orange for SS (very large since are from Halpha)
 r(10)=255
 g(10)=165

; 12th color (r,g,b(11)) is yellow for missing data
 r(11)=255
 g(11)=255

; 13th color is the tangerine border
 r(12)=255
 g(12)=192

; 14th color is the gold 8-pixel plage centers of changing flux outside active regions
 r(13)=255
 g(13)=215

; all the rest should be black 0,0,0

endif

if choice eq 1 then begin

; first color is white=0 from CR####_orig.gif
 r(0)=255
 g(0)=255
 b(0)=255

; Second color is black=1 from CR####_orig.gif (no need to assign r,g,b(1)=0, since all 0's)

; 3rd color is navy for pos CH bndry
 b(2)=128

; 4th color is blue for pos CH
 b(3)=255

; 5th color is light cyan for positive polarity
 r(4)=224
 g(4)=255
 b(4)=255

; 6th color is dark plum for neg CH bndry
  r(5)=102

; 7th color is (paler) red for neg CH
 r(6)=255

; 8th color is silver for negative polarity
 r(7)=192
 g(7)=192
 b(7)=192

; 9th color is (rose) pale green for NL or PIL line 
;  r(8)=255
;  g(8)=204
;  b(8)=229
   r(8)=204
   g(8)=255
   b(8)=204

; 10th color is dark green for filaments (ie, solid NL or PIL are near filaments)
 g(9)=110
 b(9)=30

; 11th orange for SS (very large since are from Halpha)
 r(10)=255
 g(10)=128

; 12th color (r,g,b(11)) is pale yellow for missing data
 r(11)=255
 g(11)=255
 b(11)=204

; 13th color is the black border

; 14th color is the gold 8-pixel plage centers of changing flux outside active regions
 r(13)=255
 g(13)=215

; all the rest should be black 0,0,0

endif

if choice eq 2 then begin

; first color is white=0 from CR####_orig.gif
 r(0)=255
 g(0)=255
 b(0)=255

; Second color is black=1 from CR####_orig.gif (no need to assign r,g,b(1)=0, since all 0's)

; 3rd color is navy for pos CH bndry
 b(2)=128

; 4th color is blue for pos CH
 r(3)=102
 g(3)=102
 b(3)=255

; 5th color is light cyan for positive polarity
 r(4)=224
 g(4)=255
 b(4)=255

; 6th color is dark plum for neg CH bndry
  r(5)=102

; 7th color is (paler) red for neg CH
 r(6)=255
 g(6)=102
 b(6)=102

; 8th color is silver for negative polarity
 r(7)=192
 g(7)=192
 b(7)=192

; 9th color is pink for NL or PIL line 
  r(8)=255
;   g(8)=102
;   b(8)=178
   g(8)=153
   b(8)=255

; 10th color is light plum for filaments (ie, solid NL or PIL are near filaments)
; r(9)=153
; b(9)=76
 r(9)=51
 b(9)=51

; 11th orange for SS (very large since are from Halpha)
 r(10)=255
 g(10)=165

; 12th color (r,g,b(11)) is pale yellow for missing data
 r(11)=255
 g(11)=255
 b(11)=204

; 13th color is the tangerine border
 r(12)=255
 g(12)=192

; 14th color is the gold 8-pixel plage centers of changing flux outside active regions
 r(13)=255
 g(13)=215

endif

if choice eq 3 then begin

; first color is white=0 from CR####_orig.gif
 r(0)=255
 g(0)=255
 b(0)=255

; Second color is black=1 from CR####_orig.gif (no need to assign r,g,b(1)=0, since all 0's)

; 3rd color is navy for pos CH bndry
 b(2)=128

; 4th color is blue for pos CH
 b(3)=255

; 5th color is light cyan for positive polarity
 r(4)=224
 g(4)=255
 b(4)=255

; 6th color is dark plum for neg CH bndry
  r(5)=102

; 7th color is (paler) red for neg CH
 r(6)=255

; 8th color is silver for negative polarity
 r(7)=192
 g(7)=192
 b(7)=192

; 9th color is (rose) pale green for NL or PIL line 
;  r(8)=255
;  g(8)=204
;  b(8)=229
   r(8)=204
   g(8)=255
   b(8)=204

; 10th color is dark green for filaments (ie, solid NL or PIL are near filaments)
 g(9)=110
 b(9)=30

; 11th orange for SS (very large since are from Halpha)
 r(10)=255
 g(10)=128

; 12th color (r,g,b(11)) is pale yellow for missing data
 r(11)=255
 g(11)=255
 b(11)=204

; 13th color is the black border

; 14th color is the gold 8-pixel plage centers of changing flux outside active regions
 r(13)=255
 g(13)=215

; 15th color is rose for negative polarity sunspots
  r(14)=255
  g(14)=204
  b(14)=229

; all the rest should be black 0,0,0

endif

end

