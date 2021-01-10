defmodule GatherSubmissions.Config.DefaultConfig do
  @moduledoc """
  Contains the default configuration file that will be generated when calling
  `GatherSubmissions` in a directory which does not contain a configuration file.
  """

  @default_yaml """
  #
  # This configuration file has been automatically generated.
  #
  # Modify it to configure the retrieval options and then
  # run gather_submissions again in the same directory as this
  # configuration file.
  #
  #


  #
  # csv_file_name (String)
  # -------------
  #
  # Name of the CSV file containing students data. Path is relative
  # to the current directory.
  #
  # The first line of the CSV has to contain a header (see below); the rest
  # of the lines contain the information regarding students, one per line.
  #
  # Example of a CSV file:
  #
  # ST_Surname,ST_Name,Email,DOMUser,Group
  # DOE,JOE,johndoe@server.com,C10,1
  # FOOBAR,ALICE,alice@another.com,C20,2
  # ...etc...
  #
  #
  csv_file_name: "StudentsList.csv"



  # csv_header
  # ----------
  #     name (String)
  #     surname (String)
  #     user_id (String)
  #     group (String, optional)
  #
  # As explained in the previous option, the first line of the CSV file should
  # contain a header with the name of each field. The following section specifies
  # which fields in each line of the CSV file will be used in order to retrieve the
  # submissions and generate the PDF file.
  #
  # The 'name', 'surname' options, which are mandatory, contain the name of
  # the columns containing the name and surname of each student, respectively.
  #
  # The 'user_id' option, which is also mandatory, specifies the name of the
  # column in the CSV containing the student's identifier in DOMjudge
  #
  # The 'group' option is optional, and specifies the name of the column which
  # contains the group to which each student belongs. This column contains an
  # identifier for the group, so that students whose group identifier is the same
  # are assumed to belong to the same team, so their submissions will be jointly
  # taken into account. This implies, in particular, that the PDF file will contain
  # only one submission for each group, which will be the last one submitted by
  # any of its members.
  #
  # If the 'group' option is ommited, each student will be assumed to work on their
  # own, so the output PDF file will contain the last submission of each student.
  #
  # For example, in the CSV file shown above we should have:
  #
  # csv_header:
  #   name: "ST_Name"
  #   surname: "ST_Surname"
  #   user_id: "DOMUser"
  #   group: "Group"

  csv_header:
    name: "Nombre"
    surname: "Apellidos"
    user_id: "Usuario"
    group: "Grupo"


  # The following options contain the access data to DOMjudge's server. All of these
  # are mandatory.
  #
  # The 'server_username' and 'server_password' have to contain the login
  # information of a DOMjudge user, which must have jury/admin role.
  #
  #   server_url (String)
  #   server_username (String)
  #   server_password (String)

  server_url: "http://ed.fdi.ucm.es/domjudge"
  server_username: "enter your username here"
  server_password: "enter your password here"

  # contest_name (String)
  # ------------
  #
  # It contains the name of the contest in DOMjudge to which the problem specified
  # below belongs.

  contest_name: "ED-C"

  # problem_name (String)
  # ------------
  #
  # It contains the abbreviated name of the problem in DOMjudge whose submissions
  # will be downloaded.

  problem_name: "C04"

  # deadline (String, optional)
  # --------
  #
  # If specified, it will discard all the submissions that were submitted
  # *strictly after* the given date/time. Date must be formatted as follows:
  #
  # YYYY-MM-DD HH:MM:SS

  #deadline: "2020-02-20 23:59:59"

  # last_allowed (Integer, optional)
  # ------------
  #
  # If specified, it will discard all the submissions whose Submission ID is
  # *strictly greater* than the given integer.
  #
  # This is useful when one wants to gather only the submissions that were
  # sent before (and including) a given one.

  #last_allowed: 3918

  # only_accepted (Boolean, optional, default: false)
  # -------------
  #
  # If set to true, the resulting PDF file will only take AC submissions into account
  # when displaying the source code of a team.
  #
  # If set to false, the PDF file will contain the source code of the latest
  # submission (again, before the deadline if appliable), regardless of its verdict.

  #only_accepted: true

  # output_dir (String, optional, default: "out")
  # ----------
  #
  # It contains the name of the directory in which the 'main.tex' file and the
  # source code of the downloaded submissions will be generated.
  #

  #output_dir: "result"

  # strip_outside (Boolean, optional, default: false)
  # -------------
  #
  # If set to true, the PDF file will only display the lines of the source
  # code contained within the delimiters "@ <answer>" and "@ </answer>", respectively
  #
  # This is useful when you give a template to the students, so that they have
  # to fill in the gaps.
  #
  # Zero, one, or several spaces are allowed between the @ symbol and the corresponding tag.
  #
  # For example, if you work with C++, you could give your students the following template:
  #
  #       #include <iostream>
  #       #include <stack>
  #
  #       // Enter your name here:
  #       //@ <answer>
  #       // Name:
  #       //@ </answer>
  #
  #       ... boilerplate code ...
  #
  #       //@ <answer>
  #       ... students should fill in their answers here...
  #       //@ </answer>
  #
  #       ... more boilerplate code ...
  #
  #       //@ <answer>
  #       ... more answers here ...
  #       //@ </answer>
  #
  # and the boilerplate code would be stripped away from the output.
  #
  #
  # IMPORTANT: If the file submitted by a student does not contain such tags, it
  # will be displayed as a whole, regardless of the value of this option. This is
  # just as a protection for those students which inadvertendly erase the tags
  # from the template.
  #

  #strip_outside_tags: true
  """
  @doc """
  Returns a YAML string with default configuration.
  """
  @spec default_yaml() :: String.t()
  def default_yaml(), do: @default_yaml
end
