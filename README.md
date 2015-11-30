# carbon

Carbon Crystal
A framework with Rails in mind.

## Status

[![Build Status](https://travis-ci.org/benoist/carbon-crystal.svg?branch=master)](https://travis-ci.org/benoist/carbon-crystal)
Only works on latest master. To use locally build it from source or on osx use brew install crystal-lang --HEAD.

Right now it's still alpha stage. I am testing this in production on a small project, but I wouldn't recommend to do it unless you really want to :)

## Release goal

For the first release I'm aiming towards a 15 min blog post screencast.

## TODO

- [X] Notifications (ActiveSupport like)
- [ ] Middleware
  - [X] Send file
  - [X] Static File
  - [X] Runtime
  - [X] RequestId
  - [X] Logger
  - [X] RemoteIP
  - [X] Exceptions
  - [X] ParamsParser
  - [X] Head
  - [X] Cookies
  - [X] Sessions Cookie Store
  - [X] Flash
  - [ ] ConditionalGet
  - [ ] ETag
- [X] Resourceful routing
- [X] Action filters
    - [ ] Conditional
    - [X] Halting
- [ ] Generators
- [ ] Asset pipeline
- [ ] View helpers
- [X] Write specs

## Contributing

1. Fork it ( https://github.com/[your-github-name]/carbon/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [benoist](https://github.com/benoist]) Benoist Claassen - creator, maintainer
- [JanDintel](https://github.com/JanDintel]) JanDintel - contributor
