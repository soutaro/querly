class Querly::Pattern::Parser
prechigh
  nonassoc EXCLAMATION
  nonassoc LPAREN
  left DOT
preclow

rule

target: expr

expr: constant { result = Expr::Constant.new(path: val[0]) }
  | send
  | EXCLAMATION expr { result = Expr::Not.new(pattern: val[1]) }
  | BOOL { result = Expr::Literal.new(type: :bool, value: val[0]) }
  | STRING { result = Expr::Literal.new(type: :string, value: val[0]) }
  | INT { result = Expr::Literal.new(type: :int, value: val[0]) }
  | FLOAT { result = Expr::Literal.new(type: :float, value: val[0]) }
  | SYMBOL { result = Expr::Literal.new(type: :symbol, value: val[0]) }
  | NUMBER { result = Expr::Literal.new(type: :number, value: val[0]) }
  | UNDERBAR { result = Expr::Any.new }
  | NIL { result = Expr::Nil.new }
  | LPAREN expr RPAREN { result = val[1] }
  | IVAR { result = Expr::Ivar.new(name: val[0]) }

args:  { result = nil }
  | expr { result = Argument::Expr.new(expr: val[0], tail: nil)}
  | expr COMMA args { result = Argument::Expr.new(expr: val[0], tail: val[2]) }
  | kw_args
  | DOTDOTDOT { result = Argument::AnySeq.new }
  | DOTDOTDOT COMMA kw_args { result = Argument::AnySeq.new(tail: val[2]) }

kw_args: { result = nil }
  | DOTDOTDOT { result = Argument::AnySeq.new }
  | key_value { result = Argument::KeyValue.new(key: val[0][:key],
                                                value: val[0][:value],
                                                tail: nil,
                                                negated: val[0][:negated]) }
  | key_value COLON kw_args { result = Argument::KeyValue.new(key: val[0][:key],
                                                              value: val[0][:value],
                                                              tail: val[2],
                                                              negated: val[0][:negated]) }

key_value: LIDENT COLON expr { result = { key: val[0].to_sym, value: val[2], negated: false } }
  | EXCLAMATION LIDENT COLON expr { result = { key: val[1].to_sym, value: val[3], negated: true } }

method_name: LIDENT
  | METHOD

constant: UIDENT { result = [val[0]] }
  | UIDENT COLONCOLON constant { result = [val[0]] + val[2] }

send: method_name { result = Expr::Send.new(receiver: Expr::Any.new, name: val[0]) }
  | method_name LPAREN args RPAREN { result = Expr::Send.new(receiver: Expr::Any.new,
                                                             name: val[0],
                                                             args: val[2]) }
  | expr DOT method_name { result = Expr::Send.new(receiver: val[0], name: val[2], args: Argument::AnySeq.new) }
  | expr DOT method_name LPAREN args RPAREN { result = Expr::Send.new(receiver: val[0],
                                                                      name: val[2],
                                                                      args: val[4]) }
  | UIDENT LPAREN args RPAREN { result = Expr::Send.new(receiver: Expr::Any.new, name: val[0], args: val[2]) }
  | expr DOT UIDENT { result = Expr::Send.new(receiver: val[0], name: val[2], args: Argument::AnySeq.new) }
  | expr DOT UIDENT LPAREN args RPAREN { result = Expr::Send.new(receiver: val[0],
                                                                 name: val[2],
                                                                 args: val[4]) }


end

---- inner

require "strscan"

attr_reader :input

def initialize(input)
  super()
  @input = StringScanner.new(input)
end

def self.parse(str)
  self.new(str).do_parse
end

def next_token
  input.scan /\s+/

  case
  when input.eos?
    [false, false]
  when input.scan(/true/)
    [:BOOL, true]
  when input.scan(/false/)
    [:BOOL, false]
  when input.scan(/nil/)
    [:NIL, false]
  when input.scan(/:string:/)
    [:STRING, nil]
  when input.scan(/:int:/)
    [:INT, nil]
  when input.scan(/:float:/)
    [:FLOAT, nil]
  when input.scan(/:bool:/)
    [:BOOL, nil]
  when input.scan(/:symbol:/)
    [:SYMBOL, nil]
  when input.scan(/:number:/)
    [:NUMBER, nil]
  when input.scan(/:\w+/)
    [:SYMBOL, input.matched.to_sym]
  when input.scan(/[+-]?[0-9]+\.[0-9]/)
    [:FLOAT, input.matched.to_f]
  when input.scan(/[+-]?[0-9]+/)
    [:INT, input.matched.to_i]
  when input.scan(/[A-Z]\w+/)
    [:UIDENT, input.matched.to_sym]
  when input.scan(/[a-z_](\w|=)+(\?|\!)?/)
    [:LIDENT, input.matched.to_sym]
  when input.scan(/\(/)
    [:LPAREN, input.matched]
  when input.scan(/\)/)
    [:RPAREN, input.matched]
  when input.scan(/\.\.\./)
    [:DOTDOTDOT, input.matched]
  when input.scan(/\,/)
    [:COMMA, input.matched]
  when input.scan(/\./)
    [:DOT, input.matched]
  when input.scan(/\!/)
    [:EXCLAMATION, input.matched]
  when input.scan(/\[\]/)
    [:METHOD, :"[]"]
  when input.scan(/\[\]=/)
    [:METHOD, :"[]="]
  when input.scan(/\_/)
    [:UNDERBAR, input.matched]
  when input.scan(/::/)
    [:COLONCOLON, input.matched]
  when input.scan(/:/)
    [:COLON, input.matched]
  when input.scan(/\*/)
    [:STAR, "*"]
  when input.scan(/@\w+/)
    [:IVAR, input.matched.to_sym]
  when input.scan(/@/)
    [:IVAR, nil]
  end
end
