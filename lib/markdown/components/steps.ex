defmodule Dieman.Markdown.Components.Steps do
  @moduledoc """
  Processes step-by-step instructions with numbered icons.

  ## Example

      ::steps
      Download the installer from the official website
      Run the installer and follow the prompts
      Restart your computer when complete
      Verify installation by running `--version`
      ::
  """

  def pre_process(markdown) when is_binary(markdown) do
    Regex.replace(~r/::steps\n([\s\S]*?)\n::(?![a-z])/, markdown, fn _, content ->
      steps =
        content
        |> String.trim()
        |> String.split("\n")
        |> Enum.with_index(1)
        |> Enum.map_join("", fn {step, num} ->
          step_text = step |> String.trim()
          "<!--step-#{num}-->#{step_text}<!--/step-->"
        end)

      "<!--steps-start-->#{steps}<!--steps-end-->"
    end)
  end

  def pre_process(markdown), do: markdown

  def post_process(html) when is_binary(html) do
    html =
      html
      |> String.replace("<!--steps-start-->", ~s(<div class="steps">))
      |> String.replace("<!--steps-end-->", "</div>")

    Regex.replace(~r/<!--step-(\d+)-->([\s\S]*?)<!--\/step-->/, html, fn _, num, content ->
      content =
        content
        |> String.replace(~r/<\/?p>/, "")
        |> String.trim()
        |> convert_markdown_links()

      """
      <div class="step">
        <span class="step-number">#{num}</span>
        <span class="step-content">#{content}</span>
      </div>
      """
    end)
  end

  def post_process(html), do: html

  defp convert_markdown_links(text) do
    Regex.replace(~r/\[([^\]]+)\]\(([^)]+)\)/, text, fn _, label, url ->
      ~s(<a href="#{url}" target="_blank" rel="noopener">#{label}</a>)
    end)
  end
end
