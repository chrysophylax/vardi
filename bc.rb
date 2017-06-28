module Bytecode
  
  NOP = 0     # 0x00 no op
  JMP = 1     # 0x01 jmp using immed
  JMS = 17    # 0x11 jmp using stack addr
  PEEK = 3    # 0x03 stack peek
  POP = 5     # 0x05 ciao
  CRAY = 7    # 0x07 shuffle the next four instructions
  CONS = 13   # 0x0D push immed byte onto stack ('dump')
  EXIT = 15   # 0x0F exit happily
  RET = 255   # 0xFF return
  CALL = 202  # 0xCA call subroutine
  JIZ = 31    # 0x1F jump 1f zero to immed 
  JVM = 254   # 0xFE enter java mode: pause execution for IMMED seconds
  CLS = 197   # 0xC5 call subroutine using stack as addr
  DUP = 221   # 0xDD duplicate item stack
  #stack effects
  SWAP = 2    # 0x02 switcharoo
  RSWP = 34   # 0x22 swap return address and current stack value
  ISWP = 226  # 0xE2 "evil" swap
  DEC = 4     # 0x04 DEPRECATED: decrease by 1, use CONST, 1, SUB
  ADD = 6     # 0x06 sum top two elements of the stack
  SUB = 8     # 0x08 sub top two elements of the stack
  MUL = 11    # 0x0B ...
  DIV = 12    # 0x0C ...
  PRINT = 14  # 0x0E print int->to_s
  TEXT = 10   # 0x0A print int as char

  #memory
  LOAD = 64   # 0x40 pops addr, pops val, puts val in addr
  FETCH = 60  # 0x3C pops addr, fetches val, puts val on stack
 
  

end
