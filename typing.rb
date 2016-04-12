require './syntax.rb'

def freevar_tyenv(tyenv)
	if tyenv == [] then []
	else 
		tyenv.inject([]) do |acc,item| acc | item[1].freevar end
	end
end

def closure(ty,tyenv,subst)
	fv_tyenv1 = freevar_tyenv(tyenv)
	fv_tyenv2 = fv_tyenv1.map do |id| 
		getFreshTyvar(substType(subst,Tyvar.new(id))) end
	fv_tyenv2.flatten!
	ids = (getFreshTyvar(ty) - fv_tyenv2).uniq
	return Typescheme.new(ids,ty)
end

def assignType(subst,dest)
	id = subst[0]; type = subst[1]
	case dest
	when Tyvar
		dest.tyvar == id ? type : dest
	when Tyfun
		ty1 = dest.pty; ty2 = dest.rty
		Tyfun.new(assignType(subst,ty1),assignType(subst,ty2))
	when Tyint,Tybool
		dest
	end 
end

def substType(substs,type)
	#p substs
	case substs
	when [],nil
	  return type
	else
	  return substType(substs.drop(1),assignType(substs[0],type))
	end 
end

def eqsOfSubst subst
	subst.map do |e|
	 [Tyvar.new(e[0]),e[1]] 
	end
end

def substEqs(subst,tylist)
	tylist.map do |e|
		[substType(subst,e[0]),substType(subst,e[1])]
	 end
end

def checkFtv (tyvar,ty) 
	getFreshTyvar(ty).include?(tyvar)	
end

def solve(ls,stack)
	if ls == [] then return stack else
    ty1 = ls[0][0]; ty2 = ls[0][1]; rest = ls.drop(1)
    #puts "ls = #{ls.inspect}; stack = #{stack}\n\n"
	if ty1.iseq(ty2) then solve(rest,stack) else
		case 
		when Tyfun === ty1 && Tyfun === ty2
			ty11 = ty1.pty; ty12 = ty1.rty
			ty21 = ty2.pty; ty22 = ty2.rty
			solve(([[ty11,ty21]] + [[ty12,ty22]] + rest),stack)
		when Tyvar === ty1
			i = ty1.tyvar
			checkFtv(i,ty2) ?
			raise("type error") : solve(substEqs([[i,ty2]],rest),(stack + [[i,ty2]]))
		when Tyvar === ty2
			i = ty2.tyvar
			checkFtv(i,ty1) ? 
			raise("type error") : solve(substEqs([[i,ty1]],rest),(stack + [[i,ty1]]))
		else raise "match failure #{ty1.inspect} #{ty2.inspect}"
		end
	end
    end
end

def unify(ls)
	solve(ls,[])
end

def checkBinexp(op,exp1,exp2)
	case op
	when "+","-","*","/"
		return ([[[exp1,Tyint.new],[exp2,Tyint.new]],Tyint.new])
	when "<",">"
		return ([[[exp1,Tyint.new],[exp2,Tyint.new]],Tybool.new])
	else raise "undefined"
	end
end

def checkExp(exp,tyenv)
  case exp  
  when Symbol
  	x = exp
  	ret = tyenv.assoc(x)[1]
  	#puts "ret = #{ret.inspect}"
	ty = ret.ty
	vars = ret.tyvarls
	s = vars ? vars.map{|id| [id,Tyvar.new(fresh)]} : vars
=begin
	puts "var = #{x}" 
	puts "s = #{s}" 
	puts "ty = #{ty}\n"
=end
	return [[],substType(s,ty)]
  when IntV
  	[[],Tyint.new]
  when BoolV
    [[],Tybool.new]
  when Binexp
  	op = exp.binop; exp1 = exp.exp1; exp2 = exp.exp2
  	e1 = checkExp(exp1,tyenv)
  	e2 = checkExp(exp2,tyenv)
  	e3 = checkBinexp(op,e1[1],e2[1])
  	eqs = eqsOfSubst(e1[0]) + eqsOfSubst(e2[0])+e3[0] 
  	s3 = unify(eqs)
  	return [s3,substType(s3,e3[1])]
  when Ifexp
    cond = exp.cond; exp1 = exp.exp1; exp2 = exp.exp2
 	e1 = checkExp(cond,tyenv)
  	e2 = checkExp(exp1,tyenv); e3 = checkExp(exp2,tyenv)
  	e4 = [[[e1[1],Tybool.new],[e2[1],e3[1]]],e2[1]]
  	eqs = eqsOfSubst(e1[0]) + eqsOfSubst(e2[0]) + eqsOfSubst(e3[0]) + e4[0]
  	s4 = unify(eqs)
  	return [s4,substType(s4,e4[1])]
  when Letexp
    id = exp.id; exp1 = exp.exp1; exp2 = exp.exp2
  	e1 = checkExp(exp1,tyenv)
  	scheme = closure(e1[1],tyenv,e1[0])
  	#p scheme
  	#newtyenv = [[id,e1[1]]] + tyenv
  	newtyenv = [[id,scheme]] + tyenv
  	e2 = checkExp(exp2,newtyenv)
  	eqs = eqsOfSubst(e1[0]) + eqsOfSubst(e2[0])
  	s3 = unify(eqs)
  	return [s3,substType(s3,e2[1])]
=begin
  when Fixexp
  	id1 = exp.id1; id2 = exp.id2; exp1 = exp.exp1; val = exp.exp2
  	domty = Tyvar.new(fresh)
  	e1 = checkexp(Funexp.new(id2,exp1),[[id,domty]] + tyenv)
  	fty = e1[1]
	newtyenv1 = [[id1,fty]] + tyenv	   		
=end
  when Funexp
  	id = exp.id; exp = exp.exp
  	domty = Tyvar.new(fresh)
  	e = checkExp(exp,[[id,tyscOf(domty)]] + tyenv)
  	s = e[0]; type = e[1]
  	return [s, Tyfun.new(substType(s,domty),type)]
  when Appexp
  	exp1 = exp.exp1; exp2 = exp.exp2
  	ranty = Tyvar.new(fresh)
	e1 = checkExp(exp1,tyenv)
  	e2 = checkExp(exp2,tyenv)
  	e3 = [[[e1[1],Tyfun.new(e2[1],ranty)]],ranty]
  	eqs = eqsOfSubst(e1[0]) + eqsOfSubst(e2[0]) + e3[0] 
  	s4 = unify(eqs)
  	return [s4,substType(s4,e3[1])]
  else return
  end
end

def checkDecl(exp,tyenv)
	case exp
	when Exp 
		e = checkExp(exp,tyenv)
		return [tyenv,e[1]]
	else raise "error"
	end
end
