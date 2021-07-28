defmodule Expression do
  @type t :: %Expression{
          type: :atom | :not | :conjunction | :disjunction | :implication,
          e1: t() | nil,
          e2: t() | nil,
          tag: String.t() | nil
        }

  defstruct [:type, :tag, :e1, :e2]

  ?a..?z
  |> Enum.each(fn name ->
    def unquote(:"#{<<name>>}")() do
      %__MODULE__{type: :atom, tag: "#{unquote(<<name>>)}"}
    end
  end)

  def e1 &&& e2 do
    %__MODULE__{type: :conjunction, e1: e1, e2: e2}
  end

  def e1 ||| e2 do
    %__MODULE__{type: :disjunction, e1: e1, e2: e2}
  end

  def e1 >>> e2 do
    %__MODULE__{type: :implication, e1: e1, e2: e2}
  end
  def ~~~ e do
    %__MODULE__{type: :not, e1: nil, e2: e}
  end

  def eval(_tab) do
  end

  def from_string(expr) do
    expr =
      expr
      |> String.replace(">", ">>>")
      |> String.replace("&", "&&&")
      |> String.replace("|", "|||")
      |> String.replace("!", "~~~")
    s = """
import Expression
#{expr}
"""
    {result, _}=Code.eval_string s, [], __ENV__
    result
  end
end
