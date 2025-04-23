## Set parameter
set Ith @Ith@
set Vg0 0
set Vdd 1
set HalfVdd 0.5

set ProjName1 "Idsat"
set CurveName1 "IdVg_sat"
set LogCurveName1 "IdVg_sat_log"

set ProjName2 "Idlin"
set CurveName2 "IdVg_lin"
set LogCurveName2 "IdVg_lin_log"

set ProjName3 "Ideff"
set CurveName3 "IdVg_eff"
set LogCurveName3 "IdVg_eff_log"

## Load Sdevice data & LibraryPermalink
proj_load IdVg_n@node|NMOS_IV_VSAT@_des.plt n@node@_Sat
proj_load IdVg_n@node|NMOS_IV_VLIN@_des.plt n@node@_Lin
proj_load IdVg_n@node|NMOS_IV_VEFF@_des.plt n@node@_Eff

load_library EXTRACT

## Create plot
cv_createDS $CurveName1 "n@node@_Sat gate OuterVoltage" "n@node@_Sat drain TotalCurrent"
cv_abs $CurveName1 y
cv_createWithFormula $LogCurveName1 "log10(<$CurveName1>)" A A A A

cv_createDS $CurveName2 "n@node@_Lin gate OuterVoltage" "n@node@_Lin drain TotalCurrent"
cv_abs $CurveName2 y
cv_createWithFormula $LogCurveName2 "log10(<$CurveName2>)" A A A A

cv_createDS $CurveName3 "n@node@_Eff gate OuterVoltage" "n@node@_Eff drain TotalCurrent"
cv_abs $CurveName3 y
cv_createWithFormula $LogCurveName3 "log10(<$CurveName3>)" A A A A

## Extract data using plots
set Vtsat [cv_compute "vecvalx(<$LogCurveName1>, log10($Ith))" A A A A]
set Vtlin [cv_compute "vecvalx(<$LogCurveName2>, log10($Ith))" A A A A]

set DIBL [expr $Vtsat - $Vtlin]

set Idsat [cv_compute "vecvaly(<$CurveName1>, [expr $Vdd])" A A A A]
set Idlin [cv_compute "vecvaly(<$CurveName2>, [expr $Vdd])" A A A A]
set Idoff [cv_compute "vecvaly(<$CurveName1>, [expr $Vg0])" A A A A]
set IdHigh [cv_compute "vecvaly(<$CurveName1>, [expr $HalfVdd])" A A A A]
set IdLow [cv_compute "vecvaly(<$CurveName3>, [expr $Vdd])" A A A A]
set Ideff [expr ($IdHigh-$IdLow)*0.5]

set Vrange 0.05
set Iswingsat1 [expr log10($Ith)]
set Iswingsat2 [cv_compute "vecvaly(<$LogCurveName1>, [expr $Vtsat-$Vrange])" A A A A]

set Ssat [expr $Vrange / ($Iswingsat1-$Iswingsat2)*1000]

## Put data into parameter
puts "Vtsat : $Vtsat"
puts "Vtlin : $Vtlin"
puts "DIBL : $DIBL"
puts "Idsat : $Idsat"
puts "Idlin : $Idlin"
puts "Idoff : $Idoff"
puts "Ideff : $Ideff"
puts "Ssat : $Ssat"

## Unit conversion
ft_scalar Vtsat_V [format %.3f $Vtsat]
ft_scalar Vtlin_V [format %.3f $Vtlin]
ft_scalar DIBL_mV [format %.1f [expr abs($DIBL*1e3)]]
ft_scalar Idsat_uA [format %.1f [expr $Idsat*1e6]]
ft_scalar Idlin_uA [format %.1f [expr $Idlin*1e6]]
ft_scalar Idoff_nA [format %.1f [expr $Idoff*1e9]]
ft_scalar Ssat [format %.1f $Ssat]
ft_scalar Ideff_uA [format %.1f [expr $Ideff*1e6]]









