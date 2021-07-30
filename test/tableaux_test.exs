defmodule TableauxTest do
  use ExUnit.Case, async: true

  doctest Tableaux

  test "reference tableaux formula" do
    """
        assert Tableaux.verify("w|-(p∨(q∧r))→((p∨q)∧(p∨r))") ==
          %BinTree{
            left: %BinTree{
              left: %BinTree{
                left: %BinTree{
                  left: %BinTree{
                    left: %BinTree{
                      left: %BinTree{
                        left: %BinTree{
                          left: nil,
                          right: nil,
                          sign: :F,
                          string: "p",
                          value: :p
                        },
                        right: %BinTree{
                          left: nil,
                          right: nil,
                          sign: :T,
                          string: "q",
                          value: :q
                        },
                        sign: :F,
                        string: "p",
                        value: :p
                      },
                      right: nil,
                      sign: :F,
                      string: "q",
                      value: :q
                    },
                    right: nil,
                    sign: :T,
                    string: "¬p",
                    value: {:negation, :p}
                  },
                  right: nil,
                  sign: :F,
                  string: "(¬p)→q",
                  value: {:implication, {:negation, :p}, :q}
                },
                right: %BinTree{
                  left: %BinTree{
                    left: nil,
                    right: nil,
                    sign: :F,
                    string: "p",
                    value: :p
                  },
                  right: %BinTree{
                    left: nil,

                    right: nil,
                    sign: :T,
                    string: "q",
                    value: :q
                  },
                  sign: :F,
                  string: "q",
                  value: :q
                },
                sign: :F,
                source: nil,
                string: "((¬p)→q)∧q",
                value: {:conjunction, {:implication, {:negation, :p}, :q}, :q}
              },

              right: nil,
              sign: :T,
              source: nil,
              string: "p→q",
              value: {:implication, :p, :q}
            },

            right: nil,
            sign: :T,
            source: nil,
            string: "p",
            value: :p
          }

    """
  end
end
