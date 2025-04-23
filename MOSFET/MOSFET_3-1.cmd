;; Initialize
(sde:clear)
(sde:set-process-up-direction "+Z")

;; Define variable
(define Ltot 1.0)
(define Lg 0.2)
(define Lsp 0.1)
(define Tsub 0.8)
(define Tbox 0.1)
(define Tsoi 0.015)
(define Tox @Tox@)
(define Tgate 0.2)

(define fillet-radius 0.08) 

; SOI doping
(define Nsoi 2e17 ) ; [1/cm3]

; Derived quantities
(define HalfLtot (/ Ltot 2.0))
(define HalfLg (/ Lg 2.0))
(define Xsp (+ HalfLg Lsp))
(define Lcont (- HalfLtot Xsp)) 

; - pn junction resolution
(define Gpn 0.0025) 

;; Structure
; Overlap resolution: New replaces Old
(sdegeo:set-default-boolean "ABA")

; Creating soi region
(sdegeo:create-rectangle (position (* HalfLtot -1.0) 0.0 0.0) (position HalfLtot Tsoi 0.0) "Silicon" "region_soi")

; Creating buried oxide layer
(sdegeo:create-rectangle (position (* HalfLtot -1.0) Tsoi 0.0) (position HalfLtot (+ Tsoi Tbox) 0.0) "Oxide" "region_box")

; Creating substrate region
(sdegeo:create-rectangle (position (* HalfLtot -1.0) (+ Tsoi Tbox) 0.0) (position HalfLtot (+ Tsoi Tbox Tsub) 0.0) "Silicon" "region_substrate")

; Creating gate oxide
(sdegeo:create-rectangle (position (* Xsp -1.0) 0.0 0.0) (position Xsp (- 0 Tox) 0.0) "Oxide" "region_gateoxide")

; Creating spacers regions
(sdegeo:create-rectangle (position (* Xsp -1.0) (- 0 Tox) 0.0) (position Xsp (- 0 Tox Tgate) 0.0) "Nitride" "region_spacer")

; Creating PolySilicon gate
(sdegeo:create-rectangle (position (* HalfLg -1.0) (- 0 Tox) 0.0) (position HalfLg (- 0 Tox Tgate) 0.0) "PolySilicon" "region_gate")

; rounding spacer
(sdegeo:fillet-2d (find-vertex-id (position (* Xsp -1.0) (- 0 Tox Tgate) 0.0 )) fillet-radius)
(sdegeo:fillet-2d (find-vertex-id (position Xsp (- 0 Tox Tgate) 0.0 )) fillet-radius)

;; Contact
; Contact definitions
(sdegeo:set-contact (find-edge-id (position (* (+ HalfLtot Xsp) -0.5) 0.0 0.0)) "source" )
(sdegeo:set-contact (find-edge-id (position (* (+ HalfLtot Xsp) 0.5) 0.0 0.0)) "drain")
(sdegeo:set-contact (find-edge-id (position 0.0 (- 0 Tox Tgate) 0.0)) "gate")
(sdegeo:set-contact (find-edge-id (position 0.0 (+ Tsoi Tbox Tsub) 0.0)) "substrate")

;; Doping & Mesh
; Constant Doping Profiles:
(sdedr:define-constant-profile "ConstantProfileDefinition_substrate" "BoronActiveConcentration" 1e16)
(sdedr:define-constant-profile-region "ConstantProfilePlacement_substrate" "ConstantProfileDefinition_substrate" "region_substrate")

(sdedr:define-constant-profile "ConstantProfileDefinition_soi" "BoronActiveConcentration" Nsoi)
(sdedr:define-constant-profile-region "ConstantProfilePlacement_soi" "ConstantProfileDefinition_soi" "region_soi")

(sdedr:define-constant-profile "ConstantProfileDefinition_gate" "ArsenicActiveConcentration" 1e20)
(sdedr:define-constant-profile-region "ConstantProfilePlacement_gate" "ConstantProfileDefinition_gate" "region_gate")

