(*
  PRG_HTST_CIP - Clean-In-Place program for HTST system
  Purpose: Controls the CIP sequence for cleaning the HTST system
*)

IMPORT '../HTST_Variables.st'; (* Import common variable declarations *)

(* Update output with current step *)
CIPStep := CurrentStep;

(* Emergency stop handling *)
IF CmdEmergencyStop THEN
    CurrentStep := 0;
    CIPActive := FALSE;
    CIPComplete := FALSE;
    StepTimer.IN := FALSE;
ELSIF HTSTState = STATE_EMERGENCY THEN
    CurrentStep := 0;
    CIPActive := FALSE;
    CIPComplete := FALSE;
    StepTimer.IN := FALSE;
END_IF;

(* Handle CIP start command *)
IF CmdStartCIP AND HTSTState = STATE_CIP AND CurrentStep = 0 THEN
    CurrentStep := 1; (* Start with pre-rinse *)
    CIPActive := TRUE;
    CIPComplete := FALSE;
END_IF;

(* Handle CIP stop command *)
IF CmdStopCIP AND CIPActive THEN
    (* Perform drain/shutdown sequence *)
    CurrentStep := 99; (* Drain/shutdown step *)
END_IF;

(* Process CIP state machine *)
CASE CurrentStep OF
    0:  (* Idle - CIP not running *)
        CIPActive := FALSE;
        CIPComplete := FALSE;
        StepTimer.IN := FALSE;
        
    1:  (* Pre-rinse cycle *)
        (* Setup timer for pre-rinse duration *)
        StepTimer(IN := TRUE, PT := PreRinseTime);
        
        (* Pre-rinse logic would be here *)
        (* - Open rinse water valve *)
        (* - Start CIP pump *)
        (* - Set routing valves for recirculation *)
        
        (* When timer expires, move to next step *)
        IF StepTimer.Q THEN
            StepTimer.IN := FALSE;
            CurrentStep := 2; (* Move to caustic wash *)
        END_IF;
        
    2:  (* Caustic wash cycle *)
        (* Setup timer for caustic wash duration *)
        StepTimer(IN := TRUE, PT := CausticWashTime);
        
        (* Caustic wash logic would be here *)
        (* - Close fresh water valve *)
        (* - Open caustic tank valve *)
        (* - Maintain temperature for caustic wash *)
        
        (* When timer expires, move to next step *)
        IF StepTimer.Q THEN
            StepTimer.IN := FALSE;
            CurrentStep := 3; (* Move to intermediate rinse *)
        END_IF;
        
    3:  (* Intermediate rinse cycle *)
        (* Setup timer for intermediate rinse duration *)
        StepTimer(IN := TRUE, PT := IntermediateRinseTime);
        
        (* Intermediate rinse logic would be here *)
        (* - Close caustic tank valve *)
        (* - Open fresh water valve *)
        (* - Maintain flow for rinsing *)
        
        (* When timer expires, move to next step *)
        IF StepTimer.Q THEN
            StepTimer.IN := FALSE;
            CurrentStep := 4; (* Move to acid wash *)
        END_IF;
        
    4:  (* Acid wash cycle *)
        (* Setup timer for acid wash duration *)
        StepTimer(IN := TRUE, PT := AcidWashTime);
        
        (* Acid wash logic would be here *)
        (* - Close fresh water valve *)
        (* - Open acid tank valve *)
        (* - Maintain flow for acid wash *)
        
        (* When timer expires, move to next step *)
        IF StepTimer.Q THEN
            StepTimer.IN := FALSE;
            CurrentStep := 5; (* Move to final rinse *)
        END_IF;
        
    5:  (* Final rinse cycle *)
        (* Setup timer for final rinse duration *)
        StepTimer(IN := TRUE, PT := FinalRinseTime);
        
        (* Final rinse logic would be here *)
        (* - Close acid tank valve *)
        (* - Open fresh water valve *)
        (* - Maintain flow for thorough rinsing *)
        
        (* When timer expires, move to next step *)
        IF StepTimer.Q THEN
            StepTimer.IN := FALSE;
            CurrentStep := 6; (* Move to sanitize *)
        END_IF;
        
    6:  (* Sanitize cycle *)
        (* Setup timer for sanitize duration *)
        StepTimer(IN := TRUE, PT := SanitizeTime);
        
        (* Sanitize logic would be here *)
        (* - Close fresh water valve *)
        (* - Open sanitizer tank valve *)
        (* - Maintain flow for sanitization *)
        
        (* When timer expires, move to next step *)
        IF StepTimer.Q THEN
            StepTimer.IN := FALSE;
            CurrentStep := 7; (* Move to drain *)
        END_IF;
        
    7:  (* Drain and finalize *)
        (* Drain logic would be here *)
        (* - Close all supply valves *)
        (* - Open drain valves *)
        (* - Run pump at low speed to assist draining *)
        
        (* After brief drain period *)
        StepTimer(IN := TRUE, PT := T#2m);
        
        IF StepTimer.Q THEN
            StepTimer.IN := FALSE;
            CurrentStep := 0; (* Return to idle *)
            CIPActive := FALSE;
            CIPComplete := TRUE;
        END_IF;
        
    99: (* Emergency drain/shutdown *)
        (* Close all chemical valves *)
        (* Open drain valves *)
        (* Stop pumps *)
        
        (* After brief drain period *)
        StepTimer(IN := TRUE, PT := T#1m);
        
        IF StepTimer.Q THEN
            StepTimer.IN := FALSE;
            CurrentStep := 0; (* Return to idle *)
            CIPActive := FALSE;
            CIPComplete := FALSE;
        END_IF;
        
    ELSE
        (* Invalid step - reset to idle *)
        CurrentStep := 0;
        CIPActive := FALSE;
        CIPComplete := FALSE;
        StepTimer.IN := FALSE;
END_CASE; 