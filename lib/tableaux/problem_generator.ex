defmodule ProblemGenerator do
  def generate(:php, n) do
    left =
      0..n
      |> Enum.map(fn i -> 0..(n - 1) |> Enum.map(fn j -> "p#{i + 1}_#{j + 1}" end) end)
      |> Enum.map_join("&", fn l -> round_bracket(l, "|") end)
      |> (&"(#{&1})").()

    right =
      right_list(n)
      |> Enum.join("|")

    left <> " |- " <> right
  end

  def right_list(n) do
    for(i <- 0..n, j <- 0..(n - 1), k <- 0..n, do: {i, j, k})
    |> Enum.filter(fn {i, _j, k} -> i < k end)
    |> Enum.sort_by(fn {_i, j, _k} -> j end)
    |> Enum.map(fn {i, j, k} -> "(p#{i + 1}_#{j + 1}&p#{k + 1}_#{j + 1})" end)
  end

  def round_bracket(l, op) do
    Enum.reverse(l)
    |> round_bracket_rec(op)
  end

  def round_bracket_rec([p], _) do
    p
  end

  def round_bracket_rec([p | t], op) do
    "(" <> round_bracket_rec(t, op) <> op <> p <> ")"
  end
end
