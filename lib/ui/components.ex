defmodule Dieman.UI.Components do
  @moduledoc "Base UI components and helpers."

  import Temple

  alias Dieman.Assets
  alias Dieman.Content

  defmacro __using__(_) do
    quote do
      import Temple
      import Dieman.UI.Components
      import Dieman.UI.Shell
      import Dieman.UI.Post
      import Dieman.UI.Search
    end
  end

  # Text

  def taglines do
    temple do
      for {tagline, i} <- Enum.with_index(Content.taglines()) do
        if i > 0, do: br()
        span(do: tagline)
      end
    end
  end

  def glitch_text(value) do
    temple do
      span(class: "glitch-text", data_text: value, do: "#{value}")
    end
  end

  # Links

  def links(items) do
    temple do
      for %{href: href, label: text} <- items do
        a(href: href, do: "#{text}")
      end
    end
  end

  def nav_links, do: links(Content.nav_links())

  def social_links do
    temple do
      for link <- Content.social_links() do
        a href: link.href, title: link.label, aria_label: link.label do
          icon(link.icon)
        end
      end
    end
  end

  # Icons

  def icon(name) do
    temple do
      Phoenix.HTML.raw(Assets.icon(name))
    end
  end

  # Avatar

  def avatar(class \\ "avatar") do
    temple do
      img(src: Content.avatar(), alt: Content.name(), class: class)
    end
  end
end
