module Bytecode
  
  NOP = 0
  JMP = 1
  PEEK = 3
  CRAY = 7 #shuffle the next four instructions
  CONS = 13
  EXIT = 15

  #stack effects
  SWAP = 2
  DEC = 4
  POP = 5
  ADD = 6
  SUB = 8
  MUL = 10
  DIV = 12
  PRINT = 14
  TEXT = 10

end
