;; Initialize
(sde:clear)
(sde:set-process-up-direction "+Z")

;; Define variable
(define Ltot 1.0) ; [um] Lateral extend total
(define Lg @Lg@ ) ; [um] Gate length
(define Lsp 0.1) ; [um] Spacer length
(define Tsub 0.8) ; [um] Substrate thickness
(define Tox @Tox@ ) ; [um] Gate oxide thickness
(define Tgate 0.2) ; [um] Poly gate thickness

(define fillet-radius 0.08) ; [um] Rounding radius

(define HalfLtot (/ Ltot 2.0))
(define HalfLg (/ Lg 2.0))
(define Xsp (+ HalfLg Lsp))
(define Lcont (- HalfLtot Xsp))

(define Gpn 0.0025) ; [um]

;; Structure
(sdegeo:create-rectangle (position (* HalfLtot -1.0) 0.0 0.0) (position HalfLtot Tsub 0.0) "Silicon" "region_substrate")
(sdegeo:create-rectangle (position (* Xsp -1.0) 0.0 0.0) (position Xsp (- 0 Tox) 0.0) "Oxide" "region_gateoxide")
(sdegeo:create-rectangle (position (* Xsp -1.0) (- 0 Tox) 0.0) (position Xsp (- 0 Tox Tgate) 0.0) "Nitride" "region_spacer")
(sdegeo:create-rectangle (position (* HalfLg -1.0) (- 0 Tox) 0.0) (position HalfLg (- 0 Tox Tgate) 0.0) "PolySilicon" "region_gate")

(sdegeo:fillet-2d (find-vertex-id (position (* Xsp -1.0) (- 0 Tox Tgate) 0.0 )) fillet-radius)
(sdegeo:fillet-2d (find-vertex-id (position Xsp (- 0 Tox Tgate) 0.0 )) fillet-radius)

;; Contact
(sdegeo:set-contact (find-edge-id (position (* (+ HalfLtot Xsp) -0.5) 0.0 0.0)) "source")
(sdegeo:set-contact (find-edge-id (position (* (+ HalfLtot Xsp) 0.5) 0.0 0.0)) "drain")
(sdegeo:set-contact (find-edge-id (position 0.0 (- 0 Tox Tgate) 0.0)) "gate")
(sdegeo:set-contact (find-edge-id (position 0.0 Tsub 0.0)) "substrate")

;; Doping & Mesh
(sdedr:define-constant-profile "ConstantProfileDefinition_substrate" "BoronActiveConcentration" 1e16)

(sdedr:define-constant-profile-region "ConstantProfilePlacement_substrate" "ConstantProfileDefinition_substrate" "region_substrate")

(sdedr:define-constant-profile "ConstantProfileDefinition_gate" "ArsenicActiveConcentration" 1e20)

(sdedr:define-constant-profile-region "ConstantProfilePlacement_gate" "ConstantProfileDefinition_gate" "region_gate")

(sdedr:define-refeval-window "Line_Source" "Line" (position (* HalfLtot -2.0) 0.0 0.0) (position (* Xsp -1.0) 0.0 0.0))
(sdedr:define-refeval-window "Line_Drain" "Line" (position Xsp 0.0 0.0) (position (* HalfLtot 2.0) 0.0 0.0))

(sdedr:define-gaussian-profile "AnalyticalProfileDefinition_SDprof" "PhosphorusActiveConcentration" "PeakPos" 0 "PeakVal" 1e20 "ValueAtDepth" 1e16 "Depth" 0.080 "Gauss" "Factor" 0.4)

(sdedr:define-analytical-profile-placement "AnalyticalProfilePlacement_Source" "AnalyticalProfileDefinition_SDprof" "Line_Source" "Positive" "NoReplace" "Eval")
(sdedr:define-analytical-profile-placement "AnalyticalProfilePlacement_Drain" "AnalyticalProfileDefinition_SDprof" "Line_Drain" "Positive" "NoReplace" "Eval")

(sdedr:define-refeval-window "Line_SourceExt" "Line" (position (* HalfLtot -2.0) 0.0 0.0) (position (* HalfLg -1.0) 0.0 0.0))
(sdedr:define-refeval-window "Line_DrainExt" "Line" (position HalfLg 0.0 0.0) (position (* HalfLtot 2.0) 0.0 0.0))

(sdedr:define-gaussian-profile "AnalyticalProfileDefinition_SDextprof" "ArsenicActiveConcentration" "PeakPos" 0 "PeakVal" 5e18 "ValueAtDepth" 1e16 "Depth" 0.035 "Gauss" "Factor" 0.8)

(sdedr:define-analytical-profile-placement "AnalyticalProfilePlacement_SourceExt" "AnalyticalProfileDefinition_SDextprof" "Line_SourceExt" "Positive" "NoReplace" "Eval")
(sdedr:define-analytical-profile-placement "AnalyticalProfilePlacement_DrainExt" "AnalyticalProfileDefinition_SDextprof" "Line_DrainExt" "Positive" "NoReplace" "Eval")

(sdedr:define-refinement-size "window_substrate" (/ Ltot 4.0) (/ Tsub 8.0) Gpn Gpn)
(sdedr:define-refinement-function "window_substrate"  "DopingConcentration" "MaxTransDiff" 1)
(sdedr:define-refinement-function "window_substrate" "MaxLenInt" "Silicon" "Oxide" 0.0002 1.5 "DoubleSide")
(sdedr:define-refinement-region "RefinementPlacement_substrate" "window_substrate" "region_substrate")

(sdedr:define-refinement-size "window_gateoxide" (/ Ltot 4.0) (/ Tox 4.0) Gpn (/ Tox 8.0))
(sdedr:define-refinement-region "RefinementPlacement_gateoxide" "window_gateoxide" "region_gateox")

;; Build
(sde:build-mesh "n@node@")
