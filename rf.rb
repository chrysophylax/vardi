require_relative "bc"
require_relative "messages"
require_relative "m"
require_relative "vm"
require "io/console"
require "readline"
module Inspector

  def handle_key
    STDIN.echo = false
    STDIN.raw!
    c = STDIN.read_nonblock(1) rescue nil
    STDIN.cooked!
    return c
  end

  def handle_input
    k = handle_key
    case k
        
    when ":" #enter command mode
      while (buf = Readline.readline(": ", true))
        begin
          parse_command buf
        rescue RuntimeError
          break
        end
      end
      
    when "q"
      self.halt_vm()
    end

  end
  
  def  parse_command(com)
   
    if (com == ":") then raise RuntimeError.new end
    
    if (com.start_with?("b"))
      parse_backward com
    end

    if (com == "i")
      i_peek_instruction
    end
    
    if (com == "q")
      self.halt_vm()
    end
    
    if (com == "\e")
      raise RuntimeError.new
    end

    if (com == 'd')
      i_toggle_debug
    end

    if (com == 'j')
      i_down_stack
    end

    if (com == 'k')
      i_up_stack
    end

    if (com == 'h')
      i_halt
    end

    if (com == 'f')
      i_step_forward
    end

    if (com == 'n')
      i_peek_instruction
    end

    if (com == 'x')
      i_execute_instruction
    end

    if (com == 'r')
      i_resume_execution
    end

    if (com == 'p')
      i_print
    end

    if (com == '?')
      i_debug_info
    end
    
  end

  def parse_backward com
    com.slice!(0) # eat first character
    com.strip!
    n_skip = com.to_i
    n_skip.downto(0) do
      i_step_backward
    end
    
  end
  
  def debug_bytecode_nop
    puts "\tNOP"
  end

  def debug_bytecode_print
    puts "\tPRINT.#{self.stack.last.to_s}"
  end

  def debug_bytecode_cons
    puts "\tCONS"
  end

  def debug_bytecode_pop
    puts "\tPOP"
  end

  def debug_bytecode_jmp
    puts "\tJMP"
  end

  def debug_bytecode_jms
    puts "\tJMS"
  end

  def debug_bytecode_jiz
    puts "\tJIZ"
  end

  def debug_bytecode_text
    puts "\tTEXT"
  end

  def debug_bytecode_and
    puts "\tAND"
  end

  def debug_bytecode_not
    puts "\tNOT"
  end

  def debug_bytecode_swap
    puts "\tSWAP"
  end

  def debug_bytecode_dup
    puts "\tDUP"
  end

  def debug_bytecode_rswp
    puts "\tRSWP"
  end

  def debug_bytecode_iswp
    puts "\tISWP"
  end

  def debug_bytecode_dec
    puts "\tDEC\t\t\tDEPRECATED!!"
  end

  def debug_bytecode_add
    puts "\tADD"
  end

  def debug_bytecode_sub
    puts "\tSUB"
  end

  def debug_bytecode_mul
    puts "\tMUL"
  end

  def debug_bytecode_div
    puts "\tDIV"
  end

  def debug_bytecode_cray
    puts "\tCRAY"
  end

  def debug_bytecode_jvm
    puts "\tCOFFEETIME"
  end

  def debug_bytecode_exit
    puts "\tEXIT"
  end

  def debug_bytecode_ret
    puts "\tRET"
  end

  def debug_bytecode_call
    puts "\tCALL"
  end

  def debug_bytecode_cls
    puts "\tCLS"
  end

  def debug_bytecode_load
    puts "\tLOAD"
  end

  def debug_bytecode_fetch
    puts "\tFETCH"
  end

  def debug_bytecode_peek
    puts "\tPEEK"
  end

  
  def i_debug_info
    puts VMInfo::DEBUG_INFO
  end

  def i_print
    puts VMInfo::PRINT_STACK + "\t[0x#{i_to_hex(@stack[@stack_ptr])}]"
  end

  def i_down_stack
    print VMInfo::DOWN_STACK
    self.set_stack_ptr (self.stack_ptr - 1) unless self.stack_ptr == -100
    print "\t[#{self.stack_ptr}]\n"
  end

  def i_up_stack
    print VMInfo::UP_STACK
    self.set_stack_ptr (self.stack_ptr + 1) unless self.stack_ptr == -1
    print "\t[#{self.stack_ptr}]\n"
  end
  
  def i_toggle_debug
    # toggle debug
    if @debug then @debug = false else @debug = true end
  end
  
  def i_halt
      @running = false
      puts VMInfo::HALT
  end
  
  def i_isp
    puts VMInfo::PRINT_ISP + "_#{self.isp}@[0x#{i_to_hex(peek_instr)}]."
  end
  
  def i_step_forward
      puts VMInfo::STEP_FORWARD
      step()
  end
  
  def i_step_backward
      puts VMInfo::STEP_BACKWARD
      step_back()
  end

  def i_peek_instruction
    puts VMInfo::PEEK_INSTR peek_instr
  end

  def i_execute_instruction
    puts VMInfo::EXEC_INSTR peek_instr
    interpret()
  end

  def i_resume_execution
    if self.interpreting == false then
      puts VMInfo::RESUME_EXECUTION
      sleep 1
      self.start_interpreter
    end
  end
  
end
