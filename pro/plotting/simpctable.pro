
;+
;
; NAME:
;    SIMPCTABLE
;       
; PURPOSE:
;    Define a set of colors for plotting. If the display is 8-bit, a color
;    table is created.
;
; CALLING SEQUENCE:
;    simpctable, red_ct, green_ct, blue_ct, bits=bits, help=help
;
; COMMENTS: 
;    Sets system variables with values that correspond to colors.
;
;     !Black !White !Red !Green !Blue !Yellow !Cyan !Magenta'
;
;     !LightSteelBlue     !SkyBlue         !DarkSlateGrey'
;     !SlateGrey          !LightBlue       !MidnightBlue'
;     !NavyBlue           !RoyalBlue       !DodgerBlue'
;     !DarkBlue           !Turquoise       !DarkGreen'
;     !SeaGreen           !ForestGreen     !LightGreen'
;     !Sienna             !Firebrick       !Salmon'
;     !Orange             !OrangeRed       !HotPink'               
;     !DeepPink           !Violet          !DarkRed'
;     !Purple'
;
;     !grey0 grey1 ... !grey100'
;
; For 8-bit device or display this is the default set of colors.  This set
; can be returned through the colorlist keyword on any device, also including
; !p.color at the beginning.
;
; On a true-color display, many more colors are defined: all the colors that
; are in the rgb.txt file on unix systems (see the showrgb program). 
; You can send the keyword /showcolors the command showrgb, which shows
; the color names. 
;
; On an 8-bit display or device (such as postscript) a new color table is
; loaded. 33 colors above are defined plus greys !grey00 to !grey100.  Other
; grey values are also available in the color table.  you want all greys from
; 0 to 255, run loadct,0
;
; INPUTS: 
;    None
;
; OPTIONAL INPUTS:
;    bits=bits: input the bits/pixel.  Must be either 8 or 24.
;               If not set, simpctable will
;               determine it from the number of available colors.
;
; KEYWORD PARAMETERS:
;    /help: if set, a help message is printed showing the 
;           the system variables set by SIMPCTABLE
;    /showcolors: run the program showrgb if it exists on the machine
;       
; OUTPUTS: 
;    colorlist=: Array of the standard colors listed above.
;
; OPTIONAL OUTPUTS:
;     red_ct, green_ct, blue_ct: The red, green, and blue color arrays
;     loaded for 8-bit devices
;     Useful for writing gif files from the plotting window. This only
;     makes sense on 8-bit devices
; CALLED ROUTINES:
;    (TVLCT) if 8-bit device
; 
; EXAMPLE:
;    IDL> simpctable
;    IDL> plot, [0], /nodata, yrange=[-1.2,1.2],xrange=[0,2.*!pi], $
;    IDL>    color=!black, background=!white, xstyle=1
;    IDL> x = findgen(300)/299.*2.*!pi
;    IDL> y = sin(x) + randomn(seed,300)/5.
;    IDL> oplot, x, y, color=!blue
;    IDL> oplot, x, sin(x), color=!red
;    
;	
;
; REVISION HISTORY:
;    Written May 09 2000, Erin Scott Sheldon, U. of Michigan
;    Revision History:
;      28-Feb-2002  Added all colors in rgb.txt (some 657 colors)
;                                      
;-                                       
;
;
;
;  Copyright (C) 2005  Erin Sheldon, NYU.  erin dot sheldon at gmail dot com
;
;    This program is free software; you can redistribute it and/or modify
;    it under the terms of version 2 of the GNU General Public License as 
;    published by the Free Software Foundation.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with this program; if not, write to the Free Software
;    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
;
;

PRO simpctable, rdct, grct, blct, $
                colorlist=colorlist, $
                help=help, bits=bits, showcolors=showcolors

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; set up colors. If display exists
  ;; then create dummy window to force calcuation
  ;; of number of colors (since all begin with
  ;; n_colors=256 until display is created)
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;; make sure we have a display before creating dummy
  ;; window

  dexist = display_exists()
  IF dexist THEN BEGIN 
      IF !d.name EQ 'X' AND !d.window EQ -1 THEN BEGIN ;Uninitialized?
