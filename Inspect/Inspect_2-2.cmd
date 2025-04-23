## Device Section
Device "MOS" {
    File {
        Grid = "@tdr@"
        Parameter = "@parameter@"
        Plot = "@tdrdat@"
        Current = "@plot@"
        }

    Electrode {
        { Name="gate" Voltage=0.0 }
        { Name="substrate" Voltage=0.0 }
        { Name="source" Voltage=0.0 }
        { Name="drain" Voltage=0.0 }
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
  RHSmin=1e-10
  Notdamped=100
  Iterations=50
  DirectCurrent
  ExitOnFailure
  NumberOfThreads= 8

  Method=Blocked
  SubMethod=Super
  ACMethod=Blocked
  ACSubMethod=Super

  RefDens_eGradQuasiFermi_ElectricField= 1e16
  RefDens_hGradQuasiFermi_ElectricField= 1e16
  }

## File Section
File {
  Output = "@log@"
  ACExtract = "@acplot@"
  }

## System Section
System {
    *-Physical devices:
    MOS nmos1 ( "gate"=g "source"=s "drain"=d "substrate"=b)

    *-Lumped elements:
    Vsource_pset vg (g 0) { dc = 0.0}
    Vsource_pset vb (b 0) { dc = 0.0}
    Vsource_pset vs (s 0) { dc = 0.0}
    Vsource_pset vd (d 0) { dc = 0.0}
    }

## Solve Section
Solve {
    Coupled ( Iterations=100 ){ Poisson }
    Coupled ( Iterations=100 ){ Poisson Electron Hole }
    Save ( FilePrefix="n@node@_init" )
 
    Quasistationary(
        InitialStep=1e-2 Increment=1.2
        MinStep=1e-8 MaxStep=0.5
        Goal { Parameter=vg.dc Voltage=@<-1.0*VgRange>@ }
        ){ Coupled { Poisson Electron Hole } }
 
    NewCurrentPrefix="CV_"
 
    Quasistationary(
        InitialStep=1e-2 Increment=1.2
        MinStep=1e-8 MaxStep=0.1
        Goal { Parameter=vg.dc Voltage= @VgRange@ }
        ){ ACCoupled (
            StartFrequency=@Freq@ EndFrequency=@Freq@
            NumberOfPoints=1 Decade Node(b g s d) Exclude(vb vg vs vd)
            ACCompute (Time = (Range = (0 1) Intervals = 50))
            ){ Poisson Electron Hole }
        }
    }
