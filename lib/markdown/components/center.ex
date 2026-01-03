defmodule Dieman.Markdown.Components.Center do
  @moduledoc """
  Centers content horizontally.

  ## Examples

      ::center
      ::grid[50%]
      ::figure{/images/one.jpg|First}
      ::figure{/images/two.jpg|Second}
      ::
      ::
  """

  def pre_process(markdown) when is_binary(markdown) do
    Regex.replace(~r/::center\n([\s\S]*?)\n::(?![a-z])/, markdown, fn _, content ->
      joined = content |> String.trim() |> String.replace("\n", " ")
      "<!--center-start-->#{joined}<!--center-end-->"
    end)
  end

  def pre_process(markdown), do: markdown

  def post_process(html) when is_binary(html) do
    html
    |> String.replace("<!--center-start-->", ~s(<div class="center">))
    |> String.replace("<!--center-end-->", "</div>")
  end

  def post_process(html), do: html
end
