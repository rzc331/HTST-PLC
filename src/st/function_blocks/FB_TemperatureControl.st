(*
  FB_TemperatureControl - PID control for temperature regulation
  Purpose: Controls temperature by manipulating valve position or heating element
*)

IMPORT '../HTST_Variables.st'; (* Import common variable declarations *)

(* Calculate error = setpoint - actual *)
TemperatureError := SetpointTemperature - ActualTemperature;

IF Enable THEN
    (* Initialize on first run or after disable *)
    IF FirstRun THEN
        ErrorSum := 0.0;
        PreviousError := TemperatureError;
        FirstRun := FALSE;
        PreviousCycleTime := NOW();
        Status := 1; (* Running - first cycle *)
    ELSE
        (* Calculate cycle time *)
        CycleTime := TIME_TO_REAL(TIME_SUB(NOW(), PreviousCycleTime)) / 1000.0; (* Convert ms to seconds *)
        
        (* Update previous cycle time *)
        PreviousCycleTime := NOW();
        
        (* Anti-windup: Limit the error sum *)
        IF ErrorSum * Ki > MaximumOutput THEN
            ErrorSum := MaximumOutput / Ki;
        ELSIF ErrorSum * Ki < MinimumOutput THEN
            ErrorSum := MinimumOutput / Ki;
        ELSE
            (* Accumulate error for integral term *)
            ErrorSum := ErrorSum + TemperatureError * CycleTime;
        END_IF;
        
        (* Calculate error derivative *)
        ErrorDelta := (TemperatureError - PreviousError) / CycleTime;
        
        (* Save current error for next cycle *)
        PreviousError := TemperatureError;
        
        (* Calculate PID output *)
        Output := Kp * TemperatureError + Ki * ErrorSum + Kd * ErrorDelta;
        
        (* Limit output to min/max range *)
        IF Output > MaximumOutput THEN
            ControlOutput := MaximumOutput;
        ELSIF Output < MinimumOutput THEN
            ControlOutput := MinimumOutput;
        ELSE
            ControlOutput := Output;
        END_IF;
        
        Status := 2; (* Running - normal *)
    END_IF;
ELSE
    (* Controller disabled - reset *)
    ControlOutput := MinimumOutput;
    ErrorSum := 0.0;
    FirstRun := TRUE;
    Status := 0; (* Disabled *)
END_IF; 