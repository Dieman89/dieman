defmodule Dieman.Pages.Cv do
  @moduledoc false

  use Tableau.Page,
    layout: Dieman.PostLayout,
    title: "Curriculum",
    permalink: "/cv"

  import Temple

  @turnstile_site_key "0x4AAAAAACJ_gDdA-hbW69YJ"

  def template(_assigns) do
    site_key = @turnstile_site_key

    temple do
      div class: "cv-viewer" do
        div class: "cv-locked", id: "cv-locked" do
          div class: "cv-blurred" do
            img(src: "/images/cv-blur.png", alt: "CV Preview", class: "cv-blur-image")
          end

          div class: "cv-captcha" do
            div(
              class: "cf-turnstile",
              data_sitekey: site_key,
              data_callback: "onCaptchaSuccess",
              data_theme: "dark"
            )
          end
        end

        div class: "cv-unlocked", id: "cv-unlocked", style: "display: none;" do
          a href: "#", download: "Alessandro_Buonerba_CV.pdf", class: "cv-download" do
            span class: "cv-download-icon" do
              {:safe,
               ~s(<svg viewBox="0 0 16 16" fill="currentColor"><path d="M2.75 14A1.75 1.75 0 0 1 1 12.25v-2.5a.75.75 0 0 1 1.5 0v2.5c0 .138.112.25.25.25h10.5a.25.25 0 0 0 .25-.25v-2.5a.75.75 0 0 1 1.5 0v2.5A1.75 1.75 0 0 1 13.25 14Z"/><path d="M7.25 7.689V2a.75.75 0 0 1 1.5 0v5.689l1.97-1.969a.749.749 0 1 1 1.06 1.06l-3.25 3.25a.749.749 0 0 1-1.06 0L4.22 6.78a.749.749 0 1 1 1.06-1.06l1.97 1.969Z"/></svg>)}
            end

            span(class: "cv-download-text", do: "Download PDF")
            span(class: "cv-download-arrow", do: "→")
          end

          Phoenix.HTML.raw(
            ~s(<object data="" type="application/pdf" class="cv-embed"><p>Unable to display PDF.</p></object>)
          )
        end
      end

      script(src: "https://challenges.cloudflare.com/turnstile/v0/api.js", async: true)
      script(src: "/js/cv.js")
    end
  end
end
