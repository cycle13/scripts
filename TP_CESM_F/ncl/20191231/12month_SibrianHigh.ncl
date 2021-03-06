
begin

lonstr = 70
lonend = 120
latstr = 40
latend = 60

casename = (/"CTRL","NOQ1","NOTP_NOQ1","NOTP"/)
ncase = dimsizes(casename)
month = (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
nm = dimsizes(month)

z = new((/ncase,12/), float)


do i = 0, dimsizes(casename)-1
    diri = "/home/yangsong3/data-model/wuyt/TP_"+casename(i)+"_F2000_F19G16_CAM4/pro/"
    fili = "F2000_"+casename(i)+".PSL.mon.0601-3012.nc"

    f = addfile(diri+fili, "r")
    z1 = f->PSL
    Z = clmMonTLL(z1)
    z(i,:) = wgt_areaave_Wrap(Z(:,{latstr:latend},{lonstr:lonend}), 1, 1, 0)

end do
z = z/100.
printVarSummary(z)

zx = z(0:1,:)
zx(0,:) = z(0,:) - z(1,:)
zx(1,:) = z(1,:) - z(2,:)

;=========================================================
figpath = "/home/yangsong3/wuyt/sysu/figures/TP_CESM_F/ncl/20191231/"
figname = "12month_SiberianHigh"
xaxis = ispan(1, 12, 1)
Colors = (/"black","blue","red","green4"/)

wks = gsn_open_wks("pdf", figpath+figname)
nplot = 2
plot = new(nplot, graphic)

res = True
res@gsnDraw  = False
res@gsnFrame = False

res@vpHeightF= 0.4                    ; change aspect ratio of plot
res@vpWidthF = 0.7     
res@gsnStringFontHeightF = 0.035
res@tmXBLabelFontHeightF = 0.025
res@tmYLLabelFontHeightF = 0.025

; res@trXMinF = 4
; res@trXMaxF = 9
res@xyDashPattern = 0
res@xyLineThicknessF = 5
res@xyLineColors = Colors
res@tmXBMode = "Explicit"
res@tmXBValues = xaxis
res@tmXBLabels = month
res@gsnYRefLine = 0
res@gsnYRefLineColor = "darkgoldenrod1"
res@gsnYRefLineThicknessF = 3
res@gsnYRefLineDashPattern = 2

res@gsnLeftString = "Siberian High index"

plot(0) = gsn_csm_xy(wks, xaxis, z, res)

res@gsnYRefLine = 0
plot(1) = gsn_csm_xy(wks, xaxis, zx, res)

;==================================================================================
    res_lines                   = True                  ; polyline mods desired
    res_lines@gsLineThicknessF  = 5                     ; line thicker
    

    res_text                    = True                  ; text mods desired
    res_text@txFontHeightF      = 0.018                 ; change text size
    res_text@txJust             = "CenterLeft"          ; text justification

    Texts  = casename

; ;============================================================
    interval = 3
    gx = (/4.5,5.2/)
    text_pos = 5.4
    gy1 = (/1032,1032/)
    gy2 = gy1-interval ;(/15,15/)
    gy3 = gy2-interval
    gy4 = gy3-interval
    print(gy1)

    res_lines@gsLineColor = Colors(0)
    ;res_lines@gsLineDashPattern = Patterns(0)
    dum11 = gsn_add_polyline(wks, plot(0), gx, gy1, res_lines)
    dum12 = gsn_add_text(wks, plot(0), Texts(0), text_pos, gy1, res_text)
    res_lines@gsLineColor = Colors(1)
    ;res_lines@gsLineDashPattern = Patterns(1)
    dum21 = gsn_add_polyline(wks, plot(0), gx, gy2, res_lines)
    dum22 = gsn_add_text(wks, plot(0), Texts(1), text_pos, gy2, res_text)
    res_lines@gsLineColor = Colors(2)
    ;res_lines@gsLineDashPattern = Patterns(2)
    dum31 = gsn_add_polyline(wks, plot(0), gx, gy3, res_lines)
    dum32 = gsn_add_text(wks, plot(0), Texts(2), text_pos, gy3, res_text)
    res_lines@gsLineColor = Colors(3)
    ;res_lines@gsLineDashPattern = Patterns(3)
    dum41 = gsn_add_polyline(wks, plot(0), gx, gy4, res_lines)
    dum42 = gsn_add_text(wks, plot(0), Texts(3), text_pos, gy4, res_text) 

    interval = 1
    gx = (/1.5,2.2/)
    text_pos = 2.4
    gy1 = (/-3,-3/)
    gy2 = gy1-interval ;(/15,15/)
    res_lines@gsLineColor = Colors(0)
    ;res_lines@gsLineDashPattern = Patterns(4)
    dum51 = gsn_add_polyline(wks, plot(1), gx, gy1, res_lines)
    dum52 = gsn_add_text(wks, plot(1), "Thermal", text_pos, gy1, res_text)
    res_lines@gsLineColor = Colors(1)
    ;res_lines@gsLineDashPattern = Patterns(5)
    dum61 = gsn_add_polyline(wks, plot(1), gx, gy2, res_lines)
    dum62 = gsn_add_text(wks, plot(1), "Dynamical", text_pos, gy2, res_text)

pres = True
pres@gsnMaximize = True
gsn_panel(wks, plot, (/1,2/), pres)

end