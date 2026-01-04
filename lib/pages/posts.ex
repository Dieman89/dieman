defmodule Dieman.Pages.Posts do
  @moduledoc false

  use Tableau.Page,
    layout: Dieman.PostLayout,
    title: "Posts",
    permalink: "/posts"

  use Dieman.UI.Components

  alias Dieman.Assets
  alias Dieman.Content
  alias Dieman.Markdown.Components.Language

  def template(assigns) do
    temple do
      floating_symbols()

      div class: "post-list" do
        for post <- @posts do
          languages = Language.extract_languages(post[:body] || "")

          article class: "post-item" do
            div class: "post-meta" do
              time(do: Calendar.strftime(post.date, Assets.date_format()))
              tags(post[:tags] || [])
            end

            a(href: post.permalink, do: post.title)

            if languages != [] do
              div class: "post-languages" do
                Phoenix.HTML.raw(Language.render_badges(languages))
              end
            end
          end
        end
      end

      if Enum.empty?(@posts) do
        p(class: "empty", do: Content.no_posts())
      end
    end
  end
end
