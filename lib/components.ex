defmodule Dieman.Components do
  @moduledoc "Reusable UI components."

  import Temple
  alias Dieman.Data

  # Text components

  def taglines do
    temple do
      for {tagline, i} <- Enum.with_index(Data.taglines()) do
        if i > 0, do: br()
        span(do: tagline)
      end
    end
  end

  def glitch_text(text) do
    temple do
      span(class: "glitch-text", data_text: text, do: text)
    end
  end

  # Link components

  def links(items) do
    temple do
      for %{href: href, label: text} <- items do
        a(href: href, do: "#{text}")
      end
    end
  end

  def nav_links, do: links(Data.nav_links())
  def social_links, do: links(Data.social_links())

  # Avatar

  def avatar(class \\ "avatar") do
    temple do
      img(src: Data.avatar(), alt: Data.name(), class: class)
    end
  end

  # Floating decorations

  def floating_shapes do
    temple do
      div class: "shapes" do
        for i <- 1..5, do: div(class: "shape shape-#{i}")

        for {kw, i} <- Data.keywords() |> Enum.with_index(1) do
          span(class: "keyword kw-#{i}", do: kw)
        end
      end
    end
  end

  def floating_symbols do
    temple do
      div class: "floats" do
        for {%{symbol: sym, label: label}, i} <- Data.symbols() |> Enum.with_index(1) do
          span class: "float float-#{i}", data_label: label do
            span(do: sym)
          end
        end
      end
    end
  end

  # Footer

  def footer do
    [left, right] = Data.locations()

    temple do
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

  defp location(city, flag, class) do
    temple do
      span class: "city #{class}" do
        "#{city} "
        Phoenix.HTML.raw(flag)
      end
    end
  end

  # Sidebar

  def sidebar do
    temple do
      nav do
        div class: "nav-top" do
          a(href: "/", do: avatar("nav-avatar"))

          h1 do
            a(href: "/", do: glitch_text(Data.site_title()))
          end

          p(do: taglines())

          for %{href: href, label: text} <- Data.nav_links() do
            p do
              a(href: href, do: "#{text}")
            end
          end
        end

        div(class: "nav-bottom", do: social_links())
      end
    end
  end
end
