local socket = require("socket")

local Led = {}
Led.__index = Led

local function limiteaza(x)
  return math.max(0, math.min(255, math.floor(x + 0.5)))
end

function Led.new(ip, port, pixeli, luminozitate_max)
  local self = setmetatable({}, Led)
  self.pixeli = pixeli
  self.luminozitate_max = luminozitate_max or 0.5
  self.culoare = { 255, 128, 0 }
  self.luminozitate = 30

  self.udp = assert(socket.udp())
  assert(self.udp:setpeername(ip, port))

  self:actualizeaza()
  return self
end

function Led:actualizeaza()
  local factor = (self.luminozitate / 100) * self.luminozitate_max

  local r = limiteaza(self.culoare[1] * factor)
  local g = limiteaza(self.culoare[2] * factor)
  local b = limiteaza(self.culoare[3] * factor)

  self.cadru = string.rep(string.char(r, g, b), self.pixeli)
end

function Led:seteazaCuloare(r, g, b)
  self.culoare = { r, g, b }
  self:actualizeaza()
end

function Led:seteazaLuminozitate(procent)
  self.luminozitate = procent
  self:actualizeaza()
end

function Led:trimite()
  self.udp:send(self.cadru)
end

return Led