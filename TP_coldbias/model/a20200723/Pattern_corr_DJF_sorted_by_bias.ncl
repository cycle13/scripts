
begin
season = "DJF"
sig = 0.1

ip_tbias = asciiread("./bias_list_"+season+".txt", (/28/), "integer")
print(ip_tbias)

;===================================================================
; OBS
;===================================================================
;---------------------------------------------------------
;topo data
ftopo = addfile("~/wuyt/data/topo.sfc.1x1.nc", "r")
topo = ftopo->topo(::-1,:)
;---------------------------------------------------------
; OBS tas
yrStrt = 1961
yrLast = 2018
year = ispan(yrStrt, yrLast, 1)
nyr = dimsizes(year)
month = (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)
nm = dimsizes(month)

lonstr = 75
lonend = 105
latstr = 25
latend = 40

ts_obsx = new((/nyr*nm,72,128/), float,-99.)

diriobs = "/home/yangsong3/data-observation/stationChina2000/Grid/t2m/"
do i = 0, nyr-1
    yr = yrStrt+i
    do j = 0, nm-1
        mn = sprinti("%0.2i", j+1)
        filiobs = "SURF_CLI_CHN_TEM_MON_GRID_0.5-MEAN-"+yr+mn+".txt"
        x = asciiread(diriobs+filiobs, -1, "float")
        ts_obsx(i*nm+j,:,:) = reshape(x(6:), (/72,128/))
    end do
end do
printVarSummary(ts_obsx)

ts_obs = ts_obsx(:,::-1,:)
time = ispan(1, nyr*nm, 1)

lat = fspan(18.25, 53.75, 72)
lon = fspan(72.25, 135.75, 128)

ts_obs!0 = "time"
ts_obs!1 = "lat"
ts_obs!2 = "lon"
ts_obs&time = time
ts_obs&lat = lat
ts_obs&lon = lon
ts_obs&lat@units = "degrees_north"
ts_obs&lon@units = "degrees_east"
printVarSummary(ts_obs)

ts_obs = dtrend_msg_n(time, ts_obs, False, False, 0)
TS_obs = month_to_season(ts_obs, season)

topox1 = ftopo->topo({18:54},{72:136})
lonx = topox1&lon
latx = topox1&lat
printVarSummary(topox1)
topox2 = linint2_Wrap(lonx, latx, topox1, False, lon, lat, 0)
print(topox2({35},{90}))

TS_obs = mask(TS_obs, topox2.ge.1500, True)
TP_obs = wgt_areaave_Wrap(TS_obs(:,{latstr:latend},{lonstr:lonend}), 1, 1, 0)
printVarSummary(TP_obs)

;---------------------------------------------------------
; OBS sst
diriobs = "/home/yangsong3/data-observation/SST/NOAA_ERSST/"
filiobs = "sst.mnmean.v5.nc"
fobs = addfile(diriobs+filiobs, "r")
TIMEo = fobs->time
YYYYo = cd_calendar(TIMEo, -1)/100
iYYYYo = ind(YYYYo.ge.yrStrt .and. YYYYo.le.yrLast)

SST_OBS = fobs->sst(iYYYYo,::-1,:)

sst_OBS = dtrend_msg_n(SST_OBS&time, SST_OBS, False, False, 0)
sst_obs = month_to_season(SST_OBS, season)
printVarSummary(sst_obs)

cc_obs = sst_obs(0,:,:)
prob_obs = cc_obs
printVarSummary(TP_obs)
printVarSummary(sst_obs)
cc_obs = escorc_n(TP_obs, sst_obs, 0, 0)
prob_obs = rtest(cc_obs, nyr, 0)
prob_obs = mask(prob_obs, cc_obs.eq.0, False)

