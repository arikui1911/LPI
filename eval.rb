require './scanner.rb'
require './syntax.rb'
require './environment.rb'

def evalExp(exp, env)
	case exp
	when Binexp
		arg1 = evalExp(exp.exp1, env); arg2 = evalExp(exp.exp2, env)
		case exp.binop
		when "+"
		    arg1 + arg2
		when "*" 
			arg1 * arg2
		when "-" 
			arg1 - arg2
	    when "/" 
			arg1 / arg2
		when "<"
			arg1 < arg2
		when ">"
			arg1 > arg2
		else "error"
		end
	when Ifexp
		evalExp(exp.cond, env) ? evalExp(exp.exp1, env) : evalExp(exp.exp2, env)
	when Symbol
		ret = env.assoc(exp)[1]
		if ret == [] then raise "unbound value #{exp}" else ret end
	when Funexp
		ProcV.new(exp.id,exp.exp,env)
	when Appexp
		exp1 = exp.exp1; exp2 = exp.exp2
		funval = evalExp(exp1,env)
		arg = evalExp(exp2,env)
			case funval
			when ProcV
				id = funval.id
				body = funval.exp
				env2 = funval.dnval
				newenv = [[id,arg]] + env2
				return evalExp(body,newenv)
			else return 
			end
	when Letexp
		id = exp.id; exp1 = exp.exp1; exp2 = exp.exp2
		value = evalExp(exp1, env)
		evalExp(exp2, [[id,value]] + env)
	when Fixexp
		id = exp.id1; param = exp.id2; exp1 = exp.exp1; exp2 = exp.exp2
		newenv = [[id, ProcV.new(param,exp1,[])]] + env
		newenv[0][1].changeDnval(newenv)
		evalExp(exp2,newenv)
	when IntV, BoolV
		exp.val
	else 
		#p "else!"
		exp
	end
end

def evalDecl(exp, env)
	case exp
	when Decl
      id = exp.id; e = exp.exp
      v = evalExp(e,env)
      return [id,[[id,v]]+ env,v]
    when Fixdecl
      id = exp.id1; param = exp.id2; e = exp.exp
      newenv = [[id, ProcV.new(param,e,[])]] + env
	  newenv[0][1].changeDnval(newenv)
	  return [id,newenv, ProcV.new(param,e,[])]
	else 
	  v = evalExp(exp, env)
	  return ["-",env,v]
	end 
end