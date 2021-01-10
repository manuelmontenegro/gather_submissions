defmodule GatherSubmissions.DOMjudge.Connection do
  @moduledoc """
  Defines a struct containing connection information to a server, and provides basic functions for
  issuing authorized GET requests.

  This information consists in the URL of the DOMjudge server (`endpoint`), and
  login data (`username` and `password` fields).
  """

  @type t :: %__MODULE__{
          endpoint: String.t(),
          username: String.t() | nil,
          password: String.t() | nil
        }
  defstruct [:endpoint, :username, :password]

  defmodule UnauthorizedError do
    defexception message: "DOMjudge request failed: Unauthorized"
  end

  defmodule ConnectionError do
    defexception [:url, :status_code]

    @impl true
    def message(exception) do
      "DOMjudge request failed: received #{exception.status_code} on url: #{exception.url}"
    end
  end

  @doc """
  Creates a connection to the server given in the `url` parameter.
  """
  @spec create(String.t()) :: t()
  def create(url) do
    %__MODULE__{endpoint: url}
  end

  @doc """
  Extends the connection with login info.
  """
  @spec with_authorization(t(), String.t(), String.t()) :: t()
  def with_authorization(conn, username, password) do
    %__MODULE__{conn | username: username, password: password}
  end

  @doc """
  Issues a GET request with the given `query_params`, and parses the result, which is
  expected to be in JSON format.

  It raises an `Connection.UnauthorizedError` exception when the servers return a 401 code.

  It raises an `Connection.ConnectionError` exception when the servers return a code different
  from 200 or 401.
  """
  @spec get(t(), String.t(), Keyword.t()) :: any()
  def get(%__MODULE__{} = conn, url, query_params \\ []) do
    query_string = if query_params == [], do: "", else: "?" <> URI.encode_query(query_params)
    headers = [accept: "application/json"] |> with_auth_header(conn)
    full_url = conn.endpoint <> url <> query_string
    response = HTTPoison.get!(full_url, headers)

    case response.status_code do
      200 ->
        Jason.decode!(response.body)

      401 ->
        raise UnauthorizedError

      x when not (x >= 200 and x < 300) ->
        raise ConnectionError, url: full_url, status_code: response.status_code
    end
  end

  defp with_auth_header(headers, %__MODULE__{username: nil}) do
    headers
  end

  defp with_auth_header(headers, %__MODULE__{username: username, password: password}) do
    encoded_login = "#{username}:#{password}" |> Base.encode64()

    headers
    |> Keyword.put(:authorization, "Basic #{encoded_login}")
  end
end
