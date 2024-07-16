# ✏️ TODO

A command line utility to process TODOs & FIXMEs inside files.

## Usage

To save issues into a temporary file called `.todoIssues`:

```shell
> todo [ -s | store ] <file> ...
```

To commit issues stored into `.todoIssues`

```shell
> todo [ -c | commit ]
```

To show usage:

```shell
> todo [ -h | help ]
```

## todo.json

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

**NOTE**: if this file is not provided, the program uses default info like `//` for prefix and leaves everything else empty.

## .todoIssues

This file is created by `[ -s | store ]` command.
It contains information about issues not committed yet.

`[ -c | commit ]` command pushes the issues to the remote repository
and applies the changes to the interested files.
