# Banda LED controlata din Lua

Acest proiect reprezinta un sistem de control, scris in Lua, pentru o banda LED din casa. De pe telefon se poate schimba in timp real culoarea si luminozitatea benzii. Pe un Raspberry Pi ruleaza un program Lua care serveste o pagina web de control si trimite catre ESP8266, prin UDP, cu o frecventa de 30 fps, culoarea si luminozitatea ce vor fi afisate pe LED-uri.


## Componente hardware

- **Banda LED WS2812B (NeoPixel):** 289 de pixeli, alimentata la 5 V; afiseaza culoarea.
- **ESP8266:** primeste cadrele prin Wi-Fi si comanda banda.
- **Raspberry Pi:** ruleaza programul Lua.
- **Telefon:** afiseaza pagina de control.

## Componente software

- **Sistem de operare:** Linux
- **Limbaj:** Lua 5.4
- **Biblioteci:** LuaSocket (UDP si server HTTP), iro.js (selectorul de culoare din pagina web)

## Cum functioneaza

```
telefon --HTTP--> controler.lua --UDP, 867 bytes/cadru--> ESP8266 --> banda LED
```

1. Pagina de pe telefon trimite prin HTTP culoarea (`r`, `g`, `b`, intre 0 si 255) si luminozitatea (intre 0 si 100).
2. `controler.lua` primeste cererile prin `ServerWeb`, valideaza valorile si le seteaza in obiectul `Led`.
3. `Led` aplica luminozitatea asupra culorii si construieste cadrul: 289 de pixeli x 3 bytes (R, G, B) = 867 de bytes, fara antet. Parametrul `luminozitate_max` din `config.lua` stabileste o limita superioara a luminozitatii.
4. `controler.lua` trimite cadrul prin UDP catre ESP8266, de 30 de ori pe secunda.
5. ESP8266 primeste pachetul pe portul UDP 4210 si il accepta doar daca are exact `NUM_PIXELS x 3` bytes.
6. ESP8266 transmite cadrul benzii LED.

## Fisiere

| Fisier | Rol |
| --- | --- |
| `controler.lua` | Porneste aplicatia: citeste configuratia, defineste rutele HTTP si trimite cadrele catre banda. |
| `led.lua` | Defineste clasa `Led`, care retine culoarea si luminozitatea si construieste cadrul trimis. |
| `serverweb.lua` | Defineste clasa `ServerWeb`, un server HTTP minimal realizat cu LuaSocket. |
| `config.lua` | Contine adresa IP si portul ESP-ului, numarul de pixeli si limita de luminozitate. |
| `index.html` | Contine pagina de control afisata pe telefon, cu selectorul de culoare si bara de luminozitate. |

## Rulare

```bash
sudo apt install lua5.4 lua-socket
lua5.4 controler.lua
```

Inainte de prima rulare, in `config.lua` se seteaza IP-ul ESP-ului; numarul de pixeli trebuie sa fie acelasi cu `NUM_PIXELS` din firmware. Apoi, de pe un telefon din aceeasi retea Wi-Fi, se deschide `http://<adresa Raspberry Pi>:8080`.
