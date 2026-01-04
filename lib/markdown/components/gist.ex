defmodule Dieman.Markdown.Components.Gist do
  @moduledoc """
  Embeds GitHub Gists.

  ## Example

      ::gist{username/gist_id}
      ::gist{Dieman89/abc123def456}
  """

  def process(html) when is_binary(html) do
    Regex.replace(~r/::gist\{([^}]+)\}/, html, fn _, gist_path ->
      ~s(<div class="gist-embed" data-gist="#{gist_path}"></div>)
    end)
  end

  def process(html), do: html
end
