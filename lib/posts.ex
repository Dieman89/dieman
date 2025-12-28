defmodule Dieman.Pages.Posts do
  @moduledoc false

  use Tableau.Page,
    layout: Dieman.PostLayout,
    title: "Posts",
    permalink: "/posts"

  import Temple
  alias Dieman.Components
  alias Dieman.Data

  def template(assigns) do
    temple do
      Components.floating_symbols()

      div class: "post-list" do
        for post <- @posts do
          article class: "post-item" do
            time(do: Calendar.strftime(post.date, "%b %d, %Y"))
            a(href: post.permalink, do: post.title)
          end
        end
      end

      if Enum.empty?(@posts) do
        p(class: "empty", do: Data.no_posts())
      end
    end
  end
end
