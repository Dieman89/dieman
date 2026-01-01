defmodule Mix.Tasks.Dieman.Build do
  use Mix.Task

  @shortdoc "Build site with OG images and CV protection"
  @moduledoc "Generates OG images, builds the site, and protects CV"

  @posts_dir "content/posts"
  @og_dir "static/og"

  def run(_argv) do
    :inets.start()
    :ssl.start()

    if Mix.env() == :prod, do: generate_og_images()

    Mix.Task.run("tableau.build")
    protect_cv()
  end

  defp generate_og_images do
    File.mkdir_p!(@og_dir)

    @posts_dir
    |> File.ls!()
    |> Enum.filter(&String.ends_with?(&1, ".md"))
    |> Enum.each(&generate_og_for_post/1)
  end

  defp generate_og_for_post(filename) do
    path = Path.join(@posts_dir, filename)
    content = File.read!(path)

    case parse_frontmatter(content) do
      {:ok, frontmatter} ->
        title = frontmatter["title"] || "Untitled"
        tags = frontmatter["tags"] || []
        slug = Slug.slugify(title, separator: "-")
        permalink = "/posts/#{slug}"
        output = Path.join(@og_dir, "#{slug}.png")

        Mix.shell().info("Generating OG image: #{slug}")

        case Dieman.OgImage.generate(title, permalink, output, tags: tags) do
          :ok ->
            :ok

          {:error, reason} ->
            Mix.shell().error("Failed to generate OG for #{slug}: #{inspect(reason)}")
        end

      {:error, _} ->
        Mix.shell().error("Failed to parse frontmatter: #{filename}")
    end
  end

  defp parse_frontmatter(content) do
    case String.split(content, ~r/^---\s*$/m, parts: 3) do
      ["", yaml, _body] ->
        case YamlElixir.read_from_string(yaml) do
          {:ok, map} -> {:ok, map}
          error -> error
        end

      _ ->
        {:error, :invalid_frontmatter}
    end
  end

  defp protect_cv do
    source = "site/cv.pdf"

    if File.exists?(source) do
      content = File.read!(source)
      hash = :crypto.hash(:sha256, content) |> Base.encode16(case: :lower) |> String.slice(0, 16)
      target = "site/cv-#{hash}.pdf"
      hash_file = "site/_d.txt"

      File.rename!(source, target)
      File.write!(hash_file, hash)
      Mix.shell().info("CV protected: /cv-#{hash}.pdf")
    else
      Mix.shell().info("Warning: #{source} not found")
    end
  end
end
