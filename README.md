# ✏️ TODO

A command line utility to process todos inside files.

## Usage

```shell
> todo [ -s | -c ] <file> ...
```

To show usage:

```shell
> todo -h
```

## todo.json

Put inside the root directory a file that will contain the basic info about the files.

`url`: string representation of the remote repository url (if its the same as the project, leave empty).

`prefix`: chars of the comment prefix.

`postfix`: chars of the comment postfix.

**NOTE**: if this file is not provided, the program uses default info like `//` for prefix and leaves everything else empty.

## .todo_issues

This file is created when using the command
`-s`. This contains issues info as json that will be committed using `-c` command.
