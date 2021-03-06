
begin
;==================================================================
index = asciiread("./high_point_index.txt", -1, "integer")
print(index)
; exit
;==================================================================

LEV = 500

;casename = (/"CTRL","NOTP","NOQ1","NOTP_NOQ1"/)
casename = (/"CTRL","NOQ1"/)
ncase = dimsizes(casename)
H = new((/ncase,25,92,96,144/), float)
year = ispan(6, 30, 1)
do i = 0, ncase-1
    diri = "/home/yangsong3/data-model/wuyt/TP_"+casename(i)+"_F2000_F19G16_CAM4/pro/daily/"
    do j = 0, dimsizes(year)-1
        yr = sprinti("%0.2i", year(j))
        fili = "F2000_"+casename(i)+".plevel.Z3."+yr+".daily.nc"
        f = addfile(diri+fili, "r")
        TIME = f->time
        YYYYMM = cd_calendar(TIME, -1)
        MM = mod(YYYYMM, 100)
        iMM = ind(MM.ge.3 .and. MM.le.5)
        H(i,j,:,:,:) = f->Z3(iMM,{LEV},:,:)
    end do
end do
printVarSummary(H)
h = dim_avg_n_Wrap(H, 1)
h!0 = "case"
h&case = casename
printVarSummary(h)

h_thermal = h(1,:,:,:)
h_thermal = h(0,:,:,:) - h(1,:,:,:)

HX = new((/7,dimsizes(index),96,144/), float)
HX(0,:,:,:) = h_thermal(index-3,:,:)
HX(1,:,:,:) = h_thermal(index-2,:,:)
HX(2,:,:,:) = h_thermal(index-1,:,:)
HX(3,:,:,:) = h_thermal(index,:,:)
HX(4,:,:,:) = h_thermal(index+1,:,:)
HX(5,:,:,:) = h_thermal(index+2,:,:)
HX(6,:,:,:) = h_thermal(index+3,:,:)
; HX(0,:,:,:) = h_thermal(index-6,:,:)
; HX(1,:,:,:) = h_thermal(index-4,:,:)
; HX(2,:,:,:) = h_thermal(index-2,:,:)
; HX(3,:,:,:) = h_thermal(index,:,:)
; HX(4,:,:,:) = h_thermal(index+1,:,:)
; HX(5,:,:,:) = h_thermal(index+2,:,:)
; HX(6,:,:,:) = h_thermal(index+3,:,:)

hx = dim_avg_n_Wrap(HX, 1)
printVarSummary(hx)

;==================================================================

tpmaskpath = "/home/yangsong3/wuyt/sysu/scripts/TP_CESM_F/model_need_input_data/"
tpmaskname = "TPmask_1000m_C20190410.nc"
ftp = addfile(tpmaskpath+tpmaskname, "r")

tpmask = ftp->tp
printVarSummary(tpmask)

;=========================================================
figpath = "/home/yangsong3/wuyt/sysu/figures/TP_CESM_F/ncl/20191130/"
figname = "transient_H"+LEV

lonstr = 0 ;20
lonend = 360 ;220
latstr = 10
latend = 80

wks = gsn_open_wks("pdf", figpath+figname)
nplot = 7
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
 res_topo@cnLineColor            = "blue"
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
;res@mpFillDrawOrder = "PreDraw"

res@mpMinLatF = latstr
res@mpMaxLatF = latend
res@mpMinLonF = lonstr
res@mpMaxLonF = lonend
res@mpCenterLonF = (lonstr+lonend)/2

res@cnFillOn = True
res@cnLinesOn = False
res@cnLineLabelsOn = False
res@cnInfoLabelOn = False
res@lbLabelBarOn = False

res@gsnStringFontHeightF = 0.03
res@tmXBLabelFontHeightF = 0.02
res@tmYLLabelFontHeightF = 0.02
; ;------------------------------------------

;   vcres                         = True             ; plot mods desired
;   vcres@gsnFrame                = False            ; so we can draw time stamp
;   vcres@gsnDraw                 = False
;   vcres@vcRefAnnoOrthogonalPosF =  -0.4 ;-1.0             ; move ref vector up
;   ;vcres@vcGlyphStyle            = "CurlyVector"  ;"LineArrow"    ; turn on curly vectors
;   ;vcres@vcMinDistanceF          = 0.017
;   vcres@vcGlyphStyle            = "LineArrow"
;   vcres@vcMinDistanceF          = 0.03
;   vcres@vcRefMagnitudeF         = 10.0             ; define vector ref mag
  
;   vcres@vcLineArrowThicknessF   = 3.0
;   ;vecres@vcLineArrowHeadMinSizeF = 0.008
;   ;vecres@vcLineArrowHeadMaxSizeF = 0.3

;   vcres@vcRefAnnoString2On = False
;   vcres@vcRefAnnoFontHeightF = 0.015

; ;================================================================================

res@cnLevelSelectionMode = "ManualLevels"
res@cnLevelSpacingF = 10.
res@cnMaxLevelValF = 150.
res@cnMinLevelValF = -150.
res@cnFillPalette = "BlueWhiteOrangeRed"

; vcres@vcRefMagnitudeF         = 4.0             ; define vector ref mag
; vcres@vcRefLengthF            = 0.035            ; define length of vec ref

leftsti = (/"Day-3","Day-2","Day-1","Day0","Day+1","Day+2","Day+3"/)

do i = 0, 6
res@gsnLeftString = leftsti(i)
plot(i) = gsn_csm_contour_map_ce(wks, hx(i,:,:), res)
plot_topo(i) = gsn_csm_contour(wks, tpmask, res_topo)
overlay(plot(i), plot_topo(i))
end do

pres = True
pres@gsnMaximize = True
pres@gsnPanelMainString = "H"+LEV
pres@gsnPanelLabelBar = True
;pres@pmLabelBarOrthogonalPosF = -0.01

gsn_panel(wks, plot, (/7,1/), pres)




end