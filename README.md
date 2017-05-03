# Sandthorn Event Store driver

A [Event Store](https://geteventstore.com) driver for [Sandthorn](https://github.com/Sandthorn/sandthorn).

This driver is a write upon [http_eventstore](https://github.com/arkency/http_eventstore) from [Arkency](http://arkency.com)

Currently its only `get_events` that is not implemented contra the [sandthorn_sequel_driver](https://github.com/Sandthorn/sandthorn_sequel_driver).

* save_events
* find
* all


## Installation

Add this line to your application's Gemfile:

    gem 'sandthorn_driver_event_store'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sandthorn_driver_event_store

## Usage

    SandthornDriverEventStore.driver host: "localhost", port: 2113
   
## Todo

 * Get events - Functionallity for [Sandthorn Sequel Projection](https://github.com/Sandthorn/sandthorn_sequel_projection) 

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
