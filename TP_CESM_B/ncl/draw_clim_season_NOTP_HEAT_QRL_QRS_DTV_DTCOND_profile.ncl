
begin

lonstr = 75
lonend = 105
latstr = 25
latend = 40


diri  = "/home/yangsong3/data-model/wuyt/TP_NoTOPO_heat_B2000_F19G16_CAM4/pro/"
fili1 = "TP_HEAT.QRL.mon.26001-34912.nc"
fili2 = "TP_HEAT.QRS.mon.26001-34912.nc"
fili3 = "TP_HEAT.DTCOND.mon.26001-34912.nc"
fili4 = "TP_HEAT.DTV.mon.26001-34912.nc"

f1 = addfile(diri+fili1, "r")
f2 = addfile(diri+fili2, "r")
f3 = addfile(diri+fili3, "r")
f4 = addfile(diri+fili4, "r")

x1 = f1->QRL
x2 = f2->QRS
x3 = f3->DTCOND
x4 = f4->DTV
printVarSummary(x1)
lev = x1&lev
lev!0 = "level"
lev&level = lev

Season = (/"DJF","MAM","JJA","SON"/)
x1_JJA = month_to_seasonN(x1, Season)
x2_JJA = month_to_seasonN(x2, Season)
x3_JJA = month_to_seasonN(x3, Season)
x4_JJA = month_to_seasonN(x4, Season)
printVarSummary(x1_JJA)

x11_JJA = dim_avg_n_Wrap(x1_JJA, 1)
x22_JJA = dim_avg_n_Wrap(x2_JJA, 1)
x33_JJA = dim_avg_n_Wrap(x3_JJA, 1)
x44_JJA = dim_avg_n_Wrap(x4_JJA, 1)

printVarSummary(x11_JJA)

JJA = new((/4,dimsizes(Season),dimsizes(x1&lev),dimsizes(x1&lat),dimsizes(x1&lon)/), float)
JJA(0,:,:,:,:) = x11_JJA
JJA(1,:,:,:,:) = x22_JJA
JJA(2,:,:,:,:) = x33_JJA
JJA(3,:,:,:,:) = x44_JJA
printVarSummary(JJA)

JJA2 = new((/3,dimsizes(Season),dimsizes((x1&lev)),dimsizes(x1&lat),dimsizes(x1&lon)/), float)
JJA2(1:2,:,:,:,:) = JJA(2:3,:,:,:,:)
JJA2(0,:,:,:,:) = JJA(0,:,:,:,:)+JJA(1,:,:,:,:) ;radiation cooling

;=======================================================
maskpath = "/home/yangsong3/wuyt/sysu/scripts/TP_CESM_B/model_need_input_data/"
maskname = "TPmask_C20190304.nc"
fmask = addfile(maskpath+maskname, "r")
tp = fmask->tp
tp0 = conform_dims(dimsizes(JJA2), tp, (/3,4/))
printVarSummary(tp0)
JJA2 = mask(JJA2, tp0.ge.0.9, True)
print(JJA2(0,0,4,{35},{90}))
print(JJA2(0,0,4,{20},{90}))

;jja = wgt_areaave_Wrap(JJA(:,:,:,{latstr:latend},{lonstr:lonend}), 1, 1, 1)
;jja2 = wgt_areaave_Wrap(JJA2(:,:,:,{latstr:latend},{lonstr:lonend}), 1, 1, 1)
jja = wgt_areaave_Wrap(JJA(:,:,:,{20:45},{65:110}), 1, 1, 1)
jja2 = wgt_areaave_Wrap(JJA2(:,:,:,{20:45},{65:110}), 1, 1, 1)
printVarSummary(jja)

;==============================================================
 figpath = "/home/yangsong3/wuyt/sysu/figures/TP_CESM_B/ncl/"
 figname = "draw_clim_season_NOTP_HEAT_QRL_QRS_DTV_DTCOND_profile"
 wks = gsn_open_wks("pdf", figpath+figname)
 plot = new(4, graphic)
 dum1 = new(3, graphic)
 dum2 = dum1
 
 ;Colors = (/"green","red","green4","gold"/)
 ;Texts = (/"QRL","QRS","DTCOND","DTV"/)

 Colors = (/"goldenrod","red","green4"/)
 Texts = (/"QRL+QRS","DTCOND","DTV"/)

 res = True
 res@gsnDraw  = False
 res@gsnFrame = False

 res@gsnXRefLine = 0
 res@gsnXRefLineDashPattern = 2
 res@gsnXRefLineColor = "grey"
 res@gsnXRefLineThicknessF = 3
 res@trXMinF = -6.
 res@trXMaxF = 6
 res@trYMinF   = 100
 res@trYMaxF   = 1000
 res@trYLog = True
 
 res@tmYLMode      = "Explicit"
 res@tmYLValues    = (/"1000","850","750","500","300","100"/)
 res@tmYLLabels    = (/"1000","850","750","500","300","100"/)
 res@xyLineColors = Colors
 res@xyLineThicknessF = 3
 res@xyDashPattern = 0

 res@trYReverse = True
 
 res@gsnRightString = "K"
 res@gsnStringFontHeightF = 0.025

 do j = 0,dimsizes(Season)-1
 res@gsnLeftString = Season(j)
 plot(j) = gsn_csm_xy(wks, jja2(:,j,{1000:50})*86400, lev({1000:50}), res)  ;
 
 ;res@gsnLeftString = "CTRL_DJF"
 ;plot(1) = gsn_csm_xy(wks, jja2(:,i,{1000:50})*86400, lev({1000:50}), res)  ;
 end do

 res_lines = True
 res_lines@gsLineDashPattern = 0
 res_lines@gsLineThicknessF = 3

 res_text  = True
 res_text@txFontHeightF = 0.018
 res_text@txJust = "CenterLeft"
 xx = (/-5.5,-4.5/)
 text_pos = -4.3

 do i = 0,2
    yy = (/300+i*100,300+i*100/)
    res_lines@gsLineColor = Colors(i)
    dum1(i) = gsn_add_polyline(wks, plot(0), xx, yy, res_lines)
    dum2(i) = gsn_add_text(wks, plot(0), Texts(i), text_pos, yy(0), res_text)
end do

;res = True
;res@gsnDraw  = False
;res@gsnFrame = False

;res@cnFillOn = True
;res@cnLineLabelsOn = False
;res@cnInfoLabelOn  = False
;res@cnFillPalette  = "precip2_17lev"
;res@lbLabelAutoStride = True

;res@tmYLMode      = "Explicit"
;res@tmYLValues    = (/"1000","850","750","500","300","100"/)
;res@tmYLLabels    = (/"1000","850","750","500","300","100"/)

;res@gsnRightString = "lat :25-40N"
;res@cnLevelSelectionMode = "ManualLevels"
;res@cnMaxLevelValF  = 5e-5
;res@cnMinLevelValF  = 5e-6
;res@cnLevelSpacingF = 5e-6

;res@gsnLeftString = "CTRL_JJA"
;plot(0) = gsn_csm_pres_hgt(wks, jja(2,{1000:100},:), res)
;res@gsnLeftString = "CTRL_DJF"
;plot(1) = gsn_csm_pres_hgt(wks, djf(2,{1000:100},:), res)


 pres = True
 pres@gsnMaximize = True
 pres@gsnPanelMainString = "NO_TP_HEAT"
gsn_panel(wks, plot, (/2,2/), pres)
end
