RESERVED = {
'if' => :IF,'else' => :ELSE,'then' => :THEN,'true' => :TRUE,'false' => :FALSE, 'fix' => :FIX,
'let' => :LET,'in' => :IN,'fun' => :FUN,"->" => :ARROW,"(" => :LPAREN,")" => :RPAREN,
"=" => :EQ, "+" => :PLUS, "-" => :MINUS, "*" => :MULT,"\/" => :div,
"<" => :LT, ">" => :GT
}

RESERVED_V = {
'true' => true,
'false' => false,
'nil' => nil
}

class Exp
end

class Binexp < Exp
  attr_accessor :binop,:exp1,:exp2
  
  def initialize(binop,exp1,exp2)
	  @binop = binop
	  @exp1 = exp1
	  @exp2 = exp2
  end
end

class Ifexp < Exp
  attr_accessor :cond,:exp1,:exp2
  
  def initialize(cond,exp1,exp2)
	  @cond = cond
	  @exp1 = exp1
	  @exp2 = exp2
  end
end

class Funexp < Exp
  attr_accessor :id,:exp
  
  def initialize(id,exp)
	  @id = id
	  @exp = exp
  end
end

class Appexp < Exp
  attr_accessor :exp1,:exp2
  
  def initialize(exp1,exp2)
	  @exp1 = exp1
	  @exp2 = exp2
  end
end

class Letexp < Exp
  attr_accessor :id,:exp1,:exp2
  
  def initialize(id,exp1,exp2)
    @id = id
    @exp1 = exp1
    @exp2 = exp2
  end
end

class Exval < Exp
  attr_accessor :val

  def initialize(val)
    @val = val
  end
end

class IntV < Exval
end

class BoolV < Exval
end

class ProcV < Exval
 attr_accessor :id, :exp, :dnval

 def initialize(id,exp,dnval)
  @id = id
  @exp = exp
  @dnval = dnval
 end

  def to_s
    "<fun>"
  end


  def changeDnval(exp)
   @dnval = exp
  end
end

class Fixexp < Exp
  attr_accessor :id1,:id2,:exp1,:exp2

  def initialize(id1,id2,exp1,exp2)
    @id1 = id1
    @id2 = id2
    @exp1 = exp1
    @exp2 = exp2
  end

end

class Decl
  attr_accessor :id,:exp

  def initialize(id,exp)
  	@id = id
  	@exp = exp
  end
end

class Fixdecl
  attr_accessor :id1,:id2,:exp

  def initialize(id1,id2,exp)
    @id1 = id1
    @id2 = id2
    @exp = exp
  end
end

class Typescheme
  attr_accessor :tyvarls, :ty

  def initialize(ls,type)
    @tyvarls = ls
    @ty = type
  end

  def freevar
    ftv =getFreshTyvar(@type)
    ftv ? ftv - @tyvarls : []
  end

  def iseq(type)
    @tyvarls == type.tyvarls && @ty == type.ty
  end
end



class Type < Typescheme
  def type
    self.class
  end

  def iseq(type2)
    case self
    when Tyint
      Tyint === type2
    when Tybool
      Tybool === type2
    when Tyvar 
       Tyvar  === type2 && self.tyvar == type2.tyvar
    when Tyfun
       Tyfun === type2 && self.pty.iseq(type2.pty) && self.rty.iseq(type2.rty)
    else false
    end
  end
end

class Tyint < Type
  def initialize
  end
  def display
    return "int"
  end
end

class Tybool < Type
  def initialize
  end
  def display
    return "bool"
  end
end

class Tyvar < Type
  attr_accessor :tyvar
  
  def initialize(num)
   @tyvar = num
  end

  def display
    @tyvar
  end

end

class Tyfun < Type
  attr_accessor :pty,:rty
  
  def initialize(pty,rty)
    @pty = pty
    @rty = rty
  end

  def display
    "(#{pty.display} -> #{rty.display})"
  end
end

$counter = 0

def fresh
  $counter = $counter + 1
end  

def getFreshTyvar(type)
  case type
  when Tyint,Tybool
    []
  when Tyfun
    ([getFreshTyvar(type.pty)] + [getFreshTyvar(type.rty)]).flatten
  when Tyvar
    [type.tyvar]
  end
end

def subset(g1,g2)
  copy = g2
  g1.each do |e|
  copy.reject!{|item| e.iseq(item)}
  return copy 
  end
end

def tyscOf(ty)
  Typescheme.new([],ty)
end

