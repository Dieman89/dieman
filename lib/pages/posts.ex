defmodule Dieman.Pages.Posts do
  @moduledoc false

  use Tableau.Page,
    layout: Dieman.PostLayout,
    title: "Posts",
    permalink: "/posts"

  use Dieman.UI.Components

  alias Dieman.Assets
  alias Dieman.Content

  def template(assigns) do
    temple do
      floating_symbols()

      div class: "post-list" do
        for post <- @posts do
          article class: "post-item" do
            div class: "post-meta" do
              time(do: Calendar.strftime(post.date, Assets.date_format()))
              tags(post[:tags] || [])
            end

            a(href: post.permalink, do: post.title)
          end
        end
      end

      if Enum.empty?(@posts) do
        p(class: "empty", do: Content.no_posts())
      end
    end
  end
end
