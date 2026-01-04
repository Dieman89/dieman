defmodule Dieman.PostLayout do
  @moduledoc "Layout for posts and pages with sidebar navigation."

  use Tableau.Layout, layout: Dieman.RootLayout
  import Temple
  import Dieman.UI.Shell
  import Dieman.UI.Post
  alias Dieman.Assets
  alias Dieman.Build.Git
  alias Dieman.Markdown.Components.Language

  @github_repo "dieman"

  def template(assigns) do
    current_path = assigns[:page][:permalink] || "/"
    is_post = assigns[:page][:date] != nil
    {last_modified, file_path} = post_metadata(assigns, is_post)
    languages = post_languages(assigns, is_post)

    temple do
      div class: "single" do
        sidebar(current_path)

        article do
          post_header(assigns, languages)
          Phoenix.HTML.raw(render(@inner_content))

          if is_post do
            share_buttons(assigns)
            post_footer(last_modified, file_path)
          end
        end

        post_shapes()
      end
    end
  end

  defp post_metadata(assigns, true), do: get_last_modified(assigns)
  defp post_metadata(_assigns, false), do: {nil, nil}

  defp post_languages(assigns, true), do: Language.extract_languages(assigns[:page][:body] || "")
  defp post_languages(_assigns, false), do: []

  defp post_header(assigns, languages) do
    temple do
      header do
        if assigns[:page][:date] do
          post_header_meta(assigns)
        end

        h1(do: assigns[:page][:title])

        if languages != [] do
          div class: "post-languages" do
            Phoenix.HTML.raw(Language.render_badges(languages))
          end
        end
      end
    end
  end

  defp post_header_meta(assigns) do
    temple do
      div class: "post-header-meta" do
        div class: "post-header-left" do
          span class: "date" do
            Calendar.strftime(assigns[:page][:date], Assets.date_format())
          end

          tags(assigns[:page][:tags] || [])
        end

        if assigns[:page][:body] do
          reading_time(assigns[:page][:body])
        end
      end
    end
  end

  defp get_last_modified(assigns) do
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

  defp share_buttons(assigns) do
    title = assigns[:page][:title] || ""
    permalink = assigns[:page][:permalink] || "/"
    url = "#{Assets.site_url()}#{permalink}"
    twitter_text = URI.encode("I enjoyed \"#{title}\" by @Dieman_\n\n#{url}")
    threads_text = URI.encode("I enjoyed \"#{title}\" by @diemans_\n\n#{url}")

    temple do
      div class: "share-buttons" do
        div class: "share-inner" do
          span class: "share-label" do
            "Share →"
          end

          div class: "share-icons" do
            a href: "#",
              class: "share-btn share-btn-copy",
              title: "Copy link",
              "aria-label": "Copy link" do
              Phoenix.HTML.raw(Assets.icon(:link))
            end

            a href: "https://twitter.com/intent/tweet?text=#{twitter_text}",
              class: "share-btn share-btn-twitter",
              target: "_blank",
              rel: "noopener noreferrer",
              title: "Share on X",
              "aria-label": "Share on X" do
              Phoenix.HTML.raw(Assets.icon(:twitter))
            end

            a href: "https://www.threads.net/intent/post?text=#{threads_text}",
              class: "share-btn share-btn-threads",
              target: "_blank",
              rel: "noopener noreferrer",
              title: "Share on Threads",
              "aria-label": "Share on Threads" do
              Phoenix.HTML.raw(Assets.icon(:threads))
            end

            a href: "https://www.linkedin.com/sharing/share-offsite/?url=#{URI.encode(url)}",
              class: "share-btn share-btn-linkedin",
              target: "_blank",
              rel: "noopener noreferrer",
              title: "Share on LinkedIn",
              "aria-label": "Share on LinkedIn" do
              Phoenix.HTML.raw(Assets.icon(:linkedin))
            end

            a href: "#",
              class: "share-btn share-btn-mastodon",
              title: "Share on Mastodon",
              "aria-label": "Share on Mastodon" do
              Phoenix.HTML.raw(Assets.icon(:mastodon))
            end
          end
        end
      end
    end
  end
end
