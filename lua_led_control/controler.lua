local socket = require("socket")
local Led = require("led")
local ServerWeb = require("serverweb")
local config = require("config")

local fisier = assert(io.open("index.html", "r"))
local pagina = fisier:read("a")
fisier:close()

local benzi = {}
for _, b in ipairs(config.benzi) do
  table.insert(benzi, Led.new(b.ip, b.port, b.pixeli, b.luminozitate_max))
end

local server = ServerWeb.new(config.port_http)

server:ruta("/", function()
  return "200 OK", "text/html; charset=utf-8", pagina
end)

local function valid(x)
  return x and x >= 0 and x <= 255
end

server:ruta("/culoare", function(parametri)
  local r = tonumber(parametri.r)
  local g = tonumber(parametri.g)
  local b = tonumber(parametri.b)

  if not valid(r) or not valid(g) or not valid(b) then
    return "400 Bad Request", "text/plain", "cerere invalida"
  end

  for _, led in ipairs(benzi) do
    led:seteazaCuloare(r, g, b)
  end

  return "200 OK", "text/plain", "ok"
end)

server:ruta("/luminozitate", function(parametri)
  local v = tonumber(parametri.v)

  if not v or v < 0 or v > 100 then
    return "400 Bad Request", "text/plain", "cerere invalida"
  end

  for _, led in ipairs(benzi) do
    led:seteazaLuminozitate(v)
  end

  return "200 OK", "text/plain", "ok"
end)

print(("Controlez %d benzi, %d cadre pe secunda"):format(#benzi, config.fps))
print(("Deschide pe telefon: http://<adresa acestui calculator>:%d"):format(config.port_http))

local pas = 1 / config.fps
local urmatorul = socket.gettime()

while true do
  local pauza = math.max(0, urmatorul - socket.gettime())

  if server:asteapta(pauza) then
    server:trateaza()
  end

  if socket.gettime() >= urmatorul then
    for _, led in ipairs(benzi) do
      led:trimite()
    end
    urmatorul = urmatorul + pas
  end
end
