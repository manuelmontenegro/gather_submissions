defmodule GatherSubmissions.Submission do
  @moduledoc """
  This module defines the `#{__MODULE__ |> Module.split() |> List.last()}` struct which contains the information
  of a specific submission. It contains the following fields:

  * `user`: login name of the user which sent the submission.

  * `id`: submission identifier.

  * `verdict`: result of judgement (AC, WA, RTE, etc.)

  * `time`: submission date and time

  * `files`: a list of source code files corresponding to the submission. It is wrapped
     in a closure that fetch the corresponding data.
  """

  defmodule File do
    @moduledoc """
    Defines the `#{__MODULE__ |> Module.split() |> List.last()}` struct which contains the information
    specific to a source code file.
    """
    @type t() :: %__MODULE__{
            name: String.t(),
            content: String.t()
          }
    defstruct [:name, :content]
  end

  @type t() :: %__MODULE__{
          user: String.t(),
          id: String.t(),
          verdict: String.t(),
          time: NaiveDateTime.t() | nil,
          files: (() -> [GatherSubmissions.Submission.File.t()])
        }
  defstruct [:user, :id, :verdict, :time, :files]
end
