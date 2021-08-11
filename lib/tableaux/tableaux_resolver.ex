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
          atoms: [atom()]
        }
  defstruct [:status, :counterproof, :atoms]

  @callback prove(binary()) :: any()

  @callback get_status(TableauxResolver.t()) :: :open | :closed
end
