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

  def empty_with_nid() do
    %RuleNode{
      nid: Nanoid.generate(3, "ABCDEFGHILMNOPQRSTUVWXYZ")
    }
  end
end
