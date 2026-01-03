defmodule Dieman.Build.Git do
  @moduledoc """
  Git utilities for extracting file metadata.
  """

  @doc """
  Gets the last modified date for a file from git history.
  Returns nil if git is not available or file has no commits.
  """
  def last_modified(file_path) do
    case System.cmd("git", ["log", "-1", "--format=%cI", "--", file_path], stderr_to_stdout: true) do
      {output, 0} ->
        output
        |> String.trim()
        |> parse_datetime()

      _ ->
        nil
    end
  end

  defp parse_datetime(""), do: nil

  defp parse_datetime(iso_string) do
    case DateTime.from_iso8601(iso_string) do
      {:ok, datetime, _offset} -> datetime
      _ -> nil
    end
  end
end
