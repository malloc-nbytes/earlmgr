module Templates

@pub let main_template =
"module Main

# Make sure the read the docs!
# https://malloc-nbytes.github.io/EARL-web/

# Imports go here...

# NOTE: The three hashtags are for earlmgr -- index.
#       It is needed per function/class/method etc
#       for index generation. It is optional to add these,
#       but if you don't, the indexer will not be able
#       to parse things. Also, the doc-comments are needed
#       in this format to also parse correctly.
#       See [ https://malloc-nbytes.github.io/EARL-web/earlmgr ] for more parsing information.

### Function
#-- Name: main
#-- Parameter: argc: int
#-- Parameter: argv: list<str>
#-- Returns: int
#-- Description:
#--   Prints `hello world` to stdout and
#--   returns 0 on exit.
fn main() {
    println(\"Hello EARL!\");
    return 0;
}
### End

main();
";

@pub let toml_template =
"[owner]
name = \"my-username\"
github = \"github.com/my-repo\"

# Prefix is what you use for importing
# i.e.,
#   import \"my-prefix/my-file.rl\";
[config]
prefix = \"my-prefix\"
";

# Changelog taken from https://gist.github.com/juampynr/4c18214a8eb554084e21d6e288a18a2c
@pub let changelog =
"# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased] - yyyy-mm-dd

Here we write upgrading notes for brands. It's a team effort to make them as
straightforward as possible.

### Added
- [PROJECTNAME-XXXX](http://tickets.projectname.com/browse/PROJECTNAME-XXXX)
  MINOR Ticket title goes here.
- [PROJECTNAME-YYYY](http://tickets.projectname.com/browse/PROJECTNAME-YYYY)
  PATCH Ticket title goes here.

### Changed

### Fixed

## [1.2.4] - 2017-03-15

Here we would have the update steps for 1.2.4 for people to follow.

### Added

### Changed

- [PROJECTNAME-ZZZZ](http://tickets.projectname.com/browse/PROJECTNAME-ZZZZ)
  PATCH Drupal.org is now used for composer.

### Fixed

- [PROJECTNAME-TTTT](http://tickets.projectname.com/browse/PROJECTNAME-TTTT)
  PATCH Add logic to runsheet teaser delete to delete corresponding
  schedule cards.

## [1.2.3] - 2017-03-14

### Added

### Changed

### Fixed

- [PROJECTNAME-UUUU](http://tickets.projectname.com/browse/PROJECTNAME-UUUU)
  MINOR Fix module foo tests
- [PROJECTNAME-RRRR](http://tickets.projectname.com/browse/PROJECTNAME-RRRR)
  MAJOR Module foo's timeline uses the browser timezone for date resolution";

@pub let readme = "# README ";
