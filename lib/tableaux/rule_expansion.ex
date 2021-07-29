defmodule RuleExpansion do
  @type rule :: :alpha | :beta | :atom
  @type t :: %RuleExpansion{
          rule_type: rule(),
          expanded_nodes: [RuleNode.t()]
        }

  defstruct [:rule_type, :expanded_nodes]
end
