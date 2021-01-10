defmodule GatherSubmissions.DOMjudge do
  @moduledoc """
  This module defines a function `gather_submissions` that uses the
  DOMjudge API to obtain the submissions of a given problem.
  """

  alias GatherSubmissions.DOMjudge.API
  alias GatherSubmissions.DOMjudge.Connection
  alias GatherSubmissions.Submission
  alias GatherSubmissions.Submission.File, as: SubFile

  defmodule ContestNotFoundError do
    defexception [:contest]

    @impl true
    def message(exc), do: "Contest not found: #{exc.contest}"
  end

  defmodule ProblemNotFoundError do
    defexception [:problem]

    @impl true
    def message(exc), do: "Problem not found: #{exc.problem}"
  end

  @doc """
  It gathers all the submission of a given problem in a given contest.

  The `problem_name` and `contest_name` parameters contain the name of the problem to
  be retrieved and the contest to which it belongs.

  Retrieval progress is reported by calling the `logger` function with an informative
  message.

  **IMPORTANT:** The source code is not downloaded by this function. Instead, the
  `Submission.t()` returns a closure which, when executed, performs the retrieval of
  the source code.
  """
  @spec gather_submissions(Connection.t(), String.t(), String.t(), (String.t() -> any())) :: [
          Submission.t()
        ]
  def gather_submissions(conn, contest_name, problem_name, logger \\ fn _ -> :ok end) do
    # Retrieve contest and problem IDS
    contest_id = API.get_contest_id_by_name(conn, contest_name)
    if contest_id == nil, do: raise(ContestNotFoundError, contest: contest_name)
    logger.("Contest ID: #{contest_id}")
    problem_id = API.get_problem_id_by_name(conn, contest_id, problem_name)
    if problem_id == nil, do: raise(ProblemNotFoundError, problem: problem_name)
    logger.("Problem ID: #{problem_id}")

    logger.("Fetching users...")
    teams = API.get_public_teams(conn, contest_id)

    logger.("Fetching judgements...")
    judgements = API.get_judgements(conn, contest_id)

    logger.("Fetching list of submissions...")
    subs = API.get_submissions(conn, contest_id, problem_id)

    user_table = build_user_table(teams)

    # judgements_table maps each submission ID to its judgement ID
    judgements_table = build_judgement_table(judgements)

    subs
    |> Enum.map(&into_domjudge_submission(&1, conn, contest_id, user_table, judgements_table))
  end

  defp build_user_table(users) do
    users
    |> Enum.map(fn %{"id" => id, "name" => name} -> {id, name} end)
    |> Enum.into(%{})
  end

  defp build_judgement_table(judgements) do
    judgements
    |> Enum.map(fn %{"submission_id" => sub_id, "judgement_type_id" => judgement} ->
      {sub_id, judgement}
    end)
    |> Enum.into(%{})
  end

  defp into_domjudge_submission(submission, conn, contest_id, user_table, judgements_table) do
    %{"id" => id, "team_id" => team_id, "time" => time} = submission
    require Logger

    %Submission{
      id: id,
      user: user_table[team_id],
      time: NaiveDateTime.from_iso8601!(time),
      verdict: judgements_table[id],
      files: fn ->
        get_source_code(conn, contest_id, id)
      end
    }
  end

  defp get_source_code(conn, contest_id, submission_id) do
    API.get_source_code(conn, contest_id, submission_id)
    |> Enum.map(fn %{"filename" => name, "source" => source_base_64} ->
      %SubFile{name: name, content: source_base_64 |> Base.decode64!()}
    end)
  end
end
