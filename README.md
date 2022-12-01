# ConvenSHional Commits

A [conventional commit](https://www.conventionalcommits.org/en/v1.0.0/) helper using just Bash.

![convenshional-commits-demo](https://user-images.githubusercontent.com/5902545/195580236-f737842c-19d5-4bf3-81ff-ff6bd2451e18.gif)

After forking [Comet](https://github.com/liamg/comet) into [Comet Alt](https://github.com/usrme/comet-alt) I got to thinking that something like that _really_ doesn't need Go, especially after I added the feature to choose without using arrow keys. This doesn't (yet) have niceties such as defining limits and being able to visualize those as one is typing, but this is close enough that I feel I can rely on just this instead.

## Installation

- move `convenshional-commits.sh` to any place you want it to be easily executed from
- create any aliases to make calling it easier

## Usage

There is an additional `convenshional-commits.conf` file that includes the prefixes and descriptions that I most prefer myself, which can be added to either `XDG_CONFIG_HOME` or one's home directory under `.config` as `convenshional-commits.conf`. Omitting this means that defaults are used.

Any additional arguments are passed straight to `git commit`.

### Setting character limits

To adjust the total limit of characters in the _resulting_ commit message, add the key `total_input_char_limit` into the `.convenshional-commits.conf` file with the desired limit. Omitting the key uses a default value of 80 characters.

## License

[MIT](/LICENSE)
