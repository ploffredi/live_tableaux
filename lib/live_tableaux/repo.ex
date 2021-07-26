defmodule LiveTableaux.Repo do
  use Ecto.Repo,
    otp_app: :live_tableaux,
    adapter: Ecto.Adapters.Postgres
end
