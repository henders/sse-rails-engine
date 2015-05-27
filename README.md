[![Build Status](https://travis-ci.org/henders/sse-rails-engine.svg?branch=master)](https://travis-ci.org/henders/sse-rails-engine)
[![Code Climate](https://codeclimate.com/github/henders/sse-rails-engine/badges/gpa.svg)](https://codeclimate.com/github/henders/sse-rails-engine)
[![Test Coverage](https://codeclimate.com/github/henders/sse-rails-engine/badges/coverage.svg)](https://codeclimate.com/github/henders/sse-rails-engine)
[![Gem Version](https://badge.fury.io/rb/sse-rails-engine.svg)](http://badge.fury.io/rb/sse-rails-engine)

This engine is designed to allow Server-Sent Events to be broadcast to all listeners from anywhere
in your Rails app.
At the moment it only works with Thread based Rack servers like Puma.

Plans are to hook it up to Redis if you need to use process-based servers like Unicorn.

This has been mostly tested with Ruby v2.2.1 and Rails v4.2.1 + [Puma][puma].

This uses the Rack socket hijacking functionality to avoid having to occupy a thread per connection. Now
only 1 extra thread in your app is required.

[puma]: https://github.com/puma/puma

# Installation
```ruby
gem 'sse-rails-engine'
```

# Usage

Mount the engine in your ```config/routes.rb```:
```ruby
Rails.application.routes.draw do
  mount SseRailsEngine::Engine, at: '/sse'
end
```

To use, initialize the connection on the client side, so add the following javascript:
```javascript
$(document).ready(function () {
  var source = new EventSource('/sse');

  source.addEventListener('test', function(e) {
    // Do something
  }, true);
});

```

Then you can send an event from anywhere in your app:
```ruby
SseRailsEngine.send_event('test', { foo: 'bar' })
```

# Channels

It supports the idea of channels so that if pages don't need to receive certain events, then you won't waste
the bandwidth or processing on the server:

Clientside:
```javascript
$(document).ready(function () {
  var source = new EventSource('/sse?channels=foo,bar,baz');

  source.addEventListener('other', function(e) {
    // Will never be called
  }, true);

  source.addEventListener('foo', function(e) {
    // Do stuff
  }, true);
});

```
Serverside:
```ruby
SseRailsEngine.send_event('foo', '') # Sent to the client
SseRailsEngine.send_event('other', '') # Won't be sent to the client
```

# Callbacks

You can get connect/disconnect callbacks for each client with the 'env' that is associated with each connection, e.g.:

```ruby
SseRailsEngine.manager.on_connect do |env|
  SseRailsEngine.send_event('happy event', "Everyone look, #{env['QUERY_STRING']} joined!")
end

SseRailsEngine.manager.on_disconnect do |env|
  SseRailsEngine.send_event('unhappy event', "Awwww, #{env['QUERY_STRING']} left us!")
end
```

# Notes

## Nginx
You may need to configure nginx to not buffer or cache SSE connections:
http://stackoverflow.com/questions/13672743/eventsource-server-sent-events-through-nginx

# License

MIT - Have at it! :)
