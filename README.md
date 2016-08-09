# Dive Centre HQ

Dive Centre HQ is an open source Rails-based point of sale, event management and equipment servicing platform allowing you to easily manage your retail store.

* [Check out the website](http://www.divecentrehq.com)
* [View the demo site](http://demo.divecentrehq.com)
* [Read the release notes](https://github.com/tryshoppe/core/blob/master/CHANGELOG.md)
* [Read API documentation](http://www.divecentrehq.com/apidocs)

## Features

* An attractive & easy to use interface with integrated authentication
* Point of sale
* Full product/catalogue management
* Purchase orders
* Stock control
* Tax management
* Event management with online booking engine
* Equipment servicing and rental

## Getting Started

[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

Dive Centre HQ provides the core framework for the store. It's a Rails-based application that can run in the cloud, bare-metal or virtual servers. The easiest way to get started is to use the Deploy to Heroku option to get up and running in minutes with no technical expertise required.

### Installing into a new Rails application

To get up and running with Dive Centre HQ is simple. Just follow the
instructions below and you'll be up and running in minutes.

    git clone https://github.com/dchq/dchq-core
    cd dchq-core
    bundle install
    bundle exec rake db:schema:load db:migrate db:seed
    bundle exec puma

## Contribution

If you'd like to help with this project, please get in touch by creating an issue.

## License

This software is licenced under the MIT license. Full details can be found in the MIT-LICENSE file in the root of the repository.
