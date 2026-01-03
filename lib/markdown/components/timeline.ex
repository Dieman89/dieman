defmodule Dieman.Markdown.Components.Timeline do
  @moduledoc """
  Processes timeline syntax for chronological events.

  ## Example

      ::timeline
      2024 | Senior Engineer | Led platform team ::badge[Elixir]{purple} ::badge[K8s]{blue}
      2023 | Engineer | Built notifications ::badge[Phoenix]{green}
      2022 | Junior Engineer | Started career
      ::

  Renders as a vertical timeline with dates, titles, and optional descriptions.
  Supports inline badges for technologies/skills.
  """

  @doc """
  Pre-processes timeline blocks before markdown conversion.
  """
  def pre_process(markdown) do
    Regex.replace(~r/::timeline\n([\s\S]*?)\n::/, markdown, fn _, content ->
      items = parse_timeline(content)

      if Enum.empty?(items) do
        content
      else
        "<!-- TIMELINE_PLACEHOLDER:#{Base.encode64(Jason.encode!(items))} -->"
      end
    end)
  end

  @doc """
  Post-processes timeline placeholders after markdown conversion.
  """
  def post_process(html) do
    Regex.replace(~r/<!-- TIMELINE_PLACEHOLDER:([A-Za-z0-9+\/=]+) -->/, html, fn _, encoded ->
      items = encoded |> Base.decode64!() |> Jason.decode!()
      build_timeline_html(items)
    end)
  end

  defp parse_timeline(content) do
    content
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&parse_line/1)
    |> Enum.reject(&is_nil/1)
  end

  defp parse_line(line) do
    case String.split(line, " | ", parts: 3) do
      [date, title, description] ->
        %{
          "date" => String.trim(date),
          "title" => String.trim(title),
          "description" => String.trim(description)
        }

      [date, title] ->
        %{"date" => String.trim(date), "title" => String.trim(title), "description" => nil}

      _ ->
        nil
    end
  end

  defp build_timeline_html(items) do
    items_html =
      Enum.map_join(items, "\n", fn item ->
        desc =
          if item["description"] do
            ~s(<p class="timeline-description">#{item["description"]}</p>)
          else
            ""
          end

        """
        <div class="timeline-item">
          <div class="timeline-marker"></div>
          <div class="timeline-content">
            <div class="timeline-header">
              <span class="timeline-title">#{item["title"]}</span>
              <span class="timeline-date">#{item["date"]}</span>
            </div>
            #{desc}
          </div>
        </div>
        """
      end)

    """
    <div class="timeline">
      #{items_html}
    </div>
    """
  end
end