;       If so, make a dummy window to determine the # of colors available.
          window,/free,/pixmap,xs=4, ys=4
          wdelete, !d.window
      ENDIF 
  ENDIF

  IF n_elements(bits) EQ 0 THEN BEGIN 
      IF !d.n_colors LE 256 THEN bitsperpixel=8 $
      ELSE bitsperpixel=24
  ENDIF ELSE BEGIN 
      IF (bits[0] EQ 8) OR (bits[0] EQ 24) THEN bitsperpixel=bits $
      ELSE message,'bits value of '+strmid( strtrim(string(bits[0]),2),0,1000)+' is invalid. Must be 8 or 24'
  ENDELSE 

  IF bitsperpixel EQ 8 THEN BEGIN 

      n_colors=!d.n_colors < 256

      rdct = lonarr(n_colors)
      grct = rdct
      blct = rdct

      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;; The rgb values for some colors
      ;; These will be put at the end of the color table, after the greys
      ;; white should be highest number (last in list)
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      names='!'+ ['black','magenta','red','green',$
                  'blue','yellow','cyan','white']
      redtmp =   [0,       255,      255,  0,      0,     255,     0,     255]
      greentmp = [0,       0,        0,    255,    0,     255,     255,   255]
      bluetmp =  [0,       255,      0,    0,      255,   0,       255,   255]

      ;; these generated by make_8bitcolors.pro
      addnames = '!' + ['lightsteelblue','skyblue','darkslategrey',$
                        'slategrey',$
                        'lightblue','midnightblue','navyblue', $
                        'royalblue','dodgerblue','darkblue', $
                        'turquoise','darkgreen','seagreen', $
                        'forestgreen','lightgreen','sienna', $
                        'firebrick','salmon','orange', $
                        'orangered','hotpink','deeppink', $
                        'violet','darkred','purple']
      
      addred   = [176, 135, 47, 112,  $
                  173, 25, 0,  $
                  65, 30, 0,  $
                  64, 0, 46,  $
                  34, 144, 160,  $
                  178, 250, 255,  $
                  255, 255, 255,  $
                  238, 139, 160]
      
      addgreen = [196, 206, 79, 128,  $
                  216, 25, 0,  $
                  105, 144, 0,  $
                  224, 100, 139,  $
                  139, 238, 82,  $
                  34, 128, 165,  $
                  69, 105, 20,  $
                  130, 0, 32]

      addblue  = [222, 235, 79, 144,  $
                  230, 112, 128,  $
                  225, 255, 139,  $
                  208, 0, 87,  $
                  34, 144, 45,  $
                  34, 114, 0,  $
                  0, 180, 147,  $
                  238, 0, 240]
      
      names = [addnames, names]
      redtmp = [addred, redtmp]
      greentmp = [addgreen, greentmp]
      bluetmp = [addblue, bluetmp]

      nc = n_elements(redtmp)

      ;; how many positions are left for other colors (such as the greys)?
      left = n_colors-nc

      ;; the indices in the color table for these colors
      ;; indices correspond directly with values and names above
      colornums = left + lindgen(nc)

      ;; Fill in the end of the color table
      rdct[left:n_colors-1] = long(redtmp)
      grct[left:n_colors-1] = long(greentmp)
      blct[left:n_colors-1] = long(bluetmp)

      ;; create the system variables
      FOR i=0L, nc-1 DO BEGIN 
          defsysv, names[i], colornums[i]
      ENDFOR 

      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;; The color values for greys, from black (0) to 255
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      greys = long( arrscl( findgen(left), 0, 255 ) )

      rdct[0:left-1] = greys
      grct[0:left-1] = greys
      blct[0:left-1] = greys

      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;; Define the grey color indices
      ;; will use remaining space. If left less than 100+1 then will
      ;; have some greys same.  If left > 100+1 then some color indices
      ;; won't be used
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      ngrey = 100+1
      greynums = ntostr( long( arrscl( findgen(ngrey), 0, left-1 ) ) )+'L'
      FOR i=0L, ngrey-1 DO BEGIN 
          color = greynums[i]
          name = "'!grey"+ntostr(i)+"'"
          command='defsysv, '+name+', '+color
          IF NOT execute(command) THEN message,'Error'
      ENDFOR 

      ;;;;;;;;;;;;;;;;;;;;;;;;
      ;; load the color table
      ;;;;;;;;;;;;;;;;;;;;;;;;

      IF dexist OR (!d.name EQ 'PS') THEN tvlct, rdct, grct, blct

  ENDIF ELSE BEGIN 

      ;; these generated by make_truecolors.pro
      
      R=255L & G=250L & B=250L
      defsysv, '!snow', R + 256L*(G+256L*B)

      R=248L & G=248L & B=255L
      defsysv, '!GhostWhite', R + 256L*(G+256L*B)

      R=245L & G=245L & B=245L
      defsysv, '!WhiteSmoke', R + 256L*(G+256L*B)

      R=220L & G=220L & B=220L
      defsysv, '!gainsboro', R + 256L*(G+256L*B)

      R=255L & G=250L & B=240L
      defsysv, '!FloralWhite', R + 256L*(G+256L*B)

      R=253L & G=245L & B=230L
      defsysv, '!OldLace', R + 256L*(G+256L*B)

      R=250L & G=240L & B=230L
      defsysv, '!linen', R + 256L*(G+256L*B)

      R=250L & G=235L & B=215L
      defsysv, '!AntiqueWhite', R + 256L*(G+256L*B)

      R=255L & G=239L & B=213L
      defsysv, '!PapayaWhip', R + 256L*(G+256L*B)

      R=255L & G=235L & B=205L
      defsysv, '!BlanchedAlmond', R + 256L*(G+256L*B)

      R=255L & G=228L & B=196L
      defsysv, '!bisque', R + 256L*(G+256L*B)

      R=255L & G=218L & B=185L
      defsysv, '!PeachPuff', R + 256L*(G+256L*B)

      R=255L & G=222L & B=173L
      defsysv, '!NavajoWhite', R + 256L*(G+256L*B)

      R=255L & G=228L & B=181L
      defsysv, '!moccasin', R + 256L*(G+256L*B)

      R=255L & G=248L & B=220L
      defsysv, '!cornsilk', R + 256L*(G+256L*B)

      R=255L & G=255L & B=240L
      defsysv, '!ivory', R + 256L*(G+256L*B)

      R=255L & G=250L & B=205L
      defsysv, '!LemonChiffon', R + 256L*(G+256L*B)

      R=255L & G=245L & B=238L
      defsysv, '!seashell', R + 256L*(G+256L*B)

      R=240L & G=255L & B=240L
      defsysv, '!honeydew', R + 256L*(G+256L*B)

      R=245L & G=255L & B=250L
      defsysv, '!MintCream', R + 256L*(G+256L*B)

      R=240L & G=255L & B=255L
      defsysv, '!azure', R + 256L*(G+256L*B)

      R=240L & G=248L & B=255L
      defsysv, '!AliceBlue', R + 256L*(G+256L*B)

      R=230L & G=230L & B=250L
      defsysv, '!lavender', R + 256L*(G+256L*B)

      R=255L & G=240L & B=245L
      defsysv, '!LavenderBlush', R + 256L*(G+256L*B)

      R=255L & G=228L & B=225L
      defsysv, '!MistyRose', R + 256L*(G+256L*B)

      R=255L & G=255L & B=255L
      defsysv, '!white', R + 256L*(G+256L*B)

      R=0L & G=0L & B=0L
      defsysv, '!black', R + 256L*(G+256L*B)

      R=47L & G=79L & B=79L
      defsysv, '!DarkSlateGray', R + 256L*(G+256L*B)

      R=47L & G=79L & B=79L
      defsysv, '!DarkSlateGrey', R + 256L*(G+256L*B)

      R=105L & G=105L & B=105L
      defsysv, '!DimGray', R + 256L*(G+256L*B)

      R=105L & G=105L & B=105L
      defsysv, '!DimGrey', R + 256L*(G+256L*B)

      R=112L & G=128L & B=144L
      defsysv, '!SlateGray', R + 256L*(G+256L*B)

      R=112L & G=128L & B=144L
      defsysv, '!SlateGrey', R + 256L*(G+256L*B)

      R=119L & G=136L & B=153L
      defsysv, '!LightSlateGray', R + 256L*(G+256L*B)

      R=119L & G=136L & B=153L
      defsysv, '!LightSlateGrey', R + 256L*(G+256L*B)

      R=190L & G=190L & B=190L
      defsysv, '!gray', R + 256L*(G+256L*B)

      R=190L & G=190L & B=190L
      defsysv, '!grey', R + 256L*(G+256L*B)

      R=211L & G=211L & B=211L
      defsysv, '!LightGrey', R + 256L*(G+256L*B)

      R=211L & G=211L & B=211L
      defsysv, '!LightGray', R + 256L*(G+256L*B)

      R=25L & G=25L & B=112L
      defsysv, '!MidnightBlue', R + 256L*(G+256L*B)

      R=0L & G=0L & B=128L
      defsysv, '!navy', R + 256L*(G+256L*B)

      R=0L & G=0L & B=128L
      defsysv, '!NavyBlue', R + 256L*(G+256L*B)

      R=100L & G=149L & B=237L
      defsysv, '!CornflowerBlue', R + 256L*(G+256L*B)

      R=72L & G=61L & B=139L
      defsysv, '!DarkSlateBlue', R + 256L*(G+256L*B)

      R=106L & G=90L & B=205L
      defsysv, '!SlateBlue', R + 256L*(G+256L*B)

      R=123L & G=104L & B=238L
      defsysv, '!MediumSlateBlue', R + 256L*(G+256L*B)

      R=132L & G=112L & B=255L
      defsysv, '!LightSlateBlue', R + 256L*(G+256L*B)

      R=0L & G=0L & B=205L
      defsysv, '!MediumBlue', R + 256L*(G+256L*B)

      R=65L & G=105L & B=225L
      defsysv, '!RoyalBlue', R + 256L*(G+256L*B)

      R=0L & G=0L & B=255L
      defsysv, '!blue', R + 256L*(G+256L*B)

      R=30L & G=144L & B=255L
      defsysv, '!DodgerBlue', R + 256L*(G+256L*B)

      R=0L & G=191L & B=255L
      defsysv, '!DeepSkyBlue', R + 256L*(G+256L*B)

      R=135L & G=206L & B=235L
      defsysv, '!SkyBlue', R + 256L*(G+256L*B)

      R=135L & G=206L & B=250L
      defsysv, '!LightSkyBlue', R + 256L*(G+256L*B)

      R=70L & G=130L & B=180L
      defsysv, '!SteelBlue', R + 256L*(G+256L*B)

      R=176L & G=196L & B=222L
      defsysv, '!LightSteelBlue', R + 256L*(G+256L*B)

      R=173L & G=216L & B=230L
      defsysv, '!LightBlue', R + 256L*(G+256L*B)

      R=176L & G=224L & B=230L
      defsysv, '!PowderBlue', R + 256L*(G+256L*B)

      R=175L & G=238L & B=238L
      defsysv, '!PaleTurquoise', R + 256L*(G+256L*B)

      R=0L & G=206L & B=209L
      defsysv, '!DarkTurquoise', R + 256L*(G+256L*B)

      R=72L & G=209L & B=204L
      defsysv, '!MediumTurquoise', R + 256L*(G+256L*B)

      R=64L & G=224L & B=208L
      defsysv, '!turquoise', R + 256L*(G+256L*B)

      R=0L & G=255L & B=255L
      defsysv, '!cyan', R + 256L*(G+256L*B)

      R=224L & G=255L & B=255L
      defsysv, '!LightCyan', R + 256L*(G+256L*B)

      R=95L & G=158L & B=160L
      defsysv, '!CadetBlue', R + 256L*(G+256L*B)

      R=102L & G=205L & B=170L
      defsysv, '!MediumAquamarine', R + 256L*(G+256L*B)

      R=127L & G=255L & B=212L
      defsysv, '!aquamarine', R + 256L*(G+256L*B)

      R=0L & G=100L & B=0L
      defsysv, '!DarkGreen', R + 256L*(G+256L*B)

      R=85L & G=107L & B=47L
      defsysv, '!DarkOliveGreen', R + 256L*(G+256L*B)

      R=143L & G=188L & B=143L
      defsysv, '!DarkSeaGreen', R + 256L*(G+256L*B)

      R=46L & G=139L & B=87L
      defsysv, '!SeaGreen', R + 256L*(G+256L*B)

      R=60L & G=179L & B=113L
      defsysv, '!MediumSeaGreen', R + 256L*(G+256L*B)

      R=32L & G=178L & B=170L
      defsysv, '!LightSeaGreen', R + 256L*(G+256L*B)

      R=152L & G=251L & B=152L
      defsysv, '!PaleGreen', R + 256L*(G+256L*B)

      R=0L & G=255L & B=127L
      defsysv, '!SpringGreen', R + 256L*(G+256L*B)

      R=124L & G=252L & B=0L
      defsysv, '!LawnGreen', R + 256L*(G+256L*B)

      R=0L & G=255L & B=0L
      defsysv, '!green', R + 256L*(G+256L*B)

      R=127L & G=255L & B=0L
      defsysv, '!chartreuse', R + 256L*(G+256L*B)

      R=0L & G=250L & B=154L
      defsysv, '!MediumSpringGreen', R + 256L*(G+256L*B)

      R=173L & G=255L & B=47L
      defsysv, '!GreenYellow', R + 256L*(G+256L*B)

      R=50L & G=205L & B=50L
      defsysv, '!LimeGreen', R + 256L*(G+256L*B)

      R=154L & G=205L & B=50L
      defsysv, '!YellowGreen', R + 256L*(G+256L*B)

      R=34L & G=139L & B=34L
      defsysv, '!ForestGreen', R + 256L*(G+256L*B)

      R=107L & G=142L & B=35L
      defsysv, '!OliveDrab', R + 256L*(G+256L*B)

      R=189L & G=183L & B=107L
      defsysv, '!DarkKhaki', R + 256L*(G+256L*B)

      R=240L & G=230L & B=140L
      defsysv, '!khaki', R + 256L*(G+256L*B)

      R=238L & G=232L & B=170L
      defsysv, '!PaleGoldenrod', R + 256L*(G+256L*B)

      R=250L & G=250L & B=210L
      defsysv, '!LightGoldenrodYellow', R + 256L*(G+256L*B)

      R=255L & G=255L & B=224L
      defsysv, '!LightYellow', R + 256L*(G+256L*B)

      R=255L & G=255L & B=0L
      defsysv, '!yellow', R + 256L*(G+256L*B)

      R=255L & G=215L & B=0L
      defsysv, '!gold', R + 256L*(G+256L*B)

      R=238L & G=221L & B=130L
      defsysv, '!LightGoldenrod', R + 256L*(G+256L*B)

      R=218L & G=165L & B=32L
      defsysv, '!goldenrod', R + 256L*(G+256L*B)

      R=184L & G=134L & B=11L
      defsysv, '!DarkGoldenrod', R + 256L*(G+256L*B)

      R=188L & G=143L & B=143L
      defsysv, '!RosyBrown', R + 256L*(G+256L*B)

      R=205L & G=92L & B=92L
      defsysv, '!IndianRed', R + 256L*(G+256L*B)

      R=139L & G=69L & B=19L
      defsysv, '!SaddleBrown', R + 256L*(G+256L*B)

      R=160L & G=82L & B=45L
      defsysv, '!sienna', R + 256L*(G+256L*B)

      R=205L & G=133L & B=63L
      defsysv, '!peru', R + 256L*(G+256L*B)

      R=222L & G=184L & B=135L
      defsysv, '!burlywood', R + 256L*(G+256L*B)

      R=245L & G=245L & B=220L
      defsysv, '!beige', R + 256L*(G+256L*B)

      R=245L & G=222L & B=179L
      defsysv, '!wheat', R + 256L*(G+256L*B)

      R=244L & G=164L & B=96L
      defsysv, '!SandyBrown', R + 256L*(G+256L*B)

      R=210L & G=180L & B=140L
      defsysv, '!tan', R + 256L*(G+256L*B)

      R=210L & G=105L & B=30L
      defsysv, '!chocolate', R + 256L*(G+256L*B)

      R=178L & G=34L & B=34L
      defsysv, '!firebrick', R + 256L*(G+256L*B)

      R=165L & G=42L & B=42L
      defsysv, '!brown', R + 256L*(G+256L*B)

      R=233L & G=150L & B=122L
      defsysv, '!DarkSalmon', R + 256L*(G+256L*B)

      R=250L & G=128L & B=114L
      defsysv, '!salmon', R + 256L*(G+256L*B)

      R=255L & G=160L & B=122L
      defsysv, '!LightSalmon', R + 256L*(G+256L*B)

      R=255L & G=165L & B=0L
      defsysv, '!orange', R + 256L*(G+256L*B)

      R=255L & G=140L & B=0L
      defsysv, '!DarkOrange', R + 256L*(G+256L*B)

      R=255L & G=127L & B=80L
      defsysv, '!coral', R + 256L*(G+256L*B)

      R=240L & G=128L & B=128L
      defsysv, '!LightCoral', R + 256L*(G+256L*B)

      R=255L & G=99L & B=71L
      defsysv, '!tomato', R + 256L*(G+256L*B)

      R=255L & G=69L & B=0L
      defsysv, '!OrangeRed', R + 256L*(G+256L*B)

      R=255L & G=0L & B=0L
      defsysv, '!red', R + 256L*(G+256L*B)

      R=255L & G=105L & B=180L
      defsysv, '!HotPink', R + 256L*(G+256L*B)

      R=255L & G=20L & B=147L
      defsysv, '!DeepPink', R + 256L*(G+256L*B)

      R=255L & G=192L & B=203L
      defsysv, '!pink', R + 256L*(G+256L*B)

      R=255L & G=182L & B=193L
      defsysv, '!LightPink', R + 256L*(G+256L*B)

      R=219L & G=112L & B=147L
      defsysv, '!PaleVioletRed', R + 256L*(G+256L*B)

      R=176L & G=48L & B=96L
      defsysv, '!maroon', R + 256L*(G+256L*B)

      R=199L & G=21L & B=133L
      defsysv, '!MediumVioletRed', R + 256L*(G+256L*B)

      R=208L & G=32L & B=144L
      defsysv, '!VioletRed', R + 256L*(G+256L*B)

      R=255L & G=0L & B=255L
      defsysv, '!magenta', R + 256L*(G+256L*B)

      R=238L & G=130L & B=238L
      defsysv, '!violet', R + 256L*(G+256L*B)

      R=221L & G=160L & B=221L
      defsysv, '!plum', R + 256L*(G+256L*B)

      R=218L & G=112L & B=214L
      defsysv, '!orchid', R + 256L*(G+256L*B)

      R=186L & G=85L & B=211L
      defsysv, '!MediumOrchid', R + 256L*(G+256L*B)

      R=153L & G=50L & B=204L
      defsysv, '!DarkOrchid', R + 256L*(G+256L*B)

      R=148L & G=0L & B=211L
      defsysv, '!DarkViolet', R + 256L*(G+256L*B)

      R=138L & G=43L & B=226L
      defsysv, '!BlueViolet', R + 256L*(G+256L*B)

      R=160L & G=32L & B=240L
      defsysv, '!purple', R + 256L*(G+256L*B)

      R=147L & G=112L & B=219L
      defsysv, '!MediumPurple', R + 256L*(G+256L*B)

      R=216L & G=191L & B=216L
      defsysv, '!thistle', R + 256L*(G+256L*B)

      R=255L & G=250L & B=250L
      defsysv, '!snow1', R + 256L*(G+256L*B)

      R=238L & G=233L & B=233L
      defsysv, '!snow2', R + 256L*(G+256L*B)

      R=205L & G=201L & B=201L
      defsysv, '!snow3', R + 256L*(G+256L*B)

      R=139L & G=137L & B=137L
      defsysv, '!snow4', R + 256L*(G+256L*B)

      R=255L & G=245L & B=238L
      defsysv, '!seashell1', R + 256L*(G+256L*B)

      R=238L & G=229L & B=222L
      defsysv, '!seashell2', R + 256L*(G+256L*B)

      R=205L & G=197L & B=191L
      defsysv, '!seashell3', R + 256L*(G+256L*B)

      R=139L & G=134L & B=130L
      defsysv, '!seashell4', R + 256L*(G+256L*B)

      R=255L & G=239L & B=219L
      defsysv, '!AntiqueWhite1', R + 256L*(G+256L*B)

      R=238L & G=223L & B=204L
      defsysv, '!AntiqueWhite2', R + 256L*(G+256L*B)

      R=205L & G=192L & B=176L
      defsysv, '!AntiqueWhite3', R + 256L*(G+256L*B)

      R=139L & G=131L & B=120L
      defsysv, '!AntiqueWhite4', R + 256L*(G+256L*B)

      R=255L & G=228L & B=196L
      defsysv, '!bisque1', R + 256L*(G+256L*B)

      R=238L & G=213L & B=183L
      defsysv, '!bisque2', R + 256L*(G+256L*B)

      R=205L & G=183L & B=158L
      defsysv, '!bisque3', R + 256L*(G+256L*B)

      R=139L & G=125L & B=107L
      defsysv, '!bisque4', R + 256L*(G+256L*B)

      R=255L & G=218L & B=185L
      defsysv, '!PeachPuff1', R + 256L*(G+256L*B)

      R=238L & G=203L & B=173L
      defsysv, '!PeachPuff2', R + 256L*(G+256L*B)

      R=205L & G=175L & B=149L
      defsysv, '!PeachPuff3', R + 256L*(G+256L*B)

      R=139L & G=119L & B=101L
      defsysv, '!PeachPuff4', R + 256L*(G+256L*B)

      R=255L & G=222L & B=173L
      defsysv, '!NavajoWhite1', R + 256L*(G+256L*B)

      R=238L & G=207L & B=161L
      defsysv, '!NavajoWhite2', R + 256L*(G+256L*B)

      R=205L & G=179L & B=139L
      defsysv, '!NavajoWhite3', R + 256L*(G+256L*B)

      R=139L & G=121L & B=94L
      defsysv, '!NavajoWhite4', R + 256L*(G+256L*B)

      R=255L & G=250L & B=205L
      defsysv, '!LemonChiffon1', R + 256L*(G+256L*B)

      R=238L & G=233L & B=191L
      defsysv, '!LemonChiffon2', R + 256L*(G+256L*B)

      R=205L & G=201L & B=165L
      defsysv, '!LemonChiffon3', R + 256L*(G+256L*B)

      R=139L & G=137L & B=112L
      defsysv, '!LemonChiffon4', R + 256L*(G+256L*B)

      R=255L & G=248L & B=220L
      defsysv, '!cornsilk1', R + 256L*(G+256L*B)

      R=238L & G=232L & B=205L
      defsysv, '!cornsilk2', R + 256L*(G+256L*B)

      R=205L & G=200L & B=177L
      defsysv, '!cornsilk3', R + 256L*(G+256L*B)

      R=139L & G=136L & B=120L
      defsysv, '!cornsilk4', R + 256L*(G+256L*B)

      R=255L & G=255L & B=240L
      defsysv, '!ivory1', R + 256L*(G+256L*B)

      R=238L & G=238L & B=224L
      defsysv, '!ivory2', R + 256L*(G+256L*B)

      R=205L & G=205L & B=193L
      defsysv, '!ivory3', R + 256L*(G+256L*B)

      R=139L & G=139L & B=131L
      defsysv, '!ivory4', R + 256L*(G+256L*B)

      R=240L & G=255L & B=240L
      defsysv, '!honeydew1', R + 256L*(G+256L*B)

      R=224L & G=238L & B=224L
      defsysv, '!honeydew2', R + 256L*(G+256L*B)

      R=193L & G=205L & B=193L
      defsysv, '!honeydew3', R + 256L*(G+256L*B)

      R=131L & G=139L & B=131L
      defsysv, '!honeydew4', R + 256L*(G+256L*B)

      R=255L & G=240L & B=245L
      defsysv, '!LavenderBlush1', R + 256L*(G+256L*B)

      R=238L & G=224L & B=229L
      defsysv, '!LavenderBlush2', R + 256L*(G+256L*B)

      R=205L & G=193L & B=197L
      defsysv, '!LavenderBlush3', R + 256L*(G+256L*B)

      R=139L & G=131L & B=134L
      defsysv, '!LavenderBlush4', R + 256L*(G+256L*B)

      R=255L & G=228L & B=225L
      defsysv, '!MistyRose1', R + 256L*(G+256L*B)

      R=238L & G=213L & B=210L
      defsysv, '!MistyRose2', R + 256L*(G+256L*B)

      R=205L & G=183L & B=181L
      defsysv, '!MistyRose3', R + 256L*(G+256L*B)

      R=139L & G=125L & B=123L
      defsysv, '!MistyRose4', R + 256L*(G+256L*B)

      R=240L & G=255L & B=255L
      defsysv, '!azure1', R + 256L*(G+256L*B)

      R=224L & G=238L & B=238L
      defsysv, '!azure2', R + 256L*(G+256L*B)

      R=193L & G=205L & B=205L
      defsysv, '!azure3', R + 256L*(G+256L*B)

      R=131L & G=139L & B=139L
      defsysv, '!azure4', R + 256L*(G+256L*B)

      R=131L & G=111L & B=255L
      defsysv, '!SlateBlue1', R + 256L*(G+256L*B)

      R=122L & G=103L & B=238L
      defsysv, '!SlateBlue2', R + 256L*(G+256L*B)

      R=105L & G=89L & B=205L
      defsysv, '!SlateBlue3', R + 256L*(G+256L*B)

      R=71L & G=60L & B=139L
      defsysv, '!SlateBlue4', R + 256L*(G+256L*B)

      R=72L & G=118L & B=255L
      defsysv, '!RoyalBlue1', R + 256L*(G+256L*B)

      R=67L & G=110L & B=238L
      defsysv, '!RoyalBlue2', R + 256L*(G+256L*B)

      R=58L & G=95L & B=205L
      defsysv, '!RoyalBlue3', R + 256L*(G+256L*B)

      R=39L & G=64L & B=139L
      defsysv, '!RoyalBlue4', R + 256L*(G+256L*B)

      R=0L & G=0L & B=255L
      defsysv, '!blue1', R + 256L*(G+256L*B)

      R=0L & G=0L & B=238L
      defsysv, '!blue2', R + 256L*(G+256L*B)

      R=0L & G=0L & B=205L
      defsysv, '!blue3', R + 256L*(G+256L*B)

      R=0L & G=0L & B=139L
      defsysv, '!blue4', R + 256L*(G+256L*B)

      R=30L & G=144L & B=255L
      defsysv, '!DodgerBlue1', R + 256L*(G+256L*B)

      R=28L & G=134L & B=238L
      defsysv, '!DodgerBlue2', R + 256L*(G+256L*B)

      R=24L & G=116L & B=205L
      defsysv, '!DodgerBlue3', R + 256L*(G+256L*B)

      R=16L & G=78L & B=139L
      defsysv, '!DodgerBlue4', R + 256L*(G+256L*B)

      R=99L & G=184L & B=255L
      defsysv, '!SteelBlue1', R + 256L*(G+256L*B)

      R=92L & G=172L & B=238L
      defsysv, '!SteelBlue2', R + 256L*(G+256L*B)

      R=79L & G=148L & B=205L
      defsysv, '!SteelBlue3', R + 256L*(G+256L*B)

      R=54L & G=100L & B=139L
      defsysv, '!SteelBlue4', R + 256L*(G+256L*B)

      R=0L & G=191L & B=255L
      defsysv, '!DeepSkyBlue1', R + 256L*(G+256L*B)

      R=0L & G=178L & B=238L
      defsysv, '!DeepSkyBlue2', R + 256L*(G+256L*B)

      R=0L & G=154L & B=205L
      defsysv, '!DeepSkyBlue3', R + 256L*(G+256L*B)

      R=0L & G=104L & B=139L
      defsysv, '!DeepSkyBlue4', R + 256L*(G+256L*B)

      R=135L & G=206L & B=255L
      defsysv, '!SkyBlue1', R + 256L*(G+256L*B)

      R=126L & G=192L & B=238L
      defsysv, '!SkyBlue2', R + 256L*(G+256L*B)

      R=108L & G=166L & B=205L
      defsysv, '!SkyBlue3', R + 256L*(G+256L*B)

      R=74L & G=112L & B=139L
      defsysv, '!SkyBlue4', R + 256L*(G+256L*B)

      R=176L & G=226L & B=255L
      defsysv, '!LightSkyBlue1', R + 256L*(G+256L*B)

      R=164L & G=211L & B=238L
      defsysv, '!LightSkyBlue2', R + 256L*(G+256L*B)

      R=141L & G=182L & B=205L
      defsysv, '!LightSkyBlue3', R + 256L*(G+256L*B)

      R=96L & G=123L & B=139L
      defsysv, '!LightSkyBlue4', R + 256L*(G+256L*B)

      R=198L & G=226L & B=255L
      defsysv, '!SlateGray1', R + 256L*(G+256L*B)

      R=185L & G=211L & B=238L
      defsysv, '!SlateGray2', R + 256L*(G+256L*B)

      R=159L & G=182L & B=205L
      defsysv, '!SlateGray3', R + 256L*(G+256L*B)

      R=108L & G=123L & B=139L
      defsysv, '!SlateGray4', R + 256L*(G+256L*B)

      R=202L & G=225L & B=255L
      defsysv, '!LightSteelBlue1', R + 256L*(G+256L*B)

      R=188L & G=210L & B=238L
      defsysv, '!LightSteelBlue2', R + 256L*(G+256L*B)

      R=162L & G=181L & B=205L
      defsysv, '!LightSteelBlue3', R + 256L*(G+256L*B)

      R=110L & G=123L & B=139L
      defsysv, '!LightSteelBlue4', R + 256L*(G+256L*B)

      R=191L & G=239L & B=255L
      defsysv, '!LightBlue1', R + 256L*(G+256L*B)

      R=178L & G=223L & B=238L
      defsysv, '!LightBlue2', R + 256L*(G+256L*B)

      R=154L & G=192L & B=205L
      defsysv, '!LightBlue3', R + 256L*(G+256L*B)

      R=104L & G=131L & B=139L
      defsysv, '!LightBlue4', R + 256L*(G+256L*B)

      R=224L & G=255L & B=255L
      defsysv, '!LightCyan1', R + 256L*(G+256L*B)

      R=209L & G=238L & B=238L
      defsysv, '!LightCyan2', R + 256L*(G+256L*B)

      R=180L & G=205L & B=205L
      defsysv, '!LightCyan3', R + 256L*(G+256L*B)

      R=122L & G=139L & B=139L
      defsysv, '!LightCyan4', R + 256L*(G+256L*B)

      R=187L & G=255L & B=255L
      defsysv, '!PaleTurquoise1', R + 256L*(G+256L*B)

      R=174L & G=238L & B=238L
      defsysv, '!PaleTurquoise2', R + 256L*(G+256L*B)

      R=150L & G=205L & B=205L
      defsysv, '!PaleTurquoise3', R + 256L*(G+256L*B)

      R=102L & G=139L & B=139L
      defsysv, '!PaleTurquoise4', R + 256L*(G+256L*B)

      R=152L & G=245L & B=255L
      defsysv, '!CadetBlue1', R + 256L*(G+256L*B)

      R=142L & G=229L & B=238L
      defsysv, '!CadetBlue2', R + 256L*(G+256L*B)

      R=122L & G=197L & B=205L
      defsysv, '!CadetBlue3', R + 256L*(G+256L*B)

      R=83L & G=134L & B=139L
      defsysv, '!CadetBlue4', R + 256L*(G+256L*B)

      R=0L & G=245L & B=255L
      defsysv, '!turquoise1', R + 256L*(G+256L*B)

      R=0L & G=229L & B=238L
      defsysv, '!turquoise2', R + 256L*(G+256L*B)

      R=0L & G=197L & B=205L
      defsysv, '!turquoise3', R + 256L*(G+256L*B)

      R=0L & G=134L & B=139L
      defsysv, '!turquoise4', R + 256L*(G+256L*B)

      R=0L & G=255L & B=255L
      defsysv, '!cyan1', R + 256L*(G+256L*B)

      R=0L & G=238L & B=238L
      defsysv, '!cyan2', R + 256L*(G+256L*B)

      R=0L & G=205L & B=205L
      defsysv, '!cyan3', R + 256L*(G+256L*B)

      R=0L & G=139L & B=139L
      defsysv, '!cyan4', R + 256L*(G+256L*B)

      R=151L & G=255L & B=255L
      defsysv, '!DarkSlateGray1', R + 256L*(G+256L*B)

      R=141L & G=238L & B=238L
      defsysv, '!DarkSlateGray2', R + 256L*(G+256L*B)

      R=121L & G=205L & B=205L
      defsysv, '!DarkSlateGray3', R + 256L*(G+256L*B)

      R=82L & G=139L & B=139L
      defsysv, '!DarkSlateGray4', R + 256L*(G+256L*B)

      R=127L & G=255L & B=212L
      defsysv, '!aquamarine1', R + 256L*(G+256L*B)

      R=118L & G=238L & B=198L
      defsysv, '!aquamarine2', R + 256L*(G+256L*B)

      R=102L & G=205L & B=170L
      defsysv, '!aquamarine3', R + 256L*(G+256L*B)

      R=69L & G=139L & B=116L
      defsysv, '!aquamarine4', R + 256L*(G+256L*B)

      R=193L & G=255L & B=193L
      defsysv, '!DarkSeaGreen1', R + 256L*(G+256L*B)

      R=180L & G=238L & B=180L
      defsysv, '!DarkSeaGreen2', R + 256L*(G+256L*B)

      R=155L & G=205L & B=155L
      defsysv, '!DarkSeaGreen3', R + 256L*(G+256L*B)

      R=105L & G=139L & B=105L
      defsysv, '!DarkSeaGreen4', R + 256L*(G+256L*B)

      R=84L & G=255L & B=159L
      defsysv, '!SeaGreen1', R + 256L*(G+256L*B)

      R=78L & G=238L & B=148L
      defsysv, '!SeaGreen2', R + 256L*(G+256L*B)

      R=67L & G=205L & B=128L
      defsysv, '!SeaGreen3', R + 256L*(G+256L*B)

      R=46L & G=139L & B=87L
      defsysv, '!SeaGreen4', R + 256L*(G+256L*B)

      R=154L & G=255L & B=154L
      defsysv, '!PaleGreen1', R + 256L*(G+256L*B)

      R=144L & G=238L & B=144L
      defsysv, '!PaleGreen2', R + 256L*(G+256L*B)

      R=124L & G=205L & B=124L
      defsysv, '!PaleGreen3', R + 256L*(G+256L*B)

      R=84L & G=139L & B=84L
      defsysv, '!PaleGreen4', R + 256L*(G+256L*B)

      R=0L & G=255L & B=127L
      defsysv, '!SpringGreen1', R + 256L*(G+256L*B)

      R=0L & G=238L & B=118L
      defsysv, '!SpringGreen2', R + 256L*(G+256L*B)

      R=0L & G=205L & B=102L
      defsysv, '!SpringGreen3', R + 256L*(G+256L*B)

      R=0L & G=139L & B=69L
      defsysv, '!SpringGreen4', R + 256L*(G+256L*B)

      R=0L & G=255L & B=0L
      defsysv, '!green1', R + 256L*(G+256L*B)

      R=0L & G=238L & B=0L
      defsysv, '!green2', R + 256L*(G+256L*B)

      R=0L & G=205L & B=0L
      defsysv, '!green3', R + 256L*(G+256L*B)

      R=0L & G=139L & B=0L
      defsysv, '!green4', R + 256L*(G+256L*B)

      R=127L & G=255L & B=0L
      defsysv, '!chartreuse1', R + 256L*(G+256L*B)

      R=118L & G=238L & B=0L
      defsysv, '!chartreuse2', R + 256L*(G+256L*B)

      R=102L & G=205L & B=0L
      defsysv, '!chartreuse3', R + 256L*(G+256L*B)

      R=69L & G=139L & B=0L
      defsysv, '!chartreuse4', R + 256L*(G+256L*B)

      R=192L & G=255L & B=62L
      defsysv, '!OliveDrab1', R + 256L*(G+256L*B)

      R=179L & G=238L & B=58L
      defsysv, '!OliveDrab2', R + 256L*(G+256L*B)

      R=154L & G=205L & B=50L
      defsysv, '!OliveDrab3', R + 256L*(G+256L*B)

      R=105L & G=139L & B=34L
      defsysv, '!OliveDrab4', R + 256L*(G+256L*B)

      R=202L & G=255L & B=112L
      defsysv, '!DarkOliveGreen1', R + 256L*(G+256L*B)

      R=188L & G=238L & B=104L
      defsysv, '!DarkOliveGreen2', R + 256L*(G+256L*B)

      R=162L & G=205L & B=90L
      defsysv, '!DarkOliveGreen3', R + 256L*(G+256L*B)

      R=110L & G=139L & B=61L
      defsysv, '!DarkOliveGreen4', R + 256L*(G+256L*B)

      R=255L & G=246L & B=143L
      defsysv, '!khaki1', R + 256L*(G+256L*B)

      R=238L & G=230L & B=133L
      defsysv, '!khaki2', R + 256L*(G+256L*B)

      R=205L & G=198L & B=115L
      defsysv, '!khaki3', R + 256L*(G+256L*B)

      R=139L & G=134L & B=78L
      defsysv, '!khaki4', R + 256L*(G+256L*B)

      R=255L & G=236L & B=139L
      defsysv, '!LightGoldenrod1', R + 256L*(G+256L*B)

      R=238L & G=220L & B=130L
      defsysv, '!LightGoldenrod2', R + 256L*(G+256L*B)

      R=205L & G=190L & B=112L
      defsysv, '!LightGoldenrod3', R + 256L*(G+256L*B)

      R=139L & G=129L & B=76L
      defsysv, '!LightGoldenrod4', R + 256L*(G+256L*B)

      R=255L & G=255L & B=224L
      defsysv, '!LightYellow1', R + 256L*(G+256L*B)

      R=238L & G=238L & B=209L
      defsysv, '!LightYellow2', R + 256L*(G+256L*B)

      R=205L & G=205L & B=180L
      defsysv, '!LightYellow3', R + 256L*(G+256L*B)

      R=139L & G=139L & B=122L
      defsysv, '!LightYellow4', R + 256L*(G+256L*B)

      R=255L & G=255L & B=0L
      defsysv, '!yellow1', R + 256L*(G+256L*B)

      R=238L & G=238L & B=0L
      defsysv, '!yellow2', R + 256L*(G+256L*B)

      R=205L & G=205L & B=0L
      defsysv, '!yellow3', R + 256L*(G+256L*B)

      R=139L & G=139L & B=0L
      defsysv, '!yellow4', R + 256L*(G+256L*B)

      R=255L & G=215L & B=0L
      defsysv, '!gold1', R + 256L*(G+256L*B)

      R=238L & G=201L & B=0L
      defsysv, '!gold2', R + 256L*(G+256L*B)

      R=205L & G=173L & B=0L
      defsysv, '!gold3', R + 256L*(G+256L*B)

      R=139L & G=117L & B=0L
      defsysv, '!gold4', R + 256L*(G+256L*B)

      R=255L & G=193L & B=37L
      defsysv, '!goldenrod1', R + 256L*(G+256L*B)

      R=238L & G=180L & B=34L
      defsysv, '!goldenrod2', R + 256L*(G+256L*B)

      R=205L & G=155L & B=29L
      defsysv, '!goldenrod3', R + 256L*(G+256L*B)

      R=139L & G=105L & B=20L
      defsysv, '!goldenrod4', R + 256L*(G+256L*B)

      R=255L & G=185L & B=15L
      defsysv, '!DarkGoldenrod1', R + 256L*(G+256L*B)

      R=238L & G=173L & B=14L
      defsysv, '!DarkGoldenrod2', R + 256L*(G+256L*B)

      R=205L & G=149L & B=12L
      defsysv, '!DarkGoldenrod3', R + 256L*(G+256L*B)

      R=139L & G=101L & B=8L
      defsysv, '!DarkGoldenrod4', R + 256L*(G+256L*B)

      R=255L & G=193L & B=193L
      defsysv, '!RosyBrown1', R + 256L*(G+256L*B)

      R=238L & G=180L & B=180L
      defsysv, '!RosyBrown2', R + 256L*(G+256L*B)

      R=205L & G=155L & B=155L
      defsysv, '!RosyBrown3', R + 256L*(G+256L*B)

      R=139L & G=105L & B=105L
      defsysv, '!RosyBrown4', R + 256L*(G+256L*B)

      R=255L & G=106L & B=106L
      defsysv, '!IndianRed1', R + 256L*(G+256L*B)

      R=238L & G=99L & B=99L
      defsysv, '!IndianRed2', R + 256L*(G+256L*B)

      R=205L & G=85L & B=85L
      defsysv, '!IndianRed3', R + 256L*(G+256L*B)

      R=139L & G=58L & B=58L
      defsysv, '!IndianRed4', R + 256L*(G+256L*B)

      R=255L & G=130L & B=71L
      defsysv, '!sienna1', R + 256L*(G+256L*B)

      R=238L & G=121L & B=66L
      defsysv, '!sienna2', R + 256L*(G+256L*B)

      R=205L & G=104L & B=57L
      defsysv, '!sienna3', R + 256L*(G+256L*B)

      R=139L & G=71L & B=38L
      defsysv, '!sienna4', R + 256L*(G+256L*B)

      R=255L & G=211L & B=155L
      defsysv, '!burlywood1', R + 256L*(G+256L*B)

      R=238L & G=197L & B=145L
      defsysv, '!burlywood2', R + 256L*(G+256L*B)

      R=205L & G=170L & B=125L
      defsysv, '!burlywood3', R + 256L*(G+256L*B)

      R=139L & G=115L & B=85L
      defsysv, '!burlywood4', R + 256L*(G+256L*B)

      R=255L & G=231L & B=186L
      defsysv, '!wheat1', R + 256L*(G+256L*B)

      R=238L & G=216L & B=174L
      defsysv, '!wheat2', R + 256L*(G+256L*B)

      R=205L & G=186L & B=150L
      defsysv, '!wheat3', R + 256L*(G+256L*B)

      R=139L & G=126L & B=102L
      defsysv, '!wheat4', R + 256L*(G+256L*B)

      R=255L & G=165L & B=79L
      defsysv, '!tan1', R + 256L*(G+256L*B)

      R=238L & G=154L & B=73L
      defsysv, '!tan2', R + 256L*(G+256L*B)

      R=205L & G=133L & B=63L
      defsysv, '!tan3', R + 256L*(G+256L*B)

      R=139L & G=90L & B=43L
      defsysv, '!tan4', R + 256L*(G+256L*B)

      R=255L & G=127L & B=36L
      defsysv, '!chocolate1', R + 256L*(G+256L*B)

      R=238L & G=118L & B=33L
      defsysv, '!chocolate2', R + 256L*(G+256L*B)

      R=205L & G=102L & B=29L
      defsysv, '!chocolate3', R + 256L*(G+256L*B)

      R=139L & G=69L & B=19L
      defsysv, '!chocolate4', R + 256L*(G+256L*B)

      R=255L & G=48L & B=48L
      defsysv, '!firebrick1', R + 256L*(G+256L*B)

      R=238L & G=44L & B=44L
      defsysv, '!firebrick2', R + 256L*(G+256L*B)

      R=205L & G=38L & B=38L
      defsysv, '!firebrick3', R + 256L*(G+256L*B)

      R=139L & G=26L & B=26L
      defsysv, '!firebrick4', R + 256L*(G+256L*B)

      R=255L & G=64L & B=64L
      defsysv, '!brown1', R + 256L*(G+256L*B)

      R=238L & G=59L & B=59L
      defsysv, '!brown2', R + 256L*(G+256L*B)

      R=205L & G=51L & B=51L
      defsysv, '!brown3', R + 256L*(G+256L*B)

      R=139L & G=35L & B=35L
      defsysv, '!brown4', R + 256L*(G+256L*B)

      R=255L & G=140L & B=105L
      defsysv, '!salmon1', R + 256L*(G+256L*B)

      R=238L & G=130L & B=98L
      defsysv, '!salmon2', R + 256L*(G+256L*B)

      R=205L & G=112L & B=84L
      defsysv, '!salmon3', R + 256L*(G+256L*B)

      R=139L & G=76L & B=57L
      defsysv, '!salmon4', R + 256L*(G+256L*B)

      R=255L & G=160L & B=122L
      defsysv, '!LightSalmon1', R + 256L*(G+256L*B)

      R=238L & G=149L & B=114L
      defsysv, '!LightSalmon2', R + 256L*(G+256L*B)

      R=205L & G=129L & B=98L
      defsysv, '!LightSalmon3', R + 256L*(G+256L*B)

      R=139L & G=87L & B=66L
      defsysv, '!LightSalmon4', R + 256L*(G+256L*B)

      R=255L & G=165L & B=0L
      defsysv, '!orange1', R + 256L*(G+256L*B)

      R=238L & G=154L & B=0L
      defsysv, '!orange2', R + 256L*(G+256L*B)

      R=205L & G=133L & B=0L
      defsysv, '!orange3', R + 256L*(G+256L*B)

      R=139L & G=90L & B=0L
      defsysv, '!orange4', R + 256L*(G+256L*B)

      R=255L & G=127L & B=0L
      defsysv, '!DarkOrange1', R + 256L*(G+256L*B)

      R=238L & G=118L & B=0L
      defsysv, '!DarkOrange2', R + 256L*(G+256L*B)

      R=205L & G=102L & B=0L
      defsysv, '!DarkOrange3', R + 256L*(G+256L*B)

      R=139L & G=69L & B=0L
      defsysv, '!DarkOrange4', R + 256L*(G+256L*B)

      R=255L & G=114L & B=86L
      defsysv, '!coral1', R + 256L*(G+256L*B)

      R=238L & G=106L & B=80L
      defsysv, '!coral2', R + 256L*(G+256L*B)

      R=205L & G=91L & B=69L
      defsysv, '!coral3', R + 256L*(G+256L*B)

      R=139L & G=62L & B=47L
      defsysv, '!coral4', R + 256L*(G+256L*B)

      R=255L & G=99L & B=71L
      defsysv, '!tomato1', R + 256L*(G+256L*B)

      R=238L & G=92L & B=66L
      defsysv, '!tomato2', R + 256L*(G+256L*B)

      R=205L & G=79L & B=57L
      defsysv, '!tomato3', R + 256L*(G+256L*B)

      R=139L & G=54L & B=38L
      defsysv, '!tomato4', R + 256L*(G+256L*B)

      R=255L & G=69L & B=0L
      defsysv, '!OrangeRed1', R + 256L*(G+256L*B)

      R=238L & G=64L & B=0L
      defsysv, '!OrangeRed2', R + 256L*(G+256L*B)

      R=205L & G=55L & B=0L
      defsysv, '!OrangeRed3', R + 256L*(G+256L*B)

      R=139L & G=37L & B=0L
      defsysv, '!OrangeRed4', R + 256L*(G+256L*B)

      R=255L & G=0L & B=0L
      defsysv, '!red1', R + 256L*(G+256L*B)

      R=238L & G=0L & B=0L
      defsysv, '!red2', R + 256L*(G+256L*B)

      R=205L & G=0L & B=0L
      defsysv, '!red3', R + 256L*(G+256L*B)

      R=139L & G=0L & B=0L
      defsysv, '!red4', R + 256L*(G+256L*B)

      R=255L & G=20L & B=147L
      defsysv, '!DeepPink1', R + 256L*(G+256L*B)

      R=238L & G=18L & B=137L
      defsysv, '!DeepPink2', R + 256L*(G+256L*B)

      R=205L & G=16L & B=118L
      defsysv, '!DeepPink3', R + 256L*(G+256L*B)

      R=139L & G=10L & B=80L
      defsysv, '!DeepPink4', R + 256L*(G+256L*B)

      R=255L & G=110L & B=180L
      defsysv, '!HotPink1', R + 256L*(G+256L*B)

      R=238L & G=106L & B=167L
      defsysv, '!HotPink2', R + 256L*(G+256L*B)

      R=205L & G=96L & B=144L
      defsysv, '!HotPink3', R + 256L*(G+256L*B)

      R=139L & G=58L & B=98L
      defsysv, '!HotPink4', R + 256L*(G+256L*B)

      R=255L & G=181L & B=197L
      defsysv, '!pink1', R + 256L*(G+256L*B)

      R=238L & G=169L & B=184L
      defsysv, '!pink2', R + 256L*(G+256L*B)

      R=205L & G=145L & B=158L
      defsysv, '!pink3', R + 256L*(G+256L*B)

      R=139L & G=99L & B=108L
      defsysv, '!pink4', R + 256L*(G+256L*B)

      R=255L & G=174L & B=185L
      defsysv, '!LightPink1', R + 256L*(G+256L*B)

      R=238L & G=162L & B=173L
      defsysv, '!LightPink2', R + 256L*(G+256L*B)

      R=205L & G=140L & B=149L
      defsysv, '!LightPink3', R + 256L*(G+256L*B)

      R=139L & G=95L & B=101L
      defsysv, '!LightPink4', R + 256L*(G+256L*B)

      R=255L & G=130L & B=171L
      defsysv, '!PaleVioletRed1', R + 256L*(G+256L*B)

      R=238L & G=121L & B=159L
      defsysv, '!PaleVioletRed2', R + 256L*(G+256L*B)

      R=205L & G=104L & B=137L
      defsysv, '!PaleVioletRed3', R + 256L*(G+256L*B)

      R=139L & G=71L & B=93L
      defsysv, '!PaleVioletRed4', R + 256L*(G+256L*B)

      R=255L & G=52L & B=179L
      defsysv, '!maroon1', R + 256L*(G+256L*B)

      R=238L & G=48L & B=167L
      defsysv, '!maroon2', R + 256L*(G+256L*B)

      R=205L & G=41L & B=144L
      defsysv, '!maroon3', R + 256L*(G+256L*B)

      R=139L & G=28L & B=98L
      defsysv, '!maroon4', R + 256L*(G+256L*B)

      R=255L & G=62L & B=150L
      defsysv, '!VioletRed1', R + 256L*(G+256L*B)

      R=238L & G=58L & B=140L
      defsysv, '!VioletRed2', R + 256L*(G+256L*B)

      R=205L & G=50L & B=120L
      defsysv, '!VioletRed3', R + 256L*(G+256L*B)

      R=139L & G=34L & B=82L
      defsysv, '!VioletRed4', R + 256L*(G+256L*B)

      R=255L & G=0L & B=255L
      defsysv, '!magenta1', R + 256L*(G+256L*B)

      R=238L & G=0L & B=238L
      defsysv, '!magenta2', R + 256L*(G+256L*B)

      R=205L & G=0L & B=205L
      defsysv, '!magenta3', R + 256L*(G+256L*B)

      R=139L & G=0L & B=139L
      defsysv, '!magenta4', R + 256L*(G+256L*B)

      R=255L & G=131L & B=250L
      defsysv, '!orchid1', R + 256L*(G+256L*B)

      R=238L & G=122L & B=233L
      defsysv, '!orchid2', R + 256L*(G+256L*B)

      R=205L & G=105L & B=201L
      defsysv, '!orchid3', R + 256L*(G+256L*B)

      R=139L & G=71L & B=137L
      defsysv, '!orchid4', R + 256L*(G+256L*B)

      R=255L & G=187L & B=255L
      defsysv, '!plum1', R + 256L*(G+256L*B)

      R=238L & G=174L & B=238L
      defsysv, '!plum2', R + 256L*(G+256L*B)

      R=205L & G=150L & B=205L
      defsysv, '!plum3', R + 256L*(G+256L*B)

      R=139L & G=102L & B=139L
      defsysv, '!plum4', R + 256L*(G+256L*B)

      R=224L & G=102L & B=255L
      defsysv, '!MediumOrchid1', R + 256L*(G+256L*B)

      R=209L & G=95L & B=238L
      defsysv, '!MediumOrchid2', R + 256L*(G+256L*B)

      R=180L & G=82L & B=205L
      defsysv, '!MediumOrchid3', R + 256L*(G+256L*B)

      R=122L & G=55L & B=139L
      defsysv, '!MediumOrchid4', R + 256L*(G+256L*B)

      R=191L & G=62L & B=255L
      defsysv, '!DarkOrchid1', R + 256L*(G+256L*B)

      R=178L & G=58L & B=238L
      defsysv, '!DarkOrchid2', R + 256L*(G+256L*B)

      R=154L & G=50L & B=205L
      defsysv, '!DarkOrchid3', R + 256L*(G+256L*B)

      R=104L & G=34L & B=139L
      defsysv, '!DarkOrchid4', R + 256L*(G+256L*B)

      R=155L & G=48L & B=255L
      defsysv, '!purple1', R + 256L*(G+256L*B)

      R=145L & G=44L & B=238L
      defsysv, '!purple2', R + 256L*(G+256L*B)

      R=125L & G=38L & B=205L
      defsysv, '!purple3', R + 256L*(G+256L*B)

      R=85L & G=26L & B=139L
      defsysv, '!purple4', R + 256L*(G+256L*B)

      R=171L & G=130L & B=255L
      defsysv, '!MediumPurple1', R + 256L*(G+256L*B)

      R=159L & G=121L & B=238L
      defsysv, '!MediumPurple2', R + 256L*(G+256L*B)

      R=137L & G=104L & B=205L
      defsysv, '!MediumPurple3', R + 256L*(G+256L*B)

      R=93L & G=71L & B=139L
      defsysv, '!MediumPurple4', R + 256L*(G+256L*B)

      R=255L & G=225L & B=255L
      defsysv, '!thistle1', R + 256L*(G+256L*B)

      R=238L & G=210L & B=238L
      defsysv, '!thistle2', R + 256L*(G+256L*B)

      R=205L & G=181L & B=205L
      defsysv, '!thistle3', R + 256L*(G+256L*B)

      R=139L & G=123L & B=139L
      defsysv, '!thistle4', R + 256L*(G+256L*B)

      R=0L & G=0L & B=0L
      defsysv, '!gray0', R + 256L*(G+256L*B)

      R=0L & G=0L & B=0L
      defsysv, '!grey0', R + 256L*(G+256L*B)

      R=3L & G=3L & B=3L
      defsysv, '!gray1', R + 256L*(G+256L*B)

      R=3L & G=3L & B=3L
      defsysv, '!grey1', R + 256L*(G+256L*B)

      R=5L & G=5L & B=5L
      defsysv, '!gray2', R + 256L*(G+256L*B)

      R=5L & G=5L & B=5L
      defsysv, '!grey2', R + 256L*(G+256L*B)

      R=8L & G=8L & B=8L
      defsysv, '!gray3', R + 256L*(G+256L*B)

      R=8L & G=8L & B=8L
      defsysv, '!grey3', R + 256L*(G+256L*B)

      R=10L & G=10L & B=10L
      defsysv, '!gray4', R + 256L*(G+256L*B)

      R=10L & G=10L & B=10L
      defsysv, '!grey4', R + 256L*(G+256L*B)

      R=13L & G=13L & B=13L
      defsysv, '!gray5', R + 256L*(G+256L*B)

      R=13L & G=13L & B=13L
      defsysv, '!grey5', R + 256L*(G+256L*B)

      R=15L & G=15L & B=15L
      defsysv, '!gray6', R + 256L*(G+256L*B)

      R=15L & G=15L & B=15L
      defsysv, '!grey6', R + 256L*(G+256L*B)

      R=18L & G=18L & B=18L
      defsysv, '!gray7', R + 256L*(G+256L*B)

      R=18L & G=18L & B=18L
      defsysv, '!grey7', R + 256L*(G+256L*B)

      R=20L & G=20L & B=20L
      defsysv, '!gray8', R + 256L*(G+256L*B)

      R=20L & G=20L & B=20L
      defsysv, '!grey8', R + 256L*(G+256L*B)

      R=23L & G=23L & B=23L
      defsysv, '!gray9', R + 256L*(G+256L*B)

      R=23L & G=23L & B=23L
      defsysv, '!grey9', R + 256L*(G+256L*B)

      R=26L & G=26L & B=26L
      defsysv, '!gray10', R + 256L*(G+256L*B)

      R=26L & G=26L & B=26L
      defsysv, '!grey10', R + 256L*(G+256L*B)

      R=28L & G=28L & B=28L
      defsysv, '!gray11', R + 256L*(G+256L*B)

      R=28L & G=28L & B=28L
      defsysv, '!grey11', R + 256L*(G+256L*B)

      R=31L & G=31L & B=31L
      defsysv, '!gray12', R + 256L*(G+256L*B)

      R=31L & G=31L & B=31L
      defsysv, '!grey12', R + 256L*(G+256L*B)

      R=33L & G=33L & B=33L
      defsysv, '!gray13', R + 256L*(G+256L*B)

      R=33L & G=33L & B=33L
      defsysv, '!grey13', R + 256L*(G+256L*B)

      R=36L & G=36L & B=36L
      defsysv, '!gray14', R + 256L*(G+256L*B)

      R=36L & G=36L & B=36L
      defsysv, '!grey14', R + 256L*(G+256L*B)

      R=38L & G=38L & B=38L
      defsysv, '!gray15', R + 256L*(G+256L*B)

      R=38L & G=38L & B=38L
      defsysv, '!grey15', R + 256L*(G+256L*B)

      R=41L & G=41L & B=41L
      defsysv, '!gray16', R + 256L*(G+256L*B)

      R=41L & G=41L & B=41L
      defsysv, '!grey16', R + 256L*(G+256L*B)

      R=43L & G=43L & B=43L
      defsysv, '!gray17', R + 256L*(G+256L*B)

      R=43L & G=43L & B=43L
      defsysv, '!grey17', R + 256L*(G+256L*B)

      R=46L & G=46L & B=46L
      defsysv, '!gray18', R + 256L*(G+256L*B)

      R=46L & G=46L & B=46L
      defsysv, '!grey18', R + 256L*(G+256L*B)

      R=48L & G=48L & B=48L
      defsysv, '!gray19', R + 256L*(G+256L*B)

      R=48L & G=48L & B=48L
      defsysv, '!grey19', R + 256L*(G+256L*B)

      R=51L & G=51L & B=51L
      defsysv, '!gray20', R + 256L*(G+256L*B)

      R=51L & G=51L & B=51L
      defsysv, '!grey20', R + 256L*(G+256L*B)

      R=54L & G=54L & B=54L
      defsysv, '!gray21', R + 256L*(G+256L*B)

      R=54L & G=54L & B=54L
      defsysv, '!grey21', R + 256L*(G+256L*B)

      R=56L & G=56L & B=56L
      defsysv, '!gray22', R + 256L*(G+256L*B)

      R=56L & G=56L & B=56L
      defsysv, '!grey22', R + 256L*(G+256L*B)

      R=59L & G=59L & B=59L
      defsysv, '!gray23', R + 256L*(G+256L*B)

      R=59L & G=59L & B=59L
      defsysv, '!grey23', R + 256L*(G+256L*B)

      R=61L & G=61L & B=61L
      defsysv, '!gray24', R + 256L*(G+256L*B)

      R=61L & G=61L & B=61L
      defsysv, '!grey24', R + 256L*(G+256L*B)

      R=64L & G=64L & B=64L
      defsysv, '!gray25', R + 256L*(G+256L*B)

      R=64L & G=64L & B=64L
      defsysv, '!grey25', R + 256L*(G+256L*B)

      R=66L & G=66L & B=66L
      defsysv, '!gray26', R + 256L*(G+256L*B)

      R=66L & G=66L & B=66L
      defsysv, '!grey26', R + 256L*(G+256L*B)

      R=69L & G=69L & B=69L
      defsysv, '!gray27', R + 256L*(G+256L*B)

      R=69L & G=69L & B=69L
      defsysv, '!grey27', R + 256L*(G+256L*B)

      R=71L & G=71L & B=71L
      defsysv, '!gray28', R + 256L*(G+256L*B)

      R=71L & G=71L & B=71L
      defsysv, '!grey28', R + 256L*(G+256L*B)

      R=74L & G=74L & B=74L
      defsysv, '!gray29', R + 256L*(G+256L*B)

      R=74L & G=74L & B=74L
      defsysv, '!grey29', R + 256L*(G+256L*B)

      R=77L & G=77L & B=77L
      defsysv, '!gray30', R + 256L*(G+256L*B)

      R=77L & G=77L & B=77L
      defsysv, '!grey30', R + 256L*(G+256L*B)

      R=79L & G=79L & B=79L
      defsysv, '!gray31', R + 256L*(G+256L*B)

      R=79L & G=79L & B=79L
      defsysv, '!grey31', R + 256L*(G+256L*B)

      R=82L & G=82L & B=82L
      defsysv, '!gray32', R + 256L*(G+256L*B)

      R=82L & G=82L & B=82L
      defsysv, '!grey32', R + 256L*(G+256L*B)

      R=84L & G=84L & B=84L
      defsysv, '!gray33', R + 256L*(G+256L*B)

      R=84L & G=84L & B=84L
      defsysv, '!grey33', R + 256L*(G+256L*B)

      R=87L & G=87L & B=87L
      defsysv, '!gray34', R + 256L*(G+256L*B)

      R=87L & G=87L & B=87L
      defsysv, '!grey34', R + 256L*(G+256L*B)

      R=89L & G=89L & B=89L
      defsysv, '!gray35', R + 256L*(G+256L*B)

      R=89L & G=89L & B=89L
      defsysv, '!grey35', R + 256L*(G+256L*B)

      R=92L & G=92L & B=92L
      defsysv, '!gray36', R + 256L*(G+256L*B)

      R=92L & G=92L & B=92L
      defsysv, '!grey36', R + 256L*(G+256L*B)

      R=94L & G=94L & B=94L
      defsysv, '!gray37', R + 256L*(G+256L*B)

      R=94L & G=94L & B=94L
      defsysv, '!grey37', R + 256L*(G+256L*B)

      R=97L & G=97L & B=97L
      defsysv, '!gray38', R + 256L*(G+256L*B)

      R=97L & G=97L & B=97L
      defsysv, '!grey38', R + 256L*(G+256L*B)

      R=99L & G=99L & B=99L
      defsysv, '!gray39', R + 256L*(G+256L*B)

      R=99L & G=99L & B=99L
      defsysv, '!grey39', R + 256L*(G+256L*B)

      R=102L & G=102L & B=102L
      defsysv, '!gray40', R + 256L*(G+256L*B)

      R=102L & G=102L & B=102L
      defsysv, '!grey40', R + 256L*(G+256L*B)

      R=105L & G=105L & B=105L
      defsysv, '!gray41', R + 256L*(G+256L*B)

      R=105L & G=105L & B=105L
      defsysv, '!grey41', R + 256L*(G+256L*B)

      R=107L & G=107L & B=107L
      defsysv, '!gray42', R + 256L*(G+256L*B)

      R=107L & G=107L & B=107L
      defsysv, '!grey42', R + 256L*(G+256L*B)

      R=110L & G=110L & B=110L
      defsysv, '!gray43', R + 256L*(G+256L*B)

      R=110L & G=110L & B=110L
      defsysv, '!grey43', R + 256L*(G+256L*B)

      R=112L & G=112L & B=112L
      defsysv, '!gray44', R + 256L*(G+256L*B)

      R=112L & G=112L & B=112L
      defsysv, '!grey44', R + 256L*(G+256L*B)

      R=115L & G=115L & B=115L
      defsysv, '!gray45', R + 256L*(G+256L*B)

      R=115L & G=115L & B=115L
      defsysv, '!grey45', R + 256L*(G+256L*B)

      R=117L & G=117L & B=117L
      defsysv, '!gray46', R + 256L*(G+256L*B)

      R=117L & G=117L & B=117L
      defsysv, '!grey46', R + 256L*(G+256L*B)

      R=120L & G=120L & B=120L
      defsysv, '!gray47', R + 256L*(G+256L*B)

      R=120L & G=120L & B=120L
      defsysv, '!grey47', R + 256L*(G+256L*B)

      R=122L & G=122L & B=122L
      defsysv, '!gray48', R + 256L*(G+256L*B)

      R=122L & G=122L & B=122L
      defsysv, '!grey48', R + 256L*(G+256L*B)

      R=125L & G=125L & B=125L
      defsysv, '!gray49', R + 256L*(G+256L*B)

      R=125L & G=125L & B=125L
      defsysv, '!grey49', R + 256L*(G+256L*B)

      R=127L & G=127L & B=127L
      defsysv, '!gray50', R + 256L*(G+256L*B)

      R=127L & G=127L & B=127L
      defsysv, '!grey50', R + 256L*(G+256L*B)

      R=130L & G=130L & B=130L
      defsysv, '!gray51', R + 256L*(G+256L*B)

      R=130L & G=130L & B=130L
      defsysv, '!grey51', R + 256L*(G+256L*B)

      R=133L & G=133L & B=133L
      defsysv, '!gray52', R + 256L*(G+256L*B)

      R=133L & G=133L & B=133L
      defsysv, '!grey52', R + 256L*(G+256L*B)

      R=135L & G=135L & B=135L
      defsysv, '!gray53', R + 256L*(G+256L*B)

      R=135L & G=135L & B=135L
      defsysv, '!grey53', R + 256L*(G+256L*B)

      R=138L & G=138L & B=138L
      defsysv, '!gray54', R + 256L*(G+256L*B)

      R=138L & G=138L & B=138L
      defsysv, '!grey54', R + 256L*(G+256L*B)

      R=140L & G=140L & B=140L
      defsysv, '!gray55', R + 256L*(G+256L*B)

      R=140L & G=140L & B=140L
      defsysv, '!grey55', R + 256L*(G+256L*B)

      R=143L & G=143L & B=143L
      defsysv, '!gray56', R + 256L*(G+256L*B)

      R=143L & G=143L & B=143L
      defsysv, '!grey56', R + 256L*(G+256L*B)

      R=145L & G=145L & B=145L
      defsysv, '!gray57', R + 256L*(G+256L*B)

      R=145L & G=145L & B=145L
      defsysv, '!grey57', R + 256L*(G+256L*B)

      R=148L & G=148L & B=148L
      defsysv, '!gray58', R + 256L*(G+256L*B)

      R=148L & G=148L & B=148L
      defsysv, '!grey58', R + 256L*(G+256L*B)

      R=150L & G=150L & B=150L
      defsysv, '!gray59', R + 256L*(G+256L*B)

      R=150L & G=150L & B=150L
      defsysv, '!grey59', R + 256L*(G+256L*B)

      R=153L & G=153L & B=153L
      defsysv, '!gray60', R + 256L*(G+256L*B)

      R=153L & G=153L & B=153L
      defsysv, '!grey60', R + 256L*(G+256L*B)

      R=156L & G=156L & B=156L
      defsysv, '!gray61', R + 256L*(G+256L*B)

      R=156L & G=156L & B=156L
      defsysv, '!grey61', R + 256L*(G+256L*B)

      R=158L & G=158L & B=158L
      defsysv, '!gray62', R + 256L*(G+256L*B)

      R=158L & G=158L & B=158L
      defsysv, '!grey62', R + 256L*(G+256L*B)

      R=161L & G=161L & B=161L
      defsysv, '!gray63', R + 256L*(G+256L*B)

      R=161L & G=161L & B=161L
      defsysv, '!grey63', R + 256L*(G+256L*B)

      R=163L & G=163L & B=163L
      defsysv, '!gray64', R + 256L*(G+256L*B)

      R=163L & G=163L & B=163L
      defsysv, '!grey64', R + 256L*(G+256L*B)

      R=166L & G=166L & B=166L
      defsysv, '!gray65', R + 256L*(G+256L*B)

      R=166L & G=166L & B=166L
      defsysv, '!grey65', R + 256L*(G+256L*B)

      R=168L & G=168L & B=168L
      defsysv, '!gray66', R + 256L*(G+256L*B)

      R=168L & G=168L & B=168L
      defsysv, '!grey66', R + 256L*(G+256L*B)

      R=171L & G=171L & B=171L
      defsysv, '!gray67', R + 256L*(G+256L*B)

      R=171L & G=171L & B=171L
      defsysv, '!grey67', R + 256L*(G+256L*B)

      R=173L & G=173L & B=173L
      defsysv, '!gray68', R + 256L*(G+256L*B)

      R=173L & G=173L & B=173L
      defsysv, '!grey68', R + 256L*(G+256L*B)

      R=176L & G=176L & B=176L
      defsysv, '!gray69', R + 256L*(G+256L*B)

      R=176L & G=176L & B=176L
      defsysv, '!grey69', R + 256L*(G+256L*B)

      R=179L & G=179L & B=179L
      defsysv, '!gray70', R + 256L*(G+256L*B)

      R=179L & G=179L & B=179L
      defsysv, '!grey70', R + 256L*(G+256L*B)

      R=181L & G=181L & B=181L
      defsysv, '!gray71', R + 256L*(G+256L*B)

      R=181L & G=181L & B=181L
      defsysv, '!grey71', R + 256L*(G+256L*B)

      R=184L & G=184L & B=184L
      defsysv, '!gray72', R + 256L*(G+256L*B)

      R=184L & G=184L & B=184L
      defsysv, '!grey72', R + 256L*(G+256L*B)

      R=186L & G=186L & B=186L
      defsysv, '!gray73', R + 256L*(G+256L*B)

      R=186L & G=186L & B=186L
      defsysv, '!grey73', R + 256L*(G+256L*B)

      R=189L & G=189L & B=189L
      defsysv, '!gray74', R + 256L*(G+256L*B)

      R=189L & G=189L & B=189L
      defsysv, '!grey74', R + 256L*(G+256L*B)

      R=191L & G=191L & B=191L
      defsysv, '!gray75', R + 256L*(G+256L*B)

      R=191L & G=191L & B=191L
      defsysv, '!grey75', R + 256L*(G+256L*B)

      R=194L & G=194L & B=194L
      defsysv, '!gray76', R + 256L*(G+256L*B)

      R=194L & G=194L & B=194L
      defsysv, '!grey76', R + 256L*(G+256L*B)

      R=196L & G=196L & B=196L
      defsysv, '!gray77', R + 256L*(G+256L*B)

      R=196L & G=196L & B=196L
      defsysv, '!grey77', R + 256L*(G+256L*B)

      R=199L & G=199L & B=199L
      defsysv, '!gray78', R + 256L*(G+256L*B)

      R=199L & G=199L & B=199L
      defsysv, '!grey78', R + 256L*(G+256L*B)

      R=201L & G=201L & B=201L
      defsysv, '!gray79', R + 256L*(G+256L*B)

      R=201L & G=201L & B=201L
      defsysv, '!grey79', R + 256L*(G+256L*B)

      R=204L & G=204L & B=204L
      defsysv, '!gray80', R + 256L*(G+256L*B)

      R=204L & G=204L & B=204L
      defsysv, '!grey80', R + 256L*(G+256L*B)

      R=207L & G=207L & B=207L
      defsysv, '!gray81', R + 256L*(G+256L*B)

      R=207L & G=207L & B=207L
      defsysv, '!grey81', R + 256L*(G+256L*B)

      R=209L & G=209L & B=209L
      defsysv, '!gray82', R + 256L*(G+256L*B)

      R=209L & G=209L & B=209L
      defsysv, '!grey82', R + 256L*(G+256L*B)

      R=212L & G=212L & B=212L
      defsysv, '!gray83', R + 256L*(G+256L*B)

      R=212L & G=212L & B=212L
      defsysv, '!grey83', R + 256L*(G+256L*B)

      R=214L & G=214L & B=214L
      defsysv, '!gray84', R + 256L*(G+256L*B)

      R=214L & G=214L & B=214L
      defsysv, '!grey84', R + 256L*(G+256L*B)

      R=217L & G=217L & B=217L
      defsysv, '!gray85', R + 256L*(G+256L*B)

      R=217L & G=217L & B=217L
      defsysv, '!grey85', R + 256L*(G+256L*B)

      R=219L & G=219L & B=219L
      defsysv, '!gray86', R + 256L*(G+256L*B)

      R=219L & G=219L & B=219L
      defsysv, '!grey86', R + 256L*(G+256L*B)

      R=222L & G=222L & B=222L
      defsysv, '!gray87', R + 256L*(G+256L*B)

      R=222L & G=222L & B=222L
      defsysv, '!grey87', R + 256L*(G+256L*B)

      R=224L & G=224L & B=224L
      defsysv, '!gray88', R + 256L*(G+256L*B)

      R=224L & G=224L & B=224L
      defsysv, '!grey88', R + 256L*(G+256L*B)

      R=227L & G=227L & B=227L
      defsysv, '!gray89', R + 256L*(G+256L*B)

      R=227L & G=227L & B=227L
      defsysv, '!grey89', R + 256L*(G+256L*B)

      R=229L & G=229L & B=229L
      defsysv, '!gray90', R + 256L*(G+256L*B)

      R=229L & G=229L & B=229L
      defsysv, '!grey90', R + 256L*(G+256L*B)

      R=232L & G=232L & B=232L
      defsysv, '!gray91', R + 256L*(G+256L*B)

      R=232L & G=232L & B=232L
      defsysv, '!grey91', R + 256L*(G+256L*B)

      R=235L & G=235L & B=235L
      defsysv, '!gray92', R + 256L*(G+256L*B)

      R=235L & G=235L & B=235L
      defsysv, '!grey92', R + 256L*(G+256L*B)

      R=237L & G=237L & B=237L
      defsysv, '!gray93', R + 256L*(G+256L*B)

      R=237L & G=237L & B=237L
      defsysv, '!grey93', R + 256L*(G+256L*B)

      R=240L & G=240L & B=240L
      defsysv, '!gray94', R + 256L*(G+256L*B)

      R=240L & G=240L & B=240L
      defsysv, '!grey94', R + 256L*(G+256L*B)

      R=242L & G=242L & B=242L
      defsysv, '!gray95', R + 256L*(G+256L*B)

      R=242L & G=242L & B=242L
      defsysv, '!grey95', R + 256L*(G+256L*B)

      R=245L & G=245L & B=245L
      defsysv, '!gray96', R + 256L*(G+256L*B)

      R=245L & G=245L & B=245L
      defsysv, '!grey96', R + 256L*(G+256L*B)

      R=247L & G=247L & B=247L
      defsysv, '!gray97', R + 256L*(G+256L*B)

      R=247L & G=247L & B=247L
      defsysv, '!grey97', R + 256L*(G+256L*B)

      R=250L & G=250L & B=250L
      defsysv, '!gray98', R + 256L*(G+256L*B)

      R=250L & G=250L & B=250L
      defsysv, '!grey98', R + 256L*(G+256L*B)

      R=252L & G=252L & B=252L
      defsysv, '!gray99', R + 256L*(G+256L*B)

      R=252L & G=252L & B=252L
      defsysv, '!grey99', R + 256L*(G+256L*B)

      R=255L & G=255L & B=255L
      defsysv, '!gray100', R + 256L*(G+256L*B)

      R=255L & G=255L & B=255L
      defsysv, '!grey100', R + 256L*(G+256L*B)

      R=169L & G=169L & B=169L
      defsysv, '!DarkGrey', R + 256L*(G+256L*B)

      R=169L & G=169L & B=169L
      defsysv, '!DarkGray', R + 256L*(G+256L*B)

      R=0L & G=0L & B=139L
      defsysv, '!DarkBlue', R + 256L*(G+256L*B)

      R=0L & G=139L & B=139L
      defsysv, '!DarkCyan', R + 256L*(G+256L*B)

      R=139L & G=0L & B=139L
      defsysv, '!DarkMagenta', R + 256L*(G+256L*B)

      R=139L & G=0L & B=0L
      defsysv, '!DarkRed', R + 256L*(G+256L*B)

      R=144L & G=238L & B=144L
      defsysv, '!LightGreen', R + 256L*(G+256L*B)

      


  ENDELSE 


  IF keyword_set(help) THEN BEGIN 
      print,'-Syntax: simpctable [, red_ct, green_ct, blue_ct, bits=bits, '+$
        'colorlist=, /help, /showcolors]'
      print
      print,'Below are the system variables set for all devices.  '+$
            'On 24-bit devices'
      print,'more colors are defined, which can be shown with /showcolors.'
      print,'Colors names with spaces are redundant '+$
            'and are not defined by simpctable.'
      print
      print,'   !Black !White !Red !Green !Blue !Yellow !Cyan !Magenta'
      print
      print,'   !LightSteelBlue     !SkyBlue         !DarkSlateGrey'
      print,'   !SlateGrey          !LightBlue       !MidnightBlue'
      print,'   !NavyBlue           !RoyalBlue       !DodgerBlue'
      print,'   !DarkBlue           !Turquoise       !DarkGreen'
      print,'   !SeaGreen           !ForestGreen     !LightGreen'
      print,'   !Sienna             !Firebrick       !Salmon'
      print,'   !Orange             !OrangeRed       !HotPink'               
      print,'   !DeepPink           !Violet          !DarkRed'
      print,'   !Purple'
      print
      print,'   !grey0 grey1 ... !grey100'
  ENDIF 

  IF keyword_set(showcolors) THEN BEGIN 

      spawn,'showrgb'

      print,'Colors names with spaces are redundant '+$
            'and are not defined by simpctable'
  ENDIF 

  ;; Can return a list of standard colors
  IF arg_present(colorlist) THEN BEGIN 
      IF !d.name EQ 'PS' THEN BEGIN 
          colorlist =  [!p.color, !Red,!DarkGreen,!Blue,!Orange,!DodgerBlue,$
                        !Magenta,$
                        !SkyBlue, !DarkSlateGrey, $
                        !SlateGrey,!Firebrick,!MidnightBlue,$
                        !RoyalBlue,!Cyan,$
                        !DarkBlue,!Turquoise,$
                        !SeaGreen,!ForestGreen,!LightGreen,$
                        !Sienna,!Salmon,$
                        !Yellow,!OrangeRed,!HotPink,$
                        !DeepPink,!Violet,!DarkRed,!Purple,!Green]

      ENDIF ELSE BEGIN 

          colorlist =  [!p.color, !Red,!Green,!Blue,!Yellow,!Cyan,!Magenta,$
                        !DarkGreen,!SkyBlue, !DarkSlateGrey, $
                        !SlateGrey,!Orange,!MidnightBlue,$
                        !RoyalBlue,!DodgerBlue,$
                        !DarkBlue,!Turquoise,$
                        !SeaGreen,!ForestGreen,!LightGreen,$
                        !Sienna,!Firebrick,!Salmon,$
                        !OrangeRed,!HotPink,$
                        !DeepPink,!Violet,!DarkRed,!Purple]

      ENDELSE 
  ENDIF 

END 
