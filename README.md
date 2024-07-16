# ✏️ TODO

A command line utility to process todos inside files.

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

Put inside the root directory a file that will contain the basic info about the files.

`repo`: string with repository info with <OWNER>/<REPO> format (if its the same as the project, leave empty).

`prefix`: chars of the comment prefix.

`postfix`: chars of the comment postfix.

**NOTE**: if this file is not provided, the program uses default info like `//` for prefix and leaves everything else empty.

## .todoIssues

This file is created when using the command
`-s`. This contains issues info as json that will be committed using `-c` command.
