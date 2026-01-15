defmodule Dieman.Pages.Cv do
  @moduledoc false

  use Tableau.Page,
    layout: Dieman.PostLayout,
    title: "Curriculum",
    permalink: "/cv"

  import Temple

  def template(_assigns) do
    temple do
      iframe(
        src: "https://nocturne.cv/u/dieman/embed?style=preview&bg=2C2525",
        width: "350",
        height: "565",
        frameborder: "0"
      )
    end
  end
end
