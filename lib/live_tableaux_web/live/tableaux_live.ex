defmodule LiveTableauxWeb.TableauxLive do
  use LiveTableauxWeb, :live_view

  @samples [
    "p|q,q|-q",
    "p|q,q|-!q",
    "|-(p∨(q∧r))→((p∨q)∧(p∨r))",
    "p∨q|-(p∨(q∧r))→((p∨q)∧(p∨r))"
  ]
  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, sequent: "", counterproof: [], samples: @samples, gen_info: true)}
  end

  @impl true
  def handle_event("suggest", %{"q" => sequent}, socket) do
    {:noreply, assign(socket, sequent: sequent)}
  end

  @impl true
  def handle_event("add_not", _, %{:assigns => %{:sequent => sequent}} = socket) do
    {:noreply, assign(socket, :sequent, sequent <> "¬")}
  end

  @impl true
  def handle_event("add_and", _, %{:assigns => %{:sequent => sequent}} = socket) do
    {:noreply, assign(socket, :sequent, sequent <> "∧")}
  end

  @impl true
  def handle_event("add_or", _, %{:assigns => %{:sequent => sequent}} = socket) do
    {:noreply, assign(socket, :sequent, sequent <> "∨")}
  end

  @impl true
  def handle_event("add_implies", _, %{:assigns => %{:sequent => sequent}} = socket) do
    {:noreply, assign(socket, :sequent, sequent <> "→")}
  end

  @impl true
  def handle_event("sample_selected", %{"sample" => ""}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_gen_info", _, %{:assigns => %{:gen_info => gen_info}} = socket) do
    socket = assign(socket, gen_info: !gen_info)
    {:noreply, push_event(socket, "toggleGenInfo", %{showGen: !gen_info})}
  end

  @impl true
  def handle_event("sample_selected", %{"sample" => sequent}, socket) do
    socket = assign(socket, sequent: sequent)

    proof = Tableaux.prove(sequent)

    socket = push_event(socket, "updateResultTree", proof.expanded_tree |> BinTree.to_map())

    socket = assign(socket, :counterproof, proof.counterproof)

    {:noreply, socket}
  end

  @impl true
  def handle_event("expand", %{"q" => sequent}, socket) do
    proof = Tableaux.prove(sequent)
    socket = push_event(socket, "updateResultTree", proof.expanded_tree |> BinTree.to_map())

    socket = assign(socket, :counterproof, proof.counterproof)

    {:noreply, socket}
  end
end
