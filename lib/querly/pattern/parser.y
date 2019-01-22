class Querly::Pattern::Parser
prechigh
  nonassoc EXCLAMATION
  nonassoc LPAREN
  left DOT
preclow

rule

target: kinded_expr

kinded_expr: expr { result = Kind::Any.new(expr: val[0]) }
  | expr CONDITIONAL_KIND { result = Kind::Conditional.new(expr: val[0], negated: val[1]) }
  | expr DISCARDED_KIND { result = Kind::Discarded.new(expr: val[0], negated: val[1]) }

expr: constant { result = Expr::Constant.new(path: val[0]) }
  | send
  | SELF { result = Expr::Self.new }
  | EXCLAMATION expr { result = Expr::Not.new(pattern: val[1]) }
  | BOOL { result = Expr::Literal.new(type: :bool, values: val[0]) }
  | literal { result = val[0] }
  | literal AS META { result = val[0].with_values(resolve_meta(val[2])) }
  | DSTR { result = Expr::Dstr.new() }
  | UNDERBAR { result = Expr::Any.new }
  | NIL { result = Expr::Nil.new }
  | LPAREN expr RPAREN { result = val[1] }
  | IVAR { result = Expr::Ivar.new(name: val[0]) }

literal:
    STRING { result = Expr::Literal.new(type: :string, values: val[0]) }
  | INT { result = Expr::Literal.new(type: :int, values: val[0]) }
  | FLOAT { result = Expr::Literal.new(type: :float, values: val[0]) }
  | SYMBOL { result = Expr::Literal.new(type: :symbol, values: val[0]) }
  | NUMBER { result = Expr::Literal.new(type: :number, values: val[0]) }
  | REGEXP { result = Expr::Literal.new(type: :regexp, values: nil) }

args:  { result = nil }
  | expr { result = Argument::Expr.new(expr: val[0], tail: nil)}
  | expr COMMA args { result = Argument::Expr.new(expr: val[0], tail: val[2]) }
  | AMP expr { result = Argument::BlockPass.new(expr: val[1]) }
  | kw_args
  | DOTDOTDOT { result = Argument::AnySeq.new }
  | DOTDOTDOT COMMA args { result = Argument::AnySeq.new(tail: val[2]) }
  | DOTDOTDOT COMMA kw_args { result = Argument::AnySeq.new(tail: val[2]) }

kw_args: { result = nil }
  | AMP expr { result = Argument::BlockPass.new(expr: val[1]) }
  | DOTDOTDOT { result = Argument::AnySeq.new }
  | key_value { result = Argument::KeyValue.new(key: val[0][:key],
                                                value: val[0][:value],
                                                tail: nil,
                                                negated: val[0][:negated]) }
  | key_value COMMA kw_args { result = Argument::KeyValue.new(key: val[0][:key],
                                                              value: val[0][:value],
                                                              tail: val[2],
                                                              negated: val[0][:negated]) }

key_value: keyword COLON expr { result = { key: val[0], value: val[2], negated: false } }
  | EXCLAMATION keyword COLON expr { result = { key: val[1], value: val[3], negated: true } }

method_name: METHOD
  | EXCLAMATION
  | AS
  | META { result = resolve_meta(val[0]) }

method_name_or_ident: method_name
  | LIDENT
  | UIDENT

keyword: LIDENT | UIDENT

constant: UIDENT { result = [val[0]] }
  | UIDENT COLONCOLON constant { result = [val[0]] + val[2] }

send: LIDENT block { result = val[1] != nil ? Expr::Send.new(receiver: nil, name: val[0], args: Argument::AnySeq.new, block: val[1]) : Expr::Vcall.new(name: val[0]) }
  | UIDENT block { result = Expr::Send.new(receiver: nil, name: val[0], block: val[1]) }
  | method_name { result = Expr::Send.new(receiver: nil, name: val[0], block: nil) }
  | method_name_or_ident LPAREN args RPAREN block { result = Expr::Send.new(receiver: nil,
                                                                            name: val[0],
                                                                            args: val[2],
                                                                            block: val[4]) }
  | receiver method_name_or_ident block { result = Expr::Send.new(receiver: val[0],
                                                                  name: val[1],
                                                                  args: Argument::AnySeq.new,
                                                                  block: val[2]) }
  | receiver method_name_or_ident block { result = Expr::Send.new(receiver: val[0],
                                                                  name: val[1],
                                                                  args: Argument::AnySeq.new,
                                                                  block: val[2]) }
  | receiver method_name_or_ident LPAREN args RPAREN block { result = Expr::Send.new(receiver: val[0],
                                                                                     name: val[1],
                                                                                     args: val[3],
                                                                                     block: val[5]) }
  | receiver method_name_or_ident LPAREN args RPAREN block { result = Expr::Send.new(receiver: val[0],
                                                                                     name: val[1],
                                                                                     args: val[3],
                                                                                     block: val[5]) }

receiver: expr DOT { result = val[0] }
  | expr DOTDOTDOT { result = Expr::ReceiverContext.new(receiver: val[0]) }

block: { result = nil }
  | WITH_BLOCK { result = true }
  | WITHOUT_BLOCK { result = false }

end

---- inner

require "strscan"

attr_reader :input
attr_reader :where

def initialize(input, where:)
  super()
  @input = StringScanner.new(input)
  @where = where
end

def self.parse(str, where:)
  self.new(str, where: where).do_parse
end

def next_token
  input.scan(/\s+/)

  case
  when input.eos?
    [false, false]
  when input.scan(/true\b/)
    [:BOOL, true]
  when input.scan(/false\b/)
    [:BOOL, false]
  when input.scan(/nil/)
    [:NIL, false]
  when input.scan(/:string:/)
    [:STRING, nil]
  when input.scan(/:dstr:/)
    [:DSTR, nil]
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
  when input.scan(/:regexp:/)
    [:REGEXP, nil]
  when input.scan(/:\w+/)
    s = input.matched
    [:SYMBOL, s[1, s.size - 1].to_sym]
  when input.scan(/as\b/)
    [:AS, :as]
  when input.scan(/{}/)
    [:WITH_BLOCK, nil]
  when input.scan(/!{}/)
    [:WITHOUT_BLOCK, nil]
  when input.scan(/[+-]?[0-9]+\.[0-9]/)
    [:FLOAT, input.matched.to_f]
  when input.scan(/[+-]?[0-9]+/)
    [:INT, input.matched.to_i]
  when input.scan(/\_/)
    [:UNDERBAR, input.matched]
  when input.scan(/[A-Z]\w*/)
    [:UIDENT, input.matched.to_sym]
  when input.scan(/self/)
    [:SELF, nil]
  when input.scan(/'[a-z]\w*/)
    s = input.matched
    [:META, s[1, s.size - 1].to_sym]
  when input.scan(/[a-z_](\w)*(\?|\!|=)?/)
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
    [:EXCLAMATION, input.matched.to_sym]
  when input.scan(/\[conditional\]/)
    [:CONDITIONAL_KIND, false]
  when input.scan(/\[!conditional\]/)
    [:CONDITIONAL_KIND, true]
  when input.scan(/\[discarded\]/)
    [:DISCARDED_KIND, false]
  when input.scan(/\[!discarded\]/)
    [:DISCARDED_KIND, true]
  when input.scan(/\[\]=/)
    [:METHOD, :"[]="]
  when input.scan(/\[\]/)
    [:METHOD, :"[]"]
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
  when input.scan(/&/)
    [:AMP, nil]
  end
end

def resolve_meta(name)
  where[name] or raise Racc::ParseError, "Undefined meta variable: '#{name}"
end
