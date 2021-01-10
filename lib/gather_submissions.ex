defmodule GatherSubmissions do
  @moduledoc """
  *GatherSubmissions* is a tool that obtains the submissions of a problem in a DOMjudge server,
  and generates a LaTeX file that, when rendered into a PDF, contains all the submissions with
  the names of their authors.

  This tool can be useful in academic contexts in which a lecturer uses DOMjudge in their
  subjects, and wants to gather all the submitted files in order to grade them.
  """

  alias GatherSubmissions.DOMjudge
  alias GatherSubmissions.Student
  alias GatherSubmissions.Submission
  alias GatherSubmissions.Report
  alias GatherSubmissions.TextUtils
  alias GatherSubmissions.Config, as: GConfig

  @doc """
  Retrieves all the submissions of a DOMjudge problem, and generates a LaTeX file
  with their source code.

  The `config` parameter contains a struct with all the configuration options, which
  include the name of the CSV file containing the information of students, DOMjudge
  access data, etc. See `GatherSubmissions.Config` for more details.

  This function reports the progress of the retrieval process by calling the
  `logger` function with a message string in each phase.
  """

  @spec gather_submissions(GatherSubmissions.Config.t()) :: :ok
  def gather_submissions(%GConfig{} = config, logger \\ fn _ -> :ok end) do
    students = fetch_students(config)
    grouped_subs = fetch_submissions_by_group(config, students, logger)
    selected_subs = select_sub_for_each_group(config, grouped_subs)

    text =
      build_reports(config, grouped_subs, selected_subs, students, logger)
      |> sort_reports()
      |> Report.Templates.submission_reports()

    output_file = Path.join(config.output_dir, "main.tex")
    File.mkdir_p!(config.output_dir)
    File.write!(output_file, text)
  end

  defp fetch_students(%GConfig{} = config) do
    Student.Reader.read_students_from_csv(
      config.csv_file_name,
      config.csv_header
    )
    |> set_default_group()
  end

  defp create_connection(server, username, password) do
    DOMjudge.Connection.create(server)
    |> DOMjudge.Connection.with_authorization(username, password)
  end

  defp set_default_group(students) do
    group_names = students |> Enum.map(& &1.group) |> MapSet.new()
    Enum.map(students, &set_default_group_student(&1, group_names))
  end

  # This function sets a default group id for all students with do not have one.
  # By default, the DOMjudge id of the user is used, but if there is alredy a group
  # with that name, it adds the `_group` suffix repeatedly until we ensure that
  # the generated group name is fresh.
  defp set_default_group_student(%Student{user: user, group: gr} = st, group_names)
       when gr == nil or gr == "" do
    name =
      Stream.iterate(user, &(&1 <> "_group"))
      |> Enum.find(&(&1 not in group_names))

    %Student{st | group: name}
  end

  defp set_default_group_student(student, _), do: student

  defp possibly_reject_after_deadline(subs, %GConfig{deadline: nil}), do: subs

  defp possibly_reject_after_deadline(subs, %GConfig{deadline: deadline}) do
    Submission.Utils.reject_after_deadline(subs, deadline)
  end

  defp possibly_reject_after_submission(subs, %GConfig{last_allowed: nil}), do: subs

  defp possibly_reject_after_submission(subs, %GConfig{last_allowed: last}) do
    Submission.Utils.reject_after_submission(subs, last)
  end

  defp fetch_submissions_by_group(%GConfig{} = config, students, logger) do
    require Logger

    users_ids = students |> Enum.map(& &1.user) |> MapSet.new()

    create_connection(config.server_url, config.server_username, config.server_password)
    |> DOMjudge.gather_submissions(config.contest_name, config.problem_name, logger)
    |> Enum.filter(&(&1.user in users_ids))
    |> possibly_reject_after_deadline(config)
    |> possibly_reject_after_submission(config)
    |> Submission.Utils.classify_by_group(students)
  end

  # It selects the latest submission for each group. This could be the last accepted submission
  # depending on the `only_accepted` option
  defp select_sub_for_each_group(%GConfig{only_accepted: only_accepted}, grouped_subs) do
    selection_fun = if only_accepted, do: &(&1.verdict == "AC"), else: fn _ -> true end

    :maps.map(
      fn _, subs -> Submission.Utils.first_submission(subs, selection_fun) end,
      grouped_subs
    )
  end

  defp fetch_source_code(%Submission{} = sub, output_dir, group_id, strip_outside_tags, logger) do
    possibly_strip_tags =
      if strip_outside_tags, do: &TextUtils.strip_tags/1, else: fn text -> text end

    logger.("Downloading source code of submission no. #{sub.id}")

    Submission.Utils.create_local_files(
      sub,
      output_dir,
      group_id,
      fn contents ->
        contents
        |> TextUtils.remove_fi_digraph()
        |> TextUtils.remove_bom()
        |> possibly_strip_tags.()
      end
    )
  end

  defp build_reports(%GConfig{} = config, grouped_subs, selected_sub, students, logger) do
    # Table that associates groups to lists of students
    groups_table = students |> Enum.group_by(fn st -> st.group end)

    number_of_downloads = selected_sub |> Enum.count(fn {_, v} -> v != nil end)

    {:ok, counter} = Agent.start_link(fn -> 1 end)

    fetch_logger = fn str ->
      val = Agent.get_and_update(counter, fn c -> {c, c + 1} end)
      logger.("[#{val}/#{number_of_downloads}] " <> str)
    end

    result =
      for {group_id, subs} <- grouped_subs do
        selected = Map.fetch!(selected_sub, group_id)
        students_of_group = Map.fetch!(groups_table, group_id)

        Report.build_report(group_id, subs, selected, students_of_group, fn
          nil ->
            nil

          %Submission{} = sel ->
            fetch_source_code(
              sel,
              config.output_dir,
              group_id,
              config.strip_outside_tags,
              fetch_logger
            )
        end)
      end

    Agent.stop(counter)

    result
  end

  defp convert_if_integer(id) do
    case Integer.parse(id) do
      {int, ""} -> int
      :error -> id
    end
  end

  defp sort_reports(reports) do
    Enum.sort_by(reports, &convert_if_integer(&1.group_id))
  end
end
