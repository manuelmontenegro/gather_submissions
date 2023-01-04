defmodule GatherSubmissions.Report.Templates do
  @moduledoc """
  This module defines a function that transforms a list of `t:GatherSubmissions.Report.t/0` into LaTeX source code.
  """

  require EEx

  @report_template ~S"""
  \documentclass{article}
  \usepackage[spanish]{babel}
  \usepackage[T1]{fontenc}
  \usepackage[default]{raleway}
  \usepackage{fullpage}
  \usepackage{listings}
  \usepackage{amsmath}
  \usepackage{amsfonts}
  \usepackage{tabularx}
  \usepackage{color}
  \usepackage{colortbl}
  \usepackage[listings]{tcolorbox}
  \usepackage{comment}

  \setmonofont{Inconsolata}

  \definecolor{mygreen}{rgb}{0,0.6,0}
  \definecolor{mygray}{rgb}{0.5,0.5,0.5}
  \definecolor{mymauve}{rgb}{0.58,0,0.82}


  \lstset{
    backgroundcolor=\color{white},   % choose the background color; you must add \usepackage{color} or \usepackage{xcolor}; should come as last argument
    basicstyle=\ttfamily,        % the size of the fonts that are used for the code
    columns=fullflexible,
    breakatwhitespace=false,         % sets if automatic breaks should only happen at whitespace
    breaklines=true,                 % sets automatic line breaking
    commentstyle=\color{mygreen},    % comment style
    deletekeywords={...},            % if you want to delete keywords from the given language
    extendedchars=true,              % lets you use non-ASCII characters; for 8-bits encodings only, does not work with UTF-8
    % frame=single,	                   % adds a frame around the code
    keepspaces=true,                 % keeps spaces in text, useful for keeping indentation of code (possibly needs columns=flexible)
    keywordstyle=\color{blue},       % keyword style
    language=C++,                    % the language of the code
    stringstyle=\color{mymauve},     % string literal style
    tabsize=2	                   % sets default tabsize to 2 spaces
  }

  \definecolor{Oscuro}{rgb}{0,0.4,0.4}
  \definecolor{Claro}{rgb}{0.3,0.8,0.8}
  \definecolor{Accept}{rgb}{0.01, 0.75, 0.24}
  \definecolor{Reject}{rgb}{0.55, 0.0, 0.0}
  \definecolor{Selected}{rgb}{0.97, 0.91, 0.81}

  \newcounter{startsubmission}
  \newwrite\myoutput
  \immediate\openout\myoutput=pages_per_group.output

  \begin{document}
  <%= for report <- reports do %>
  <%#--------------------------------------- REPORT --------------------------------------- %>
    \setcounter{startsubmission}{\thepage}

    <%#--------------------------------------- STUDENTS ----------------------------------- %>
    \begin{tcolorbox}[colback=Claro!70,colframe=Oscuro]
      \begin{center}
        {\Large\textbf{Grupo <%= report.group_id %>}}\end{center}
      \tcblower
      \textbf{Estudiantes:}

      \begin{itemize}
        <%= for st <- report.students do %>
          \item <%= st.surname %>, <%= st.name %> (<%= st.user %>)
        <% end %>
      \end{itemize}
    \end{tcolorbox}
    <%#------------------------------------ END STUDENTS ---------------------------------- %>

    <%#------------------------------------- ATTEMPTS ------------------------------------- %>
    <%= if report.attempts != [] do %>
      \begin{center}\begin{tabular}{|c|c|l|c|}\hline
      \textbf{ID envio} & \textbf{Usuario/a} & \textbf{Hora envío} & \textbf{Veredicto} \\\hline
      <%= for attempt <- report.attempts do %>
        <%= if attempt.selected do %>\rowcolor{Selected}<% end %>
        <%= attempt.submission_id %> & <%= attempt.user_id %> & <%= attempt.time %> & 
          <%= if attempt.verdict == "AC" do %>
            \textcolor{Accept}{\textbf{AC}}
          <% else %>
            \textcolor{Reject}{\textbf{<%= attempt.verdict %>}}
          <% end %>
        \\\hline
      <% end %>
      \end{tabular}\end{center}
    <% end %>
    <%#------------------------------------ END ATTEMPTS ---------------------------------- %>

    <%#--------------------------------- FILE CONTENTS ------------------------------------ %>
    <%= if report.local_files do %>
      <%= for file <- report.local_files do %>
        Fichero \verb|<%= Path.basename(file) %>|
        \lstinputlisting[language=C++]{<%= file %>}
      <% end %>
    <% else %>
      No hay ninguna entrega ACCEPT antes de la fecha límite.
    <% end %>
    \write\myoutput{<%= report.group_id %>,\thestartsubmission,\thepage}
    <%#-------------------------------- END FILE CONTENTS --------------------------------- %>

    \newpage
  <%#------------------------------------- END REPORT ------------------------------------- %>
  <% end %>
  \end{document}
  """

  EEx.function_from_string(:defp, :submission_reports_default, @report_template, [:reports])


  @doc """
  Generates the LaTeX code corresponding to a list of reports.

  It may receive the name of an EEX file as second parameter. If this parameter is `nil`,
  it uses a default template.
  """
  @spec submission_reports([GatherSubmissions.Report.t()], String.t() | nil) :: String.t()
  def submission_reports(reports, template \\ nil, logger \\ fn _ -> :ok end)

  def submission_reports(reports, nil, _), do: submission_reports_default(reports)
  def submission_reports(reports, template, logger) do
    logger.("Using custom template at #{template}")
    EEx.eval_string(File.read!(template), reports: reports)
  end


  @doc """
  It returns the default template in EEx format.
  """
  @spec default_template() :: String.t()
  def default_template() do
    @report_template
  end
end
