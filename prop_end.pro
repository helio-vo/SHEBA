@./planet_orbit.pro
@./cme_prop_sp.pro
pro ploting_prop,planets,cme,cme_s,file_out

lon_0 = cme_s[0]
width = cme_s[1]

inner_r = [-2.5,2.5]
outer_r = [-46.5,46.5]

cme_t = 0
cme_r = 0

planets_colors=[9,7,5,3,6,2,4,10,9]

for i =0,8 do begin
   cme_t =[cme_t,cme[(i*2)]]
   cme_r =[cme_r,cme[(i*2)+1]]
endfor


set_plot,'z'
loadct,0,/silent
COMBINE_COLORS,/LOWER	
loadct,5,/silent
COMBINE_COLORS
set_line_color
Device, Set_Resolution=[2400, 2400]
;window,15,xsize=600, ysize=600
!p.background = 255
position=[0.1,0.1,0.9,0.9]
xsol=[0,0]
ysol=[0,0]

angle_arr  = findgen(width*10)/10 - width/2.

ff=1
Cs=1.5*4
syms = 7



lab_r3 = where(cme_r le 3,nl3)

cme_days3 = findgen(1000)*max(cme_t[lab_r3])/1000
cme_radius3 = interpol(cme_r[lab_r3],cme_t[lab_r3],cme_days3)



;plot inner system 
; Get the cme plot to overplot
;loadct,0,/silent
plot,xsol,ysol,psym=3,xrange=inner_r,yrange=inner_r,xstyle=5,ystyle=5,position=position
;loadct,5,/silent
      cme_xx = fltarr(1000)
      cme_yy = fltarr(1000)
      for j=0, n_elements(angle_arr)-1 do begin
         for i=0,1000-1  do begin
            polrec,cme_radius3[i],lon_0+angle_arr[j],cme_x,cme_y,/degrees
            cme_xx[i]=cme_x
            cme_yy[i]=cme_y
         endfor
         color = bytscl(cme_days3)/2 + (255./2.)
         for i=0,1000-2 do plots,[cme_xx[i],cme_xx[i+1]],[cme_yy[i],cme_yy[i+1]],color=color[i],thick=2
      endfor
color_bar,cme_days3,.1,0.9,0.87,0.93,/normal,bottom=min(color)+1,color=0,/above,Font=ff, Charsize=cs,title='Days'
foreground = TVREAD(TRUE=3)
; Plot the planets on both times, with fill and not.
;loadct,0,/silent
plot,xsol,ysol,psym=3,xrange=inner_r,yrange=inner_r,xstyle=5,ystyle=5,position=position

;orbits
for i = 0,3 do begin
   pp=plot_orbit(planets[i],/orbit,/over,color=100,thick=5)
endfor
;planets
;set_line_color
circle_sym, thick = 2
for i = 0,3  do begin
   plots,planets[i].start.orbit_x,planets[i].start.orbit_y,psym=8,color=planets_colors[i],symsize=syms
endfor
circle_sym, thick = 2,/fill
for i = 0,3  do begin
   plots,planets[i].hitpos.orbit_x,planets[i].hitpos.orbit_y,psym=8,color=planets_colors[i],symsize=syms
   if planets[i].hitormiss eq 1 then begin
      circle_sym, thick = 3
      plots,planets[i].hitpos.orbit_x,planets[i].hitpos.orbit_y,psym=8,color=100,symsize=syms
      circle_sym, thick = 2,/fill
   endif
endfor
;Plot the sun
 plots, [ 0 , 0 ], [ 0, 0 ], psym = 8, color = 2, symsize = syms+1

