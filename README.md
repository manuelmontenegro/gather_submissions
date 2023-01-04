# GatherSubmissions

A tool that downloads submissions from a DOMjudge server and generates a LaTeX file with their source code.

This tool can be useful for instructors who use DOMjudge to validate the programs
submitted by their students, and then want to obtain a PDF file of each submission
in order to grade them offline.

*GatherSubmissions* will obtain the submissions from DOMjudge, but it needs a [CSV](https://en.wikipedia.org/wiki/Comma-separated_values) file with the students information (name, surname, DOMjudge login, etc.) which will be included in the generated LaTeX file.

## Requirements

* Erlang/OTP 21 or later.

  Most GNU/Linux distributions provide packages for this. For example, in Fedora:

  ```
  # sudo dnf install erlang
  ```

  In macOS you can use [brew](https://formulae.brew.sh/formula/erlang)

  ```
  # brew install erlang
  ```

  You can also download an [installation executable](https://www.erlang.org/downloads) for Windows from Erlang's home page.

## Installation

No instalation is required. Just download the `gather_submissions` script from the releases page. In GNU/Linux or macOS you can make this file executable:

```
# chmod u+x gather_submissions
```

In Windows systems you have to run the script manually:

```
> escript gather_submissions
```

provided the directory of `escript.exe` belongs to the system `PATH`.

## Usage

Just run `gather_submissions` in the command line:

```
# ./gather_submissions
```

If will create a `gather_submissions.yaml` file in the current directory. Read this file carefully and modify it by setting the corresponding options. Then, run `gather_submissions` again in the same directory as the configuration file.

The generated LaTeX file is meant to be run with `xelatex`. If you want to use another system (e.g. `pdflatex`) or you want to
customize the appearance of the PDF file, you have to modify the LaTeX template. In order to do this, pass the `--gen-template`
option:

```
# ./gather_submissions --gen-template
```

This generates a `gather_submissions_template.eex` file with the default template, which you can adjust to your needs.

When `gather_submissions` is run, it looks for a `gather_submissions_template.eex` file in the current directory, and uses it
as a template. If such a file does not exist, the default template will be used.

## How to build from source

Compiling from source code requires [Elixir](https://elixir-lang.org/) version 11.1 or later.

1. Download the source code

   ```
   # git clone https://github.com/manuelmontenegro/gather_submissions.git
   # cd gather_submissions
   ```

2. Compile and generate the script

   ```
   # mix compile
   # mix escript.build
   ```

3. Optionally, install the script

   ```
   # mix escript.install
   ```

## License

Copyright (C) 2023 by Manuel Montenegro (<montenegro@fdi.ucm.es>)

This code is released under Apache License 2.0
