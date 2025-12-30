defmodule Dieman.Pages.Cv do
  @moduledoc false

  use Tableau.Page,
    layout: Dieman.PostLayout,
    title: "Curriculum",
    permalink: "/cv"

  import Temple
  alias Dieman.Settings

  def template(_assigns) do
    if Settings.cv_protected?() do
      protected_template()
    else
      unprotected_template()
    end
  end

  defp protected_template do
    temple do
      div class: "cv-viewer" do
        div class: "cv-locked" do
          div class: "cv-overlay" do
            div class: "cv-lock-icon" do
              Phoenix.HTML.raw("&#128274;")
            end

            p(class: "cv-lock-text", do: "Enter password to view CV")

            input(
              type: "password",
              id: "cv-password",
              class: "cv-password-input",
              placeholder: "Password",
              autocomplete: "off"
            )

            button(class: "cv-unlock-btn", onclick: "unlockCV()", do: "Unlock")
            p(class: "cv-error", id: "cv-error")
          end

          div class: "cv-blurred" do
            Phoenix.HTML.raw(
              ~s(<object data="/cv.pdf" type="application/pdf" class="cv-embed"><p>PDF viewer not supported</p></object>)
            )
          end
        end

        div class: "cv-unlocked", style: "display: none;" do
          a(
            href: "/cv.pdf",
            download: "Alessandro_Buonerba_CV.pdf",
            class: "cv-download",
            do: "Download PDF"
          )

          Phoenix.HTML.raw(
            ~s(<object data="/cv.pdf" type="application/pdf" class="cv-embed"><p>Unable to display PDF. <a href="/cv.pdf">Download it instead</a></p></object>)
          )
        end
      end

      Phoenix.HTML.raw(~s(<script>window.CV_HASH="#{Settings.cv_password_hash()}";</script>))
      script(src: "/js/cv.js")
    end
  end

  defp unprotected_template do
    temple do
      div class: "cv-viewer" do
        div class: "cv-unlocked", style: "display: flex;" do
          a(
            href: "/cv.pdf",
            download: "Alessandro_Buonerba_CV.pdf",
            class: "cv-download",
            do: "Download PDF"
          )

          Phoenix.HTML.raw(
            ~s(<object data="/cv.pdf" type="application/pdf" class="cv-embed"><p>Unable to display PDF. <a href="/cv.pdf">Download it instead</a></p></object>)
          )
        end
      end
    end
  end
end
