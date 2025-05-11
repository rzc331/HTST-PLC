# HTST Pasteurization PLC Control System

This repository contains a PLCopen XML-based control system for an HTST (High-Temperature Short-Time) pasteurization process. The implementation uses Structured Text (ST) as the main programming language following the IEC 61131-3 standard.

## System Overview

The HTST pasteurization process includes:
- Temperature control for heating and cooling
- Flow control for product throughput
- Valve sequencing for flow path control
- CIP (Clean-In-Place) operations
- Alarm handling and safety controls
- HMI integration points

## Repository Structure

- `/src` - Source code for PLC programs
  - `/st` - Structured Text source files 
    - `/function_blocks` - ST code for function blocks
    - `/programs` - ST code for main programs
    - `HTST_Variables.st` - Common variable declarations
  - `/pou` - Program Organization Units
    - `/programs` - Main programs (XML interface definitions)
    - `/function_blocks` - Reusable function blocks (XML interface definitions)
    - `/functions` - Global functions
  - `/data_types` - Custom data type definitions
  - `/visualization` - HMI elements
- `/docs` - Documentation and design specifications
- `/tests` - Test configurations and validation procedures

## Implementation Details

The control system is implemented according to PLCopen standards, supporting export and import via XML format. The structured text (ST) code is maintained in separate `.st` files that are referenced from the XML files, providing better maintainability and version control. For more details on the ST code organization, see [ST Code Organization](docs/ST_Code_Organization.md).

## Requirements

- PLC development environment supporting PLCopen XML
- IEC 61131-3 compatibility with Structured Text support