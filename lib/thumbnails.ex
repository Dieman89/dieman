defmodule Dieman.Thumbnails do
  @moduledoc "Generate image thumbnails using Vix/libvips."

  @compile {:no_warn_undefined, Vix.Vips.Image}
  @compile {:no_warn_undefined, Vix.Vips.Operation}

  alias Vix.Vips.Image
  alias Vix.Vips.Operation

  @thumbnail_width 800
  @quality 80

  @doc "Generate thumbnails for all project images."
  def generate_all do
    source_dir = "static/images/projects"
    output_dir = "static/images/projects/thumbnails"

    File.mkdir_p!(output_dir)

    source_dir
    |> File.ls!()
    |> Enum.filter(&image?/1)
    |> Enum.each(fn filename ->
      source = Path.join(source_dir, filename)
      output = Path.join(output_dir, filename)
      generate(source, output)
    end)
  end

  @doc "Generate a single thumbnail."
  def generate(source, output) do
    with {:ok, img} <- Image.new_from_file(source),
         {:ok, thumb} <- Operation.thumbnail_image(img, @thumbnail_width),
         :ok <- write_optimized(thumb, output) do
      Mix.shell().info("Thumbnail: #{Path.basename(output)}")
      :ok
    else
      error ->
        Mix.shell().error("Failed thumbnail #{source}: #{inspect(error)}")
        error
    end
  end

  defp write_optimized(img, path) do
    cond do
      String.ends_with?(path, ".png") ->
        Image.write_to_file(img, path, compression: 9)

      String.ends_with?(path, ".jpg") or String.ends_with?(path, ".jpeg") ->
        Image.write_to_file(img, path, Q: @quality)

      true ->
        Image.write_to_file(img, path)
    end
  end

  defp image?(filename) do
    ext = Path.extname(filename) |> String.downcase()
    ext in [".png", ".jpg", ".jpeg", ".webp"]
  end
end
