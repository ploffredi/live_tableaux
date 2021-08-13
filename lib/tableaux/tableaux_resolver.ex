defmodule TableauxResolver do
  defmacro __using__(_) do
    quote do
      @behaviour TableauxResolver

      def get_status(%TableauxResolver{status: status}), do: status
      defoverridable get_status: 1
    end
  end

  @type t :: %__MODULE__{
          status: :open | :closed,
          counterproof: [{atom(), boolean()}],
          simple_propositions: [atom()],
          expanded_tree: any()
        }
  defstruct [:status, :counterproof, :simple_propositions, :expanded_tree]

  @callback prove(binary()) :: any()

  @callback get_status(TableauxResolver.t()) :: :open | :closed
end
