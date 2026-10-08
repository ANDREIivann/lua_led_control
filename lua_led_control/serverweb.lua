local socket = require("socket")

local ServerWeb = {}
ServerWeb.__index = ServerWeb

local function citeste_parametri(query)
  local parametri = {}
  for cheie, valoare in (query or ""):gmatch("([^&=]+)=([^&]*)") do
    parametri[cheie] = valoare
  end
  return parametri
end

local function raspunde(client, cod, tip, corp)
  local raspuns = ("HTTP/1.1 %s\r\nContent-Type: %s\r\nContent-Length: %d\r\nConnection: close\r\n\r\n%s")
    :format(cod, tip, #corp, corp)
  client:send(raspuns)
  client:close()
end

function ServerWeb.new(port)
  local self = setmetatable({}, ServerWeb)
  self.rute = {}
  self.socket = assert(socket.bind("*", port))
  return self
end

function ServerWeb:ruta(cale, functie)
  self.rute[cale] = functie
  return self
end

function ServerWeb:asteapta(pauza)
  local gata = socket.select({ self.socket }, nil, pauza)
  return gata[1] ~= nil
end

function ServerWeb:trateaza()
  local client = self.socket:accept()
  if not client then
    return
  end
  client:settimeout(0.1)

  local cerere = client:receive("*l")
  if not cerere then
    client:close()
    return
  end

  repeat
    local linie = client:receive("*l")
  until not linie or linie == ""

  local cale, query = cerere:match("^GET ([^%s?]+)%??(%S*)")
  local functie = cale and self.rute[cale]

  if not functie then
    raspunde(client, "404 Not Found", "text/plain", "negasit")
    return
  end

  local cod, tip, corp = functie(citeste_parametri(query))
  raspunde(client, cod, tip, corp)
end

return ServerWeb