class Memory

  def initialize()
    @memory = Array.new(size=256*256, default=0)
  end

  def load(addr, data)
    
    # 64K addr space, 8 bit data size
    if (addr < 0 || addr > 65536) then puts "\tMEMIAD" end
    if data > 255 then puts "\tMEMISD" end
  
    @memory[addr] = data   
  end

  def fetch(addr)
    if (addr < 0 || addr > 65536) then puts "\tMEMIAD" end
    return @memory[addr]
  end
  
end
