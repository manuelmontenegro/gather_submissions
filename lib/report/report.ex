defmodule GatherSubmissions.Report do
  alias GatherSubmissions.Submission
  alias GatherSubmissions.Student

  defmodule Attempt do
    @moduledoc """
    Describes an individual attempt of a given group. This is used when generating the table of
    attempts in the LaTeX file.
    """

    @type t() :: %__MODULE__{
            submission_id: String.t(),
            user_id: String.t(),
            time: String.t(),
            verdict: String.t(),
            selected: boolean()
          }
    defstruct [:submission_id, :user_id, :time, :verdict, :selected]
  end

  @moduledoc """
  This module defines the type `t:t/0` of group reports. Each report contains the students of
  that group, the list of `t:GatherSubmissions.Report.Attempt.t/0` structs with each submission attempt, and the names of the
  local files associated with the selected submission (i.e. the one to be graded).
  """

  @type t() :: %__MODULE__{
          group_id: String.t(),
          students: [Student.t()],
          attempts: [Attempt.t()],
          local_files: [String.t()]
        }

  defstruct [:group_id, :students, :attempts, :local_files]

  @doc """
  Builds a `t:t/0` struct with the given information.

  It receives the following parameters:

  * `group_id` contains the identifier of the students group corresponding to this report.

  * `submission` is a list of attempts.

  * `selected` contains the submission that will be downloaded and graded.

  * `students` is the list of students belonging to the group given by `group_id`.

  * `local_files_fun` is a callback function that fetches the source code of the selected submission and
    stores it locally. This function should return the name of the local files created, relative to the output
    directory.
  """
  @spec build_report(
          String.t(),
          [Submission.t()],
          Submission.t(),
          [Student.t()],
          (Submission.t() -> [String.t()])
        ) :: t()
  def build_report(group_id, submissions, selected, students, local_files_fun) do
    %__MODULE__{
      group_id: group_id,
      students: students,
      attempts:
        for %Submission{id: id, user: user_id, time: naive_time, verdict: verdict} <- submissions do
          %Attempt{
            submission_id: id,
            user_id: user_id,
            time: time_to_string(naive_time),
            verdict: verdict,
            selected: selected != nil && id == selected.id
          }
        end,
      local_files: local_files_fun.(selected)
    }
  end

  defp time_to_string(nil) do
    "<Not specified>"
  end

  defp time_to_string(%NaiveDateTime{} = naive_time) do
    NaiveDateTime.to_iso8601(naive_time)
  end
end
