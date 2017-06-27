module Bytecode
  
  NOP = 0 # no op
  JMP = 1 # jmp to instr spec. in immed byte
  PEEK = 3 # stack peek
  CRAY = 7 #shuffle the next four instructions
  CONS = 13 # push immed byte onto stack
  EXIT = 15 # exit happily

  #stack effects
  SWAP = 2 # switcharoo
  DEC = 4 # DEPRECATED: decrease by 1, use CONST, 1, SUB
  POP = 5 # ciao
  ADD = 6 # sum top two
  SUB = 8 # sub top two
  MUL = 10 # ...
  DIV = 12 # ..
  PRINT = 14 # print int->to_s
  TEXT = 10 # print int as char

end
