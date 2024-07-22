# ✏️ TODO

A command line utility to process TODOs & FIXMEs inside files.

## Description

Todo is a command line utility to process TODOs and FIXMEs inside the file[s] provided as argument[s].
If no option is provided, the program will be executed in its entirety.

But what exactly does this program do?

It will scan the file[s] searching TODOs and FIXMEs, then it asks the user to add or discard them interactively. 
If you provide something different from the choices, by default the program will discard that issue.

Based on which command is being executed, the program handles issues differently (see OPTIONS below).
At the end of the process, only accepted issues will be posted on GitHub and TODOs and FIXMEs are replaced with ISSUE(#number)
where 'number' is the corresponding id on the remote.

## Usage

Default behaviour:

```shell
> todo <file> ... 
```

To show usage:

```shell
> todo [ -h | help ]
```

To save issues into a temporary file called `.issues.todo`:

```shell
> todo [ -s | store ] <file> ...
```

To commit issues stored into `.issues.todo`:

```shell
> todo [ -c | commit ]
```

To get the issues from the remote: 

```shell
> todo [ -g | get ] [ open | closed | all ]
```

> **NOTE**: The default state used is 'open'

To list the issues inside '.issues.todo': 

```shell
> todo [ -l | list ] 
```

## settings.todo

It holds the information about the project and files.

Example:

```json
{
    "repo": "<OWNER>/<REPO>"
    "prefix": "//"
    "postfix": ""
}
```

`repo`: information about remote repository (if empty by default will be used git to fetch this data)

`prefix`: chars of the comment prefix.

`postfix`: chars of the comment postfix.

> **NOTE**: If this file is not provided, the program uses default info like `//` for prefix and leaves everything else empty.

## .issues.todo

This file is created by `[ -s | store ]` command.
It contains information about issues not committed yet.

`[ -c | commit ]` command pushes the issues to the remote repository
and applies the changes to the interested files.

To show pending issues inside this file, you can use
`[ -l | list ]` command.

## License

See the license here: [LICENSE](https://github.com/Cardisk/todo/LICENSE).
