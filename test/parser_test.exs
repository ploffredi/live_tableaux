defmodule ParserTest do
  use ExUnit.Case, async: true

  test "parses a simple sequent" do
    assert Tableaux.parse_sequent("p->q,p|-q") == [
             %TableauxNode{
               expression: {:implication, :p, :q},
               string: "p→q",
               sign: :T,
               step: 0,
               nid: 1,
               source: 0
             },
             %TableauxNode{
               expression: :p,
               string: "p",
               sign: :T,
               step: 0,
               nid: 2,
               source: 0
             },
             %TableauxNode{
               expression: :q,
               string: "q",
               sign: :F,
               step: 0,
               nid: 3,
               source: 0
             }
           ]
  end

  test "ignores spaces on input" do
    assert Tableaux.parse_sequent("p -> q,   p|-   q") == Tableaux.parse_sequent("p->q,p|-q")
  end

  test "uses the correct operator precedence" do
    assert Tableaux.parse_sequent("p&q->!r|s|-t") == Tableaux.parse_sequent("(p&q)->((!r)|s)|-t")
  end

  test "parses complex sequents" do
    assert Tableaux.parse_sequent("p&!q->r|t, t->q|!r, r&!q, p|t |- p->!r") == [
             %TableauxNode{
               expression:
                 {:implication, {:conjunction, :p, {:negation, :q}}, {:disjunction, :r, :t}},
               sign: :T,
               string: "(p∧(¬q))→(r∨t)",
               sign: :T,
               step: 0,
               nid: 1,
               source: 0
             },
             %TableauxNode{
               expression: {:implication, :t, {:disjunction, :q, {:negation, :r}}},
               sign: :T,
               string: "t→(q∨(¬r))",
               sign: :T,
               step: 0,
               nid: 2,
               source: 0
             },
             %TableauxNode{
               expression: {:conjunction, :r, {:negation, :q}},
               sign: :T,
               string: "r∧(¬q)",
               sign: :T,
               step: 0,
               nid: 3,
               source: 0
             },
             %TableauxNode{
               expression: {:disjunction, :p, :t},
               sign: :T,
               string: "p∨t",
               sign: :T,
               step: 0,
               nid: 4,
               source: 0
             },
             %TableauxNode{
               expression: {:implication, :p, {:negation, :r}},
               sign: :F,
               string: "p→(¬r)",
               sign: :F,
               step: 0,
               nid: 5,
               source: 0
             }
           ]
  end
end
