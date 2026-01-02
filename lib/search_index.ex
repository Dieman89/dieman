defmodule Dieman.SearchIndex do
  @moduledoc "Generate search index JSON"

  @posts_dir "content/posts"
  @output_path "static/search-index.json"

  alias Dieman.Data

  def generate do
    posts = index_posts()
    projects = index_projects()

    documents = posts ++ projects

    index_data = %{documents: documents}

    json = Jason.encode!(index_data)
    File.write!(@output_path, json)
    Mix.shell().info("Search index: #{length(documents)} documents")
  end

  defp index_posts do
    case File.ls(@posts_dir) do
      {:ok, files} ->
        files
        |> Enum.filter(&String.ends_with?(&1, ".md"))
        |> Enum.map(&parse_post/1)
        |> Enum.reject(&is_nil/1)

      {:error, _} ->
        []
    end
  end

  defp parse_post(filename) do
    path = Path.join(@posts_dir, filename)

    with {:ok, content} <- File.read(path),
         {:ok, frontmatter, body} <- parse_frontmatter(content) do
      # Extract slug from filename: YYYY-MM-DD-slug.md -> slug
      slug =
        filename
        |> String.replace(~r/^\d{4}-\d{2}-\d{2}-/, "")
        |> String.replace(".md", "")

      title = frontmatter["title"] || "Untitled"
      tags = frontmatter["tags"] || []

      %{
        id: "post-#{slug}",
        type: "post",
        title: title,
        body: strip_markdown(body),
        tags: Enum.join(tags, " "),
        url: "/posts/#{slug}/"
      }
    else
      _ -> nil
    end
  end

  defp index_projects do
    Data.projects()
    |> Enum.with_index()
    |> Enum.map(fn {project, _idx} ->
      slug = project.title |> String.downcase() |> String.replace(~r/[^a-z0-9]+/, "-")

      %{
        id: "project-#{slug}",
        type: "project",
        title: project.title,
        body: project.description,
        tags: Enum.join(project.tags ++ project.tech, " "),
        url: "/projects/"
      }
    end)
  end

  defp parse_frontmatter(content) do
    case String.split(content, ~r/^---\s*$/m, parts: 3) do
      ["", yaml, body] ->
        case YamlElixir.read_from_string(yaml) do
          {:ok, fm} -> {:ok, fm, body}
          error -> error
        end

      _ ->
        {:error, :invalid_frontmatter}
    end
  end

  defp strip_markdown(text) do
    text
    # Remove code blocks
    |> String.replace(~r/```[\s\S]*?```/, " ")
    # Remove inline code
    |> String.replace(~r/`[^`]+`/, " ")
    # Extract link text
    |> String.replace(~r/\[([^\]]+)\]\([^)]+\)/, "\\1")
    # Remove markdown chars
    |> String.replace(~r/[#*_~`\[\]()>|]/, " ")
    # Collapse whitespace
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
    # Limit length for index size
    |> String.slice(0, 2000)
  end
end
