# Structured Text (ST) Code Organization

## Overview

This document describes how the Structured Text (ST) code is organized in the HTST Pasteurization Control System. The system uses external ST files that are referenced from the PLCopen XML files, providing better code management and maintainability.

## Directory Structure

The ST code is organized as follows:

```
src/
├── st/
│   ├── HTST_Variables.st       # Common variable declarations
│   ├── function_blocks/        # ST code for function blocks
│   │   ├── FB_TemperatureControl.st
│   │   ├── FB_ValveControl.st
│   │   └── FB_FlowControl.st
│   └── programs/               # ST code for programs
│       ├── PRG_HTST_Main.st
│       ├── PRG_HTST_CIP.st
│       └── PRG_HTST_Alarms.st
├── pou/
│   ├── function_blocks/        # XML definitions for function blocks
│   │   ├── FB_TemperatureControl.xml
│   │   ├── FB_ValveControl.xml
│   │   └── FB_FlowControl.xml
│   └── programs/               # XML definitions for programs
│       ├── PRG_HTST_Main.xml
│       ├── PRG_HTST_CIP.xml
│       └── PRG_HTST_Alarms.xml
└── ...
```

## XML to ST File References

The PLCopen XML files contain references to the ST files using the `<externalText>` element:

```xml
<body>
  <ST>
    <externalText>
      <file>../st/function_blocks/FB_TemperatureControl.st</file>
    </externalText>
  </ST>
</body>
```

## Common Variable Imports

Each ST file imports a common variable declaration file `HTST_Variables.st` to ensure consistency:

```st
IMPORT '../HTST_Variables.st'; (* Import common variable declarations *)
```

The `HTST_Variables.st` file contains:
- Constant definitions for process states
- Global parameters for the HTST system
- Other shared constants and variables

## Benefits of External ST Files

1. **Easier Editing**: ST code can be edited directly without modifying XML files
2. **Version Control**: Better diff and merge capabilities for code changes
3. **Code Reuse**: Common variable declarations in a single place
4. **Maintainability**: Clear separation between interface (XML) and implementation (ST)
5. **Development Tools**: Better support for ST-specific tools, syntax highlighting, etc.

## Implementation Notes

When making changes to the ST code:

1. Edit the `.st` files directly
2. Ensure imports are properly maintained
3. Use consistent naming conventions
4. Follow the structured text coding guidelines

For adding new functions or variables to the common imports:

1. Add the definition to `HTST_Variables.st`
2. Import the file in any ST code that needs the new functions/variables 