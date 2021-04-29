# Changelog

# Version 0.2.1

Reset current directory (`Dir.pwd`) to project root in the generator
`railbus:install`.

# Version 0.2.0

1. Extract Axios-related functionality to NPM package 'yambus-axios'.
2. Add support for `fetch` with NPM package 'yambus-fetch'.
3. Custom request function now can add options before performing request
   (`set_options` in `Railbus.generate`). Also it may be useful for logging
   requests.
4. Enriched support for multiple Rails engines. Now Railbus autodetects endpoint
   for mounted engines for generating correct paths.

# Version 0.1.2

Extract JavaScript generators to NPM package called 'yambus'.
Added Rails generator: `rails g railbus:install`.

# Version 0.1.1

Change prefix for `delete` routes from `destroy_` to `delete_`.

# Version 0.1.0

First release.
