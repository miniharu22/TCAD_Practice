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
    
    NMOS nmos1 ( "source"=0 "drain"=in2 "gate"=in "substrate"=0 )
    PMOS pmos1 ( "source"=dd "drain"=in2 "gate"=in "substrate"=dd )

    NMOS nmos2 ( "source"=0 "drain"=in3 "gate"=in2 "substrate"=0 )
    PMOS pmos2 ( "source"=dd "drain"=in3 "gate"=in2 "substrate"=dd )

    NMOS nmos3 ( "source"=0 "drain"=in4 "gate"=in3 "substrate"=0 )
    PMOS pmos3 ( "source"=dd "drain"=in4 "gate"=in3 "substrate"=dd )

    NMOS nmos4 ( "source"=0 "drain"=in5 "gate"=in4 "substrate"=0 )
    PMOS pmos4 ( "source"=dd "drain"=in5 "gate"=in4 "substrate"=dd )

    NMOS nmos5 ( "source"=0 "drain"=out "gate"=in5 "substrate"=0 )
    PMOS pmos5 ( "source"=dd "drain"=out "gate"=in5 "substrate"=dd )
    Capacitor_pset cout ( out 0 ) {capacitance = 1e-14}

    Plot "n@node@_sys_des.plt" (time() v(in) v(in2) v(in3) v(in4) v(in5) v(out) i(nmos5, out) i(pmos5, out) i(cout, out))
    } 

## Solve Section
Solve {
    Coupled ( Iterations=100 ){ Poisson }
    Coupled {Poisson Electron Hole Contact Circuit}
 
    Quasistationary(
        InitialStep=1e-3 Increment=1.35
        MinStep=1e-5 MaxStep=0.05
        Goal { Parameter=vdd.dc Voltage= @Vd@}
        ){ Coupled { nmos1.poisson nmos1.electron nmos1.hole nmos1.contact
                    pmos1.poisson pmos1.electron pmos1.hole pmos1.contact
                    nmos2.poisson nmos2.electron nmos2.hole nmos2.contact
                    pmos2.poisson pmos2.electron pmos2.hole pmos2.contact
                    nmos3.poisson nmos3.electron nmos3.hole nmos3.contact
                    pmos3.poisson pmos3.electron pmos3.hole pmos3.contact
                    nmos4.poisson nmos4.electron nmos4.hole nmos4.contact
                    pmos4.poisson pmos4.electron pmos4.hole pmos4.contact
                    nmos5.poisson nmos5.electron nmos5.hole nmos5.contact
                    pmos5.poisson pmos5.electron pmos5.hole pmos5.contact
                    circuit 
                    }
            }

    NewCurrentPrefix="Transient_"
    
    Transient(
        InitialTime=0 FinalTime=200e-10
        InitialStep= 1e-12 MaxStep=2e-11 MinStep=1e-15
        Increment = 1.3
        ){ Coupled { nmos1.poisson nmos1.electron nmos1.hole nmos1.contact
                    pmos1.poisson pmos1.electron pmos1.hole pmos1.contact
                    nmos2.poisson nmos2.electron nmos2.hole nmos2.contact
                    pmos2.poisson pmos2.electron pmos2.hole pmos2.contact
                    nmos3.poisson nmos3.electron nmos3.hole nmos3.contact
                    pmos3.poisson pmos3.electron pmos3.hole pmos3.contact
                    nmos4.poisson nmos4.electron nmos4.hole nmos4.contact
                    pmos4.poisson pmos4.electron pmos4.hole pmos4.contact
                    nmos5.poisson nmos5.electron nmos5.hole nmos5.contact
                    pmos5.poisson pmos5.electron pmos5.hole pmos5.contact
                    circuit 
                    }
            }
    }