;Legend of planets
plots,0.1,0.1,/normal,psym = 8, color = 2, symsize = syms
xyouts, 0.13,0.09, 'Sun',color=0,/normal,Font=ff, Charsize=cs
circle_sym, thick = 2
plots,0.3,0.1,/normal,psym = 8, color = 0, symsize = syms
xyouts, 0.33,0.09, 'Start Time',color=0,/normal,Font=ff, Charsize=cs
circle_sym, thick = 2,/fill
plots,0.5,0.1,/normal,psym = 8, color = 0, symsize = syms
xyouts, 0.53,0.09, 'End Time',color=0,/normal,Font=ff, Charsize=cs
plots,0.1,0.05,/normal,psym = 8, color = planets_colors[0], symsize = syms
xyouts, 0.13,0.04, 'Mercury',color=0,/normal,Font=ff, Charsize=cs
plots,0.3,0.05,/normal,psym = 8, color = planets_colors[1], symsize = syms
xyouts, 0.33,0.04, 'Venus',color=0,/normal,Font=ff, Charsize=cs
plots,0.5,0.05,/normal,psym = 8, color = planets_colors[2], symsize = syms
xyouts, 0.53,0.04, 'Earth',color=0,/normal,Font=ff, Charsize=cs
plots,0.7,0.05,/normal,psym = 8, color = planets_colors[3], symsize = syms
xyouts, 0.73,0.04, 'Mars',color=0,/normal,Font=ff, Charsize=cs


background = TVREAD(TRUE=3)

;** imagemagick way
a = rebin(transpose(foreground,[2,0,1]),3,600,600)
write_png,file_out+'_inner_fg.png',a
a = rebin( transpose(background,[2,0,1]),3,600,600)
write_png,file_out+'_inner_bg.png',a
spawn,'convert '+file_out+'_inner_bg.png -fuzz 05% -transparent white '+file_out+'_inner_bg_tr.png'
spawn,'convert '+file_out+'_inner_fg.png -fuzz 05% -transparent white '+file_out+'_inner_fg_tr.png'
spawn,'composite -dissolve 100 -gravity center '+ file_out+'_inner_bg_tr.png '+file_out+'_inner_fg_tr.png '+file_out+'_inner_b.png'
spawn,'convert '+file_out+'_inner_b.png -background white -flatten '+file_out+'_inner.png'
spawn,'rm '+file_out+'_inner_[fg,bg,b]*.png'




lab_r10 = where(cme_r le 50,nl3)

cme_days10 = findgen(1000)*max(cme_t[lab_r10])/1000
cme_radius10 = interpol(cme_r[lab_r10],cme_t[lab_r10],cme_days10)



;plot inner system 
; Get the cme plot to overplot
;loadct,0,/silent
plot,xsol,ysol,psym=3,xrange=outer_r,yrange=outer_r,xstyle=5,ystyle=5,position=position
;loadct,5,/silent
      cme_xx = fltarr(1000)
      cme_yy = fltarr(1000)
      for j=0, n_elements(angle_arr)-1 do begin
         for i=0,1000-1  do begin
            polrec,cme_radius10[i],lon_0+angle_arr[j],cme_x,cme_y,/degrees
            cme_xx[i]=cme_x
            cme_yy[i]=cme_y
         endfor
         color = bytscl(cme_days10)/2 + (255./2.)
         for i=0,1000-2 do plots,[cme_xx[i],cme_xx[i+1]],[cme_yy[i],cme_yy[i+1]],color=color[i],thick=2
      endfor
color_bar,cme_days10,.1,0.9,0.87,0.93,/normal,bottom=min(color)+1,color=0,/above,Font=ff, Charsize=cs,title='Days'
foreground = TVREAD(TRUE=3)
; Plot the planets on both times, with fill and not.
;loadct,0,/silent
plot,xsol,ysol,psym=3,xrange=outer_r,yrange=outer_r,xstyle=5,ystyle=5,position=position

;orbits
for i = 4,8 do begin
   pp=plot_orbit(planets[i],/orbit,/over,color=100,thick=5)
endfor
;planets
;set_line_color
circle_sym, thick = 2
for i = 4,8  do begin
   plots,planets[i].start.orbit_x,planets[i].start.orbit_y,psym=8,color=planets_colors[i],symsize=syms
endfor
circle_sym, thick = 2,/fill
for i = 4,8  do begin
   plots,planets[i].hitpos.orbit_x,planets[i].hitpos.orbit_y,psym=8,color=planets_colors[i],symsize=syms
   if planets[i].hitormiss eq 1 then begin
      circle_sym, thick = 3
      plots,planets[i].hitpos.orbit_x,planets[i].hitpos.orbit_y,psym=8,color=100,symsize=syms
      circle_sym, thick = 2,/fill
   endif
