#!/usr/bin/env ruby
require "./bc"

class VirtualMachine

  
  def initialize()
    @instructions = Array.new
    @stack = Array.new
    @stack.push(0)
    @isp = 0
    @sp = 0
    @debug = false
    @running = false
  end

  
  def pretty_print_instructions
    puts "\t\t --- instructions --- \n" + @instructions.to_s
  end
  
  def step
    if @debug then puts "Stepping" end
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
     if @debug then  puts instr end
      case instr
      when Bytecode::NOP
        if @debug then puts "NOP" end

      when Bytecode::PEEK
        if @debug then puts "PEEK" end
        puts @stack.peek.to_s

      when Bytecode::PRINT
        if @debug then puts "PRINT" end
        print @stack.pop.to_s

      when Bytecode::CONS
        if @debug then puts "CONS" end
        a = fetch()
        @stack.push(a)

      when Bytecode::POP
        if @debug then puts "POP" end
        @stack.pop()

      when Bytecode::JMP
        if @debug then puts "JMP" end
        addr = fetch()
        @isp = addr
        
      when Bytecode::TEXT
        if @debug then puts "TEXT" end
        print @stack.pop.chr
        $stdout.flush()

      when Bytecode::SWAP
        if @debug then puts "SWAP" end
        last = @stack.pop()
        older = @stack.pop()
        @stack.push(last).push(older)

      when Bytecode::DEC
        a = @stack.pop()
        @stack.push(a-1)

      when Bytecode::ADD
        a = @stack.pop()
        b = @stack.pop()
        @stack.push(b+a)

      when Bytecode::SUB
        a = @stack.pop()
        b = @stack.pop()
        @stack.push(b-a)

      when Bytecode::MUL
        a = @stack.pop()
        b = @stack.pop()
        @stack.push(b*a)

      when Bytecode::DIV
        a = @stack.pop()
        b = @stack.pop()
        @stack.push(b/a)

      when Bytecode::CRAY
        #TODO: Malbolge crazy operator

      when Bytecode::EXIT
        if @debug then puts "EXIT" end
        @running = false

      else
        #curse programmer in hex
        puts "Error on instruction #{instr.to_s(16)}"
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
    puts "Program length: #{@instructions.length} instructions"
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
