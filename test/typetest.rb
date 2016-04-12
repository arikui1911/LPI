require 'test/unit'
require './typing.rb'
require './scanner.rb'

TESTS = ["1 + 2",
"-2 * 2",
"1 < 2",
"fun x -> x",
"fun x -> fun y -> x",
"fun x -> fun y -> y",
"(fun x -> x + 1) 2 + (fun x -> x + -1) 3",
"fun f -> fun g -> fun x -> g (f x)",
"fun x -> fun y -> fun z -> x z (y z)",
"fun x -> let y = x + 1 in x",
"fun x -> let y = x + 1 in y",
"fun b -> fun x -> if x b then x else (fun x -> b)",
"fun x -> if true then x else (if x then true else false)",
"fun x -> fun y -> if x then x else y",
"fun n -> (fun x -> x (fun y -> y)) (fun f -> f n)",
"fun x -> fun y -> x y",
"fun x -> fun y -> x (y x)",
"fun x -> fun y -> x (y x) (y x)",
"fun x -> fun y -> fun z -> x (z x) (y (z x y))",
"let id = fun x -> x in let f = fun y -> id (y id) in f",
"let k = fun x -> fun y -> x in let k1 = fun x -> fun y -> k (x k) in k1",
"let s = fun x -> fun y -> fun z -> x z (y z) in let s1 = fun x -> fun y -> fun z -> x s (z s) (y s (z s)) in s1",
"let g = fun h -> fun t -> fun f -> fun x -> f h (t f x) in g",
"let s = fun x -> fun y -> fun z -> x z (y z) in let k = fun x -> fun y -> x in let l = fun x -> fun y -> x in s k l"] 

class TestSample < Test::Unit::TestCase
  class << self
    # テスト群の実行前に呼ばれる．変な初期化トリックがいらなくなる
    def startup
    end

    # テスト群の実行後に呼ばれる
    def shutdown
    end
  end

  # 毎回テスト実行前に呼ばれる
  def setup
  end

  # テストがpassedになっている場合に，テスト実行後に呼ばれる．テスト後の状態確認とかに使える
  def cleanup
  end

  # 毎回テスト実行後に呼ばれる
  def teardown
  end

  def test1  
    $parser = Calcp.new
     p "Checking " + TESTS[22]  
     decl = $parser.parse(TESTS[22])
     ty = checkDecl(decl,[])
  end

end