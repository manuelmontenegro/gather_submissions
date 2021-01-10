defmodule GatherSubmissions.Config do
  @moduledoc """
  Provides the definition of the struct `t:t/0` that stores the configuration
  options given to *GatherSubmissions*, and functions for reading it from a
  YAML file.

  The supported options are:

    * `csv_file_name`: name of the CSV file containing students info.

    * `csv_header`: a map that specifies the correspondence between the
      information needed and the headers of the columns in the CSV file.

    * `server_url`: URL of the DOMjudge server (without trailing slash)

    * `server_username`, `server_password`: login data of the user which
      will be used to fetch the submissions. It must have admin or jury role.

    * `problem_name`, `contest_name`: name of the problem to be downloaded, and
      the context to which it belongs.

    * `deadline`: date and time of the last submission accepted (if given)

    * `last_allowed`: identifier of the last submission gathered. All submissions
       send after it will be discarded.

    * `only_accepted`: boolean that specifies whether to consider only submissions
       with an AC judgement.

    * `output_dir`: name of directory in which the output files (.tex and source code)
      will be generated.

    * `strip_outside_tags`: when set to true, strips away all the code which is not
      contained within `@ <answer>` and `@ </answer>` tags.

  """

  @type t() :: %__MODULE__{
          csv_file_name: String.t(),
          csv_header: %{String.t() => String.t()},
          server_url: String.t(),
          server_username: String.t(),
          server_password: String.t(),
          contest_name: String.t(),
          problem_name: String.t(),
          deadline: NaiveDateTime.t() | nil,
          last_allowed: integer() | nil,
          only_accepted: boolean(),
          output_dir: String.t(),
          strip_outside_tags: boolean()
        }

  defstruct [
    :csv_file_name,
    :csv_header,
    :server_url,
    :server_username,
    :server_password,
    :contest_name,
    :problem_name,
    :deadline,
    :last_allowed,
    :only_accepted,
    :output_dir,
    :strip_outside_tags
  ]

  defmodule MissingOptionError do
    defexception [:option_name]

    @impl true
    def message(exception) do
      "Missing option: #{exception.option_name}"
    end
  end

  defmodule InvalidDeadlineError do
    defexception message: "Invalid deadline format. Expected: YYYY-MM-DD HH:MM:SS"
  end

  defmodule InvalidLastSubmissionError do
    defexception message: "Value of last_allowed must be an integer number"
  end

  defmodule ExpectedBoolean do
    defexception [:field]

    @impl true
    def message(ex), do: "Value of #{ex.field} must be a boolean (true or false without quotes)"
  end

  @required_header_fields ["name", "surname", "user_id"]
  @default_output_dir "out"

  @doc """
  Obtains a `t:t/0` struct from a string that contains YAML content.

  All options are validated and processed, raising the following exceptions if
  there is any error:

    * `GatherSubmissions.Config.MissingOptionError`, when a mandatory option
      is ommited.

    * `GatherSubmissions.Config.InvalidDeadlineError`, when the deadline option
      does not contain a valid date in format `YYYY-MM-DD HH:MM:SS`.

    * `GatherSubmissions.Config.InvalidLastSubmissionError`, when the lastSubmission
      option does not contain an integer number

    * `GatherSubmissions.Config.ExpectedBoolean`, when `only_accepted` or
      `strip_outside_tags` options contain a string different from `true` or `false`.

  """
  @spec read_from_yaml(String.t()) :: t()
  def read_from_yaml(string) do
    yaml = YamlElixir.read_from_string!(string)

    %__MODULE__{}
    |> cast_mandatory_field(yaml, :csv_file_name)
    |> cast_mandatory_field(yaml, :csv_header, &cast_header/1)
    |> cast_optional_field(yaml, :server_url, &String.trim_trailing(&1, "/"))
    |> cast_mandatory_field(yaml, :server_username)
    |> cast_mandatory_field(yaml, :server_password)
    |> cast_mandatory_field(yaml, :contest_name)
    |> cast_mandatory_field(yaml, :problem_name)
    |> cast_optional_field(yaml, :deadline, &cast_deadline/1)
    |> cast_optional_field(yaml, :last_allowed, &expect_integer/1)
    |> cast_optional_field(yaml, :only_accepted, &expect_boolean(&1, "only_accepted"), false)
    |> cast_optional_field(yaml, :output_dir, &convert_to_string/1, @default_output_dir)
    |> cast_optional_field(
      yaml,
      :strip_outside_tags,
      &expect_boolean(&1, "strip_outside_tags"),
      false
    )
  end

  defp cast_mandatory_field(
         config,
         map,
         field,
         process_fun \\ fn val -> convert_to_string(val) end
       ) do
    field_string = to_string(field)

    if map[field_string] in [nil, ""] do
      raise MissingOptionError, option_name: field_string
    else
      Map.put(config, field, process_fun.(map[field_string]))
    end
  end

  defp cast_header(header) do
    case Enum.find(@required_header_fields, nil, &(not Map.has_key?(header, &1))) do
      nil -> header
      field -> raise MissingOptionError, option_name: "csv_header.#{field}"
    end
  end

  defp cast_optional_field(config, map, field, process_fun, default \\ nil) do
    field_string = to_string(field)

    if map[field_string] in [nil, ""] do
      Map.put(config, field, default)
    else
      Map.put(config, field, process_fun.(map[field_string]))
    end
  end

  defp convert_to_string(str) when is_binary(str), do: str

  defp convert_to_string(number) when is_integer(number) or is_float(number),
    do: to_string(number)

  defp cast_deadline(string) when is_binary(string) do
    case NaiveDateTime.from_iso8601(string) do
      {:ok, dt} ->
        dt |> NaiveDateTime.add(1, :second)

      {:error, :invalid_format} ->
        raise InvalidDeadlineError
    end
  end

  defp cast_deadline(_other), do: raise(InvalidDeadlineError)

  defp expect_integer(number) when is_integer(number), do: number
  defp expect_integer(_other), do: raise(InvalidLastSubmissionError)

  defp expect_boolean(true, _), do: true
  defp expect_boolean(false, _), do: false
  defp expect_boolean(_other, field), do: raise(ExpectedBoolean, field: field)
end
