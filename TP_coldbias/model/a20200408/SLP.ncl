
begin

lonstr = 75
lonend = 105
latstr = 25
latend = 40
yrStrt = 198102
yrLast = 200601

casename = (/"Ctrl_FAMIP","Hist_FAMIP"/)
ncase = dimsizes(casename)

nyear = 25
; t = new((/ncase,nyear,12,96,144/), float)

; do i = 0, ncase-1
;     diri = "/home/yangsong3/data-model/wuyt/TPbias/TPbias_"+casename(i)+"/a20191206/"
;     fili1 = casename(i)+".cam.h0.PS.1979-2005.nc"

;     f1 = addfile(diri+fili1, "r")

;     TIME = f1->time
;     YYYY = cd_calendar(TIME, -1)
;     iYYYY = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)

;     T1 = f1->PS(iYYYY,:,:)
;     T1 = T1/100
;     T1@units = "hPa"
;     t(i,:,:,:,:) = reshape(T1, (/nyear,12,96,144/))
;     copy_VarCoords(T1(0,:,:), t(i,0,0,:,:))
;     ; t(i,:,:,:) = clmMonTLL(T1)
; end do
; printVarSummary(t)

; ;=======================================================================
; ; ttest
; ;=======================================================================

; t_ave = dim_avg_n_Wrap(t, 1)
; t_var = dim_variance_n_Wrap(t, 1)

; prob = ttest(t_ave(0,:,:,:), t_var(0,:,:,:), nyear, t_ave(1,:,:,:), t_var(1,:,:,:), nyear, False, False)
; copy_VarCoords(t_ave(0,:,:,:), prob)
; printVarSummary(prob)

; diff = t_ave(0,:,:,:)
; diff = t_ave(1,:,:,:) - t_ave(0,:,:,:)

t = new((/ncase,nyear,96,144/), float)
season = "DJF"
do i = 0, ncase-1
    diri = "/home/yangsong3/data-model/wuyt/TPbias/TPbias_"+casename(i)+"/a20191206/"
    fili1 = casename(i)+".cam.h0.PS.1979-2005.nc"

    f1 = addfile(diri+fili1, "r")

    TIME = f1->time
    YYYY = cd_calendar(TIME, -1)
    iYYYY = ind(YYYY.ge.yrStrt .and. YYYY.le.yrLast)

    T1 = f1->PS(iYYYY,:,:)
    T1 = T1/100
    T1@units = "hPa"
    t(i,:,:,:) = month_to_season(T1, season)
    ; t(i,:,:,:) = clmMonTLL(T1)
end do
printVarSummary(t)

;=======================================================================
; ttest
;=======================================================================

t_ave = dim_avg_n_Wrap(t, 1)
t_var = dim_variance_n_Wrap(t, 1)

prob = ttest(t_ave(0,:,:), t_var(0,:,:), nyear, t_ave(1,:,:), t_var(1,:,:), nyear, False, False)
copy_VarCoords(t_ave(0,:,:), prob)
printVarSummary(prob)

diff = t_ave(0,:,:)
diff = t_ave(1,:,:) - t_ave(0,:,:)
; printMinMax(OMEGA(0,:,:,:), False)
; printMinMax(diff, False)
; exit
; diff = mask(diff, prob.le.0.1, True)
printVarSummary(diff)

Mth = (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)

;===================================================================
; topo data
;===================================================================
ftopo = addfile("~/wuyt/data/topo.sfc.1x1.nc", "r")
topo = ftopo->topo(::-1,:)

;=========================================================
; plot 
;=========================================================
figpath = "/home/yangsong3/wuyt/sysu/figures/TP_coldbias/model/a20200408/"
figname = season+"_SLP"

wks = gsn_open_wks("pdf", figpath+figname)
plot = new(12, graphic)
plot_topo = plot
plot_prob = plot

 res_topo            = True
 res_topo@cnFillOn   = False
 res_topo@cnLinesOn  = True
 res_topo@gsnFrame   = False
 res_topo@gsnDraw    = False
 res_topo@cnLineLabelsOn         = False
 res_topo@cnLineThicknessF       = 5
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
res@cnFillPalette = "BlueWhiteOrangeRed"
res@cnLevelSelectionMode = "ManualLevels"
res@cnMaxLevelValF = 3
res@cnMinLevelValF = -3
res@cnLevelSpacingF = 0.2
; res@lbLabelBarOn = False

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
; do i = 0, 11
;     res@gsnLeftString = Mth(i)
;     plot(i) = gsn_csm_contour_map(wks, diff(i,:,:), res)
;     plot_topo(i) = gsn_csm_contour(wks, topo, res_topo)
;     overlay(plot(i), plot_topo(i))
;     plot_prob(i) = gsn_csm_contour(wks,prob(i,:,:),res3)
;     plot_prob(i) = ShadeLtContour(plot_prob(i),0.055,17)
;     overlay(plot(i), plot_prob(i))
; end do
res@gsnLeftString = "DJF SLP"
plot(0) = gsn_csm_contour_map(wks, diff, res)
plot_topo(0) = gsn_csm_contour(wks, topo, res_topo)
overlay(plot(0), plot_topo(0))
plot_prob(0) = gsn_csm_contour(wks,prob,res3)
plot_prob(0) = ShadeLtContour(plot_prob(0),0.055,17)
overlay(plot(0), plot_prob(0))
draw(plot(0))
exit()

pres = True
pres@gsnMaximize = True
pres@gsnPanelLabelBar = True
pres@lbLabelFontHeightF = 0.013
pres@gsnPanelMainString = "SLP diff: sst bias run - Ctrl run"
gsn_panel(wks, plot, (/3,4/), pres)

end