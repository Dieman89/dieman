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
                  {:safe,
                   ~s(<svg viewBox="0 0 16 16" fill="currentColor"><path d="M6.906.664a1.749 1.749 0 0 1 2.187 0l5.25 4.2c.415.332.657.835.657 1.367v7.019A1.75 1.75 0 0 1 13.25 15h-3.5a.75.75 0 0 1-.75-.75V9H7v5.25a.75.75 0 0 1-.75.75h-3.5A1.75 1.75 0 0 1 1 13.25V6.23c0-.531.242-1.034.657-1.366l5.25-4.2Zm1.25 1.171a.25.25 0 0 0-.312 0l-5.25 4.2a.25.25 0 0 0-.094.196v7.019c0 .138.112.25.25.25H5.5V8.25a.75.75 0 0 1 .75-.75h3.5a.75.75 0 0 1 .75.75v5.25h2.75a.25.25 0 0 0 .25-.25V6.23a.25.25 0 0 0-.094-.195Z"/></svg>)}
                end

                span(do: "cd ~")
              end

              a href: "/posts", class: "terminal-nav-link" do
                span class: "terminal-nav-icon" do
                  {:safe,
                   ~s(<svg viewBox="0 0 16 16" fill="currentColor"><path d="M2 1.75C2 .784 2.784 0 3.75 0h6.586c.464 0 .909.184 1.237.513l2.914 2.914c.329.328.513.773.513 1.237v9.586A1.75 1.75 0 0 1 13.25 16h-9.5A1.75 1.75 0 0 1 2 14.25Zm1.75-.25a.25.25 0 0 0-.25.25v12.5c0 .138.112.25.25.25h9.5a.25.25 0 0 0 .25-.25V6h-2.75A1.75 1.75 0 0 1 9 4.25V1.5Zm6.75.062V4.25c0 .138.112.25.25.25h2.688l-.011-.013-2.914-2.914-.013-.011Z"/></svg>)}
                end

                span(do: "ls posts")
              end

              a href: "/projects", class: "terminal-nav-link" do
                span class: "terminal-nav-icon" do
                  {:safe,
                   ~s(<svg viewBox="0 0 16 16" fill="currentColor"><path d="M1.75 1A1.75 1.75 0 0 0 0 2.75v10.5C0 14.216.784 15 1.75 15h12.5A1.75 1.75 0 0 0 16 13.25v-8.5A1.75 1.75 0 0 0 14.25 3H7.5a.25.25 0 0 1-.2-.1l-.9-1.2C6.07 1.26 5.55 1 5 1H1.75Z"/></svg>)}
                end

                span(do: "ls projects")
              end

              a href: "/cv", class: "terminal-nav-link" do
                span class: "terminal-nav-icon" do
                  {:safe,
                   ~s(<svg viewBox="0 0 16 16" fill="currentColor"><path d="M10.561 8.073a6.005 6.005 0 0 1 3.432 5.142.75.75 0 1 1-1.498.07 4.5 4.5 0 0 0-8.99 0 .75.75 0 0 1-1.498-.07 6.004 6.004 0 0 1 3.431-5.142 3.999 3.999 0 1 1 5.123 0ZM10.5 5a2.5 2.5 0 1 0-5 0 2.5 2.5 0 0 0 5 0Z"/></svg>)}
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
