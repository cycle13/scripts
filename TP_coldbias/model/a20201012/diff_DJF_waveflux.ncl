
begin
  
  lonstr = 10
  lonend = 220
  latstr = 10
  latend = 70

casename = (/"Ctrl_FAMIP","Hist_FAMIP","Hist_FAMIP_CMIP6"/) ;,"Hist_IO","Hist_PO","Hist_AO"
ncase = dimsizes(casename)
LEV = 500
season = "DJF"

nlat = 96
nlon = 144
yrStrt = 1981
yrLast = 2005
year = ispan(yrStrt, yrLast, 1)
nyear = dimsizes(year)

u = new((/ncase,nyear,nlat,nlon/), double)
v = u
z = u

do i = 0, ncase-1
    filiu = "./"+casename(i)+".TN2001-Fx.monthly.1981-2005.nc"
    filiv = "./"+casename(i)+".TN2001-Fy.monthly.1981-2005.nc"
    filiz = "./"+casename(i)+".psidev.monthly.1981-2005.nc"

    fu = addfile(filiu, "r")
    fv = addfile(filiv, "r")
    fz = addfile(filiz, "r")

    U = fu->Fx(:,{LEV},:,:)
    V = fv->Fy(:,{LEV},:,:)
    Z = fz->psidev(:,{LEV},:,:)
    printVarSummary(U)

    u(i,:,:,:) = month_to_season(U, season)
    v(i,:,:,:) = month_to_season(V, season)
    z(i,:,:,:) = month_to_season(Z, season)

end do
printVarSummary(u)
z = z * 1.e-6
;=======================================================================
; ttest
;=======================================================================

u_ave = dim_avg_n_Wrap(u, 1)
u_var = dim_variance_n_Wrap(u, 1)

v_ave = dim_avg_n_Wrap(v, 1)
v_var = dim_variance_n_Wrap(v, 1)

z_ave = dim_avg_n_Wrap(z, 1)
z_var = dim_variance_n_Wrap(z, 1)

probu = ttest(u_ave(0,:,:), u_var(0,:,:), nyear, u_ave(1,:,:), u_var(1,:,:), nyear, False, False)
copy_VarCoords(u_ave(0,:,:), probu)
probv = ttest(v_ave(0,:,:), v_var(0,:,:), nyear, v_ave(1,:,:), v_var(1,:,:), nyear, False, False)
copy_VarCoords(v_ave(0,:,:), probv)
probz = ttest(z_ave(0,:,:), z_var(0,:,:), nyear, z_ave(1,:,:), z_var(1,:,:), nyear, False, False)
copy_VarCoords(z_ave(0,:,:), probz)
printVarSummary(probz)

diffu = u_ave(0,:,:)
diffu = u_ave(1,:,:) - u_ave(0,:,:)
diffv = v_ave(0,:,:)
diffv = v_ave(1,:,:) - v_ave(0,:,:)
diffz = z_ave(0,:,:)
diffz = z_ave(1,:,:) - z_ave(0,:,:)
printVarSummary(diffu)

sig = 0.05

; diffu = mask(diffu, probu.le.sig .and. probv.le.sig, diffu@_FillValue)
; diffv = mask(diffv, probu.le.sig .and. probv.le.sig, diffv@_FillValue)

;===================================================================
; topo data
;===================================================================
ftopo = addfile("~/wuyt/data/topo.sfc.1x1.nc", "r")
topo = ftopo->topo(::-1,:)
topo = smth9_Wrap(topo, 0.5, 0.25, True)

;=========================================================
; plot 
;=========================================================
figpath = "/home/yangsong3/wuyt/sysu/figures/TP_coldbias/model/a20201012/"
figname = "diff_DJF_waveflux_"+LEV+"hPa"

pwks = "png"
pwks@wkHeight              = 3048
pwks@wkWidth               = 6048

wks = gsn_open_wks("pdf", figpath+figname) ;
plot = new(3, graphic)
plot_topo = plot
plot_prob = plot
plotv = plot

 res_topo            = True
 res_topo@cnFillOn   = False
 res_topo@cnLinesOn  = True
 res_topo@gsnFrame   = False
 res_topo@gsnDraw    = False
 res_topo@cnLineLabelsOn         = False
 res_topo@cnLineThicknessF       = 3
 res_topo@cnLineColor            = "grey40"
 res_topo@cnInfoLabelOn          = False
 res_topo@cnLevelSelectionMode   ="ExplicitLevels"
 res_topo@cnLevels               = (/2000/)
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
; res@mpMaxLatF            = latend
; res@mpMinLonF            = lonstr
; res@mpMaxLonF            = lonend
res@mpCenterLonF         = 180.
res@tmXBLabelFontHeightF = 0.02
res@tmYLLabelFontHeightF = 0.02

