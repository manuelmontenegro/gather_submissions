defmodule GatherSubmissions.Submission.Utils do
  @moduledoc """
  Contains some utility functions to work with DOMjudge submissions.
  """

  alias GatherSubmissions.Submission
  alias GatherSubmissions.Submission.File, as: SubFile
  alias GatherSubmissions.Student

  @doc """
  Given a list of submissions, removes those submitted after the given `deadline`.
  """
  @spec reject_after_deadline([Submission.t()], NaiveDateTime.t()) :: [Submission.t()]
  def reject_after_deadline(submissions, deadline) do
    submissions
    |> Enum.reject(&(NaiveDateTime.compare(&1.time, deadline) == :gt))
  end

  @doc """
  Given a list of submissions, removes those submitted after the one with the given id.
  """
  @spec reject_after_submission([Submission.t()], String.t()) :: [Submission.t()]
  def reject_after_submission(submissions, last_submission) do
    submissions
    |> Enum.reject(&(String.to_integer(&1.id) > last_submission))
  end

  @doc """
  Classifies the submissions according to the group to which they belong.

  If two students belong to the same group, their submissions will appear in the list corresponding
  to that group.

  This function returns a map that associates group identifiers with their corresponding lists of
  submissions.
  """
  @spec classify_by_group([Submission.t()], [Student.t()]) :: %{String.t() => [Submission.t()]}
  def classify_by_group(submissions, students) do
    user_table = students |> Enum.map(&{&1.user, &1}) |> Enum.into(%{})
    groups = get_all_groups(students)
    empty_map = groups |> Enum.map(&{&1, []}) |> Enum.into(%{})

    groups_map = submissions |> Enum.group_by(fn sub -> user_table[sub.user].group end)

    merged = Map.merge(empty_map, groups_map)

    :maps.map(
      fn _, list ->
        Enum.sort_by(list, &String.to_integer(&1.id), :desc)
      end,
      merged
    )
  end

  @doc """
  Returns the first submission on the list for which the given predicate holds.
  """
  @spec first_submission([Submission.t()], (Submission.t() -> boolean())) :: Submission.t() | nil
  def first_submission(submissions, verdict_fun \\ fn _ -> true end) do
    Enum.find(submissions, nil, verdict_fun)
  end

  @doc """
  Downloads and creates the files corresponding to a given submission.

  All files will be created in `root_dir/subdir` directory, which will be created if necessary.

  Before writing the file, the function `transform_content` will be applied to its contents. This is
  useful for preprocessing the file (e.g. stripping away content) before writing it.

  It returns the list of the names of the generated files, **relative to `root_dir`**.
  """
  @spec create_local_files(Submission.t(), String.t(), String.t(), (String.t() -> String.t())) ::
          [String.t()]
  def create_local_files(
        %Submission{} = submission,
        root_dir,
        subdir,
        transform_content \\ fn content -> content end
      ) do
    subdir_name = Path.join(root_dir, subdir)
    File.mkdir_p!(subdir_name)

    submission.files.()
    |> Enum.map(fn %SubFile{name: name, content: content} ->
      local_file_name = Path.join(subdir_name, name)
      File.write!(local_file_name, transform_content.(content |> convert_to_utf8()))
      Path.join(subdir, name)
    end)
  end

  defp convert_to_utf8(content) do
    case :unicode.characters_to_binary(content) do
      {:error, _, _} ->
        case :unicode.characters_to_binary(content, :latin1) do
          {:error, _, _} -> content
          bin -> bin
        end
      _ -> content
    end
  end

  defp get_all_groups(students) do
    students
    |> Enum.map(& &1.group)
    |> Enum.dedup()
  end
end
