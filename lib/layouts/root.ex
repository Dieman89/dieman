defmodule Dieman.RootLayout do
  @moduledoc "Base HTML layout with head, body, and footer."

  use Tableau.Layout
  import Temple
  import Dieman.UI.Shell, only: [site_footer: 0]
  import Dieman.UI.Search
  alias Dieman.Assets
  alias Dieman.Content

  defp build_title(assigns) do
    [assigns[:page][:title], Content.site_title()]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" | ")
  end

  defp og_type(assigns) do
    if assigns[:page][:date], do: "article", else: "website"
  end

  defp image_lightbox do
    temple do
      div id: "image-lightbox", class: "image-lightbox", onclick: "closeImageLightbox()" do
        button class: "image-lightbox-close", onclick: "closeImageLightbox()" do
          "×"
        end

        img(id: "lightbox-img", src: "", alt: "")
      end

      script do
        """
        function openImageLightbox(src) {
          const lightbox = document.getElementById('image-lightbox');
          const img = document.getElementById('lightbox-img');
          img.src = src;
          lightbox.classList.add('active');
          document.body.style.overflow = 'hidden';
        }
        function closeImageLightbox() {
          const lightbox = document.getElementById('image-lightbox');
          lightbox.classList.remove('active');
          document.body.style.overflow = '';
        }
        document.addEventListener('keydown', function(e) {
          if (e.key === 'Escape') closeImageLightbox();
        });
        """
      end
    end
  end

  defp page_class(assigns) do
    cond do
      assigns[:page][:permalink] == "/" -> "page-home"
      assigns[:page][:permalink] == "/404" -> "page-404"
      assigns[:page][:permalink] == "/posts" -> "page-posts"
      assigns[:page][:permalink] == "/projects" -> "page-projects"
      assigns[:page][:permalink] == "/cv" -> "page-cv"
      assigns[:page][:date] -> "page-article"
      true -> "page-single"
    end
  end

  defp og_image(assigns) do
    permalink = assigns[:page][:permalink] || "/"

    if assigns[:page][:date] && String.starts_with?(permalink, "/posts/") do
      slug = String.trim_leading(permalink, "/posts/")
      Dieman.absolute_url("/og/#{slug}.png")
    else
      Dieman.absolute_url(Content.avatar())
    end
  end

  def template(assigns) do
    page_title = build_title(assigns)
    description = assigns[:page][:description] || "#{Content.name()} - #{hd(Content.taglines())}"
    url = Dieman.absolute_url(assigns[:page][:permalink] || "/")
    image = og_image(assigns)
    body_class = page_class(assigns)

    temple do
      "<!DOCTYPE html>"

      html lang: "en" do
        head do
          meta(charset: "utf-8")
          meta(name: "viewport", content: "width=device-width, initial-scale=1.0")
          meta(name: "color-scheme", content: "dark")
          meta(name: "description", content: description)
          meta(name: "author", content: Content.name())

          title(do: page_title)

          # Open Graph
          meta(property: "og:type", content: og_type(assigns))
          meta(property: "og:title", content: page_title)
          meta(property: "og:description", content: description)
          meta(property: "og:url", content: url)
          meta(property: "og:image", content: image)
          meta(property: "og:site_name", content: Content.site_title())

          # Twitter Card
          meta(name: "twitter:card", content: "summary_large_image")
          meta(name: "twitter:title", content: page_title)
          meta(name: "twitter:description", content: description)
          meta(name: "twitter:image", content: image)

          # RSS
          link(
            rel: "alternate",
            type: "application/rss+xml",
            title: "#{Content.site_title()} RSS",
            href: "/feed.xml"
          )

          # Fonts
          for url <- Assets.font_preconnect() do
            link(rel: "preconnect", href: url, crossorigin: url =~ "gstatic")
          end

          link(rel: "stylesheet", href: Assets.font_stylesheet())

          # Styles & Favicon
          link(rel: "stylesheet", href: Assets.stylesheet())
          link(rel: "icon", type: "image/jpeg", href: Content.avatar())
        end

        body class: body_class do
          render(@inner_content)

          search_modal()
          image_lightbox()
          site_footer()

          Dieman.live_reload(assigns)

          script(src: Assets.glitch_script())

          if body_class == "page-article" do
            script(src: Assets.toc_script())
            script(src: Assets.progress_script())
            script(src: Assets.copy_code_script())
            script(src: Assets.back_to_top_script())
            script(src: Assets.like_heart_script())
          end

          Dieman.analytics()

          script(defer: true, src: "https://cdn.jsdelivr.net/npm/lunr@2.3.9/lunr.min.js")
          script(src: Assets.search_script())
        end
      end
    end
    |> Phoenix.HTML.Safe.to_iodata()
  end
end
