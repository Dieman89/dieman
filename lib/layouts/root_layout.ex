defmodule Dieman.RootLayout do
  use Dieman.Component
  use Tableau.Layout

  def template(assigns) do
    ~H"""
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta name="color-scheme" content="dark" />
        <style>body{background:#2C2525;color:#FFF8F9;font-family:monospace}</style>
        <title>
          <%= [@page[:title], "dieman.dev"]
          |> Enum.filter(& &1)
          |> Enum.intersperse("|")
          |> Enum.join(" ") %>
        </title>

        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
        <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;700&display=swap" rel="stylesheet" />
        <link rel="stylesheet" href="/css/site.css" />
        <link rel="icon" type="image/jpeg" href="/images/avatar.jpeg" />
        <!-- Turbo disabled due to syntax highlighting issues -->
        <!-- <script type="module" src="https://unpkg.com/@hotwired/turbo@8"></script> -->
      </head>
      <body>
        <.inner_content content={render(@inner_content)} />
        <%= if is_nil(@page[:date]) do %>
          <p class="made-with">Made with <span class="heart">&#9829;</span> between <span class="city city-left">Puebla 🇲🇽</span> and <span class="city city-right">London 🇬🇧</span></p>
        <% end %>

        <%= if Mix.env() == :dev do %>
          <%= assigns |> Tableau.live_reload() |> Phoenix.HTML.raw() %>
        <% end %>
        <script>
          document.addEventListener('DOMContentLoaded', function() {
            const glitchText = document.querySelector('.glitch-text');
            if (!glitchText) return;

            function triggerGlitch() {
              glitchText.classList.add('active');

              setTimeout(() => {
                glitchText.classList.remove('active');
              }, Math.random() * 300 + 200);

              setTimeout(triggerGlitch, Math.random() * 2000 + 3000);
            }

            setTimeout(triggerGlitch, Math.random() * 2000 + 1000);
          });
        </script>
      </body>
    </html>
    """
    |> Phoenix.HTML.Safe.to_iodata()
  end
end
