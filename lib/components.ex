defmodule Dieman.Components do
  @moduledoc "Reusable UI components."

  import Temple

  alias Dieman.Data
  alias Dieman.Settings

  defmacro __using__(_) do
    quote do
      import Temple
      import unquote(__MODULE__)
    end
  end

  # Text

  def taglines do
    temple do
      for {tagline, i} <- Enum.with_index(Data.taglines()) do
        if i > 0, do: br()
        span(do: tagline)
      end
    end
  end

  def glitch_text(value) do
    temple do
      span(class: "glitch-text", data_text: value, do: "#{value}")
    end
  end

  # Links

  def links(items) do
    temple do
      for %{href: href, label: text} <- items do
        a(href: href, do: "#{text}")
      end
    end
  end

  def nav_links, do: links(Data.nav_links())

  def social_links do
    temple do
      for link <- Data.social_links() do
        a href: link.href, title: link.label, aria_label: link.label do
          icon(link.icon)
        end
      end
    end
  end

  # Icons (16x16 SVG)

  def icon(name) do
    temple do
      Phoenix.HTML.raw(Settings.icon(name))
    end
  end

  # Avatar

  def avatar(class \\ "avatar") do
    temple do
      img(src: Data.avatar(), alt: Data.name(), class: class)
    end
  end

  # Floating decorations
  # Shape counts: homepage uses 5, post pages use 7

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
        for {%{symbol: sym, label: lbl}, i} <- Data.symbols() |> Enum.with_index(1) do
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

  # Footer

  def footer do
    [left, right] = Data.locations()

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

  # Sidebar

  def sidebar(current_path \\ "/") do
    temple do
      nav do
        div class: "nav-top" do
          a(href: "/", do: avatar("nav-avatar"))

          h1 do
            a(href: "/", do: glitch_text(Data.site_title()))
          end

          p(do: taglines())

          ul class: "nav-links" do
            for %{href: href, label: text} <- Data.nav_links() do
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

  # Post metadata

  def post_date(date) do
    temple do
      time datetime: Date.to_iso8601(date) do
        Calendar.strftime(date, Settings.date_format())
      end
    end
  end

  def reading_time(content) do
    mins = Dieman.reading_time(content)

    temple do
      span(class: "reading-time", do: "#{mins} min read")
    end
  end

  def tags([_ | _] = tags) do
    temple do
      span class: "tags" do
        for tag <- tags do
          span(class: "tag", do: "##{tag}")
        end
      end
    end
  end

  def tags(_), do: ""

  # Search Modal

  def search_modal do
    temple do
      div id: "search-overlay", class: "search-overlay" do
        div class: "search-modal" do
          div class: "search-input-wrapper" do
            span(class: "search-icon", do: icon(:search))

            input(
              type: "search",
              id: "search-input",
              class: "search-input",
              placeholder: "Search posts and projects...",
              autocomplete: "off",
              aria_label: "Search"
            )

            span class: "search-esc" do
              "esc"
            end
          end

          div(id: "search-results", class: "search-results", role: "listbox")
        end
      end
    end
  end
end
