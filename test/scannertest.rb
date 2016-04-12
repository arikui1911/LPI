require 'test/unit'
require './scanner.rb'

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

  def test_if
    parser = Calcp.new
    str = "if 1 then 2 else 3"
    res = parser.parse(str)
    assert_equal(res.cond.val,1)
    assert_equal(res.exp1.val,2)
    assert_equal(res.exp2.val,3)
  end


  def test_fun
    parser = Calcp.new
    str = "fun p -> p"
    res = parser.parse(str)
    assert_equal(res.id,:p)
    assert_equal(res.exp,:p)
  end

  def test_sub
    parser = Calcp.new
    str = "15 - 5"
    res = parser.parse(str)
    assert_equal(res.binop,"-")
    assert_equal(res.exp1.val,15)
    assert_equal(res.exp2.val,5)
  end

  def test_paren1
    parser = Calcp.new
    str = "(fun p -> p)"
    res = parser.parse(str)
    assert_equal(res.id,:p)
    assert_equal(res.exp,:p)
  end

  def test_paren2
    parser = Calcp.new
    str = "(15 - 5)"
    res = parser.parse(str)
    assert_equal(res.binop,"-")
    assert_equal(res.exp1.val,15)
    assert_equal(res.exp2.val,5)
  end

  def test_decl
    parser = Calcp.new
    str = "let x = 5"
    res = parser.parse(str)
    assert_equal(res.id,:x)
    assert_equal(res.exp.val,5)
  end

  def test_let
    parser = Calcp.new
    str = "let x = 5 in x"
    res = parser.parse(str)
    assert_equal(res.id,:x)
    assert_equal(res.exp1.val,5)
    assert_equal(res.exp2,:x)
  end

  def test_fix
    parser = Calcp.new
    str = "fix f = fun x -> x in (f 5)"
    res = parser.parse(str)
  end
end