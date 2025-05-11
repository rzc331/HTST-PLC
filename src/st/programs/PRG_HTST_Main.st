(*
  PRG_HTST_Main - Main control program for HTST pasteurization process
*)

IMPORT '../HTST_Variables.st'; (* Import common variable declarations *)

(* Initialize system on first run *)
IF InitialRun THEN
    HTST.State := STATE_IDLE;
    InitialRun := FALSE;
END_IF;

(* Output current state *)
Status := HTST.State;

(* Handle emergency stop *)
IF CmdEmergencyStop THEN
    HTST.State := STATE_EMERGENCY;
    HTST.Alarms.EmergencyStop := TRUE;
END_IF;

(* Reset alarms if commanded *)
IF CmdReset THEN
    HTST.Alarms.HighTemp := FALSE;
    HTST.Alarms.LowTemp := FALSE;
    HTST.Alarms.FlowLow := FALSE;
    HTST.Alarms.PressureLow := FALSE;
    HTST.Alarms.EmergencyStop := FALSE;
    
    IF HTST.State = STATE_EMERGENCY AND NOT CmdEmergencyStop THEN
        HTST.State := STATE_IDLE;
    END_IF;
    
    IF HTST.State = STATE_FAULT THEN
        HTST.State := STATE_IDLE;
    END_IF;
END_IF;

(* State machine *)
CASE HTST.State OF
    STATE_IDLE:
        TempControl.Enable := FALSE;
        FlowControl.Enable := FALSE;
        
        IF CmdStart AND NOT CmdEmergencyStop THEN
            HTST.State := STATE_STARTUP;
        END_IF;
        
    STATE_STARTUP:
        TempControl.Enable := TRUE;
        TempControl.SetpointTemperature := TempSetpoint;
        TempControl.ActualTemperature := HTST.HoldingTube.EntryTemp.Value;
        
        HTST.HeatExchanger.HotWaterValve.Command := TempControl.ControlOutput;
        
        IF ABS(HTST.HoldingTube.EntryTemp.Value - TempSetpoint) < 5.0 THEN
            HTST.State := STATE_PRODUCTION;
        END_IF;
        
        IF CmdStop THEN
            HTST.State := STATE_SHUTDOWN;
        END_IF;
        
    STATE_PRODUCTION:
        TempControl.Enable := TRUE;
        FlowControl.Enable := TRUE;
        
        IF HTST.HoldingTube.EntryTemp.Value < MinPasteurizationTemp THEN
            HTST.FlowDiverter.Command := 100.0; (* Divert flow *)
            HTST.Alarms.LowTemp := TRUE;
        ELSE
            HTST.FlowDiverter.Command := 0.0; (* Forward flow *)
            HTST.Alarms.LowTemp := FALSE;
        END_IF;
        
        IF CmdStop THEN
            HTST.State := STATE_SHUTDOWN;
        END_IF;
        
    STATE_SHUTDOWN:
        FlowControl.Enable := FALSE;
        HTST.FeedPump.Command := 0.0;
        TempControl.Enable := FALSE;
        HTST.HeatExchanger.HotWaterValve.Command := 0.0;
        
        IF HTST.FlowMeter.FlowRate < 1.0 THEN
            HTST.State := STATE_IDLE;
        END_IF;
        
    STATE_EMERGENCY:
        TempControl.Enable := FALSE;
        FlowControl.Enable := FALSE;
        HTST.HeatExchanger.HotWaterValve.Command := 0.0;
        HTST.FeedPump.Command := 0.0;
        HTST.FlowDiverter.Command := 100.0;
        
    STATE_FAULT:
        TempControl.Enable := FALSE;
        FlowControl.Enable := FALSE;
        HTST.HeatExchanger.HotWaterValve.Command := 0.0;
        HTST.FeedPump.Command := 0.0;
        HTST.FlowDiverter.Command := 100.0;
        
    ELSE
        HTST.State := STATE_FAULT;
END_CASE; 