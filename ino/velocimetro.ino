const int pingPin = 7;
unsigned long tiempo = 0, t=0;
String comando = "";         
boolean comandoNuevo = false;  
boolean medir = false;  

long leer(){
  unsigned long pulso = 0;
  // Envía señal para comenzar la medicion
  pinMode(pingPin, OUTPUT);
  digitalWrite(pingPin, LOW);
  delayMicroseconds(2);
  digitalWrite(pingPin, HIGH);
  delayMicroseconds(5);
  digitalWrite(pingPin, LOW);
  
  // Recibe el tiempo que se demora en volver el eco
  pinMode(pingPin, INPUT);
  pulso = pulseIn(pingPin, HIGH);
  if(pulso <= 175 || pulso >= 23000) //limites del sensor 3cm y 400cm
    pulso = 0;
  return pulso;
}

long microsegundoACentimetro(long microseconds) {
  // La velocidad del sonido equivale a 340 m/s o 29 ms por centimetro
  // El sensor emite un ultrasonido para detectar la distancia del objeto
  // dado que debe emitir y recibir el resultado se considera la mitad 
  // de la distancia recorrida
  return microseconds / 29 / 2;
}

void serialEvent() {
  while (Serial.available()) {    
    char inChar = (char)Serial.read();    
    comando += inChar;    
    if (inChar == '\n') {
      comandoNuevo = true;
    }
  }
}

void setup() {
  Serial.begin(9600);
  comando.reserve(10);
}

void loop() {
  unsigned long distancia = 0;
  
  if (comandoNuevo) {
    if(comando == "start\n")
      medir = true;
    else if(comando == "stop\n")
      medir = false;
    tiempo = 0;
    t = millis();
    comando = "";
    comandoNuevo = false;
  } 
  
  if(medir){
    distancia = leer();
    tiempo = millis() - t;
    
    distancia = microsegundoACentimetro(distancia);

    Serial.print(distancia);
    Serial.print(";");
    Serial.print(tiempo);
    Serial.println();
	  
  }
  
  delay(100);
  
}
