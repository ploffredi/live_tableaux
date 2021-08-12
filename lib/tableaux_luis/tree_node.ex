defmodule Luis.TreeNode do
  @type formula :: {:implies | :and | :or, atom(), atom()} | {:not, atom()}

  @type t() :: %Luis.TreeNode{formula: formula(), sign: :T | :F}

  defstruct [:formula, :sign]
end
