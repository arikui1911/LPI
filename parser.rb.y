class Calcp
  prechigh
    left '->'
    right '^'
    left '*' '/'
    left '+' '-'
  preclow
rule

  target: Expr
        | /* none */ { result = 0 }
        | LET IDENT EQ Expr { result = Decl.new(val[1],val[3])}
        | FIX IDENT EQ FUN IDENT ARROW Expr { result = Fixdecl.new(val[1],val[4],val[6])}
  
  Expr: IfExpr
      | RelExpr
      | LetExpr
      | FunExpr
      | FixExpr

  FixExpr: FIX IDENT EQ FUN IDENT ARROW Expr IN Expr { result = Fixexp.new(val[1],val[4],val[6],val[8])}

  LetExpr: LET IDENT EQ Expr IN Expr { result = Letexp.new(val[1],val[3],val[5])}

  FunExpr: FUN IDENT ARROW Expr { result = Funexp.new(val[1],val[3]) }

  RelExpr: ASExpr LT ASExpr { result = Binexp.new('<',val[0],val[2])}
         | ASExpr GT ASExpr { result = Binexp.new('>',val[0],val[2])}
         | ASExpr

  ASExpr: ASExpr PLUS MDExpr { result = Binexp.new('+',val[0],val[2])}
        | ASExpr MINUS MDExpr { result = Binexp.new('-',val[0],val[2])}
        | MDExpr

  MDExpr: MDExpr MULT AppExpr { result = Binexp.new('*',val[0],val[2])}
        | MDExpr DIV AppExpr { result = Binexp.new('/',val[0],val[2])}
        | AppExpr

  AppExpr: AppExpr AExpr { result = Appexp.new(val[0],val[1])}
         | AExpr

  IfExpr: IF Expr THEN Expr ELSE Expr { result = Ifexp.new(val[1],val[3],val[5])}

  AExpr: LPAREN Expr RPAREN { result = val[1] }
       | NUMBER {result = IntV.new(val[0])}
       | boolean
       | IDENT

  boolean: TRUE { result = BoolV.new("true") }
         | FALSE { result = BoolV.new("false") }
end

