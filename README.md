# groundskeeper

grounds·​keep·​er | \ ˈgrau̇n(d)z-ˌkē-pər \ | [Source](https://www.merriam-webster.com/dictionary/groundskeeper)

Definition: 
- a person who cares for the grounds of a usually large property (such as a sports field) 
- `Groundskeeper` is a package to interact with Swift playgrounds (Version 6.0).

## Example Usage

```bash
# create a playground with random name in ~/Downloads
▶ playground create

# add a new page with random name to an existing playground
▶ playground add-page /path/to/my.playground
```

## Create a new playground

```bash
▶ playground help create
USAGE: playground create [<name>] [--output-path <output-path>] [--xed] [--no-xed] [--template <template>] [--target-platform <target-platform>]

ARGUMENTS:
  <name>                  Name of the new playground. If no name is given, a random name will be used

OPTIONS:
  --output-path <output-path>
                          URL to the output path where the playground will be created (default: ~/Downloads)
  --xed/--no-xed          Automatically open the playground after creation using 'xed' (default: true)
  --template <template>   Source code template for the playground page. Options are 'swift', 'swiftui' or a URL pointing to content
                          (default: swift)
  --target-platform <target-platform>
                          Target platform for the new playground. Options are 'ios' or 'macos' (default: macos)
  --version               Show the version.
  -h, --help              Show help information.
```

## Add a new page to an existing playground

```bash
▶ playground help add-page
USAGE: playground add-page <playground-path> [<page-name>] [--xed] [--no-xed] [--template <template>]

ARGUMENTS:
  <playground-path>       URL to an existing playground
  <page-name>             Name of the new playground page. If no name is given, a random name will be used

OPTIONS:
  --xed/--no-xed          Automatically open the playground after adding a page using 'xed' (default: true)
  --template <template>   Source code template for the playground page. Options are 'swift', 'swiftui' or a URL pointing to content (default: swift)
  --version               Show the version.
  -h, --help              Show help information.
```

## Customization

### Change default output path when omitting `--output-path` option
 
```bash
# Write new default value
▶ defaults write com.groundskeeper.playground GKPlaygroundOutputPath -string "~/Downloads"

# Verify output path
▶ defaults read com.groundskeeper.playground GKPlaygroundOutputPath

# Remove default value
▶ defaults delete com.groundskeeper.playground GKPlaygroundOutputPath

# Remove all default values
▶ defaults delete com.groundskeeper.playground
```

