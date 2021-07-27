defmodule LiveTableauxWeb.TableauxLive do
  use LiveTableauxWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, sequent: "")}
  end

  @impl true
  def handle_event("suggest", %{"q" => sequent}, socket) do
    {:noreply, assign(socket, sequent: sequent)}
  end


  @impl true
  def handle_event("add_not", _ , %{:assigns => %{:sequent => sequent}}=socket) do
    {:noreply, assign(socket,:sequent, sequent <> "¬")}
  end

  @impl true
  def handle_event("add_and", _ , %{:assigns => %{:sequent => sequent}}=socket) do
    {:noreply, assign(socket,:sequent, sequent <> "∧")}
  end

  @impl true
  def handle_event("add_or", _ , %{:assigns => %{:sequent => sequent}}=socket) do
    {:noreply, assign(socket,:sequent, sequent <> "∨")}
  end

  @impl true
  def handle_event("add_implies", _ , %{:assigns => %{:sequent => sequent}}=socket) do
    {:noreply, assign(socket,:sequent, sequent <> "→")}
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
end
