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
```
gem 'sse-rails-engine'
```

# Usage

Mount the engine in your ```config/routes.rb```:
```
Rails.application.routes.draw do
  mount SseRailsEngine::Engine, at: '/sse'
end
```

To use, initialize the connection on the client side, so add the following javascript:
```
$(document).ready(function () {
  var source = new EventSource('/sse');

  source.addEventListener('test', function(e) {
    // Do something
  }, true);
});

```

Then you can send an event from anywhere in your app:
```
SseRailsEngine.send_event('test', { foo: 'bar' })
```

# Notes

## Nginx
You may need to configure nginx to not buffer or cache SSE connections:
http://stackoverflow.com/questions/13672743/eventsource-server-sent-events-through-nginx

# License

MIT - Have at it! :)
