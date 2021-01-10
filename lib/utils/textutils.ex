defmodule GatherSubmissions.TextUtils do
  @moduledoc """
  Defines several utility functions on strings.
  """

  @start_tag ~r{@[[:space:]]*<answer>}
  @end_tag ~r{@[[:space:]]*</answer>}

  @fi_digraph <<28>>
  @fi_text "fi"

  @spec strip_tags(String.t()) :: String.t()
  def strip_tags(contents) do
    if Regex.match?(@start_tag, contents) do
      contents
      |> String.split("\n")
      |> Enum.map_reduce(
        false,
        fn
          line, false ->
            {nil, Regex.match?(@start_tag, line)}

          line, true ->
            if Regex.match?(@end_tag, line) do
              {nil, false}
            else
              {line <> "\n", true}
            end
        end
      )
      |> elem(0)
      |> Enum.reject(&(&1 == nil))
      |> Enum.join()
    else
      contents
    end
  end

  @spec remove_fi_digraph(String.t()) :: String.t()
  def remove_fi_digraph(contents) do
    contents |> String.replace(@fi_digraph, @fi_text)
  end

  @spec remove_bom(String.t()) :: String.t()
  def remove_bom(contents) do
    String.trim_leading(contents, "\uFEFF")
  end
end
