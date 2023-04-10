# ConvenSHional Commits

A [conventional commit](https://www.conventionalcommits.org/en/v1.0.0/) helper using mostly Bash.

![ConvenSHional Commits - animated GIF demo](examples/demo.gif)

After forking [Comet](https://github.com/liamg/comet) into [Comet Alt](https://github.com/usrme/comet-alt) I got to thinking that something like that _really_ doesn't need Go, especially after I added the feature to choose without using arrow keys.

## Installation

- move `convenshional-commits.sh` to any place you want it to be easily executed from
- create any aliases to make calling it easier

## Usage

There is an additional `convenshional-commits.conf` file that includes the prefixes and descriptions that I most prefer myself, which can be added to `${XDG_CONFIG_HOME}/convenshional-commits/config.conf`. Omitting this means that defaults are used.

Any additional arguments are passed straight to `git commit`.

### Setting character limits

To adjust the total limit of characters in the _resulting_ commit message, add the key `total_input_char_limit` into the `convenshional-commits.conf` file with the desired limit. Omitting the key uses a default value of 80 characters.

It goes without saying that since this character limit indicator expects there to be around 30 characters of additional space on the right side in order for the marker to make sense. Significantly narrower and it may make sense to just disable the visual indicator entirely by setting the value of `total_input_char_limit` to 0.

## License

[MIT](/LICENSE)
