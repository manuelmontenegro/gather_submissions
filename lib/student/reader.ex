defmodule GatherSubmissions.Student.Reader do
  @moduledoc """
  Provides a function for reading students' information from a CSV file.
  """

  alias GatherSubmissions.Student

  defmodule DuplicateHeaderError do
    defexception message: "Duplicate headers in input CSV file"
  end

  defmodule MissingHeaderError do
    defexception [:header]

    @impl true
    def message(exception) do
      "Missing header '#{exception.header}' in CSV file"
    end
  end

  @doc """
  Reads a CSV file with student information and returns a list of `t:GatherSubmissions.Student.t/0` structs.

  The first line of the CSV has to contain a header with the names of each field in the
  CSV file. The `header_map` parameter must contain the keys `"name"`, `"surname"` and `"user_id"`
  mapped to the names of the corresponding fields in the CSV file. Optionally, it could
  also map the key `"group"` key to the name of the column containing the stundent's group.

  This function raises the following exceptions:

  * `DuplicateHeaderError` when the `header_map` contains several keys mapped to the same value.

  * `MissingHeaderError` when the `header_map` does not contain the mandatory keys: `"name"`, `"surname"`, and `"user_id"`.
  """
  @spec read_students_from_csv(String.t(), %{String.t() => String.t()}) :: [Student.t()]
  def read_students_from_csv(filename, header_map) do
    check_no_duplicate_headers(header_map)

    File.stream!(filename)
    |> CSV.decode!(headers: true)
    |> Enum.map(&line_to_student(&1, header_map))
  end

  defp check_no_duplicate_headers(header) do
    values = Map.values(header)

    if Enum.uniq(values) == values do
      :ok
    else
      raise DuplicateHeaderError
    end
  end

  defp check_header_fields(map, header) do
    case Enum.find(Map.values(header), nil, &(not Map.has_key?(map, &1))) do
      nil -> :ok
      field -> raise MissingHeaderError, header: field
    end
  end

  defp line_to_student(map, header) do
    check_header_fields(map, header)

    %Student{
      name: map[header["name"]],
      surname: map[header["surname"]],
      user: map[header["user_id"]],
      group: if(Map.has_key?(header, "group"), do: map[header["group"]], else: nil),
      metadata: if(Map.has_key?(header, "metadata"), do: map[header["metadata"]], else: nil)
    }
  end
end
