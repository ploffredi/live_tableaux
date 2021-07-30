defmodule RuleNode do
  @type rule :: :alpha | :beta | :atom
  @type t :: %RuleNode{
          expression: any,
          string: binary(),
          source: binary(),
          step: integer(),
          sign: :T | :F,
          nid: binary()
        }

  defstruct [:expression, :string, :source, :step, :sign, nid: nil]
end
