defmodule GatherSubmissions.DOMjudge.API do
  alias GatherSubmissions.DOMjudge.Connection

  @moduledoc """
  This module wraps the API functionality provided by DOMjudge.
  """

  @contests_url "/api/v4/contests"
  @user_info_url "/api/v4/user"

  defp problems_url(contest_id) do
    "/api/v4/contests/#{contest_id}/problems"
  end

  defp submissions_url(contest_id) do
    "/api/v4/contests/#{contest_id}/submissions"
  end

  defp teams_url(contest_id) do
    "/api/v4/contests/#{contest_id}/teams"
  end

  defp judgements_url(contest_id) do
    "/api/v4/contests/#{contest_id}/judgements"
  end

  defp source_code_url(contest_id, submission_id) do
    "/api/v4/contests/#{contest_id}/submissions/#{submission_id}/source-code"
  end

  @doc """
  Returns the identifier of the DOMjudge contest whose name is given as parameter.
  """
  @spec get_contest_id_by_name(Connection.t(), String.t()) :: String.t() | nil
  def get_contest_id_by_name(conn, name) do
    Connection.get(conn, @contests_url)
    |> Enum.find(nil, fn contest -> contest["shortname"] == name end)
    |> Access.get("id")
  end

  @doc """
  Returns the identifier of the DOMjudge problem whose name is given as parameter.

  The `contest_id` parameter has to contain the identifier of the contest to which the
  problem belongs, not its name.
  """
  @spec get_problem_id_by_name(Connection.t(), String.t(), String.t()) :: String.t() | nil
  def get_problem_id_by_name(conn, contest_id, problem_name) do
    Connection.get(conn, problems_url(contest_id))
    |> Enum.find(nil, &(&1["short_name"] == problem_name))
    |> Access.get("id")
  end

  @doc """
  Returns a list of submissions corresponding to a given problem in a given contest.

  Both `contest_id` and `problem_id` parameters contain DOMjudge identifiers, not names.
  Use `get_contest_id_by_name/2` and `get_problem_id_by_name/3` to obtain those identifiers.
  """
  @spec get_submissions(Connection.t(), String.t(), String.t()) :: [map()]
  def get_submissions(conn, contest_id, problem_id) do
    Connection.get(conn, submissions_url(contest_id))
    |> Enum.filter(&(&1["problem_id"] == problem_id))
  end

  @doc """
  Returns a list of public DOMjudge users (teams) participating in a contest.

  The `contest_id` contains the identifier of a contest; not its name. Use
  `get_contest_id_by_name/2` to obtain the identifier if needed.
  """
  @spec get_public_teams(Connection.t(), String.t()) :: [map()]
  def get_public_teams(conn, contest_id) do
    Connection.get(conn, teams_url(contest_id), public: true)
  end

  @doc """
  Returns a list of judgements applied in a contest.

  The `contest_id` contains the identifier of a contest; not its name. Use
  `get_contest_id_by_name/2` to obtain the identifier if needed.
  """
  @spec get_judgements(Connection.t(), String.t()) :: [map()]
  def get_judgements(conn, contest_id) do
    Connection.get(conn, judgements_url(contest_id))
  end

  @doc """
  Returns the source code of a given submission.

  The `contest_id` contains the identifier of a contest; not its name. Use
  `get_contest_id_by_name/2` to obtain the identifier if needed.

  This function returns a list of maps, one for each file belonging to the submission.
  Each map contains a `"source"` key, with the contents of the file encoded in base 64.
  """
  @spec get_source_code(Connection.t(), String.t(), String.t()) :: [map()]
  def get_source_code(conn, contest_id, submission_id) do
    Connection.get(conn, source_code_url(contest_id, submission_id))
  end

  @doc """
  Returns the information of all users in the system.
  """
  @spec get_user_info(Connection.t()) :: [map()]
  def get_user_info(conn) do
    Connection.get(conn, @user_info_url)
  end
end
