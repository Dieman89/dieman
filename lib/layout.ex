defmodule Dieman.RootLayout do
  @moduledoc "Base HTML layout with head, body, and footer."

  use Tableau.Layout
  import Temple
  alias Dieman.Components
  alias Dieman.Data

  defp build_title(assigns) do
    [assigns[:page][:title], Data.site_title()]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" | ")
  end

  defp og_type(assigns) do
    if assigns[:page][:date], do: "article", else: "website"
  end

  defp page_class(assigns) do
    cond do
      assigns[:page][:permalink] == "/" -> "page-home"
      assigns[:page][:permalink] == "/posts" -> "page-posts"
      assigns[:page][:date] -> "page-article"
      true -> "page-single"
    end
  end

  def template(assigns) do
    page_title = build_title(assigns)
    description = assigns[:page][:description] || "#{Data.name()} - #{hd(Data.taglines())}"
    url = Dieman.absolute_url(assigns[:page][:permalink] || "/")
    image = Dieman.absolute_url(Data.avatar())
    body_class = page_class(assigns)

    temple do
      "<!DOCTYPE html>"

      html lang: "en" do
        head do
          meta(charset: "utf-8")
          meta(name: "viewport", content: "width=device-width, initial-scale=1.0")
          meta(name: "color-scheme", content: "dark")
          meta(name: "description", content: description)
          meta(name: "author", content: Data.name())

          title(do: page_title)

          # Open Graph
          meta(property: "og:type", content: og_type(assigns))
          meta(property: "og:title", content: page_title)
          meta(property: "og:description", content: description)
          meta(property: "og:url", content: url)
          meta(property: "og:image", content: image)
          meta(property: "og:site_name", content: Data.site_title())

          # Twitter Card
          meta(name: "twitter:card", content: "summary")
          meta(name: "twitter:title", content: page_title)
          meta(name: "twitter:description", content: description)
          meta(name: "twitter:image", content: image)

          # RSS
          link(
            rel: "alternate",
            type: "application/rss+xml",
            title: "#{Data.site_title()} RSS",
            href: "/feed.xml"
          )

          # Fonts
          link(rel: "preconnect", href: "https://fonts.googleapis.com")
          link(rel: "preconnect", href: "https://fonts.gstatic.com", crossorigin: true)

          link(
            rel: "stylesheet",
            href:
              "https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;700&display=swap"
          )

          # Styles & Favicon
          link(rel: "stylesheet", href: "/css/site.css")
          link(rel: "icon", type: "image/jpeg", href: Data.avatar())
        end

        body class: body_class do
          render(@inner_content)

          Components.footer()

          Dieman.live_reload(assigns)

          script(src: "/js/glitch.js")
        end
      end
    end
    |> Phoenix.HTML.Safe.to_iodata()
  end
end

defmodule Dieman.PostLayout do
  @moduledoc "Layout for posts and pages with sidebar navigation."

  use Tableau.Layout, layout: Dieman.RootLayout
  import Temple
  alias Dieman.Components

  def template(assigns) do
    current_path = assigns[:page][:permalink] || "/"

    temple do
      div class: "single" do
        Components.sidebar(current_path)

        article do
          header do
            if assigns[:page][:date] do
              div class: "post-header-meta" do
                div class: "post-header-left" do
                  span class: "date" do
                    Calendar.strftime(@page.date, "%b %d, %Y")
                  end

                  Components.tags(@page[:tags] || [])
                end

                if assigns[:page][:body] do
                  Components.reading_time(@page.body)
                end
              end
            end

            h1(do: @page.title)
          end

          Phoenix.HTML.raw(render(@inner_content))
        end
      end
    end
  end
end