endfor
;Plot the sun
 plots, [ 0 , 0 ], [ 0, 0 ], psym = 8, color = 2, symsize = syms+1

;Legend of planets
plots,0.1,0.1,/normal,psym = 8, color = 2, symsize = syms
xyouts, 0.13,0.09, 'Sun',color=0,/normal,Font=ff, Charsize=cs
circle_sym, thick = 2
plots,0.3,0.1,/normal,psym = 8, color = 0, symsize = syms
xyouts, 0.33,0.09, 'Start Time',color=0,/normal,Font=ff, Charsize=cs
circle_sym, thick = 2,/fill
plots,0.5,0.1,/normal,psym = 8, color = 0, symsize = syms
xyouts, 0.53,0.09, 'End Time',color=0,/normal,Font=ff, Charsize=cs
plots,0.1,0.05,/normal,psym = 8, color = planets_colors[4], symsize = syms
xyouts, 0.13,0.04, 'Jupiter',color=0,/normal,Font=ff, Charsize=cs
plots,0.3,0.05,/normal,psym = 8, color = planets_colors[5], symsize = syms
xyouts, 0.33,0.04, 'Saturn',color=0,/normal,Font=ff, Charsize=cs
plots,0.5,0.05,/normal,psym = 8, color = planets_colors[6], symsize = syms
xyouts, 0.53,0.04, 'Uranus',color=0,/normal,Font=ff, Charsize=cs
plots,0.7,0.05,/normal,psym = 8, color = planets_colors[7], symsize = syms
xyouts, 0.73,0.04, 'Neptune',color=0,/normal,Font=ff, Charsize=cs
plots,0.85,0.05,/normal,psym = 8, color = planets_colors[8], symsize = syms
xyouts, 0.88,0.04, 'Pluto',color=0,/normal,Font=ff, Charsize=cs


background = TVREAD(TRUE=3)

;** imagemagick way
a = rebin(transpose(foreground,[2,0,1]),3,600,600)
write_png,file_out+'_outer_fg.png',a
a = rebin( transpose(background,[2,0,1]),3,600,600)
write_png,file_out+'_outer_bg.png',a
spawn,'convert '+file_out+'_outer_bg.png -fuzz 05% -transparent white '+file_out+'_outer_bg_tr.png'
spawn,'convert '+file_out+'_outer_fg.png -fuzz 05% -transparent white '+file_out+'_outer_fg_tr.png'
spawn,'composite -dissolve 100 -gravity center '+ file_out+'_outer_bg_tr.png '+file_out+'_outer_fg_tr.png '+file_out+'_outer_b.png'
spawn,'convert '+file_out+'_outer_b.png -background white -flatten '+file_out+'_outer.png'
spawn,'rm '+file_out+'_outer_[fg,bg,b]*.png'




end

pro prop_end,t0=t0,x0=x0,width=width,vel=vel,FILE_OUT = FILE_OUT

if ~keyword_set(t0) then t0 = systim()
if ~keyword_set(x0) then x0=[0]; lon-lat HGI
if ~keyword_set(width) then width=45 ; width in deg
if ~keyword_set(vel) then vel=800 ;km/s
if ~keyword_set(file_out) then file_out = '/tmp/prop_'+string(strcompress(t0,/remove_all))


xsol = [x0,0]
for i=1,9 do begin

   cme_prop_sp,planetn=i,x_sol=x_sol,t_sol=t0,cme_vel=vel,dlong=width,planet_out=planet,cme_val=cme
   planet_all = (i eq 1)?planet:[planet_all,planet]
   cme_all = (i eq 1)?cme:[cme_all,cme]
   delvarx,planet,cme

endfor

ploting_prop,planet_all,cme_all,[long_hgihg(x_sol[0],/hg,date=t_sol),width],file_out

;writing out the info
openw,lun,file_out+'.out',/get_lun
for i=0,8 do begin
   printf,lun,'------------------------------'
   printf,lun,'planet:'+string(planet_all[i].n,format='(I1)')
   printf,lun,'hit:'+ string(planet_all[i].hitormiss,format='(I1)')
   t1_out = (planet_all[i].hitormiss eq 0)?'0':planet_all[i].hitpos.date
   printf,lun,'eta:'+t1_out
endfor
close,/all


set_plot,'x'
end