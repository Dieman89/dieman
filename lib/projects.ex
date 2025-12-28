defmodule Dieman.Pages.Projects do
  @moduledoc false

  use Tableau.Page,
    layout: Dieman.PostLayout,
    title: "Projects",
    permalink: "/projects"

  import Temple
  alias Dieman.Data

  def template(_assigns) do
    temple do
      p(class: "empty", do: Data.coming_soon())
    end
  end
end
