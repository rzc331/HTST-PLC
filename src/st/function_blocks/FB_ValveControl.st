(*
  FB_ValveControl - Valve control function block
  Purpose: Controls valves with digital on/off or analog positioning
*)

IMPORT '../HTST_Variables.st'; (* Import common variable declarations *)

IF EnableControl THEN
    (* Update valve feedback status *)
    IsOpen := FeedbackOpened;
    IsClosed := FeedbackClosed;
    
    (* Determine if valve is in transition *)
    InTransition := NOT (IsOpen OR IsClosed);
    
    IF UsePercentageControl THEN
        (* Modulating valve control (percentage-based) *)
        
        (* Apply percentage command with limits *)
        IF PercentageCommand > 100.0 THEN
            PercentageOutput := 100.0;
        ELSIF PercentageCommand < 0.0 THEN
            PercentageOutput := 0.0;
        ELSE
            PercentageOutput := PercentageCommand;
        END_IF;
        
        (* Set digital outputs based on percentage *)
        IF PercentageOutput > 0.0 THEN
            ValveOpen := TRUE;
            ValveClose := FALSE;
        ELSE
            ValveOpen := FALSE;
            ValveClose := TRUE;
        END_IF;
        
        (* Reset fault status for modulating mode *)
        Fault := FALSE;
        Status := 1; (* Running in modulating mode *)
        
    ELSE
        (* Digital on/off valve control *)
        
        (* Process open and close commands *)
        IF OpenCommand AND NOT CloseCommand THEN
            (* Open valve command *)
            ValveOpen := TRUE;
            ValveClose := FALSE;
            
            (* Start timeout timer for opening *)
            OpenTimer(IN := NOT IsOpen, PT := OpenTimeout);
            IF OpenTimer.Q THEN
                (* Valve failed to open within timeout *)
                Fault := TRUE;
                Status := 100; (* Fault: open timeout *)
            END_IF;
            
        ELSIF CloseCommand AND NOT OpenCommand THEN
            (* Close valve command *)
            ValveOpen := FALSE;
            ValveClose := TRUE;
            
            (* Start timeout timer for closing *)
            CloseTimer(IN := NOT IsClosed, PT := CloseTimeout);
            IF CloseTimer.Q THEN
                (* Valve failed to close within timeout *)
                Fault := TRUE;
                Status := 101; (* Fault: close timeout *)
            END_IF;
            
        ELSIF OpenCommand AND CloseCommand THEN
            (* Invalid command combination *)
            ValveOpen := FALSE;
            ValveClose := FALSE;
            Fault := TRUE;
            Status := 102; (* Fault: conflicting commands *)
            
        ELSE
            (* No active command - maintain position *)
            ValveOpen := FALSE;
            ValveClose := FALSE;
            Fault := FALSE;
            
            IF IsOpen THEN
                Status := 2; (* Open position *)
            ELSIF IsClosed THEN
                Status := 3; (* Closed position *)
            ELSE
                Status := 4; (* Intermediate position *)
            END_IF;
        END_IF;
        
        (* For digital mode, set percentage based on feedback *)
        IF IsOpen THEN
            PercentageOutput := 100.0;
        ELSIF IsClosed THEN
            PercentageOutput := 0.0;
        ELSE
            (* In transition - use feedback position if available *)
            PercentageOutput := FeedbackPosition;
        END_IF;
    END_IF;
ELSE
    (* Control disabled *)
    ValveOpen := FALSE;
    ValveClose := FALSE;
    PercentageOutput := 0.0;
    IsOpen := FeedbackOpened;
    IsClosed := FeedbackClosed;
    InTransition := FALSE;
    Fault := FALSE;
    Status := 0; (* Disabled *)
END_IF; 