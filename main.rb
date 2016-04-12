require './scanner.rb'
require './eval.rb'
require './typing.rb'

$parser = Calcp.new

def repl(env,tyenv)
  print '# '
  str = gets.chop!
  begin
  	decl = $parser.parse(str)
    res = evalDecl(decl, env)
    ty = checkDecl(decl,tyenv)
    id = res[0];newenv = res[1]; v = res[2]
    newtyenv = ty[0]
    tystr = ty[1].display
begin
    tyvar = getFreshTyvar(ty[1]).uniq
  if tyvar != []
    tyalpha = ("a".."zzzz").take(tyvar.length).map do 
      |e| e = "'" + e
    end
    pair = tyvar.zip(tyalpha)
    pair.each do |e|
      tystr.gsub!(e[0].to_s,e[1])
    end
  end
end
    puts "val #{id} : #{tystr} = #{v}"
    repl(newenv,newtyenv)
    rescue ParseError
    puts $!
    repl(env,tyenv)
  　rescue
    puts $!
    repl(env,tyenv)
  end
end

a = [Tyvar.new(1),Tyvar.new(2),Tyvar.new(3)]
b = [Tyvar.new(1),Tyvar.new(3)]

puts
puts 'type "Q" to quit.'
puts

repl([],[])

