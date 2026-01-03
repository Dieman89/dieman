defmodule Dieman.Pages.Error404 do
  @moduledoc false

  use Tableau.Page,
    layout: Dieman.RootLayout,
    permalink: "/404",
    title: "404"

  use Dieman.UI.Components

  def template(_assigns) do
    temple do
      div class: "error-404" do
        div class: "terminal" do
          div class: "terminal-header" do
            span(class: "terminal-dot red")
            span(class: "terminal-dot yellow")
            span(class: "terminal-dot green")
            span(class: "terminal-title", do: "zsh")
          end

          div class: "terminal-body" do
            p class: "terminal-line" do
              span(class: "terminal-prompt", do: "$ ")
              span(do: "curl dieman.dev/this-page")
            end

            p class: "terminal-output error" do
              glitch_text("404")
              span(do: " Not Found")
            end

            pre class: "terminal-error" do
              """
              ** (PageNotFoundError) no route matches "/this-page"
                  (dieman 1.0.0) lib/router.ex:42: Dieman.Router.match!/1
                  (dieman 1.0.0) lib/endpoint.ex:15: Dieman.Endpoint.call/2
                  (plug 1.14.0) lib/plug/router.ex:246: Plug.Router.call/2

              hint: try one of these routes instead
              """
            end

            p class: "terminal-line" do
              span(class: "terminal-prompt", do: "$ ")
              span(class: "cursor", do: "_")
            end
          end
        end

        nav class: "error-nav" do
          a(href: "/", class: "terminal-link", do: "cd ~/home")
          a(href: "/posts", class: "terminal-link", do: "ls ~/posts")
          a(href: "/projects", class: "terminal-link", do: "ls ~/projects")
        end
      end
    end
  end
end
