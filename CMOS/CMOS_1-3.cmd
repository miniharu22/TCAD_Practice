## File Section
File {
    Grid = "@tdr@"
    Parameter = "@parameter@"
    Plot = "@tdrdat@"
    Current = "@plot@"
    Output = "@log@"
    }

## Electrode Section
Electrode {
    { Name="gate" Voltage=0.0 }
    { Name="substrate" Voltage=0.0 }
    { Name="source" Voltage=0.0 }
    { Name="drain" Voltage=0.0 }
    }

## Physics Section
Physics (Region = "region_gate") {
    MetalWorkfunction (Workfuntion = @nWF@)
    }

Physics {
        EffectiveIntrinsicDensity(OldSlotboom)
        Fermi
        Mobility (
            PhuMob
            Enormal
            HighFieldSaturation(EparallelToInterface)
            )
        Recombination (
            SRH(DopingDep TempDependence)
            Band2Band (Model = Hurkx)
            )
        } 

## Plot Section
Plot{
  eDensity hDensity
  TotalCurrent/Vector eCurrent/Vector hCurrent/Vector
  eMobility hMobility
  eVelocity hVelocity
  eQuasiFermi hQuasiFermi
  eTemperature Temperature * hTemperature
  ElectricField/Vector Potential SpaceCharge
  Doping DonorConcentration AcceptorConcentration
  SRH Band2Band * AugerS
  eGradQuasiFermi/Vector hGradQuasiFermi/Vector
  eEparallel hEparallel eENormal hENormal
  BandGap
  BandGapNarrowing
  Affinity
  ConductionBand ValenceBand
  eBarrierTunneling hBarrierTunneling * BarrierTunneling
  eTrappedCharge hTrappedCharge
  eGapStatesRecombination hGapStatesRecombination
  eDirectTunnel hDirectTunnel
  }

## Math Section
Math {
  Extrapolate
  Derivatives
  RelErrControl
  Digits=5
  Notdamped=50
  Iterations=30
  DirectCurrent
  ExitOnFailure
  NumberOfThreads= 8

  Method=pardiso 

  RefDens_eGradQuasiFermi_ElectricField= 1e12
  RefDens_hGradQuasiFermi_ElectricField= 1e12
  }

## Solve Section
Solve {
    Coupled ( Iterations=100 ){ Poisson }
    Coupled ( Iterations=100 ){ Poisson Electron Hole }
    Save ( FilePrefix="n@node@_init" )

    #-- Ramp drain to VdSat
    Load ( FilePrefix="n@node@_init" )
 
    Quasistationary(
        InitialStep=1e-2 Increment=1.35
        MinStep=1e-6 MaxStep=0.5
        Goal { Name="drain" Voltage= @Vd@}
        ){ Coupled { Poisson Electron Hole}}
    Save ( FilePrefix="n@node@_Vd")
 
    Quasistationary(
        InitialStep=1e-2 Increment=1.1
        MinStep=1e-6 MaxStep=0.05
        Goal { Name="gate" Voltage= -0.5}
        ){ Coupled { Poisson Electron Hole } }
    Plot( FilePrefix="n@node@_Vgn0_5")

    NewCurrentFile="IdVg_"
    
    Quasistationary(
        DoZero
        InitialStep=1e-2 Increment=1.1
        MinStep=1e-6 MaxStep=0.05
        Goal { Name="gate" Voltage= 0.0}
        ){ Coupled { Poisson Electron Hole } }
    Plot( FilePrefix="n@node@_Vg0_0")

    Quasistationary(
        InitialStep=1e-2 Increment=1.1
        MinStep=1e-6 MaxStep=0.05
        Goal { Name="gate" Voltage= 1.0}
        ){ Coupled { Poisson Electron Hole } }
    Plot ( FilePrefix="n@node@_Vg1_0")

    Quasistationary(
        InitialStep=1e-2 Increment=1.1
        MinStep=1e-6 MaxStep=0.05
        Goal { Name="gate" Voltage= 1.5}
        ){ Coupled { Poisson Electron Hole } }
    Plot ( FilePrefix="n@node@_Vg1_5")
    }
