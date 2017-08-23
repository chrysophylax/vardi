#!/usr/bin/env ruby
require "./bc"
require "./m"

class VirtualMachine

  
  def initialize()
    @instructions = Array.new
    @memory = Memory.new
    @returns = Array.new
    @stack = Array.new
    @stack.push(0)
    @isp = 0
    @debug = false
    @running = false
  end
  
  def pretty_print_instructions
    puts "\t\t --- instructions --- \n" + @instructions.to_s
  end
  
  def step
      @isp +=1
  end

  def fetch()
    val = @instructions[@isp]
    step()
    return val
  end
  def interpret()
    while @running

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
        if @debug then puts "\tCONS" end
        a = fetch()
        @stack.push(a)

      when Bytecode::POP
        if @debug then puts "\tPOP" end
        @stack.pop()
        
      when Bytecode::JMP
        if @debug then puts "\tJMP" end
        addr = fetch()
        @isp = addr

      when Bytecode::JMS
        if @debug then puts "\tJMS" end
        addr = @stack.pop()
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
        if @debug then puts "ADDR: #{addr}\nDATA: #{value}"  end
        @memory.load(addr,value)
        
      when Bytecode::FETCH
        if @debug then puts "\tFETCH" end
        upper = @stack.pop().to_s(16)
        lower = @stack.pop().to_s(16)
        addr = (upper + lower).to_i(16)
        value = @memory.fetch(addr)
        @stack.push(value)
        
      else
        #curse programmer in hex
        puts "Could not understand  #{@isp}: instr. was #{instr.to_s(16)}."
        @running = false
      end

      
      # Let us exit even if programmer forgot to 0x1111
      if @instructions.length <= @isp then @running = false end

    end
    
  end
  
  def set_flags
    if ARGV[1].to_s == "d"
      @debug = true
    end
  end
  
  def load_file
    file_name = ARGV[0].to_s
    raise RuntimeError unless File.exist?(file_name) && File.readable?(file_name)
    file = IO.read(file_name)
    file.each_byte do |byte|
      @instructions << byte.to_i
    end    
  end

  def print_stats()
    puts "Program length: #{@instructions.length} instructions. Executed #{@isp}"
  end
  def start
    set_flags
    load_file
    if @debug
    pretty_print_instructions()
    end
    @running = true
    puts "vardi>"
    interpret()
    if @debug
      print_stats()
    end
  end


end

vm = VirtualMachine.new
vm.start()
