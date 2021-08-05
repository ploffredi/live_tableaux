defmodule TableauxResolver do
  defmacro __using__(_) do
    quote do
      @behaviour TableauxResolver
    end
  end

  @callback is_valid?(binary()) :: boolean()
end
