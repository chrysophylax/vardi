#!/usr/bin/env ruby
require_relative 'bc'
module Tools
  class BytecodePrinter
    def initialize
      @bc_lookup_hash = generate_reverse_hash
    end
    
    def generate_reverse_hash
      bytecodes = []
      Bytecode.constants.each { |bc|
        bytecodes << { (Bytecode.const_get bc) => bc }
      }
      bytecodes.reduce({}, :merge)
    end

    def pretty_print(bytes)
      bytes.each { |byte|
        if @bc_lookup_hash[byte] then
          puts @bc_lookup_hash[byte].to_s + "\t\t0x#{byte.to_s(16).upcase}"
        else
          puts "DATA" + "\t\t0x#{byte.to_s(16).upcase}" + "\t\td: #{byte.to_s(10)}" + "\t\ta: #{byte.chr}"
        end
      }
    end

    def run
      output_file?
      load_file
    end

    def output_file?
      if ARGV[1]
        $stdout.reopen(ARGV[1].to_s, "w")
      end
    end
    
    def load_file
      file_name = ARGV[0].to_s
      raise RuntimeError.new("No file was given.") unless File.exist?(file_name) && File.readable?(file_name)
      file = IO.read(file_name)
      pretty_print(file.bytes)
    end     
  end
end

legographs = Tools::BytecodePrinter.new
legographs.run
