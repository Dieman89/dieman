defmodule Dieman.Components do
  @moduledoc "Reusable UI components."

  import Temple

  alias Dieman.Data

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
          if Data.social_display() == :icon do
            icon(link.icon)
          else
            "#{link.label}"
          end
        end
      end
    end
  end

  # Icons (16x16 SVG)

  def icon(:github) do
    temple do
      Phoenix.HTML.raw(
        ~s(<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/></svg>)
      )
    end
  end

  def icon(:linkedin) do
    temple do
      Phoenix.HTML.raw(
        ~s(<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M19 0h-14c-2.761 0-5 2.239-5 5v14c0 2.761 2.239 5 5 5h14c2.762 0 5-2.239 5-5v-14c0-2.761-2.238-5-5-5zm-11 19h-3v-11h3v11zm-1.5-12.268c-.966 0-1.75-.79-1.75-1.764s.784-1.764 1.75-1.764 1.75.79 1.75 1.764-.783 1.764-1.75 1.764zm13.5 12.268h-3v-5.604c0-3.368-4-3.113-4 0v5.604h-3v-11h3v1.765c1.396-2.586 7-2.777 7 2.476v6.759z"/></svg>)
      )
    end
  end

  def icon(:rss) do
    temple do
      Phoenix.HTML.raw(
        ~s(<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M6.503 20.752c0 1.794-1.456 3.248-3.251 3.248-1.796 0-3.252-1.454-3.252-3.248 0-1.794 1.456-3.248 3.252-3.248 1.795.001 3.251 1.454 3.251 3.248zm-6.503-12.572v4.811c6.05.062 10.96 4.966 11.022 11.009h4.817c-.062-8.71-7.118-15.758-15.839-15.82zm0-3.368c10.58.046 19.152 8.594 19.183 19.188h4.817c-.03-13.231-10.755-23.954-24-24v4.812z"/></svg>)
      )
    end
  end

  def icon(:email) do
    temple do
      Phoenix.HTML.raw(
        ~s(<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="currentColor"><path d="M0 3v18h24v-18h-24zm21.518 2l-9.518 7.713-9.518-7.713h19.036zm-19.518 14v-11.817l10 8.104 10-8.104v11.817h-20z"/></svg>)
      )
    end
  end

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
        for {%{symbol: sym, label: lbl}, i} <- Data.symbols() |> Enum.with_index(1) do
          span class: "float float-#{i}", data_label: lbl do
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

  def sidebar(current_path \\ "/") do
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
              a(href: href, class: nav_link_class(href, current_path), do: "#{text}")
            end
          end
        end

        div(class: "nav-bottom", do: social_links())
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
        Calendar.strftime(date, "%b %d, %Y")
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
end
