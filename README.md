# velocimetro
Proyecto desarrollado para la clase de Mecánica primer semestre 2016
Por Angel Ayala

**Descripción**: Velocimetro con tecnología arduino y el sensor ping))), Ruby y Javascript

#### Arduino
Interfaz de comunicación entre el sensor y el computador.

**Conexión**
Los terminales del sensor ping))), deben ser conectados a vcc y gnd respectivamente, y el pin de señal debe estar conectado en la entrada digital 7 del Arduino.

**Código Fuente**
El código lee la entrada serial esperando las palabras "start" y "stop" que inicia o detiene respectivamente, la activación del sensor para calcular la velocidad del objeto frente a este.
El resultado es impreso por salida serial en formato "{distancia};{tiempo}";

#### Motor
Ejecuta la lógica de interacción entre el frontend y la comunicación serial con Arduino

**Descripción** 
Ejecuta un websocket con el cual escucha las palabras que debe enviar por el puerto serial y/o comunica la velocidad actual del objeto, ambas acciones desde y hacia el frontend.

#### Frontend
Interfaz entre el usuario y el Motor enviando la señal de iniciar medición a traves de la palabra "start" y mostrar mediante un gráfico las lecturas correspondientes a la medida o, detener la medición con la palabra "stop"
