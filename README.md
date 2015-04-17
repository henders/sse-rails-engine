This engine is designed to allow Server-Sent Events to be broadcast to all listeners from anywhere
in your Rails app.
At the moment it only works with Thread based Rack servers like Puma, Thin, Reel, ...

Plans are to hook it up to Redis if you need to use process-based servers like Unicorn.

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

# License

MIT - Have at it! :)