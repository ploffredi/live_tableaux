defmodule LiveTableauxWeb.TableauxLive do
  use LiveTableauxWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", results: %{})}
  end

  @impl true
  def handle_event("suggest", %{"q" => query}, socket) do
    {:noreply, assign(socket, results: validate(query), query: query)}
  end

  @impl true
  def handle_event("validate", _, socket) do
    {:noreply,
     push_event(socket, "updateResultTree", %{
       name: "T[p|q]",
       children: [
         %{
           name: "T[!p]",
           children: [
             %{
               name: "F[q]",
               children: [
                 %{name: "T[p]", children: [%{name: "X"}]},
                 %{name: "T[q]", children: [%{name: "X"}]}
               ]
             }
           ]
         }
       ]
     })}
  end


  @impl true
  def handle_info("update-tree", socket) do
    {:noreply,
     push_event(socket, "updateResultTree", %{
       name: "T[p|q]",
       children: [
         %{
           name: "T[!p]",
           children: [
             %{
               name: "F[q]",
               children: [
                 %{name: "T[p]", children: [%{name: "X"}]},
                 %{name: "T[q]", children: [%{name: "X"}]}
               ]
             }
           ]
         }
       ]
     })}
  end

  defp validate(query) do
    if not LiveTableauxWeb.Endpoint.config(:code_reloader) do
      raise "action disabled when not in development"
    end

    for {app, desc, vsn} <- Application.started_applications(),
        app = to_string(app),
        String.starts_with?(app, query) and not List.starts_with?(desc, ~c"ERTS"),
        into: %{},
        do: {app, vsn}
  end
end
