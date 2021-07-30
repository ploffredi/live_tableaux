defmodule RuleNode do
  @type rule :: :alpha | :beta | :atom
  @type t :: %RuleNode{
          expression: Expressions.expr(),
          string: binary(),
          source: nil | binary(),
          step: integer(),
          sign: :T | :F,
          nid: binary(),
          closed: boolean()
        }

  defstruct [:expression, :string, :source, :step, :sign, nid: nil, closed: false]
end