res@gsnStringFontHeightF = 0.025
; res@gsnRightString       = "K"

res@pmLabelBarOrthogonalPosF = 0.25
res@pmLabelBarWidthF = 0.7
res@lbLabelFontHeightF = 0.015
res@cnFillPalette = "BlueWhiteOrangeRed"
res@cnLevelSelectionMode = "ManualLevels"
res@cnMaxLevelValF = 10
res@cnMinLevelValF = -10
res@cnLevelSpacingF = 1.
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
 res3@cnFillColor  =  "black"
 res3@gsnLeftString = ""
 res3@cnFillDotSizeF = 0.003
 res3@cnFillScaleF  = 1.2
 ;----------------------------------------------
 ;------------------------------------------

  vcres                         = True             ; plot mods desired
  vcres@gsnFrame                = False            ; so we can draw time stamp
  vcres@gsnDraw                 = False
  vcres@vcRefAnnoOrthogonalPosF = -1.0    ; -0.35          ; move ref vector up

  vcres@vcGlyphStyle            = "LineArrow"  ;"LineArrow"    ; turn on curly vectors
  ;vcres@vcMinDistanceF          = 0.017
  ;vcres@vcGlyphStyle            = "LineArrow"
  vcres@vcMinDistanceF          = 0.03
  vcres@vcRefLengthF            = 0.045            ; define length of vec ref
  
  vcres@vcLineArrowThicknessF   = 3.0
  ;vecres@vcLineArrowHeadMinSizeF = 0.008
  ;vecres@vcLineArrowHeadMaxSizeF = 0.3

  vcres@vcRefAnnoString2On = False
  vcres@vcRefAnnoFontHeightF = 0.012
  vcres@gsnLeftString = ""
  vcres@gsnRightString = ""
;------------------------------------------
 ;----------------------------------------------


; vcres@vcRefMagnitudeF         = 3.0 
; res@gsnLeftString = "diff stream function at "+LEV+" hPa"
; plot(0) = gsn_csm_contour_map(wks, diffz, res)
; plot_topo(0) = gsn_csm_contour(wks, topo, res_topo)
; overlay(plot(0), plot_topo(0))
; plotv(0) = gsn_csm_vector(wks, diffu, diffv, vcres)
; overlay(plot(0), plotv(0))

; plot_prob(0) = gsn_csm_contour(wks,probz,res3)
; plot_prob(0) = ShadeLtContour(plot_prob(0),sig,6)
; overlay(plot(0), plot_prob(0))


vcres@vcRefMagnitudeF         = 20.0 
do i = 0,1
plot(i) = gsn_csm_contour_map(wks, z_ave(i,:,:), res)
plot_topo(i) = gsn_csm_contour(wks, topo, res_topo)
overlay(plot(i), plot_topo(i))
plotv(i) = gsn_csm_vector(wks, u_ave(i,:,:), v_ave(i,:,:), vcres)
overlay(plot(i), plotv(i))
end do
; plot_prob(0) = gsn_csm_contour(wks,probz,res3)
; plot_prob(0) = ShadeLtContour(plot_prob(0),sig,6)
; overlay(plot(0), plot_prob(0))


vcres@vcRefMagnitudeF         = 3.0 
res@cnLevelSelectionMode = "ManualLevels"
res@cnMaxLevelValF = 2
res@cnMinLevelValF = -2
res@cnLevelSpacingF = 0.2
; res@gsnLeftString = "diff stream function at "+LEV+" hPa"
plot(2) = gsn_csm_contour_map(wks, diffz, res)
plot_topo(2) = gsn_csm_contour(wks, topo, res_topo)
overlay(plot(2), plot_topo(2))
plotv(2) = gsn_csm_vector(wks, diffu, diffv, vcres)
overlay(plot(2), plotv(2))

plot_prob(2) = gsn_csm_contour(wks,probz,res3)
plot_prob(2) = ShadeLtContour(plot_prob(2),sig,6)
overlay(plot(2), plot_prob(2))


pres = True
pres@gsnMaximize = True
pres@gsnFrame    = True
pres@gsnDraw     = True
; pres@gsnPanelLabelBar = True

; pres@lbLabelFontHeightF = 0.015
; pres@pmLabelBarWidthF = 0.8    ;plot manager 
; pres@pmLabelBarHeightF = 0.06
gsn_panel(wks, plot, (/3,1/), pres)

end