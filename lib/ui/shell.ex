defmodule Dieman.UI.Shell do
  @moduledoc "Shell components: sidebar, footer, decorative shapes."

  import Temple
  import Dieman.UI.Components

  alias Dieman.Content

  # Sidebar

  def sidebar(current_path \\ "/") do
    temple do
      nav do
        div class: "nav-top" do
          a(href: "/", do: avatar("nav-avatar"))

          h1 do
            a(href: "/", do: glitch_text(Content.site_title()))
          end

          p(do: taglines())

          ul class: "nav-links" do
            for %{href: href, label: text} <- Content.nav_links() do
              li do
                a(href: href, class: nav_link_class(href, current_path), do: "#{text}")
              end
            end
          end
        end

        div class: "nav-bottom" do
          div(class: "social-links", do: social_links())
          p(class: "search-hint", do: "⌘K to search")
        end
      end
    end
  end

  defp nav_link_class(href, current_path) do
    if String.starts_with?(current_path, href), do: "active", else: nil
  end

  # Footer

  def site_footer do
    [left, right] = Content.locations()

    temple do
      footer class: "site-footer" do
        div(class: "social-links", do: social_links())

        p class: "made-with" do
          "Made with "
          span(class: "heart", do: Phoenix.HTML.raw("&#9829;"))
          " between "
          location(left.city, left.flag, "city-left")
          " and "
          location(right.city, right.flag, "city-right")
        end
      end
    end
  end

  defp location(city, flag, class) do
    temple do
      span class: "city #{class}" do
        "#{city} "
        Phoenix.HTML.raw(flag)
      end
    end
  end

  # Decorative shapes

  def floating_shapes do
    temple do
      div class: "shapes" do
        for i <- 1..5, do: div(class: "shape shape-#{i}")

        for {kw, i} <- Content.keywords() |> Enum.with_index(1) do
          span(class: "keyword kw-#{i}", do: kw)
        end
      end
    end
  end

  def floating_symbols do
    temple do
      div class: "floats" do
        for {%{symbol: sym, label: lbl}, i} <- Content.symbols() |> Enum.with_index(1) do
          span class: "float float-#{i}", data_label: lbl do
            span(do: sym)
          end
        end
      end
    end
  end

  def post_shapes do
    temple do
      div class: "post-shapes" do
        for i <- 1..7, do: div(class: "shape shape-#{i}")
      end
    end
  end
end
