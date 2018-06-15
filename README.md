# Sandthorn Event Store driver

A [Event Store](geteventstore.com) driver for [Sandthorn](https://github.com/Sandthorn/sandthorn).

This driver is built upon [http_eventstore](https://github.com/arkency/http_eventstore) from [Arkency](http://arkency.com)

A subset of the functionality supported by the [sandthorn_driver_sequel](https://github.com/Sandthorn/sandthorn_driver_sequel) is available:

| Supported? | Feature | Description |
| --- | --- | --- |
| :white_check_mark: | `save_events` | . |
| :white_check_mark: | `find` | . |
|  | All | Get all events based on Aggregate type (Class) |
|  | Get events | Functionality for [Sandthorn Sequel Projection](https://github.com/Sandthorn/sandthorn_sequel_projection)  |

## Installation

Add this line to your application's Gemfile:

    gem 'sandthorn_driver_event_store'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sandthorn_driver_event_store

## Usage

    SandthornDriverEventStore.driver host: "localhost", port: 2113

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