cc_obs = where(prob_obs.le.sig, cc_obs, 0)
;=============================================================================
; GCMs
;=============================================================================
;---------------------------------------------------------
; GCM tas
dirigcm = "/home/yangsong3/data-model/wuyt/CMIP5/aaa-post/tas/"
models = (/"ACCESS1-0","ACCESS1-3","bcc-csm1-1","CanESM2","CCSM4","CESM1-BGC","CESM1-CAM5",\
        "CMCC-CM","CMCC-CMS","CNRM-CM5","CSIRO-Mk3-6-0","GFDL-CM3","GFDL-ESM2G","GFDL-ESM2M",\
        "GISS-E2-H","GISS-E2-R","HadGEM2-CC","HadGEM2-ES","inmcm4","IPSL-CM5A-LR","IPSL-CM5A-MR",\
        "IPSL-CM5B-LR","MIROC5","MPI-ESM-LR","MPI-ESM-MR","MRI-CGCM3","NorESM1-M","NorESM1-ME"/)
nmodel = dimsizes(models)

TS_GCM = new((/nmodel,50,181,360/), float)
TS_GCM!0 = "model"
TS_GCM&model = models
do i = 0, nmodel-1
    filigcm = systemfunc("ls "+dirigcm+"tas_mon_"+models(i)+"_historical_r1i1p1_195101-200012.nc")
    fgcm = addfile(filigcm, "r")
    TS_GCMs = fgcm->tas
    TS_GCMs = dtrend_msg_n(TS_GCMs&time, TS_GCMs, False, False, 0)
    TS_GCM(i,:,:,:) = month_to_season(TS_GCMs, season)
end do

printVarSummary(TS_GCM)
TS_GCM = TS_GCM - 273.15
TS_GCM = mask(TS_GCM, topo.ge.1500, True)
TP_GCM = wgt_areaave_Wrap(TS_GCM(:,:,{latstr:latend},{lonstr:lonend}), 1, 1, 0)

;---------------------------------------------------------
; GCM sst
dirigcm = "/home/yangsong3/data-model/wuyt/CMIP5/aaa-post/ts/"
SST_GCM = new((/nmodel,50,181,360/), float)
SST_GCM!0 = "model"
SST_GCM&model = models
do i = 0, nmodel-1
    filigcm = systemfunc("ls "+dirigcm+"ts_mon_"+models(i)+"_historical_r1i1p1_195101-200012.nc")
    fgcm = addfile(filigcm, "r")
    SST_GCMs = fgcm->ts
    SST_GCMs = dtrend_msg_n(SST_GCMs&time, SST_GCMs, False, False, 0)
    SST_GCM(i,:,:,:) = month_to_season(SST_GCMs, season)
end do
printVarSummary(SST_GCM)
;===================================================================
; land sea mask
;===================================================================
a      = addfile ("$NCARG_ROOT/lib/ncarg/data/cdf/landsea.nc","r")
lsdata = a->LSMASK
lsm = landsea_mask(lsdata, SST_GCM&lat, SST_GCM&lon)
;lmask = where(lsm.eq.1 .or. lsm.eq.3 .or. lsm.eq.4, 0, 1)
SST_GCM = mask(SST_GCM, lsm.eq.1 .or. lsm.eq.3 .or. lsm.eq.4, False)
;===================================================================
; regression data
;===================================================================
cc_model = new((/nmodel,181,360/), float)
prob_model = cc_model
do i = 0, nmodel-1
    cc_model(i,:,:) = escorc_n(TP_GCM(i,:), SST_GCM(i,:,:,:), 0, 0)
    prob_model(i,:,:) = rtest(cc_model(i,:,:), 50, 0)
end do
copy_VarCoords(SST_GCM(:,0,:,:), cc_model)
copy_VarCoords(SST_GCM(:,0,:,:), prob_model)
prob_model = mask(prob_model, cc_model.eq.0, False)

cc_model = where(prob_model.le.sig, cc_model, 0)
printVarSummary(cc_model)


pa_corr1 = new(nmodel, float)
pa_corr2 = pa_corr1
pa_corr3 = pa_corr1
pa_corr4 = pa_corr1

cc_lat = tofloat(cc_model&lat)
clat = cos(0.01745329*cc_lat)
cc_obsx = linint2_Wrap(cc_obs&lon, cc_obs&lat, cc_obs, True, cc_model&lon, cc_model&lat, 0)
printVarSummary(cc_obsx)

