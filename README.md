# GatherSubmissions

A tool that downloads submissions from a DOMjudge server and generates a LaTeX file with their source code.

This tool can be useful for instructors who use DOMjudge to validate the programs
submitted by their students, and then want to obtain a PDF file of each submission
in order to grade them offline.

*GatherSubmissions* will obtain the submissions from DOMjudge, but it needs a [CSV](https://en.wikipedia.org/wiki/Comma-separated_values) file with the students information (name, surname, DOMjudge login, etc.) which will be included in the generated LaTeX file.

## Requirements

* Erlang/OTP 21 or later.

  Most GNU/Linux distributions provide packages for this. For example, in Fedora 33:

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

Copyright (C) 2021 by Manuel Montenegro (<montenegro@fdi.ucm.es>)

This code is released under Apache License 2.0
