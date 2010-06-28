module Grid 

class Text

  attr_accessor :columns

  def self.parse(line, unpacker)
    result = new
    result.columns = unpacker.unpack(line)
    result
  end

  def columns
    @columns ||= []
  end

  def attributes(unpacker)
    unpacker.headings.zip(columns).inject({}) { |h, (heading, col)| h[heading] = col; h }
  end

  # XXX - (c|sh)ould be made more robust
  def +(other)
    result = self.dup
    i = 0
    other.columns.each { |col|
      result.columns[i] = [result.columns[i] , col ].join(' ').strip if col.size > 0
      i+=1
    }
    result
  end

  def nil?
    columns.select { |col| col.nil? }.size > 0
  end

  def started?
    !columns[0].nil? and columns[0].size > 0
  end

  def to_s
    "<##{self.class.name}: #{columns.join(' : ')}>"
  end
end

class Unpacker
  # Used on a per grid basis to unpack lines of text in the grid based on given columns
  # in the unpack_str and header_re

  attr_reader :header_re

  def initialize(header_re)
    @header_re = header_re
    @unpack_str = "A%d " * header_re.source.scan(/\(/).size + "A**"
  end

  def headings
    (header_re.source.scan(/\((.*?)\\s\*\)/) + header_re.source.scan(/([^)]+)$/)).flatten.collect { |h|
      h.downcase.gsub(' ', '_').gsub('.', '_').gsub('__', '_').to_sym
    }
  end
  # This measures the widths of each column using this header line to constuct a fmt,
  # which is then used to unpack each following line in the grid
  def align(header_line)
    #puts "header_line = #{header_line.inspect}" if ENV['DEBUG']
    @fmt = @unpack_str % header_line.scan(@header_re).first.collect { |group| group.size }
  end

  def unpack(line)
    line.unpack(@fmt).collect { |x| x.strip }
  end
end

end
