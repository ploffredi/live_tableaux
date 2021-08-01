defmodule TableauxNode do
  @type t :: %TableauxNode{
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
