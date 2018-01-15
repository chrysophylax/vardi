#!/usr/bin/env ruby
require_relative "bc"
require_relative "m"
require_relative "messages"
require_relative "rf"


class VirtualMachine
  include Inspector
  attr_accessor :instructions, :interpreting, :running,
                :max_stack_depth, :memory
  attr_reader :stack_ptr, :isp, :cycles, :max_stack_depth, :stack
  
  def initialize()
    @max_stack_depth = 100
    @instructions = Array.new
    @memory = Memory.new
    @returns = Array.new(size=100, default=0)
    @cycles = 0
    @stack = Array.new(size=100, default=0)
    @isp = 0
    @debug = false
    @interactive = false
    @interpreting = false # i.e. interpreting
    @running = true # main program operation
    @stack_ptr = -1 # "last element"

  end

  
  def halt_vm()
    @running = false
    puts "Halting vardi..."
  end
  def start_vm()
    @running = true
    program_loop
  end

  def start_interpreter()
    @interpreting = true
    program_loop
  end
  
  def halt_interpreter()
    @interpreting = false
  end

  
  def set_stack_ptr val 
    @stack_ptr = val unless val == @max_stack_depth
  end
  
  def pretty_print_instructions
    puts VMInfo::PP_INSTRUCTIONS + @instructions.to_s
  end
  
  def step
    @isp +=1 
  end
  
  def step_back
    @isp -= 1 unless @isp == 0
  end

  def fetch()
    if  @isp == @instructions.length then return -1 end
    val = @instructions[@isp]
    step()
    return val
  end

  def peek_instr
    if  @isp == @instructions.length then return -1 end
    val = @instructions[@isp]
    return val 
  end

  def i_to_hex i
    return i.to_s(16).upcase
  end

  def bytecode_exit
    if @debug then debug_bytecode_exit end
    halt_interpreter()
    halt_vm() unless @interactive
  end
    
  def interpret()
    @cycles += 1

    #fetch
    instr = fetch()

    #decode
    case instr
    when -1
      puts "Overran!"
      bytecode_exit
    when Bytecode::NOP
      if @debug then debug_bytecode_nop end
      
    when Bytecode::PEEK
      if @debug then debug_bytecode_peek end
      puts @stack.last.to_s

    when Bytecode::PRINT
      if @debug then debug_bytecode_print  end
      print @stack.pop.to_s

    when Bytecode::CONS
      a = fetch()
      @stack.push(a)
      if @debug then debug_bytecode_cons end
      #if @debug then puts "\tCONS.#{@stack.last.to_s}" end
      
    when Bytecode::POP
      if @debug then debug_bytecode_pop end
      @stack.pop()
      
    when Bytecode::JMP
      if @debug then debug_bytecode_jmp end
      addr = fetch()
      @isp = addr

    when Bytecode::JMS
      if @debug then debug_bytecode_jms end
      upper = @stack.pop().to_s(16)
      lower = @stack.pop().to_s(16)
      addr = (upper + lower).to_i(16)
      @isp = addr

    when Bytecode::JIZ
      if @debug then debug_bytecode_jiz end
      v = @stack.last()
      if v == 0
        addr = fetch()
        @isp = addr
        if @debug then puts "TRUE" end
      elsif
        fetch() #skip jmp marker
        if @debug then puts "FALSE" end
      end
      
    when Bytecode::TEXT
      if @debug then debug_bytecode_text end
      print @stack.pop.chr
      $stdout.flush()
    when Bytecode::AND
      if @debug then debug_bytecode_and end
      #pop, AND, push
      a = @stack.pop()
      b = @stack.pop()
      c = a & b
      @stack.push(c)
      
    when Bytecode::NOT
      if @debug then debug_bytecode_not end
      
    when Bytecode::SWAP
      if @debug then debug_bytecode_swap end
      last = @stack.pop()
      older = @stack.pop()
      @stack.push(last).push(older)

    when Bytecode::DUP
      if @debug then debug_bytecode_dup end
      @stack.push(@stack.last)
      
    when Bytecode::RSWP
      if @debug then debug_bytecode_rswp end
      addr = @returns.pop()
      val = @stack.pop()
      @returns.push(val)
      @stack.push(addr)

    when Bytecode::ISWP
