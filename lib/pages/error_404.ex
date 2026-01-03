defmodule Dieman.Pages.Error404 do
  @moduledoc false

  use Tableau.Page,
    layout: Dieman.RootLayout,
    permalink: "/404",
    title: "404"

  use Dieman.UI.Components
  alias Dieman.Assets

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
            div(class: "terminal-path-line", do: "~")

            div class: "terminal-line" do
              span(class: "terminal-prompt", do: "❯ ")
              span(class: "terminal-cmd", do: "curl")
              span(do: " dieman.dev")
              span(id: "error-path", do: "/...")
            end

            div class: "terminal-output error" do
              glitch_text("404")
              span(do: " Not Found")
            end

            div class: "terminal-error" do
              span(do: "** (PageNotFoundError) no route matches \"")
              span(id: "error-path-msg", do: "/...")
              span(do: "\"")
            end

            pre class: "terminal-stack" do
              """
                  (dieman 1.0.0) lib/router.ex:42: Dieman.Router.match!/1
                  (dieman 1.0.0) lib/endpoint.ex:15: Dieman.Endpoint.call/2
                  (plug 1.14.0) lib/plug/router.ex:246: Plug.Router.call/2

              hint: try one of these routes instead
              """
            end

            nav class: "terminal-nav" do
              a href: "/", class: "terminal-nav-link" do
                span class: "terminal-nav-icon" do
                  {:safe, Assets.icon(:home)}
                end

                span(do: "cd ~")
              end

              a href: "/posts", class: "terminal-nav-link" do
                span class: "terminal-nav-icon" do
                  {:safe, Assets.icon(:file)}
                end

                span(do: "ls posts")
              end

              a href: "/projects", class: "terminal-nav-link" do
                span class: "terminal-nav-icon" do
                  {:safe, Assets.icon(:folder)}
                end

                span(do: "ls projects")
              end

              a href: "/cv", class: "terminal-nav-link" do
                span class: "terminal-nav-icon" do
                  {:safe, Assets.icon(:user)}
                end

                span(do: "ls cv")
              end
            end

            div class: "terminal-line" do
              span(class: "terminal-prompt", do: "❯ ")
              span(class: "cursor", do: "_")
            end
          end

          script do
            """
            (function() {
              var path = window.location.pathname;
              document.getElementById('error-path').textContent = path;
              document.getElementById('error-path-msg').textContent = path;
            })();
            """
          end
        end
      end
    end
  end
end
