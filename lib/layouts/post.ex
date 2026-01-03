defmodule Dieman.PostLayout do
  @moduledoc "Layout for posts and pages with sidebar navigation."

  use Tableau.Layout, layout: Dieman.RootLayout
  import Temple
  import Dieman.UI.Shell
  import Dieman.UI.Post
  alias Dieman.Assets
  alias Dieman.Build.Git

  @github_repo "dieman"

  def template(assigns) do
    current_path = assigns[:page][:permalink] || "/"
    is_post = assigns[:page][:date] != nil
    {last_modified, file_path} = if is_post, do: get_last_modified(assigns), else: {nil, nil}

    temple do
      div class: "single" do
        sidebar(current_path)

        article do
          header do
            if assigns[:page][:date] do
              div class: "post-header-meta" do
                div class: "post-header-left" do
                  span class: "date" do
                    Calendar.strftime(@page.date, Assets.date_format())
                  end

                  tags(@page[:tags] || [])
                end

                if assigns[:page][:body] do
                  reading_time(@page.body)
                end
              end
            end

            h1(do: @page.title)
          end

          Phoenix.HTML.raw(render(@inner_content))

          if is_post do
            post_footer(last_modified, file_path)
          end
        end

        post_shapes()
      end
    end
  end

  defp get_last_modified(assigns) do
    # Use the post's date to find the matching file
    post_date = assigns[:page][:date]

    if post_date do
      date_prefix = Calendar.strftime(post_date, "%Y-%m-%d")

      with {:ok, files} <- File.ls("content/posts"),
           file when not is_nil(file) <- Enum.find(files, &String.starts_with?(&1, date_prefix)) do
        file_path = "content/posts/#{file}"
        {Git.last_modified(file_path) || dev_fallback_date(), file_path}
      else
        _ -> {dev_fallback_date(), nil}
      end
    else
      {nil, nil}
    end
  end

  defp dev_fallback_date do
    if Mix.env() == :dev do
      DateTime.utc_now()
    else
      nil
    end
  end

  defp post_footer(last_modified, file_path) do
    github_url =
      if file_path, do: "#{Assets.github_url(@github_repo)}/commits/main/#{file_path}", else: nil

    temple do
      footer class: "post-footer" do
        div class: "post-stat" do
          span class: "post-stat-icon" do
            Phoenix.HTML.raw(Assets.icon(:eye))
          end

          span class: "post-views-count" do
            "—"
          end

          span class: "post-stat-label" do
            "views"
          end
        end

        if last_modified do
          if github_url do
            a href: github_url,
              target: "_blank",
              rel: "noopener noreferrer",
              class: "post-stat post-stat-link" do
              span class: "post-stat-icon" do
                Phoenix.HTML.raw(Assets.icon(:pencil))
              end

              span class: "post-stat-value" do
                format_date(last_modified)
              end

              span class: "post-stat-label" do
                "updated"
              end
            end
          else
            div class: "post-stat" do
              span class: "post-stat-icon" do
                Phoenix.HTML.raw(Assets.icon(:pencil))
              end

              span class: "post-stat-value" do
                format_date(last_modified)
              end

              span class: "post-stat-label" do
                "updated"
              end
            end
          end
        end
      end
    end
  end

  defp format_date(%DateTime{} = dt) do
    Calendar.strftime(dt, Assets.date_format())
  end

  defp format_date(_), do: nil
end
