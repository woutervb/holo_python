# This is the minimal code to set the buildin rgb led to
# bright white

from machine import Pin
from neopixel import NeoPixel

pin = Pin(27, Pin.OUT)
np = NeoPixel(pin,1)
np[0] = (255, 255, 255)
np.write()
