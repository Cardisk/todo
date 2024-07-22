# ✏️ TODO

A command line utility to process TODOs & FIXMEs inside files.

## Usage

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

**NOTE**: the default state used is 'open'.

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

**NOTE**: if this file is not provided, the program uses default info like `//` for prefix and leaves everything else empty.

## .issues.todo

This file is created by `[ -s | store ]` command.
It contains information about issues not committed yet.

`[ -c | commit ]` command pushes the issues to the remote repository
and applies the changes to the interested files.

To show pending issues inside this file, you can use
`[ -l | list ]` command.