#      if @debug then puts "\tISWP.*0x#{@instructions[@isp].to_s(16)}<-0x#{@stack.last.to_s(16)}" end
      if @debug then debug_bytecode_iswp end
      instr = @instructions[@isp]
      val = @stack.pop()
      @stack.push(instr)
      @instructions[@isp] = val
      
    when Bytecode::DEC
      if @debug then debug_bytecode_dec end
      a = @stack.pop()
      @stack.push(a-1)
      
    when Bytecode::ADD
      if @debug then debug_bytecode_add end
      a = @stack.pop()
      b = @stack.pop()
      @stack.push(b+a)

    when Bytecode::SUB
      if @debug then debug_bytecode_sub end
      a = @stack.pop()
      b = @stack.pop()
      @stack.push(b-a)
      if @debug then puts "RES: #{@stack.last()}"end
      
    when Bytecode::MUL
      if @debug then debug_bytecode_mul end
      a = @stack.pop()
      b = @stack.pop()
      @stack.push(b*a)
      
    when Bytecode::DIV
      if @debug then debug_bytecode_div end
      a = @stack.pop()
      b = @stack.pop()
      @stack.push(b/a)
      
    when Bytecode::CRAY
    #TODO: Malbolge crazy operator
      if @debug then debug_bytecode_cray end
      
    when Bytecode::JVM
      #if @debug then puts "\t***COFFEETIME***" end
      if @debug then debug_bytecode_jvm end
      duration = fetch()
      sleep(duration)
      
    when Bytecode::EXIT
      if @debug then debug_bytecode_exit end
      bytecode_exit
      
    when Bytecode::RET
      if @debug then debug_bytecode_ret end
#     if @debug then puts "\tRET.0x#{@returns.last.to_s(16)}" end 
      addr = @returns.pop()
      @isp = addr
      
    when Bytecode::CALL
#      if @debug then puts "\tCALL.*0x#{@instructions[@isp].to_s(16)}<-0x#{(@isp-1).to_s(16)}" end
      if @debug then debug_bytecode_call end
      addr = fetch()
      current = @isp
      @isp = addr
      @returns.push(current)
      
    when Bytecode::CLS
      if @debug then puts "\tCLS.*0x#{@stack.last.to_s(16)}<-0x#{(@isp-1).to_s(16)}" end
      @returns.push(@isp)
      addr = @stack.pop()
      @isp = addr
      
    when Bytecode::LOAD
      if @debug then puts "\tLOAD" end
      upper = @stack.pop().to_s(16)
      lower = @stack.pop().to_s(16)
      addr = (upper + lower).to_i(16)
      value = @stack.pop()
      if @debug then puts "ADDR: #{addr.to_s.hex}\nDATA: #{value}"  end
      @memory.load(addr,value)
      
    when Bytecode::FETCH
      if @debug then puts "\tFETCH" end
      upper = @stack.pop().to_s(16)
      lower = @stack.pop().to_s(16)
      addr = (upper + lower).to_i(16)
      value = @memory.fetch(addr)
      if @debug then puts "ADDR: #{addr.to_s.hex}\nDATA: #{value}" end
      @stack.push(value)
      
    else
      #curse programmer in hex
      puts VMInfo::MAL_INSTR
      puts "#{@isp} -> [#{i_to_hex ( @instructions[@isp] ) }]."
      @running = false
    end


    if (@isp == @instructions.length) then halt_interpreter() end 
    # Let us exit even if programmer forgot to 0x1111
    #if @instructions.length <= @isp then @running = false end
  end
  
  
  def set_flags
    if ARGV.include?("-d")
      @debug = true
    end
    if ARGV.include?("-i")
      @interactive = true
    end
    if ARGV.include?("-h")
      halt_interpreter()
    end

  end

  def program_loop
   while @running
    if @interactive
      handle_input
    end
    if @interpreting
      interpret()
    end
   end
   
  end
  
  def load_file
    file_name = ARGV[0].to_s
    raise RuntimeError.new("No file was given.") unless File.exist?(file_name) && File.readable?(file_name)
    file = IO.read(file_name)
    file.each_byte do |byte|
      @instructions << byte.to_i
    end    
  end

  def print_stats()
    puts "Program length: #{@instructions.length} bytes. Executed #{@cycles} cycles."
  end

  def start
    set_flags
    load_file
    if @debug
      pretty_print_instructions()
    end
    start_interpreter()
    if @debug
      print_stats()
    end
  end


end
