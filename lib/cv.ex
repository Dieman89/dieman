defmodule Dieman.Pages.Cv do
  @moduledoc false

  use Tableau.Page,
    layout: Dieman.PostLayout,
    title: "CV",
    permalink: "/cv"

  import Temple
  alias Dieman.Data

  def template(_assigns) do
    temple do
      p(class: "empty", do: Data.coming_soon())
    end
  end
end
