defmodule Dieman.Pages.Projects do
  @moduledoc false

  use Tableau.Page,
    layout: Dieman.PostLayout,
    title: "Projects",
    permalink: "/projects"

  import Temple
  alias Dieman.{Assets, Content}

  defp thumbnail(path) do
    thumb =
      path
      |> Path.dirname()
      |> Path.join("thumbnails")
      |> Path.join(Path.basename(path))

    # Fallback to original if thumbnail doesn't exist (local dev)
    if File.exists?("static" <> thumb), do: thumb, else: path
  end

  def template(_assigns) do
    temple do
      div class: "projects-list" do
        for project <- Content.projects() do
          article class: "project-card" do
            div class: "project-image", onclick: "openImageLightbox('#{project.image}')" do
              img(src: thumbnail(project.image), alt: project.title, loading: "lazy")
            end

            div class: "project-content" do
              h2 class: "project-title" do
                project.title
              end

              p class: "project-description" do
                project.description
              end

              div class: "project-tags" do
                for lang <- project.tech do
                  span(class: "project-tag tech", do: lang)
                end

                for tag <- project.tags do
                  span(class: "project-tag", do: tag)
                end
              end

              div class: "project-meta" do
                time class: "project-date" do
                  Calendar.strftime(project.date, Assets.date_format())
                end

                a href: project.repo, class: "project-repo", target: "_blank" do
                  Phoenix.HTML.raw(Assets.icon(:github))
                  span(do: "View on GitHub")
                end
              end
            end
          end
        end
      end
    end
  end
end
