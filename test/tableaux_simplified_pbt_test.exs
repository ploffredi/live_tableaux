defmodule TableauxSimplifiedPbtTest do
  use ExUnit.Case, async: true
  use PropCheck

  alias Tableaux, as: TReference
  alias Luis.Tableaux, as: TImpl

  @numtests 200
  @max_size 30
  @negation " ¬ "
  @conjunction " ∧ "
  @disjunction " ∨ "
  @implication " → "
  @assertion "|-"

  property "a simple proposition is not verifiable" do
    forall p <- simple_proposition() do
      # collect(
      not TImpl.prove(@assertion <> p)
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
      TImpl.prove(
        @assertion <> "(" <> p <> ")" <> @disjunction <> "(" <> @negation <> "(" <> p <> "))"
      )

      #  ,
      # type_of_nexus(p)
      # )
    end
  end

  property "if a the ascendant and the consequence of a sequent are the same proposition the sequent should verify",
           [:verbose, numtests: @numtests, max_size: @max_size] do
    forall p <- proposition() do
      TImpl.prove("(" <> p <> ")" <> @assertion <> "(" <> p <> ")")
    end
  end

  property "the results must be consistent with the the bintree based implementation",
           [:verbose, numtests: @numtests, max_size: @max_size] do
    forall p <- proposition() do
      TImpl.prove(@assertion <> "(" <> p <> ")") ==
        TReference.prove(@assertion <> "(" <> p <> ")")
    end
  end

  property "a proposition always implies itself", [
    :verbose,
    numtests: @numtests,
    max_size: @max_size
  ] do
    forall p <- proposition() do
      TImpl.prove(@assertion <> "(" <> p <> ")" <> @implication <> "(" <> p <> ")")
    end
  end

  property "commutative laws", [:verbose, numtests: @numtests, max_size: @max_size] do
    forall [a, b] <- [proposition(), proposition()] do
      TImpl.prove(@assertion <> "(" <> a <> ")" <> @conjunction <> "(" <> b <> ")") ==
        TImpl.prove(@assertion <> "(" <> b <> ")" <> @conjunction <> "(" <> a <> ")") &&
        TImpl.prove(@assertion <> "(" <> a <> ")" <> @disjunction <> "(" <> b <> ")") ==
          TImpl.prove(@assertion <> "(" <> b <> ")" <> @disjunction <> "(" <> a <> ")")
    end
  end

  property "associative laws", [:verbose, numtests: @numtests, max_size: @max_size] do
    forall [a, b, c] <- [proposition(), proposition(), proposition()] do
      TImpl.prove(
        @assertion <>
          "((" <> a <> ")" <> @disjunction <> "(" <> b <> "))" <> @disjunction <> "(" <> c <> ")"
      ) ==
        TImpl.prove(
          @assertion <>
            "(" <>
            a <> ")" <> @disjunction <> "((" <> b <> ")" <> @disjunction <> "(" <> c <> "))"
        ) &&
        TImpl.prove(
          @assertion <>
            "((" <>
            a <> ")" <> @conjunction <> "(" <> b <> "))" <> @conjunction <> "(" <> c <> ")"
        ) ==
          TImpl.prove(
            @assertion <>
              "(" <>
              a <> ")" <> @conjunction <> "((" <> b <> ")" <> @conjunction <> "(" <> c <> "))"
          )
    end
  end

  property "distributive laws", [:verbose, numtests: @numtests, max_size: @max_size] do
    forall [a, b, c] <- [proposition(), proposition(), proposition()] do
      TImpl.prove(
        @assertion <>
          "(" <> a <> ")" <> @conjunction <> "((" <> b <> ")" <> @disjunction <> "(" <> c <> "))"
      ) ==
        TImpl.prove(
          @assertion <>
            "((" <>
            a <>
            ")" <>
            @conjunction <>
            "(" <>
            b <> "))" <> @disjunction <> "((" <> a <> ")" <> @conjunction <> "(" <> c <> "))"
        ) &&
        TImpl.prove(
          @assertion <>
            "(" <>
            a <> ")" <> @disjunction <> "((" <> b <> ")" <> @conjunction <> "(" <> c <> "))"
        ) ==
          TImpl.prove(
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

  property "absorption laws", [:verbose, numtests: @numtests, max_size: @max_size] do
    forall [a, b] <- [proposition(), proposition()] do
      TImpl.prove(
        @assertion <>
          "(" <> a <> ")" <> @conjunction <> "((" <> a <> ")" <> @disjunction <> "(" <> b <> "))"
      ) ==
        TImpl.prove(@assertion <> "(" <> a <> ")") &&
        TImpl.prove(
          @assertion <>
            "(" <>
            a <> ")" <> @disjunction <> "((" <> a <> ")" <> @conjunction <> "(" <> b <> "))"
        ) ==
          TImpl.prove(@assertion <> "(" <> a <> ")")
    end
  end

  property "idempotent laws", [:verbose, numtests: @numtests, max_size: @max_size] do
    forall a <- proposition() do
      TImpl.prove(@assertion <> "(" <> a <> ")" <> @conjunction <> "(" <> a <> ")") ==
        TImpl.prove(@assertion <> "(" <> a <> ")") &&
        TImpl.prove(@assertion <> "(" <> a <> ")" <> @disjunction <> "(" <> a <> ")") ==
          TImpl.prove(@assertion <> "(" <> a <> ")")
    end
  end

  property "De Morgan's laws", [:verbose, numtests: @numtests, max_size: @max_size] do
    forall [a, b] <- [proposition(), proposition()] do
      TImpl.prove(
        @assertion <> "(" <> @negation <> "((" <> a <> ")" <> @conjunction <> "(" <> b <> ")))"
      ) ==
        TImpl.prove(
          @assertion <>
            "(" <>
            @negation <> "(" <> a <> "))" <> @disjunction <> "(" <> @negation <> "(" <> b <> "))"
        ) &&
        TImpl.prove(
          @assertion <> "(" <> @negation <> "((" <> a <> ")" <> @disjunction <> "(" <> b <> ")))"
        ) ==
          TImpl.prove(
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

  # defp type_of_nexus(p),
  #   do:
  #     type_of_nexus(
  #       String.contains?(p, @conjunction),
  #       String.contains?(p, @disjunction),
  #       String.contains?(p, @implication)
  #     )

  # defp type_of_nexus(true, _, _), do: " contains AND "
  # defp type_of_nexus(false, true, _), do: " contains OR "
  # defp type_of_nexus(false, false, true), do: " contains IMPLIES "
  # defp type_of_nexus(false, false, false), do: " contains none "
end