do i = 0,nmodel-1
    pa_corr1(i) = pattern_cor(cc_obsx, cc_model(i,:,:), 1., 0)
    pa_corr2(i) = pattern_cor(cc_obsx, cc_model(i,:,:), 1., 1)
    pa_corr3(i) = pattern_cor(cc_obsx, cc_model(i,:,:), clat, 0)
    pa_corr4(i) = pattern_cor(cc_obsx, cc_model(i,:,:), clat, 1)
end do

write_table("./Pattern_corr_weightlat_uncentered_mask_"+season+".txt", "w", [/"model", "w1c", "w1u","wlatc","wlatu"/], "%4s %4s %4s %4s %4s")
write_table("./Pattern_corr_weightlat_uncentered_mask_"+season+".txt", "a", [/models(ip_tbias),pa_corr1(ip_tbias),pa_corr2(ip_tbias),pa_corr3(ip_tbias),pa_corr4(ip_tbias)/], "%4s %4.2f %4.2f %4.2f %4.2f")

; write_table("./Pattern_corr_weightlat_centered_"+season+".txt", "w", [/models(ip_tbias),pa_corr3(ip_tbias)/], "%10s %4.2f")
; exit
;===================================================================
; Plot
;===================================================================
filipath = "./"
filiname = "test"
wks = gsn_open_wks("pdf", filipath+filiname)
plot = new(nmodel, graphic)
plot_prob = plot
plotc = plot

res = True
res@gsnDraw  = False
res@gsnFrame = False
res@gsnMaximize = True

res@mpOutlineOn = True
res@mpFillOn = True
res@mpGeophysicalLineThicknessF = 2
res@mpGeophysicalLineColor = "grey25" ;"red" 
res@mpFillDrawOrder = "PostDraw"
res@mpCenterLonF = 180

res@cnFillOn = True
res@cnLinesOn = False
res@cnLineLabelsOn = False
res@cnInfoLabelOn = False

res@gsnStringFontHeightF = 0.035
res@tmXBLabelFontHeightF = 0.02
res@tmYLLabelFontHeightF = 0.02

; res@lbLabelBarOn = False
res@cnLevelSelectionMode = "ManualLevels"
res@cnLevelSpacingF = 0.1
res@cnMaxLevelValF = 0.5
res@cnMinLevelValF = -0.5
res@cnFillPalette = "CBR_coldhot"
;res@gsnRightString = "K"

;=====================================================
    cnres = True
    cnres@gsnDraw = False
    cnres@gsnFrame = False

    cnres@cnFillOn = False
    cnres@cnLinesOn = True
    cnres@cnLineLabelsOn = True
    cnres@cnLineLabelFontColor = "red"
    cnres@cnLineColor = "purple" ;goldenrod2 ;dodgerblue2
    cnres@cnLineThicknessF = 5
    cnres@cnInfoLabelOn = True
    ;cnres@cnLineDrawOrder = "PostDraw"
    cnres@cnLabelDrawOrder = "PostDraw"
    ;cnres@cnLevelFlag = "LineAndLabel"
    cnres@cnLineLabelInterval = 1
    cnres@gsnLeftString = ""
    cnres@gsnRightString = ""
    cnres@cnLevelSelectionMode = "ManualLevels"
    cnres@cnLevelSpacingF = 0.1
    cnres@cnMaxLevelValF = 1 ;0.5
    cnres@cnMinLevelValF = -1 ;0.5

;=====================================================

;------------------------
; draw prob
;------------------------
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

;res3@cnFillPattern = 17 ;(/17/)
res3@cnFillColor  =  "black" ;"green4"
res3@gsnLeftString = ""
res3@cnFillDotSizeF = 0.003
res3@cnFillScaleF  = 1 ;1.2

res@gsnRightString = (1-sig)*100+"%"


; res@gsnLeftString = "OBS corr map"
; plot(0) = gsn_csm_contour_map(wks, x_obsx, res)

do i = 0, nmodel-1
    res@gsnLeftString = models(ip_tbias(i))
    plot(i) = gsn_csm_contour_map(wks, cc_model(ip_tbias(i),:,:), res)
    ; plotc(i) = gsn_csm_contour(wks, x_obs(ip_tbias(i),:,:), cnres)
    plotc(i) = gsn_csm_contour(wks, cc_obsx, cnres)
    overlay(plot(i), plotc(i))
    draw(plot(i))
    frame(wks)
end do

end