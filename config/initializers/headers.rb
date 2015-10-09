headers = [
  "HTTP/1.1 200 OK",
  "Content-Type: text/event-stream",
  "Cache-Control: no-cache, no-store",
  "Connection: close"
]

if origin = SseRailsEngine.access_control_allow_origin
  headers << "Access-Control-Allow-Origin: #{origin}"
end

headers << "" << ""

SseRailsEngine::Connection.sse_header = headers.join("\r\n").freeze
