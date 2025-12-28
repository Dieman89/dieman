defmodule Dieman.Pages.Home do
  @moduledoc false

  use Tableau.Page,
    layout: Dieman.RootLayout,
    permalink: "/"

  import Temple
  alias Dieman.Components
  alias Dieman.Data

  def template(_assigns) do
    temple do
      div class: "home" do
        div do
          Components.avatar()

          h1 do
            Components.glitch_text(Data.name())
          end

          p class: "title" do
            Components.taglines()
          end

          nav class: "links" do
            Components.nav_links()
          end
        end

        Components.floating_shapes()

        footer class: "social" do
          Components.social_links()
        end
      end
    end
  end
end
