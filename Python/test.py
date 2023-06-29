import pyautogui
import math
import time

# Le centre du cercle
center_x = 981
center_y = 547

# Le rayon du cercle
radius = 400

# Le nombre de pas pour dessiner le cercle (plus il est élevé, plus le cercle sera lisse)
steps = 50

# Attendez quelques secondes avant de commencer (pour que vous puissiez lâcher la souris)
time.sleep(1)

for i in range(steps+5):
    # Calculez les coordonnées du point sur le cercle
    angle = math.pi * 2 * i / steps
    x = center_x + radius * math.cos(angle)
    y = center_y + radius * math.sin(angle)

    # Déplacez la souris vers le point
    pyautogui.moveTo(x, y, duration=0.1)
