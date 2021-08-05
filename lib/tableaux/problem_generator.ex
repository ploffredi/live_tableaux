defmodule ProblemGenerator do
  def generate(:php, n) do
    "(" <> (0..n
     |> Enum.map(fn p -> 0..(n - 1) |> Enum.map(fn b -> "p#{p+1}_#{b+1}" end) end)
     |> Enum.map(fn l -> round_bracket(l, "|") end)
     |> Enum.join("&")) <>
      ") |- " <>
      ((n - 1)..0
       |> Enum.flat_map(fn c -> fac_list(n - 1, c, []) end)
       |> Enum.join("|"))
      
  end

  def fac_list(n, c, l) do
    0..n
    |> Enum.map(fn i -> (i + 1)..(n + 1) |> Enum.map(&{&1, n - c}) end)
    |> Enum.with_index(fn e, j -> Enum.map(e, fn {e1, e2} -> "(p#{j+1}_#{e2+1}&p#{e1+1}_#{e2+1})" end) end)
    |> Enum.flat_map(& &1)
  end

  def round_bracket(l, op) do
    Enum.reverse(l)
    |> round_bracket_rec(op)
  end

  def round_bracket_rec([p], _) do
    p
  end

  def round_bracket_rec([p | t] = l, op) do
    "(" <> round_bracket_rec(t, op) <> op <> p <> ")"
  end
end