; Source/Drain base line definitions
(sdedr:define-refeval-window "Line_Source" "Line" (position (* HalfLtot -2.0) 0.0 0.0) (position (* Xsp -1.0) 0.0 0.0))
(sdedr:define-refeval-window "Line_Drain" "Line" (position Xsp 0.0 0.0) (position (* HalfLtot 2.0) 0.0 0.0))

; Source/Drain implant definition
(sdedr:define-gaussian-profile "AnalyticalProfileDefinition_SDprof" "PhosphorusActiveConcentration" "PeakPos" 0 "PeakVal" 1e20 "ValueAtDepth" Nsoi "Depth" (* Tsoi 1.2) "Gauss" "Factor" 0.4)

; Source/Drain implants
(sdedr:define-analytical-profile-placement "AnalyticalProfilePlacement_Source" "AnalyticalProfileDefinition_SDprof" "Line_Source" "Positive" "NoReplace" "Eval")
(sdedr:define-analytical-profile-placement "AnalyticalProfilePlacement_Drain" "AnalyticalProfileDefinition_SDprof" "Line_Drain" "Positive" "NoReplace" "Eval")

; Source/Drain extensions base line definitions
(sdedr:define-refeval-window "Line_SourceExt" "Line" (position (* HalfLtot -2.0) 0.0 0.0) (position (* HalfLg -1.0) 0.0 0.0))
(sdedr:define-refeval-window "Line_DrainExt" "Line" (position HalfLg 0.0 0.0) (position (* HalfLtot 2.0) 0.0 0.0))

; Source/Drain implant definition
(sdedr:define-gaussian-profile "AnalyticalProfileDefinition_SDextprof" "ArsenicActiveConcentration" "PeakPos" 0 "PeakVal" 5e18 "ValueAtDepth" Nsoi "Depth" (* Tsoi 0.35) "Gauss" "Factor" 0.8)

; Source/Drain implants
(sdedr:define-analytical-profile-placement "AnalyticalProfilePlacement_SourceExt" "AnalyticalProfileDefinition_SDextprof" "Line_SourceExt" "Positive" "NoReplace" "Eval")
(sdedr:define-analytical-profile-placement "AnalyticalProfilePlacement_DrainExt" "AnalyticalProfileDefinition_SDextprof" "Line_DrainExt" "Positive" "NoReplace" "Eval")

; Substrate
(sdedr:define-refinement-size "window_substrate" (/ Ltot 4.0) (/ Tsub 8.0) Gpn Gpn)
(sdedr:define-refinement-function "window_substrate" "DopingConcentration" "MaxTransDiff" 1)
(sdedr:define-refinement-function "window_substrate" "MaxLenInt" "Silicon" "Oxide" 0.001 1.5 "DoubleSide")
(sdedr:define-refinement-region "RefinementPlacement_substrate" "window_substrate" "region_substrate" )

; Buried oxide
(sdedr:define-refinement-size "window_box" (/ Ltot 4.0) (/ Tbox 4.0) Gpn Gpn)
(sdedr:define-refinement-region "RefinementPlacement_box" "window_box" "region_box")

; SOI
(sdedr:define-refinement-size "window_soi" (/ Lcont 4.0) (/ Tsoi 8.0) Gpn Gpn)
(sdedr:define-refinement-function "window_soi" "DopingConcentration" "MaxTransDiff" 1)
(sdedr:define-refinement-function "window_soi" "MaxLenInt" "Silicon" "Oxide" 0.0002 1.5 "DoubleSide")
(sdedr:define-refinement-region "RefinementPlacement_soi" "window_soi" "region_soi")

; Gate oxide
(sdedr:define-refinement-size "window_gateoxide" (/ Ltot 4.0) (/ Tox 4.0) Gpn (/ Tox 8.0))
(sdedr:define-refinement-region "RefinementPlacement_gateoxide" "window_gateoxide" "region_gateox")

;; Build
(sde:build-mesh "n@node@")
