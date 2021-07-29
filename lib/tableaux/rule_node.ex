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
    UniqueCounter.increment()
    %RuleNode{
      nid: Integer.to_string(UniqueCounter.get_value)
    }
  end
end
