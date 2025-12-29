defmodule Mix.Tasks.Dieman.Gen.Post do
  use Mix.Task

  alias Dieman.Settings

  @shortdoc "Generate a new post"
  @moduledoc @shortdoc

  @doc false
  def run(argv) do
    if argv == [] do
      raise "Missing argument: Filename"
    end

    post_title = Enum.join(argv, " ")
    post_date = Date.utc_today()
    post_time = Settings.default_post_time()

    file_name =
      post_title
      |> String.replace(" ", "-")
      |> String.replace("_", "-")
      |> String.replace(~r/[^[:alnum:]\/\-.]/, "")
      |> String.downcase()

    file_path =
      "./content/posts/#{post_date}-#{file_name}.md"

    if File.exists?(file_path) do
      raise "File already exists"
    end

    front_matter = """
    ---
    layout: Dieman.PostLayout
    title: \"#{post_title}\"
    date: #{post_date} #{post_time}
    permalink: /:title/
    ---
    """

    File.write!(file_path, front_matter)

    Mix.shell().info("Succesfully created #{file_path}!")
  end
end
