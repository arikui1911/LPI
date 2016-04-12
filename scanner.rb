require './syntax.rb'
require './parser.rb'

class Calcp
  
  def initialize
    @vartab = {}
  end

  def parse(str)
    @q = []
    until str.empty?
      case str
      when /\A\s+/
      when /\A\d+/
        @q.push [:NUMBER, $&.to_i] 
      when /\A[a-zA-Z_]\w*/
        word = $&
        @q.push [(RESERVED[word] || :IDENT),
        RESERVED_V.key?(word) ? RESERVED_V[word] : word.intern ]
      when /->|(\A.|\n)/
        word = $&
        @q.push [(RESERVED[word] || :IDENT),
        RESERVED_V.key?(word) ? RESERVED_V[word] : word.intern ]  
      end
      str = $'
    end
    @q.push [false, '$end']
    do_parse
  end

  def next_token
    @q.shift
  end

end