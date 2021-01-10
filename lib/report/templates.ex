defmodule GatherSubmissions.Report.Templates do
  @moduledoc """
  This module defines a function that transforms a list of `t:GatherSubmissions.Report.t/0` into LaTeX source code.
  """

  require EEx

  @file_include_template ~S"""
  Fichero \verb|<%= Path.basename(file) %>|
  \lstset{inputencoding=utf8/latin1}
  \lstinputlisting[language=C++]{<%= file %>}
  """

  @attempt_row_template ~S"""
  <%= if attempt.selected do %>\rowcolor{Selected}<% end %>
  <%= attempt.submission_id %> & <%= attempt.user_id %> & <%= attempt.time %> & <%= color_verdict(attempt.verdict) %>
  """

  @attempt_table_template ~S"""
  \begin{center}\begin{tabular}{|c|c|l|c|}\hline
  \textbf{ID envio} & \textbf{Usuario/a} & \textbf{Hora envío} & \textbf{Veredicto} \\\hline
  <%= for attempt <- attempts do %>
    <%= attempt_row(attempt) %>\\\hline
  <% end %>
  \end{tabular}\end{center}
  """

  @submission_template ~S"""
  \begin{tcolorbox}[colback=Claro!70,colframe=Oscuro]
    \begin{center}
      {\Large\textbf{Grupo <%= report.group_id %>}}\end{center}
    \tcblower
    \textbf{Estudiantes:}

    \begin{itemize}<%= for st <- report.students do %>
      \item <%= st.surname %>, <%= st.name %> (<%= st.user %>)<% end %>
    \end{itemize}
  \end{tcolorbox}

  <%= if report.attempts != [], do: attempt_table(report.attempts) %>

  <%= if report.local_files do %>
  <%= for file <- report.local_files do %>
  <%= file_include(file) %>
  <% end %>
  <% else %>
  No hay ninguna entrega ACCEPT antes de la fecha límite.
  <% end %>
  """

  @whole_template ~S"""
  \documentclass{article}

  \usepackage[spanish]{babel}
  \usepackage[utf8]{inputenc}
  \usepackage[T1]{fontenc}
  \usepackage[default]{raleway}
  \usepackage{fullpage}
  \usepackage{listings}
  \usepackage{listingsutf8}
  \usepackage{inconsolata}
  \usepackage{amsmath}
  \usepackage{amsfonts}
  \usepackage{tabularx}
  \usepackage{color}
  \usepackage{colortbl}
  \usepackage[listings]{tcolorbox}
  \usepackage{comment}



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
  \setcounter{startsubmission}{\thepage}
  <%= submission_report(report) %>
  \write\myoutput{<%= report.group_id %>,\thestartsubmission,\thepage}
  \newpage
  <% end %>
  \end{document}
  """

  defp color_verdict("AC"), do: "\\textcolor{Accept}{\\textbf{AC}}"
  defp color_verdict(other), do: "\\textcolor{Reject}{\\textbf{#{other}}}"

  EEx.function_from_string(:defp, :file_include, @file_include_template, [:file])

  EEx.function_from_string(:defp, :submission_report, @submission_template, [:report])

  @doc """
  Genrates the LaTeX code corresponding to a list of reports.
  """
  @spec submission_reports([GatherSubmissions.Report.t()]) :: String.t()
  EEx.function_from_string(:def, :submission_reports, @whole_template, [:reports])

  EEx.function_from_string(:defp, :attempt_row, @attempt_row_template, [:attempt])

  EEx.function_from_string(:defp, :attempt_table, @attempt_table_template, [:attempts])
end
