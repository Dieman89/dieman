defmodule Dieman.Pages.Cv do
  @moduledoc false

  use Tableau.Page,
    layout: Dieman.PostLayout,
    title: "Curriculum",
    permalink: "/cv"

  import Temple
  alias Dieman.Assets

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
              {:safe, Assets.icon(:download)}
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
