defmodule Dieman.RootLayout do
  @moduledoc "Base HTML layout with head, body, and footer."

  use Tableau.Layout
  import Temple
  alias Dieman.Components
  alias Dieman.Data

  def template(assigns) do
    temple do
      "<!DOCTYPE html>"

      html lang: "en" do
        head do
          meta(charset: "utf-8")
          meta(name: "viewport", content: "width=device-width, initial-scale=1.0")
          meta(name: "color-scheme", content: "dark")

          title do
            [@page[:title], Data.site_title()]
            |> Enum.reject(&is_nil/1)
            |> Enum.join(" | ")
          end

          link(rel: "preconnect", href: "https://fonts.googleapis.com")
          link(rel: "preconnect", href: "https://fonts.gstatic.com", crossorigin: true)

          link(
            rel: "stylesheet",
            href:
              "https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;700&display=swap"
          )

          link(rel: "stylesheet", href: "/css/site.css")
          link(rel: "icon", type: "image/jpeg", href: Data.avatar())
        end

        body do
          render(@inner_content)

          unless @page[:date], do: Components.footer()

          if Mix.env() == :dev do
            Phoenix.HTML.raw(Tableau.live_reload(assigns))
          end

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
    temple do
      div class: "single" do
        Components.sidebar()

        article do
          header do
            if assigns[:page][:date] do
              p class: "date" do
                Calendar.strftime(@page.date, "%b %d, %Y")
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
