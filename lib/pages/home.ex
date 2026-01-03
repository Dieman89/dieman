defmodule Dieman.Pages.Home do
  @moduledoc false

  use Tableau.Page,
    layout: Dieman.RootLayout,
    permalink: "/"

  use Dieman.UI.Components

  alias Dieman.Content

  def template(_assigns) do
    temple do
      div class: "home" do
        div do
          avatar()

          h1 do
            glitch_text(Content.name())
          end

          p class: "title" do
            taglines()
          end

          nav class: "links" do
            nav_links()
          end
        end

        floating_shapes()

        footer class: "social-links" do
          social_links()
        end
      end
    end
  end
end
