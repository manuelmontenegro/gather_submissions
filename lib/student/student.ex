defmodule GatherSubmissions.Student do
  @moduledoc """
  It defines the `#{__MODULE__} |> Module.split() |> List.last()` struct, which contains information
  on a given student.

  * `name`: name of the student.

  * `surname`: surname of the student.

  * `user`: DOMjudge user name corresponding to the student.

  * `group`: group identifier to which the student belongs.
  """

  @type t() :: %__MODULE__{
          name: String.t(),
          surname: String.t(),
          user: String.t(),
          group: String.t()
        }
  defstruct [:name, :surname, :user, :group]
end
