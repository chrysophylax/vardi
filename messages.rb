module VMInfo
  SEP = "\t\t\t\t\t\t"
  PRINT_STACK = SEP + " stack value -> "
  TOGGLE_DEBUG = SEP + " debug toggled "
  STEP_FORWARD = SEP + " step increased."
  STEP_BACKWARD = SEP + " step decreased."
  RESUME_EXECUTION = SEP + " resuming execution."
  HALT = SEP + " halt issued."
  PRINT_ISP = SEP + " instruction pointer -> "
  DOWN_STACK = SEP + " stack DOWN -> "
  UP_STACK = SEP + " stack UP -> "
  PP_INSTRUCTIONS = "\t\t --- instructions --- \n"
  MAL_INSTR = SEP + " could not understand "
  def VMInfo::PEEK_INSTR i
    SEP + " next instruction ->\t[0x#{i.to_s(16).upcase}]"
  end
  def VMInfo::EXEC_INSTR i
    SEP + " execute instruction ->\t[0x#{i.to_s(16).upcase}]"
  end

  DEBUG_INFO =
    "Vardi interactive debugger mode.\n
    
    * p : PRINT_STACK
    * j : NAVIGATE_DOWN_STACK
    * k : NAVIGATE_UP_STACK
    * d : TOGGLE_DEBUG
    * h : HALT_EXECUTION
    * i : PRINT_ISP
    * f : STEP_FORWARD
    * b : STEP_BACKWARD
    * n : PEEK_NEXT_INSTR
    * x : EXEC_NEXT_INSTR
    * r : RESUME_EXECUTION
    * q : QUIT_VM
    * ? : PRINT_HELP
    "
end
