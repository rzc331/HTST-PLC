(*
  FB_FlowControl - Flow control function block
  Purpose: Controls product flow by adjusting pump speed using PID control
*)

IMPORT '../HTST_Variables.st'; (* Import common variable declarations *)

(* Calculate flow error = setpoint - actual *)
FlowError := FlowSetpoint - ActualFlow;

IF Enable THEN
    (* Set pump running status *)
    PumpRunning := FlowSetpoint > 0.0;
    
    (* Flow alarm check logic *)
    IF PumpRunning AND FlowSetpoint > MinimumFlow THEN
        (* Check if flow is below minimum and pump is running *)
        FlowDetectedBelowMinimum := ActualFlow < MinimumFlow;
        
        (* Start timeout timer if flow is below minimum *)
        FlowTimer(IN := FlowDetectedBelowMinimum, PT := FlowTimeout);
        
        (* Set alarm if timeout occurs *)
        FlowAlarm := FlowTimer.Q;
    ELSE
        FlowDetectedBelowMinimum := FALSE;
        FlowAlarm := FALSE;
    END_IF;
    
    (* Set FlowOK flag *)
    FlowOK := PumpRunning AND ActualFlow >= MinimumFlow AND (ABS(FlowError) / FlowSetpoint <= 0.1 OR FlowSetpoint < 0.1);
    
    IF FirstRun THEN
        (* Initialize controller on first run *)
        ErrorSum := 0.0;
        PreviousError := FlowError;
        FirstRun := FALSE;
        PreviousCycleTime := NOW();
        
        (* Initial pump speed based on setpoint *)
        IF FlowSetpoint > 0.0 THEN
            PumpSpeedOutput := MaxPumpSpeed * 0.5; (* Start at 50% *)
        ELSE
            PumpSpeedOutput := MinPumpSpeed;
        END_IF;
        
        Status := 1; (* Initializing *)
    ELSE
        (* Only run PID control if setpoint is greater than zero *)
        IF PumpRunning THEN
            (* Calculate cycle time for integration and derivation *)
            CycleTime := TIME_TO_REAL(TIME_SUB(NOW(), PreviousCycleTime)) / 1000.0; (* Convert ms to seconds *)
            PreviousCycleTime := NOW();
            
            (* Anti-windup: Limit the error sum *)
            IF ErrorSum * Ki > MaxPumpSpeed THEN
                ErrorSum := MaxPumpSpeed / Ki;
            ELSIF ErrorSum * Ki < MinPumpSpeed THEN
                ErrorSum := MinPumpSpeed / Ki;
            ELSE
                (* Accumulate error for integral term *)
                ErrorSum := ErrorSum + FlowError * CycleTime;
            END_IF;
            
            (* Calculate error derivative *)
            ErrorDelta := (FlowError - PreviousError) / CycleTime;
            
            (* Save current error for next cycle *)
            PreviousError := FlowError;
            
            (* Calculate PID output *)
            Output := Kp * FlowError + Ki * ErrorSum + Kd * ErrorDelta;
            
            (* Limit pump speed to min/max range *)
            IF Output > MaxPumpSpeed THEN
                PumpSpeedOutput := MaxPumpSpeed;
            ELSIF Output < MinPumpSpeed THEN
                PumpSpeedOutput := MinPumpSpeed;
            ELSE
                PumpSpeedOutput := Output;
            END_IF;
            
            Status := 2; (* Running - normal control *)
        ELSE
            (* No flow required - stop pump *)
            PumpSpeedOutput := MinPumpSpeed;
            Status := 3; (* Idle - zero setpoint *)
        END_IF;
    END_IF;
ELSE
    (* Controller disabled - reset outputs *)
    PumpSpeedOutput := MinPumpSpeed;
    PumpRunning := FALSE;
    FlowOK := FALSE;
    FlowAlarm := FALSE;
    ErrorSum := 0.0;
    FirstRun := TRUE;
    Status := 0; (* Disabled *)
END_IF; 