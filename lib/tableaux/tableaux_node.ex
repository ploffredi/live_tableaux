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

  @spec to_tableaux_nodes([Expressions.expr()], integer(), integer()) :: [TableauxNode.t()]
  def to_tableaux_nodes([expression], step, idx) do
    [
      %TableauxNode{
        expression: expression,
        string: Expressions.expression_to_string(expression),
        sign: :F,
        step: step,
        nid: idx,
        source: nil,
        closed: false
      }
    ]
  end

  def to_tableaux_nodes([expression | t], step, idx) do
    [
      %TableauxNode{
        expression: expression,
        nid: idx,
        sign: :T,
        source: nil,
        step: step,
        string: Expressions.expression_to_string(expression),
        closed: false
      }
      | to_tableaux_nodes(t, step, idx + 1)
    ]
  end
end
