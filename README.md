# zsh-run

Nested aliases from JSON file for `zsh`. For `bash`, consider using [bishop](https://github.com/stuartervine/bishop)

## Requirements

`zsh-run` requires [jq](https://stedolan.github.io/jq/) to parse JSON files.

## Instalation

### Manual

Clone the repository in preferred directory. For example `~/zsh-plugins/zsh-run`:

`$ git clone https://github.com/foxmk/zsh-run.git ~/zsh-plugins/zsh-run`

Set configuration variables if needed:

`$ echo 'ZSH_RUN_CMD=runthisnowplease' >> ~/.zshrc`

Source `run.zsh` file in your `~/.zshrc`:

`$ echo 'source ~/zsh-plugins/zsh-run' >> ~/.zshrc`

Reload your config:

`$ source ~/.zshrc`

## Usage

### Commands files

Put this in your `$HOME/.commands.json` file:

```json
{
    "foo": {
        "bar": {
            "baz": "echo foobarbaz"
        },
        "quux": "echo some_other_command"
    }
}
```

Now you can use those aliases:

```sh
$ run foo bar baz
foobarbaz

$ run foo quux
some_other_command
```

If you don't pass full path for command, `zsh-run` will show possible completions:

```sh
$ run foo
Possible paths:
bar baz: echo foobarbaz
quux: echo some_other_command
```

`zsh-run` takes aliases from `.commands.json` in your `HOME` (configurable) and all existing `.commands.json` files in current working directory and parent directories. Aliases with the same path are taken from the closest `.commands.json` file. `$HOME/.commands.json` takes the lowest precedence.

So, if you put `.commands.json` in you current working directory with following content:

```json
{
    "foo": {
        "bar": {
            "baz": "echo specific_command_for_this_dir"
        }
    }
}
```

And then run:

```sh
$ run foo bar baz
specific_command_for_this_dir
```

## Configuration

### `ZSH_RUN_CMD`

Command to invoke `zsh-run`. Default: `run`

### `ZSH_RUN_COMMANDS_FILE`

Global file with aliases. Default: `$HOME/.commands.json`

### `ZSH_PRINT_COMMAND`

If `true` prints command before executing. Possible values: `true` or `false`. Default: `true`
