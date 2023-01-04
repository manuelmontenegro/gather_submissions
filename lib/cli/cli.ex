defmodule GatherSubmissions.CLI do
  @config_file "gather_submissions.yaml"
  @template_file "gather_submissions_template.eex"

  @usage """
  USAGE:

  gather_submissions
    If #{@config_file} does not exist, it generates a default configuration file.
    If it exists, downloads submissions of the exercise specified in #{@config_file}

  gather_submissions --gen-template
    It generates a default template file: #{@template_file} 
  """

  @moduledoc """
  Manages the command-line interface (CLI) tool. It contains the `main/1` function.

  The CLI tool checks for the existence of a `#{@config_file}` configuration file. If not found,
  then a skeleton configuration file is generated in the current directory. Otherwise, the
  configuration is read and then `GatherSubmissions.gather_submissions/2` is called with the
  parsed configuration, which performs all the retrieval and PDF generation.
  """

  @doc """
  Main function of the CLI tool.

  If it receives no arguments, it tries to read `#{@config_file}` file from the current directory.
  If `#{@config_file}` does not exist, it generates a template configuration file for the user to
  fill in. Otherwise, it reads the configuration options and download the submissions according to
  the information given in that file.

  If the `--gen-template` option is given as parameter, it generates a default LaTeX template file
  and exits.
  """

  @spec main(any()) :: :ok
  def main([]) do
    if File.exists?(@config_file) do
      template_file = if File.exists?(@template_file), do: @template_file, else: nil
      run(@config_file, template_file)
    else
      log("No configuration file found. Creating it")
      create_default_config(@config_file)
      IO.puts("Configuration file created")
      IO.puts("Edit #{@config_file} and then run again")
    end
  end
  def main(["--gen-template"]) do
    if File.exists?(@template_file) do      
      IO.puts(in_red("Error:") <> " #{@template_file} already exists")
      IO.puts("If you want the default template, delete #{@template_file} from the current directory.")
    else
      File.write!(@template_file, GatherSubmissions.Report.Templates.default_template())
      log("Template created in #{@template_file}.")
    end
  end
  def main(_) do
    IO.puts(in_red("Error:") <> " invalid arguments")
    IO.puts(@usage)
  end

  defp run(config_file, template_file) do
    try do
      config =
        File.read!(config_file)
        |> GatherSubmissions.Config.read_from_yaml()

      GatherSubmissions.gather_submissions(config, template_file, &log/1)
      output_file = Path.join(config.output_dir, "main.tex")
      IO.puts("Created #{output_file}")
    rescue
      exc -> IO.puts(("Error: " |> in_red()) <> Exception.message(exc))
    end
  end

  defp create_default_config(config_file) do
    File.write!(config_file, GatherSubmissions.Config.DefaultConfig.default_yaml())
  end

  defp in_red(text) do
    IO.ANSI.red() <> text <> IO.ANSI.reset()
  end

  defp in_green(text) do
    IO.ANSI.green() <> text <> IO.ANSI.reset()
  end

  defp log(text) do
    IO.puts(in_green("*") <> " " <> text)
  end
end
