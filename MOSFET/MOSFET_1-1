;; Initialize
(sde:clear)

;; Define variable
(define Nd @Nd@)

;; Structure
(sdegeo:create-rectangle (position -0.5 0 0) (position 0.5 0.2 0) "Silicon" "region_body")
(sdegeo:create-rectangle (position -0.5 0 0) (position -0.25 0.05 0) "Silicon" "region_source")
(sdegeo:create-rectangle (position 0.25 0 0) (position 0.5 0.05 0) "Silicon" "region_drain")
(sdegeo:create-rectangle (position -0.25 0 0) (position 0.25 -0.005 0) "Oxide" "region_gateoxide")
(sdegeo:create-rectangle (position -0.25 -0.005 0) (position 0.25 -0.1 0) "TiN" "region_gate")

;; Contact
(sdegeo:define-contact-set "gate" 4 (color:rgb 1 0 0)"##")
(sdegeo:define-contact-set "source" 4 (color:rgb 1 0 0)"##")
(sdegeo:define-contact-set "drain" 4 (color:rgb 1 0 0)"##")
(sdegeo:define-contact-set "body" 4 (color:rgb 1 0 0)"##")

(sdegeo:insert-vertex (position -0.3 0.0 0.0))
(sdegeo:insert-vertex (position 0.3 0.0 0.0))

(sdegeo:set-contact (list (car (find-edge-id (position 0.0 -0.1 0)))) "gate")
(sdegeo:set-contact (list (car (find-edge-id (position -0.375 0.0 0)))) "source")
(sdegeo:set-contact (list (car (find-edge-id (position 0.375 0.0 0)))) "drain")
(sdegeo:set-contact (list (car (find-edge-id (position 0.0 0.2 0)))) "body")

;; Doping & Mesh
(sdedr:define-constant-profile "ConstantProfileDefinition_body" "BoronActiveConcentration" Na)
(sdedr:define-constant-profile-region "ConstantProfilePlacement_body" "ConstantProfileDefinition_body" "region_body")

(sdedr:define-constant-profile "ConstantProfileDefinition_source" "ArsenicActiveConcentration" 2e+20)
(sdedr:define-constant-profile-region "ConstantProfilePlacement_source" "ConstantProfileDefinition_source" "region_source")

(sdedr:define-constant-profile "ConstantProfileDefinition_drain" "ArsenicActiveConcentration" 2e+20)
(sdedr:define-constant-profile-region "ConstantProfilePlacement_drain" "ConstantProfileDefinition_drain" "region_drain")

(sdedr:define-refeval-window "body_window" "Rectangle" (position -0.5 0.0 0) (position 0.5 0.2 0))
(sdedr:define-refinement-size "RefinementDefinition_bodyregion" 0.050 0.050 0 0.050 0.050 0 )
(sdedr:define-refinement-placement "RefinementPlacement_bodyregion" "RefinementDefinition_bodyregion" (list "window" "body_window" ) )

(sdedr:define-refeval-window "source_window" "Rectangle" (position -0.5 0.0 0) (position 0.25 0.05 0))
(sdedr:define-refinement-size "RefinementDefinition_sourceregion" 0.005 0.0050 0 0.005 0.005 0 )
(sdedr:define-refinement-placement "RefinementPlacement_sourceregion" "RefinementDefinition_sourceregion" (list "window" "source_window" ) )

(sdedr:define-refeval-window "drain_window" "Rectangle" (position 0.25 0.0 0) (position 0.5 0.05 0))
(sdedr:define-refinement-size "RefinementDefinition_drainregion" 0.005 0.005 0 0.005 0.005 0 )
(sdedr:define-refinement-placement "RefinementPlacement_drainregion" "RefinementDefinition_drainregion" (list "window" "drain_window" ) )

(sdedr:define-refeval-window "gate_window" "Rectangle" (position -0.25 -0.005 0) (position 0.25 -0.1 0))
(sdedr:define-refinement-size "RefinementDefinition_gateregion" 0.01 0.01 0 0.01 0.01 0 )
(sdedr:define-refinement-placement "RefinementPlacement_gateregion" "RefinementDefinition_gateregion" (list "window" "gate_window" ) )

(sdedr:define-refeval-window "gateoxide_window" "Rectangle" (position -0.25 0.0 0) (position 0.25 -0.005 0))
(sdedr:define-refinement-size "RefinementDefinition_gateoxideregion" 0.002 0.002 0 0.002 0.002 0 )
(sdedr:define-refinement-placement "RefinementPlacement_gateoxideregion" "RefinementDefinition_gateoxideregion" (list "window" "gateoxide_window" ) )

;; Build
(sde:build-mesh "n@node@")
