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

    when "?"
      puts VMInfo::DEBUG_INFO
      
    when "p"
      puts VMInfo::PRINT_STACK + "\t[0x#{i_to_hex(@stack[@stack_ptr])}]"
      
    when "j"
      print VMInfo::DOWN_STACK
      self.set_stack_ptr (self.stack_ptr - 1) unless self.stack_ptr == -100
      print "\t[#{self.stack_ptr}]\n"
      
    when "k"
      print VMInfo::UP_STACK
      self.set_stack_ptr (self.stack_ptr + 1) unless self.stack_ptr == -1
      print "\t[#{self.stack_ptr}]\n"
      
    when "d"
      # toggle debug
      if @debug then @debug = false else @debug = true end
      
    when "h"
      @running = false
      puts VMInfo::HALT
    when "i"
      puts VMInfo::PRINT_ISP + "_#{self.isp}@[0x#{i_to_hex(peek_instr)}]."
    when "f"
      puts VMInfo::STEP_FORWARD
      step()
    when "b"
      puts VMInfo::STEP_BACKWARD
      step_back()
    when "n"
      puts VMInfo::PEEK_INSTR peek_instr
    when "x"
      puts VMInfo::EXEC_INSTR peek_instr
      interpret()  
    when "r"
      if self.interpreting == false then
        puts VMInfo::RESUME_EXECUTION
        sleep 1
        self.start_interpreter
      end

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
    puts com
    if (com == ":") then raise RuntimeError.new end
    if (com.start_with?("b"))
      skip_n = Readline.readline("lines?\n: ", true).to_i
      @isp -= skip_n
    end
    if (com == "q")
      self.halt_vm()
    end
    
  end
  

  def debug_bytecode_nop
    puts "\tNOP"
  end

  def debug_bytecode_print
    puts "\tPRINT.#{self.stack.last.to_s}"
  end

  def debug_bytecode_cons
  end

  def debug_bytecode_pop
  end

  def debug_bytecode_jmp
  end

  def debug_bytecode_jms
  end

  def debug_bytecode_jiz
  end

  def debug_bytecode_text
  end

  def debug_bytecode_and
  end

  def debug_bytecode_not
  end

  def debug_bytecode_swap
  end

  def debug_bytecode_dup
  end

  def debug_bytecode_rswp
  end

  def debug_bytecode_iswp
  end

  def debug_bytecode_dec
  end

  def debug_bytecode_add
  end

  def debug_bytecode_sub
  end

  def debug_bytecode_mul
  end

  def debug_bytecode_div
  end

  def debug_bytecode_cray
  end

  def debug_bytecode_jvm
    puts "\tCOFFEETIME"
  end

  def debug_bytecode_exit
    puts "\tEXIT"
  end

  def debug_bytecode_ret
  end

  def debug_bytecode_call
  end

  def debug_bytecode_cls
  end

  def debug_bytecode_load
  end

  def debug_bytecode_fetch
  end

  def debug_bytecode_peek
  end
  
end
