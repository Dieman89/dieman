defmodule Dieman.UI.Post do
  @moduledoc "Post-related UI components: date, tags, reading time."

  import Temple

  alias Dieman.Assets

  def post_date(date) do
    temple do
      time datetime: Date.to_iso8601(date) do
        Calendar.strftime(date, Assets.date_format())
      end
    end
  end

  def reading_time(content) do
    words = content |> String.split(~r/\s+/) |> length()
    mins = Dieman.reading_time(content)

    temple do
      span(class: "reading-time", data_words: "#{words} words", do: "#{mins} min read")
    end
  end

  def tags([_ | _] = tags) do
    temple do
      span class: "tags" do
        for tag <- tags do
          span(class: "tag", do: "##{tag}")
        end
      end
    end
  end

  def tags(_), do: ""
end
