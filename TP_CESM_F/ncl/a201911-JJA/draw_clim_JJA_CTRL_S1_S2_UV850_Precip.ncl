
begin

diri1 = "/home/yangsong3/data-model/wuyt/TP_CTRL_F2000_F19G16_CAM4/pro/"
diri2 = "/home/yangsong3/data-model/wuyt/TP_NOQ1_F2000_F19G16_CAM4/pro/"
diri3 = "/home/yangsong3/data-model/wuyt/TP_NOTP_NOQ1_F2000_F19G16_CAM4/pro/"

filiu1 = "F2000_CTRL.plevel.U.mon.0601-3012.nc"
filiu2 = "F2000_NOQ1.plevel.U.mon.0601-3012.nc"
filiu3 = "F2000_NOTP_NOQ1.plevel.U.mon.0601-3012.nc"

filiv1 = "F2000_CTRL.plevel.V.mon.0601-3012.nc"
filiv2 = "F2000_NOQ1.plevel.V.mon.0601-3012.nc"
filiv3 = "F2000_NOTP_NOQ1.plevel.V.mon.0601-3012.nc"

filic1 = "F2000_CTRL.PRECC.mon.0601-3012.nc"
filic2 = "F2000_NOQ1.PRECC.mon.0601-3012.nc"
filic3 = "F2000_NOTP_NOQ1.PRECC.mon.0601-3012.nc"

filil1 = "F2000_CTRL.PRECL.mon.0601-3012.nc"
filil2 = "F2000_NOQ1.PRECL.mon.0601-3012.nc"
filil3 = "F2000_NOTP_NOQ1.PRECL.mon.0601-3012.nc"

fu1 = addfile(diri1+filiu1, "r")
fu2 = addfile(diri2+filiu2, "r")
fu3 = addfile(diri3+filiu3, "r")

fv1 = addfile(diri1+filiv1, "r")
fv2 = addfile(diri2+filiv2, "r")
fv3 = addfile(diri3+filiv3, "r")

u1 = fu1->U
u2 = fu2->U
u3 = fu3->U
v1 = fv1->V
v2 = fv2->V
v3 = fv3->V
printVarSummary(u1)

;================================================================
fc1 = addfile(diri1+filic1, "r")
fc2 = addfile(diri2+filic2, "r")
fc3 = addfile(diri3+filic3, "r")
fl1 = addfile(diri1+filil1, "r")
fl2 = addfile(diri2+filil2, "r")
fl3 = addfile(diri3+filil3, "r")

c1 = fc1->PRECC
c2 = fc2->PRECC
c3 = fc3->PRECC
l1 = fl1->PRECL
l2 = fl2->PRECL
l3 = fl3->PRECL
printVarSummary(c1)
;==================================================================

p1 = c1+l1
p2 = c2+l2
p3 = c3+l3
p1 = p1*1000*86400. ; convert units from m/s to mm/day
p2 = p2*1000*86400.
p3 = p3*1000*86400.
copy_VarCoords(c1, p1)
copy_VarCoords(c2, p2)
copy_VarCoords(c3, p3)
printVarSummary(p1)

;Season = (/"DJF","MAM","JJA","SON"/)
Season = "DJF"
pp11 = month_to_season(p1, Season)
pp1 = dim_avg_n_Wrap(pp11, 0)
pp22 = month_to_season(p2, Season)
pp2 = dim_avg_n_Wrap(pp22, 0)
pp33 = month_to_season(p3, Season)
pp3 = dim_avg_n_Wrap(pp33, 0)

uu11 = month_to_season(u1, Season)
uu1 = dim_avg_n_Wrap(uu11, 0)
uu22 = month_to_season(u2, Season)
uu2 = dim_avg_n_Wrap(uu22, 0)
uu33 = month_to_season(u3, Season)
uu3 = dim_avg_n_Wrap(uu33, 0)

vv11 = month_to_season(v1, Season)
vv1 = dim_avg_n_Wrap(vv11, 0)
vv22 = month_to_season(v2, Season)
vv2 = dim_avg_n_Wrap(vv22, 0)
vv33 = month_to_season(v3, Season)
vv3 = dim_avg_n_Wrap(vv33, 0)
printVarSummary(uu1)

p_m = pp2 - pp3
p_h = pp1 - pp2
copy_VarCoords(pp1, p_m)
copy_VarCoords(pp1, p_h)

u_m = uu2 - uu3
u_h = uu1 - uu2
copy_VarCoords(uu1, u_m)
copy_VarCoords(uu1, u_h)

v_m = vv2 - vv3
v_h = vv1 - vv2
copy_VarCoords(vv1, v_m)
copy_VarCoords(vv1, v_h)

;----------------------------------------------------------------
tpmaskpath = "/home/yangsong3/wuyt/sysu/scripts/TP_CESM_F/model_need_input_data/"
tpmaskname = "TPmask_1000m_C20190410.nc"
ftp = addfile(tpmaskpath+tpmaskname, "r")

tpmask = ftp->tp
printVarSummary(tpmask)

;=========================================================
figpath = "/home/yangsong3/wuyt/sysu/figures/TP_CESM_F/ncl/JJA/"
figname = "draw_clim_JJA_UV850_Precip_v2"

lonstr = 20 ;20
lonend = 160 ;220
latstr = -20
latend = 70

