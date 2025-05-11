(* 
  HTST_Variables.st
  Common variable declarations for HTST pasteurization system
  This file is intended to be imported by ST programs as needed
*)

(* Process States *)
VAR_GLOBAL CONSTANT
    STATE_IDLE      : INT := 0;
    STATE_STARTUP   : INT := 1;
    STATE_PREHEATING: INT := 2;
    STATE_PRODUCTION: INT := 3;
    STATE_CIP       : INT := 4;
    STATE_SHUTDOWN  : INT := 5;
    STATE_EMERGENCY : INT := 6;
    STATE_FAULT     : INT := 7;
END_VAR

(* Global parameters *)
VAR_GLOBAL
    g_PasteurizationTemp : REAL := 72.0;     (* Default pasteurization temperature *)
    g_MinimumLegalTemp   : REAL := 71.5;     (* Minimum allowable pasteurization temperature *)
    g_TargetFlowRate     : REAL := 100.0;    (* Default flow rate in L/min *)
    g_MinimumFlowRate    : REAL := 10.0;     (* Minimum flow rate for operation *)
    g_HoldingTime        : REAL := 15.0;     (* Holding time in seconds *)
END_VAR 