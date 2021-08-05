defmodule TableauxSimplifiedPbtTest do
  use ExUnit.Case, async: true
  use PropCheck

  @numtests 100
  @negation " ¬ "
  @conjunction " ∧ "
  @disjunction " ∨ "
  @implication " → "
  @assertion "|-"

  property "a simple proposition is not verifiable" do
    forall p <- simple_proposition() do
      # collect(
      not TableauxSimplified.is_valid?(@assertion <> p)
      #  p
      # )
    end
  end

  property "either a proposition or its negation is always verifiable", [
    :verbose,
    numtests: @numtests
  ] do
    forall p <- proposition() do
      # IO.inspect(@assertion <> "(" <> p <> ")"<> @disjunction <>  "(" <> @negation <> "(" <> p <> "))", label: "sequent")
      # collect(
      TableauxSimplified.is_valid?(
        @assertion <> "(" <> p <> ")" <> @disjunction <> "(" <> @negation <> "(" <> p <> "))"
      )

      #  ,
      # type_of_nexus(p)
      # )
    end
  end

  property "if a the ascendant and the consequence of a sequent are the same proposition the sequent should verify",
           [:verbose, numtests: @numtests] do
    forall p <- proposition() do
      TableauxSimplified.is_valid?("(" <> p <> ")" <> @assertion <> "(" <> p <> ")")
    end
  end

  property "the results must be consistent with the the bintree based implementation",
           [:verbose, numtests: @numtests] do
    forall p <- proposition() do
      TableauxSimplified.is_valid?(@assertion <> "(" <> p <> ")") ==
        Tableaux.is_valid?(@assertion <> "(" <> p <> ")")
    end
  end

  property "a proposition always implies itself", [:verbose, numtests: @numtests] do
    forall p <- proposition() do
      TableauxSimplified.is_valid?(
        @assertion <> "(" <> p <> ")" <> @implication <> "(" <> p <> ")"
      )
    end
  end

  property "commutative laws", [:verbose, numtests: @numtests] do
    forall [a, b] <- [proposition(), proposition()] do
      TableauxSimplified.is_valid?(
        @assertion <> "(" <> a <> ")" <> @conjunction <> "(" <> b <> ")"
      ) ==
        TableauxSimplified.is_valid?(
          @assertion <> "(" <> b <> ")" <> @conjunction <> "(" <> a <> ")"
        ) &&
        TableauxSimplified.is_valid?(
          @assertion <> "(" <> a <> ")" <> @disjunction <> "(" <> b <> ")"
        ) ==
          TableauxSimplified.is_valid?(
            @assertion <> "(" <> b <> ")" <> @disjunction <> "(" <> a <> ")"
          )
    end
  end

  property "associative laws", [:verbose, numtests: @numtests] do
    forall [a, b, c] <- [proposition(), proposition(), proposition()] do
      TableauxSimplified.is_valid?(
        @assertion <>
          "((" <> a <> ")" <> @disjunction <> "(" <> b <> "))" <> @disjunction <> "(" <> c <> ")"
      ) ==
        TableauxSimplified.is_valid?(
          @assertion <>
            "(" <>
            a <> ")" <> @disjunction <> "((" <> b <> ")" <> @disjunction <> "(" <> c <> "))"
        ) &&
        TableauxSimplified.is_valid?(
          @assertion <>
            "((" <>
            a <> ")" <> @conjunction <> "(" <> b <> "))" <> @conjunction <> "(" <> c <> ")"
        ) ==
          TableauxSimplified.is_valid?(
            @assertion <>
              "(" <>
              a <> ")" <> @conjunction <> "((" <> b <> ")" <> @conjunction <> "(" <> c <> "))"
          )
    end
  end

  property "distributive laws", [:verbose, numtests: @numtests] do
    forall [a, b, c] <- [proposition(), proposition(), proposition()] do
      TableauxSimplified.is_valid?(
        @assertion <>
          "(" <> a <> ")" <> @conjunction <> "((" <> b <> ")" <> @disjunction <> "(" <> c <> "))"
      ) ==
        TableauxSimplified.is_valid?(
          @assertion <>
            "((" <>
            a <>
            ")" <>
            @conjunction <>
            "(" <>
            b <> "))" <> @disjunction <> "((" <> a <> ")" <> @conjunction <> "(" <> c <> "))"
        ) &&
        TableauxSimplified.is_valid?(
          @assertion <>
            "(" <>
            a <> ")" <> @disjunction <> "((" <> b <> ")" <> @conjunction <> "(" <> c <> "))"
        ) ==
          TableauxSimplified.is_valid?(
            @assertion <>
              "((" <>
              a <>
              ")" <>
              @disjunction <>
              "(" <>
              b <> "))" <> @conjunction <> "((" <> a <> ")" <> @disjunction <> "(" <> c <> "))"
          )
    end
  end

  property "absorption laws", [:verbose, numtests: @numtests] do
    forall [a, b] <- [proposition(), proposition()] do
      TableauxSimplified.is_valid?(
        @assertion <>
          "(" <> a <> ")" <> @conjunction <> "((" <> a <> ")" <> @disjunction <> "(" <> b <> "))"
      ) ==
        TableauxSimplified.is_valid?(@assertion <> "(" <> a <> ")") &&
        TableauxSimplified.is_valid?(
          @assertion <>
            "(" <>
            a <> ")" <> @disjunction <> "((" <> a <> ")" <> @conjunction <> "(" <> b <> "))"
        ) ==
          TableauxSimplified.is_valid?(@assertion <> "(" <> a <> ")")
    end
  end

  property "idempotent laws", [:verbose, numtests: @numtests] do
    forall a <- proposition() do
      TableauxSimplified.is_valid?(
        @assertion <> "(" <> a <> ")" <> @conjunction <> "(" <> a <> ")"
      ) ==
        TableauxSimplified.is_valid?(@assertion <> "(" <> a <> ")") &&
        TableauxSimplified.is_valid?(
          @assertion <> "(" <> a <> ")" <> @disjunction <> "(" <> a <> ")"
        ) ==
          TableauxSimplified.is_valid?(@assertion <> "(" <> a <> ")")
    end
  end

  property "De Morgan's laws", [:verbose, numtests: @numtests] do
    forall [a, b] <- [proposition(), proposition()] do
      TableauxSimplified.is_valid?(
        @assertion <> "(" <> @negation <> "((" <> a <> ")" <> @conjunction <> "(" <> b <> ")))"
      ) ==
        TableauxSimplified.is_valid?(
          @assertion <>
            "(" <>
            @negation <> "(" <> a <> "))" <> @disjunction <> "(" <> @negation <> "(" <> b <> "))"
        ) &&
        TableauxSimplified.is_valid?(
          @assertion <> "(" <> @negation <> "((" <> a <> ")" <> @disjunction <> "(" <> b <> ")))"
        ) ==
          TableauxSimplified.is_valid?(
            @assertion <>
              "(" <>
              @negation <>
              "(" <> a <> "))" <> @conjunction <> "(" <> @negation <> "(" <> b <> "))"
          )
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
