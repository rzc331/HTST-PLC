(*
  PRG_HTST_Alarms - Alarm handling for HTST system
  Purpose: Manages alarm detection, logging, and acknowledgment
*)

IMPORT '../HTST_Variables.st'; (* Import common variable declarations *)

(* Initialize alarm descriptions on first run *)
IF InitialRun THEN
    AlarmDescriptions[1] := 'Emergency Stop Activated';
    AlarmDescriptions[2] := 'High Temperature Alarm';
    AlarmDescriptions[3] := 'Low Temperature Alarm';
    AlarmDescriptions[4] := 'Low Flow Alarm';
    AlarmDescriptions[5] := 'Low Pressure Alarm';
    AlarmDescriptions[6] := 'Valve Failure';
    AlarmDescriptions[7] := 'Pump Failure';
    AlarmDescriptions[8] := 'Temperature Sensor Failure';
    AlarmDescriptions[9] := 'Flow Meter Failure';
    AlarmDescriptions[10] := 'Control System Failure';
    InitialRun := FALSE;
END_IF;

(* Check for new alarms and update alarm buffer *)

(* Emergency Stop Alarm *)
IF HTST.Alarms.EmergencyStop AND NOT AlarmBuffer[0].Active THEN
    (* New emergency stop alarm *)
    AlarmBuffer[0].Active := TRUE;
    AlarmBuffer[0].Acknowledged := FALSE;
    AlarmBuffer[0].TimeStamp := NOW();
    AlarmBuffer[0].AlarmCode := 1;
    AlarmBuffer[0].Description := AlarmDescriptions[1];
ELSIF NOT HTST.Alarms.EmergencyStop AND AlarmBuffer[0].Active THEN
    (* Emergency stop cleared *)
    AlarmBuffer[0].Active := FALSE;
END_IF;

(* High Temperature Alarm *)
IF HTST.Alarms.HighTemp AND NOT AlarmBuffer[1].Active THEN
    (* New high temperature alarm *)
    AlarmBuffer[1].Active := TRUE;
    AlarmBuffer[1].Acknowledged := FALSE;
    AlarmBuffer[1].TimeStamp := NOW();
    AlarmBuffer[1].AlarmCode := 2;
    AlarmBuffer[1].Description := AlarmDescriptions[2];
ELSIF NOT HTST.Alarms.HighTemp AND AlarmBuffer[1].Active THEN
    (* High temperature alarm cleared *)
    AlarmBuffer[1].Active := FALSE;
END_IF;

(* Low Temperature Alarm *)
IF HTST.Alarms.LowTemp AND NOT AlarmBuffer[2].Active THEN
    (* New low temperature alarm *)
    AlarmBuffer[2].Active := TRUE;
    AlarmBuffer[2].Acknowledged := FALSE;
    AlarmBuffer[2].TimeStamp := NOW();
    AlarmBuffer[2].AlarmCode := 3;
    AlarmBuffer[2].Description := AlarmDescriptions[3];
ELSIF NOT HTST.Alarms.LowTemp AND AlarmBuffer[2].Active THEN
    (* Low temperature alarm cleared *)
    AlarmBuffer[2].Active := FALSE;
END_IF;

(* Low Flow Alarm *)
IF HTST.Alarms.FlowLow AND NOT AlarmBuffer[3].Active THEN
    (* New low flow alarm *)
    AlarmBuffer[3].Active := TRUE;
    AlarmBuffer[3].Acknowledged := FALSE;
    AlarmBuffer[3].TimeStamp := NOW();
    AlarmBuffer[3].AlarmCode := 4;
    AlarmBuffer[3].Description := AlarmDescriptions[4];
ELSIF NOT HTST.Alarms.FlowLow AND AlarmBuffer[3].Active THEN
    (* Low flow alarm cleared *)
    AlarmBuffer[3].Active := FALSE;
END_IF;

(* Low Pressure Alarm *)
IF HTST.Alarms.PressureLow AND NOT AlarmBuffer[4].Active THEN
    (* New low pressure alarm *)
    AlarmBuffer[4].Active := TRUE;
    AlarmBuffer[4].Acknowledged := FALSE;
    AlarmBuffer[4].TimeStamp := NOW();
    AlarmBuffer[4].AlarmCode := 5;
    AlarmBuffer[4].Description := AlarmDescriptions[5];
ELSIF NOT HTST.Alarms.PressureLow AND AlarmBuffer[4].Active THEN
    (* Low pressure alarm cleared *)
    AlarmBuffer[4].Active := FALSE;
END_IF;

(* Process alarm acknowledgment *)
IF AcknowledgeAlarms THEN
    FOR i := 0 TO 19 DO
        IF AlarmBuffer[i].Active THEN
            AlarmBuffer[i].Acknowledged := TRUE;
        END_IF;
    END_FOR;
END_IF;

(* Count active alarms *)
AlarmCount := 0;
AlarmActive := FALSE;

FOR i := 0 TO 19 DO
    IF AlarmBuffer[i].Active THEN
        AlarmCount := AlarmCount + 1;
        AlarmActive := TRUE;
    END_IF;
END_FOR; 