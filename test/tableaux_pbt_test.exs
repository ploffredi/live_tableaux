defmodule PbtTest do
  use ExUnit.Case
  use PropCheck

  @negation " ¬ "
  @conjunction " ∧ "
  @disjunction " ∨ "
  @implication " → "

  property "a simple proposition is not verifiable", [:verbose, numtests: 1000] do
    forall p <- simple_proposition() do
      # collect(
      not Tableaux.is_valid?("|-" <> p)
      #  p
      # )
    end
  end

  property "either a proposition or its negation is always verifiable", [:verbose, numtests: 1000] do
    forall p <- proposition() do
      collect(
        Tableaux.is_valid?(
          "(" <> p <> ")|-(" <> p <> ")"
        ),
        type_of_nexus(p)
      )
    end
  end

  property "a proposition always implies itself" do
    forall p <- proposition() do
      Tableaux.is_valid?("|-(" <> p <> ")" <> @implication <> "(" <> p <> ")")
    end
  end

  # Generators
  def simple_proposition() do
    # char()
    # range(?a, ?z)
    let({c, n} <- {range(?a, ?z), boolean()}, do: make_string(n, c))
  end

  defp make_string(true, c), do: to_string([c])
  defp make_string(false, c), do: @negation <> make_string(true, c)

  def proposition(), do: sized(size, proposition(size))

  defp proposition(0), do: simple_proposition()

  defp proposition(size),
    do:
      frequency([
        {1, simple_proposition()},
        {9,
         let_shrink([
           p1 <- proposition(div(size, 2)),
           p2 <- proposition(div(size, 2)),
           n <- nexus()
         ]) do
           "(" <> p1 <> ")" <> n <> "(" <> p2 <> ")"
         end}
      ])

  defp nexus() do
    oneof([@conjunction, @disjunction, @implication])
  end

  ## Utility functions (for data collection and analysis)

  defp type_of_nexus(p),
    do:
      type_of_nexus(
        String.contains?(p, @conjunction),
        String.contains?(p, @disjunction),
        String.contains?(p, @implication)
      )

  defp type_of_nexus(true, _, _), do: " contains AND "
  defp type_of_nexus(false, true, _), do: " contains OR "
  defp type_of_nexus(false, false, true), do: " contains IMPLIES "
  defp type_of_nexus(false, false, false), do: " contains none "
end
