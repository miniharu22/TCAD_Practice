## NMOS Device Section
Device NMOS {
    File {
        Grid = "n@node|NMOS@_msh.tdr"
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

    Physics (Region = "region_gate") {
        MetalWorkfunction (Workfuntion = @nWF@)
        }

    Physics {
        AreaFactor=1
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

## PMOS Device Section
Device PMOS {
    File {
        Grid = "n@node|PMOS@_msh.tdr"
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

    Physics (Region = "region_gate") {
        MetalWorkfunction (Workfuntion = @pWF@)
        }

    Physics {
        AreaFactor=2
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
    RelErrControl
    Digits=4
    Notdamped=50
    Iterations=12
    
    Transient=BE

    Method=Blocked
    SubMethod=ParDiSo
}

## File Section
File{
    Output = "@log@"
    }

## System Section
System{
    Vsource_pset vdd (dd 0) { dc = 0.0 }
    Vsource_pset vin (in 0) {
        pulse = ( 0.0
                @Vd@
                10e-11
                10e-11
                10e-11
                120e-11
                200e-11)
        }
    NMOS nmos1 ( "source"=0 "drain"=out "gate"=in "substrate"=0 )
    PMOS pmos1 ( "source"=dd "drain"=out "gate"=in "substrate"=dd )
    Capacitor_pset cout ( out 0 ) {capacitance = @cap@}

    Plot "n@node@_sys_des.plt" (time() v(in) v(out) i(nmos1, out) i(pmos1, out) i(cout, out))
    }   

## Solve Section
Solve {
    Coupled ( Iterations=100 ){ Poisson }
    Coupled {Poisson Electron Hole Contact Circuit}
    Quasistationary(
        InitialStep=1e-3 Increment=1.35
        MinStep=1e-5 MaxStep=0.05
        Goal { Parameter=vdd.dc Voltage= @Vd@}
        ){ Coupled { nmos1.poisson nmos1.electron nmos1.hole nmos1.contact pmos1.poisson pmos1.electron pmos1.hole pmos1.contact circuit }
        }

    NewCurrentPrefix="Transient_"

    Transient(
        InitialTime=0 FinalTime=200e-11
        InitialStep= 1e-12 MaxStep=2e-11 MinStep=1e-15
        Increment = 1.3
        ){ Coupled { nmos1.poisson nmos1.electron nmos1.hole nmos1.contact pmos1.poisson pmos1.electron pmos1.hole pmos1.contact circuit }
        }
    }
