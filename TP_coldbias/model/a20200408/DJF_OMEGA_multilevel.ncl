
begin

lonstr = 75
lonend = 105
latstr = 25
latend = 40
yrStrt = 198102
yrLast = 200601

casename = (/"Ctrl_FAMIP","Hist_FAMIP"/)
ncase = dimsizes(casename)
LEV = (/900,750,500,300/)
nlev = dimsizes(LEV)
printVarSummary(LEV)
nyear = 25
season = "DJF"
OMEGA = new((/ncase,nyear,nlev,96,144/), float)


do i = 0, ncase-1
    diri = "/home/yangsong3/data-model/wuyt/TPbias/TPbias_"+casename(i)+"/a20191206/"
    fili = casename(i)+".cam.h0.OMEGA.1979-2005.nc"
    
    f1 = addfile(diri+fili, "r")

    TIME = f1->time
    YYYY = cd_calendar(TIME, -1)
    iYYYY = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)

    OMEGAX = f1->OMEGA(iYYYY,{LEV},:,:)
    OMEGA(i,:,:,:,:) = month_to_season(OMEGAX, season)
    ; OMEGA(i,:,:,:) = dim_avg_n_Wrap(OMEGA0, 0)
    ; OMEGA(i,:,:,:) = OMEGA(i,:,:,:)*100.
end do
printVarSummary(OMEGA)
OMEGA = OMEGA*100.
OMEGA@units = "10^-2 Pa/s"
printVarSummary(OMEGA)

;=======================================================================
; ttest
;=======================================================================

OMEGA_ave = dim_avg_n_Wrap(OMEGA, 1)
OMEGA_var = dim_variance_n_Wrap(OMEGA, 1)

prob = ttest(OMEGA_ave(0,:,:,:), OMEGA_var(0,:,:,:), nyear, OMEGA_ave(1,:,:,:), OMEGA_var(1,:,:,:), nyear, False, False)
copy_VarCoords(OMEGA_ave(0,:,:,:), prob)
printVarSummary(prob)

diff = OMEGA_ave(0,:,:,:)
diff = OMEGA_ave(1,:,:,:) - OMEGA_ave(0,:,:,:)
; printMinMax(OMEGA(0,:,:,:), False)
; printMinMax(diff, False)
; exit
; diff = mask(diff, prob.le.0.1, True)

;===================================================================
; topo data
;===================================================================
ftopo = addfile("~/wuyt/data/topo.sfc.1x1.nc", "r")
topo = ftopo->topo(::-1,:)

;=========================================================
; plot 
;=========================================================
figpath = "/home/yangsong3/wuyt/sysu/figures/TP_coldbias/model/a20200408/"
figname = season+"_OMEGA_multilevel_ttest"

; lonstr = 0
; lonend = 360
; latstr = -30
; latend = 60

wks = gsn_open_wks("pdf", figpath+figname)
plot = new(8, graphic)
plot_topo = plot
plot_prob = plot

 res_topo            = True
 res_topo@cnFillOn   = False
 res_topo@cnLinesOn  = True
 res_topo@gsnFrame   = False
 res_topo@gsnDraw    = False
 res_topo@cnLineLabelsOn         = False
 res_topo@cnLineThicknessF       = 3
 res_topo@cnLineColor            = "grey"
 res_topo@cnInfoLabelOn          = False
 res_topo@cnLevelSelectionMode   ="ExplicitLevels"
 res_topo@cnLevels               = (/1500/)
 res_topo@gsnLeftString = ""
 res_topo@gsnRightString = ""


res                       = True     ; plot mods desired
res@gsnDraw               = False
res@gsnFrame              = False

res@gsnMaximize           = True     ; Make plot fit the frame
res@cnFillOn              = True     ; turn on color fill
res@cnLinesOn             = False    ; turn of contour lines
res@cnLineLabelsOn        = False
res@cnInfoLabelOn         = False
;res@lbLabelBarOn          = False

res@mpMinLatF            = latstr      ; range to zoom in on
res@mpMaxLatF            = latend
res@mpMinLonF            = lonstr
res@mpMaxLonF            = lonend
; res@mpCenterLonF         = 180.
res@tmXBLabelFontHeightF = 0.025
res@tmYLLabelFontHeightF = 0.025

res@gsnStringFontHeightF = 0.035
;res@gsnRightString       = "K"

res@pmLabelBarOrthogonalPosF = 0.12
res@pmLabelBarWidthF = 0.7
res@lbLabelFontHeightF = 0.02

res@cnFillPalette  = "MPL_RdBu"

;----------------------------------------------
; draw prob
;----------------------------------------------
 res3  = True
 res3@gsnDraw   = False
 res3@gsnFrame  = False

 ;res3@cnFillOn  = False 
 res3@cnLinesOn = False
 res3@cnLineLabelsOn = False
 res3@cnInfoLabelOn  = False
 ;res3@lbLabelBarOn   = False

 res3@gsnRightString = ""

 res3@cnLevelSelectionMode = "ManualLevels"
 res3@cnMinLevelValF = 0.00
 res3@cnMaxLevelValF = 0.10
 res3@cnLevelSpacingF = 0.01

 ; res3@cnFillPattern = 17 ;(/17/)
 res3@cnFillColor  =  "red"
 res3@gsnLeftString = ""
 res3@cnFillDotSizeF = 0.003
 res3@cnFillScaleF  = 1.2
 ;----------------------------------------------
 ;----------------------------------------------

do i = 0,3
res@gsnLeftString  = "OMEGA "+LEV(i)+"hPa"
res@gsnRightString = "Ctrl"
res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF = -20
res@cnMaxLevelValF = 20
res@cnLevelSpacingF = 2.
plot(i) = gsn_csm_contour_map(wks, OMEGA_ave(0,i,:,:), res)
plot_topo(i) = gsn_csm_contour(wks, topo, res_topo)
overlay(plot(i), plot_topo(i))

res@gsnRightString = "Diff"
res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF = -5
res@cnMaxLevelValF = 5
res@cnLevelSpacingF = 0.5
plot(i+4) = gsn_csm_contour_map(wks, diff(i,:,:), res)
plot_topo(i+4) = gsn_csm_contour(wks, topo, res_topo)
overlay(plot(i+4), plot_topo(i+4))
plot_prob(i) = gsn_csm_contour(wks,prob(i,:,:),res3)
plot_prob(i) = ShadeLtContour(plot_prob(i),0.055,17)
overlay(plot(i+4), plot_prob(i))
end do


pres = True
pres@gsnMaximize = True
;pres@gsnPanelLabelBar  = True
pres@gsnPanelMainString = season+" mean: Omega at diff levels"
gsn_panel(wks, plot, (/2,4/), pres)

end