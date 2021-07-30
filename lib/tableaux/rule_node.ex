defmodule RuleNode do
  @type rule :: :alpha | :beta | :atom
  @type t :: %RuleNode{
          expression: Expressions.expr(),
          string: binary(),
          source: binary(),
          step: integer(),
          sign: :T | :F,
          nid: binary()
        }

  defstruct [:expression, :string, :source, :step, :sign, nid: nil]
end
