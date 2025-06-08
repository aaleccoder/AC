Para compilar, ejecuta el siguiente comando en PowerShell:

.\build.ps1


Para correr el juego:
qemu-system-i386 -drive format=raw,file=racing_game.img

PORFAVOR profe hay un pequenito bug en el que no se pueden mover los dos carros al mismo tiempo, si se mantiene una tecla presionada. Ahora se puede jugar perfecto si se juega regla de (confia en mi, no voy a hacer trampa) de que los jugadores le den repetivamente a la teclas para moverse en ese caso casi que se puede jugar bien sin problemas. 