defmodule TableauxNode do
  @type t :: %TableauxNode{
          expression: Expressions.expr(),
          string: binary(),
          source: nil | integer(),
          step: nil | integer(),
          sign: :T | :F,
          nid: nil | integer(),
          closed: boolean()
        }

  defstruct [:expression, :string, :source, :sign, step: nil, nid: nil, closed: false]
end
