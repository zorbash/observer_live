defmodule LiveViewExamples.Format do
  def number_to_human_size(size) when is_integer(size) and size < 1024, do: "#{size} B"
  def number_to_human_size(size) when size < 1024 * 1024, do: "#{Float.round(size / 1024, 4)} KB"
  def number_to_human_size(size) when size < 1024 * 1024 * 1024, do: "#{Float.round(size / (1024 * 1024), 4)} MB"
  def number_to_human_size(size) when size < 1024 * 1024 * 1024 * 1024 do
    "#{Float.round(size / (1024 * 1024 * 1024), 4)} GB"
  end
  def number_to_human_size(size), do: "#{size} ??"

  def to_percentage(num) when num < 0.1, do: "#{Float.round(num * 100, 2)}%"
  def to_percentage(num) when num < 1, do: "#{Float.round(num * 100, 2)}%"
  def to_percentage(_), do: "100%"
end
