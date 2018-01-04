#!/usr/bin/env ruby
require_relative "bc"
require_relative "m"

class VirtualMachine
  require 'io/console'

  @@ssep = "\t\t\t\t\t\t"

  def handle_key
    STDIN.echo = false
    STDIN.raw!
    c = STDIN.read_nonblock(1) rescue nil
    STDIN.cooked!
    return c
  end

  def handle_input
    k =  handle_key
    case k

    when "p"
      puts "#{@@ssep} stack top -> #{i_to_hex(@stack.last)}."
      
    when "d"
      # toggle debug
      if @debug then @debug = false else @debug = true end
      
    when "h"
      @running = false
    when "i"
      puts "#{@@ssep} instruction pointer is: #{@isp} -> #{i_to_hex(peek_fetch)}."
    when "f"
      puts "#{@@ssep} step increased."
      step()
    when "b"
      puts "#{@@ssep} step decreased."
      step_back()
    when "x"
      interpret()  
    when "r"
      if @running == false then
        puts "#{@@ssep} resuming execution."
        sleep 1
        @running = true
      end
      
    when "q"
      @looping = false
    end
    
    if @running
      interpret()
    end
  end
  


  def initialize()
    @instructions = Array.new
    @memory = Memory.new
    @returns = Array.new
    @cycles = 0
    @stack = Array.new
    @stack.push(0)
    @isp = 0
    @debug = false
    @running = false # i.e. interpreting
    @looping = false # main program operation
  end
  
  def pretty_print_instructions
    puts "\t\t --- instructions --- \n" + @instructions.to_s
  end
  
  def step
    @isp +=1
  end
  
  def step_back
    @isp -= 1 unless @isp == 0
  end

  def peek_fetch
    val = @instructions[@isp]
    return val
  end
  
  def fetch()
    val = @instructions[@isp]
    step()
    return val
  end

  def i_to_hex i
    return i.to_s(16).upcase
  end

  def interpret()
    @cycles += 1
    
    #fetch
    instr = fetch()

    #decode
    case instr
    when Bytecode::NOP
      if @debug then puts "\tNOP" end
      
    when Bytecode::PEEK
      if @debug then puts "\tPEEK" end
      puts @stack.last.to_s

    when Bytecode::PRINT
      if @debug then puts "\tPRINT.#{@stack.last.to_s}" end
      print @stack.pop.to_s

    when Bytecode::CONS
      a = fetch()
      @stack.push(a)
      if @debug then puts "\tCONS.#{@stack.last.to_s}" end
      
    when Bytecode::POP
      if @debug then puts "\tPOP" end
      @stack.pop()
      
    when Bytecode::JMP
      if @debug then puts "\tJMP" end
      addr = fetch()
      @isp = addr

    when Bytecode::JMS
      if @debug then puts "\tJMS" end
      upper = @stack.pop().to_s(16)
      lower = @stack.pop().to_s(16)
      addr = (upper + lower).to_i(16)
      @isp = addr

    when Bytecode::JIZ
      if @debug then puts "\tJIZ" end
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
      if @debug then puts "\tTEXT.#{@stack.last.chr}" end
      print @stack.pop.chr
      $stdout.flush()
    when Bytecode::AND
      if @debug then puts "\tAND" end
      #pop, AND, push
      a = @stack.pop()
      b = @stack.pop()
      c = a & b
      @stack.push(c)
      
    when Bytecode::NOT
    when Bytecode::SWAP
      if @debug then puts "\tSWAP" end
      last = @stack.pop()
      older = @stack.pop()
      @stack.push(last).push(older)

    when Bytecode::DUP
      if @debug then puts "\tDUP" end
      @stack.push(@stack.last)
      
    when Bytecode::RSWP
      if @debug then puts "\tRSWP" end
      addr = @returns.pop()
      val = @stack.pop()
      @returns.push(val)
      @stack.push(addr)

    when Bytecode::ISWP
      if @debug then puts "\tISWP.*0x#{@instructions[@isp].to_s(16)}<-0x#{@stack.last.to_s(16)}" end
      instr = @instructions[@isp]
      val = @stack.pop()
      @stack.push(instr)
      @instructions[@isp] = val
      
    when Bytecode::DEC
      if @debug then puts "\tDEPRECATED: DEC" end
      a = @stack.pop()
      @stack.push(a-1)
      
    when Bytecode::ADD
      if @debug then puts "\tADD" end
      a = @stack.pop()
      b = @stack.pop()
      @stack.push(b+a)
      
    when Bytecode::SUB
      if @debug then puts "\tSUB" end
      a = @stack.pop()
      b = @stack.pop()
      @stack.push(b-a)
      if @debug then puts "RES: #{@stack.last()}"end
      
    when Bytecode::MUL
      if @debug then puts "\tMUL" end
      a = @stack.pop()
      b = @stack.pop()
      @stack.push(b*a)
      
    when Bytecode::DIV
      if @debug then puts "\tDIV" end 
      a = @stack.pop()
      b = @stack.pop()
      @stack.push(b/a)
      
    when Bytecode::CRAY
    #TODO: Malbolge crazy operator
      
    when Bytecode::JVM
      if @debug then puts "\t***COFFEETIME***" end
      duration = fetch()
      sleep(duration)
      
    when Bytecode::EXIT
      if @debug then puts "\tEXIT" end
      @running = false
      
    when Bytecode::RET
      if @debug then puts "\tRET.0x#{@returns.last.to_s(16)}" end
      addr = @returns.pop()
      @isp = addr
      
    when Bytecode::CALL
      if @debug then puts "\tCALL.*0x#{@instructions[@isp].to_s(16)}<-0x#{(@isp-1).to_s(16)}" end
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
      puts "#{@@ssep}Could not understand  #{@isp}: instr. was #{i_to_hex(peek_fetch)}."
      @running = false
    end

    
    # Let us exit even if programmer forgot to 0x1111
    #if @instructions.length <= @isp then @running = false end
  end
  
  
  def set_flags
    if ARGV[1].to_s == "d"
      @debug = true
    end
  end

  def run_loop
    while @running
      interpret()
    end
  end

  def program_loop
    while @looping
      handle_input
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
    @looping = true
    puts "vardi>"
    program_loop
    if @debug
      print_stats()
    end
  end


end
