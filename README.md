# ConvenSHional Commits

A [conventional commit](https://www.conventionalcommits.org/en/v1.0.0/) helper using just Bash.

![convenshional-commits-demo](https://user-images.githubusercontent.com/5902545/194108291-b30acd35-5548-4504-a4a0-37c7a16d76a0.gif)

After forking [Comet](https://github.com/liamg/comet) into [Comet Alt](https://github.com/usrme/comet-alt) I got to thinking that something like that _really_ doesn't need Go, especially after I added the feature to choose without using arrow keys. This doesn't (yet) have niceties such as defining limits and being able to visualize those as one is typing, but this is close enough that I feel I can rely on just this instead.

## Installation

- move `convenshional-commits.sh` to any place you want it to be easily executed from
- create any aliases to make calling it easier

## Usage

Since I haven't added the ability to define choices in an external file then to edit any of the default choices you need to modify the script itself. Any additional arguments are passed straight to `git commit`.

## License

[MIT](/LICENSE)