wks = gsn_open_wks("pdf", figpath+figname)
nplot = 5
plot = new(nplot, graphic)
plotv = plot
plot_topo = plot

 res_topo            = True
 res_topo@cnFillOn   = False
 res_topo@cnLinesOn  = True
 res_topo@gsnFrame   = False
 res_topo@gsnDraw    = False
 res_topo@cnLineLabelsOn         = False
 res_topo@cnLineThicknessF       = 3
 res_topo@cnLineColor            = "green4"
 res_topo@cnInfoLabelOn          = False
 res_topo@cnLevelSelectionMode   ="ExplicitLevels"
 res_topo@cnLevels               = (/0.9/)
 res_topo@gsnLeftString = ""
 res_topo@gsnRightString = ""


res = True
res@gsnDraw  = False
res@gsnFrame = False

res@mpOutlineOn = True
res@mpFillOn = True
res@mpGeophysicalLineThicknessF = 2
res@mpGeophysicalLineColor = "grey45" ;"grey25"
res@mpFillDrawOrder = "PreDraw"

res@mpMinLatF = latstr
res@mpMaxLatF = latend
res@mpMinLonF = lonstr
res@mpMaxLonF = lonend
res@mpCenterLonF = (lonstr+lonend)/2

res@cnFillOn = True
res@cnLinesOn = False
res@cnLineLabelsOn = False
res@cnInfoLabelOn = False

res@gsnStringFontHeightF = 0.035
res@tmXBLabelFontHeightF = 0.025
res@tmYLLabelFontHeightF = 0.025
;------------------------------------------

  vcres                         = True             ; plot mods desired
  vcres@gsnFrame                = False            ; so we can draw time stamp
  vcres@gsnDraw                 = False
  vcres@vcRefAnnoOrthogonalPosF =  -0.35 ;-1.0             ; move ref vector up

  ;vcres@vcGlyphStyle            = "CurlyVector"  ;"LineArrow"    ; turn on curly vectors
  ;vcres@vcMinDistanceF          = 0.017
  vcres@vcGlyphStyle            = "LineArrow"
  vcres@vcMinDistanceF          = 0.03
  vcres@vcRefLengthF            = 0.025            ; define length of vec ref
  
  vcres@vcLineArrowThicknessF   = 3.0
  ;vecres@vcLineArrowHeadMinSizeF = 0.008
  ;vecres@vcLineArrowHeadMaxSizeF = 0.3

  vcres@vcRefAnnoString2On = False
  vcres@vcRefAnnoFontHeightF = 0.02
;------------------------------------------
vcres@vcRefMagnitudeF         = 2.0  ; define vector ref mag
res@lbLabelBarOn = False
res@cnLevelSelectionMode = "ManualLevels"
res@cnLevelSpacingF = 0.5
res@cnMaxLevelValF = 5.
res@cnMinLevelValF = -5.
res@cnFillPalette = "CBR_drywet"

res@gsnLeftString = "thermal"
plot(0) = gsn_csm_contour_map(wks, p_h, res)
plot_topo(0) = gsn_csm_contour(wks, tpmask, res_topo)
plotv(0) = gsn_csm_vector(wks, u_h({850},:,:), v_h({850},:,:), vcres)
overlay(plot(0), plot_topo(0))
overlay(plot(0), plotv(0))

res@gsnLeftString = "mechanical"
plot(1) = gsn_csm_contour_map(wks, p_m, res)
plot_topo(1) = gsn_csm_contour(wks, tpmask, res_topo)
plotv(1) = gsn_csm_vector(wks, u_m({850},:,:), v_m({850},:,:), vcres)
overlay(plot(1), plot_topo(1))
overlay(plot(1), plotv(1))


pres = True
pres@gsnMaximize = True
pres@gsnPanelMainString = Season+"_UV850_Precip_difference"
pres@gsnPanelLabelBar = True
pres@pmLabelBarOrthogonalPosF = -0.01

gsn_panel(wks, plot(0:1), (/1,2/), pres)

;------------------------------------------
vcres@vcRefMagnitudeF         = 3.0  ; define vector ref mag
;vcres@vcRefLengthF            = 0.035            ; define length of vec ref
res@lbLabelBarOn = False
res@cnLevelSelectionMode = "ManualLevels"
res@cnLevelSpacingF = 2.0
res@cnMaxLevelValF = 15.
res@cnMinLevelValF = 1.
res@cnFillPalette = "CBR_wet"


res@gsnLeftString = "CTRL"
plot(2) = gsn_csm_contour_map(wks, pp1, res)
plot_topo(2) = gsn_csm_contour(wks, tpmask, res_topo)
plotv(2) = gsn_csm_vector(wks, uu1({850},:,:), vv1({850},:,:), vcres)
overlay(plot(2), plot_topo(2))
overlay(plot(2), plotv(2))

res@gsnLeftString = "NOQ1"
plot(3) = gsn_csm_contour_map(wks, pp2, res)
plot_topo(3) = gsn_csm_contour(wks, tpmask, res_topo)
plotv(3) = gsn_csm_vector(wks, uu2({850},:,:), vv2({850},:,:), vcres)
overlay(plot(3), plot_topo(3))
overlay(plot(3), plotv(3))

res@gsnLeftString = "NOTP_NOQ1"
plot(4) = gsn_csm_contour_map(wks, pp3, res)
plot_topo(4) = gsn_csm_contour(wks, tpmask, res_topo)
plotv(4) = gsn_csm_vector(wks, uu3({850},:,:), vv3({850},:,:), vcres)
overlay(plot(4), plot_topo(4))
overlay(plot(4), plotv(4))


pres = True
pres@gsnMaximize = True
pres@gsnPanelMainString = Season+"_UV850_Precip_climatology"
pres@gsnPanelLabelBar = True
pres@pmLabelBarOrthogonalPosF = -0.01

gsn_panel(wks, plot(2:4), (/1,3/), pres)

end