
## Set parameter
set Ith @Ith@
set Vg0 0
set Vdd 1
set Vdd_n -1

set ProjName3 "Cgg"
set CurveName3 "Cgg_curve"

set ProjName4 "Cgd"
set CurveName4 "Cgd_curve"

set ProjName5 "Cgd_0"
set CurveName5 "Cgd_0_curve"

## Load Sdevice data & LibraryPermalink
proj_load CV_n@node|CV@_ac_des.plt n@node|CV@_cv

load_library EXTRACT

## Create plot
cv_createDS $CurveName3 {n@node|CV@_cv v(g)} {n@node|CV@_cv c(g,g)} y
cv_abs $CurveName3 y

cv_createDS $CurveName4 {n@node|CV@_cv v(g)} {n@node|CV@_cv c(g,d)} y
cv_abs $CurveName4 y

## Extract data using plots
set Cgg_Vddp [cv_compute "vecvaly(<$CurveName3>, [expr $Vdd])" A A A A]
set Cgd_0 [cv_compute "vecvaly(<$CurveName4>, [expr $Vg0])" A A A A]
set Cgd_Vddn [cv_compute "vecvaly(<$CurveName4>, [expr $Vdd_n])" A A A A]

set Cox [expr $Cgg_Vddp-2*$Cgd_0]
set Cgg_Vddp_fF [expr $Cgg_Vddp*1e15]
set Cgd_0_fF [expr $Cgd_0*1e15]
set Cgd_Vddn_fF [expr $Cgd_Vddn*1e15]
set Cox_fF [expr $Cox*1e15]

## Put data into parameter
puts "Cgg_Vddp : $Cgg_Vddp"
puts "Cgd_0 : $Cgd_0"
puts "Cgd_Vddn : $Cgd_Vddn"
puts "Cov : $Cgd_0"
puts "Cox : $Cox"

## Unit conversion
ft_scalar Cgg_Vddp_fF [format %.2f [expr $Cgg_Vddp_fF]]
ft_scalar Cgd_0_fF [format %.2f [expr $Cgd_0_fF]]
ft_scalar Cgd_Vddn_fF [format %.2f [expr $Cgd_Vddn_fF]]
ft_scalar Cov_fF [format %.2f [expr $Cgd_0_fF]]
ft_scalar Cox_fF [format %.2f [expr $Cox_fF]]
