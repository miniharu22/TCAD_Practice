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
    { Name="gate" Voltage=0.1 }
    { Name="substrate" Voltage=0.0 }
    { Name="source" Voltage=0.0 }
    { Name="drain" Voltage=0.0 }
    }

## Physics Section
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
        Band2Band (E1)
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

    #-- Ramp drain to VdSat (드레인 전압 변화)
    Load ( FilePrefix="n@node@_init" )
 
    Quasistationary(
        InitialStep=1e-2 Increment=1.35
        MinStep=1e-6 MaxStep=0.05
        Goal { Name="drain" Voltage= 0.0}
        ){ Coupled { Poisson Electron Hole } }
    Save ( FilePrefix="n@node@_Vd0_0")

    NewCurrentFile="IdVd_"
    
    Quasistationary(
        InitialStep=1e-2 Increment=1.35
        MinStep=1e-6 MaxStep=0.05
        Goal { Name="drain" Voltage= 0.5}
        ){ Coupled { Poisson Electron Hole } }
    Save ( FilePrefix="n@node@_Vd0_5")
 
    Quasistationary(
        InitialStep=1e-2 Increment=1.35
        MinStep=1e-6 MaxStep=0.05
        Goal { Name="drain" Voltage= 1.0}
        ){ Coupled { Poisson Electron Hole } }
    Save ( FilePrefix="n@node@_Vd1_0")
 
    Quasistationary(
        DoZero
        InitialStep=1e-2 Increment=1.35
        MinStep=1e-6 MaxStep=0.05
        Goal { Name="drain" Voltage= 1.5}
        ){ Coupled { Poisson Electron Hole } }
    Save ( FilePrefix="n@node@_Vd1_5")

    Quasistationary(
        InitialStep=1e-2 Increment=1.35
        MinStep=1e-6 MaxStep=0.05
        Goal { Name="drain" Voltage= 2.0}
        ){ Coupled { Poisson Electron Hole } }
    Save ( FilePrefix="n@node@_Vd2_0")
    }
