defmodule ProblemGenerator do
  @moduledoc """
  Generators for multiple types of logical problems.
  """

  @doc """
  Generates a problem.

  ## Examples

      iex> ProblemGenerator.generate(:php, 1)
      "(p1_1&p2_1) |- (p1_1&p2_1)"

      iex> ProblemGenerator.generate(:php, 2)
      "((p1_1|p1_2)&(p2_1|p2_2)&(p3_1|p3_2)) |- ((p1_1&p2_1)|(p1_1&p3_1)|(p2_1&p3_1)|(p1_2&p2_2)|(p1_2&p3_2)|(p2_2&p3_2))"

      iex> ProblemGenerator.generate(:php, 3)
      "((p1_1|p1_2|p1_3)&(p2_1|p2_2|p2_3)&(p3_1|p3_2|p3_3)&(p4_1|p4_2|p4_3)) |- ((p1_1&p2_1)|(p1_1&p3_1)|(p1_1&p4_1)|(p2_1&p3_1)|(p2_1&p4_1)|(p3_1&p4_1)|(p1_2&p2_2)|(p1_2&p3_2)|(p1_2&p4_2)|(p2_2&p3_2)|(p2_2&p4_2)|(p3_2&p4_2)|(p1_3&p2_3)|(p1_3&p3_3)|(p1_3&p4_3)|(p2_3&p3_3)|(p2_3&p4_3)|(p3_3&p4_3))"
  """
  @spec generate(atom(), integer()) :: String.t()
  def generate(type \\ :php, number)

  def generate(:php, number) do
    left = php_left_side(number)
    right = php_right_side(number)

    case number do
      1 -> "(#{left}) |- #{right}"
      _ -> "(#{left}) |- (#{right})"
    end
  end

  @spec php_left_side(integer()) :: String.t()
  defp php_left_side(number) do
    1..(number + 1)
    |> Enum.map_join("&", fn x ->
      1..number
      |> Enum.map_join("|", fn y ->
        "p#{x}_#{y}"
      end)
      |> enclose_parentesis()
    end)
  end

  defp php_right_side(number) do
    1..number
    |> Enum.map_join("|", fn x ->
      1..(number + 1)
      |> Enum.map(fn z ->
        "p#{z}_#{x}"
      end)
      |> generate_permutations()
      |> Enum.map(fn pairs -> pairs |> Enum.join("&") |> enclose_parentesis() end)
      |> Enum.join("|")
    end)
  end

  @spec generate_permutations([String.t()], [String.t()]) :: [String.t()]
  defp generate_permutations(list, acc \\ [])

  defp generate_permutations([], acc), do: acc

  defp generate_permutations([head | tail], acc) do
    generate_permutations(tail, acc ++ Enum.map(tail, fn elem -> [head, elem] end))
  end

  @spec enclose_parentesis(String.t()) :: String.t()
  defp enclose_parentesis(string) do
    if String.contains?(string, ["|", "&"]) do
      "(#{string})"
    else
      string
    end
  end
end
