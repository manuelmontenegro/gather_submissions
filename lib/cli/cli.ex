defmodule GatherSubmissions.CLI do
  @config_file "gather_submissions.yaml"

  @moduledoc """
  Manages the command-line interface (CLI) tool. It contains the `main/1` function.

  The CLI tool checks for the existence of a `#{@config_file}` configuration file. If not found,
  then a skeleton configuration file is generated in the current directory. Otherwise, the
  configuration is read and then `GatherSubmissions.gather_submissions/2` is called with the
  parsed configuration, which performs all the retrieval and PDF generation.
  """

  @doc """
  Main function of the CLI tool. The command line arguments (`args`) are ignored.
  """

  @spec main(any()) :: :ok
  def main(_args) do
    if File.exists?(@config_file) do
      run(@config_file)
    else
      log("No configuration file found. Creating it")
      create_default_config(@config_file)
      IO.puts("Configuration file created")
      IO.puts("Edit #{@config_file} and then run again")
    end
  end

  defp run(config_file) do
    try do
      config =
        File.read!(config_file)
        |> GatherSubmissions.Config.read_from_yaml()

      GatherSubmissions.gather_submissions(config, &log/1)
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
