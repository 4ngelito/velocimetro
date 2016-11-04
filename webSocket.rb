require 'serialport'
require 'em-websocket'
require 'json'

@distancia = @tiempo = 0.0
@distanciaAnterior = @tiempoAnterior = 0.0
@deltaDistancia = @deltaTiempo = 0.0
@velocidad = 0.0
@primero = true

# Arreglo de datos para el envío
@posicionTiempo = Array.new #posicion versus tiempo
@velocidadTiempo = Array.new #velocidad vs tiempo

@capturar = false

def iniciarCaptura
  
  # Inicialización del puerto serie
  port_str = '/dev/ttyACM0'
  baud_rate = 9600
  data_bits = 8
  stop_bits = 1
  parity = SerialPort::NONE
  @sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)
  
  # Inicializacion de las variables
  @distancia = @tiempo = 0.0
  @distanciaAnterior = @tiempoAnterior = 0.0
  @deltaDistancia = @deltaTiempo = 0.0
  @velocidad = 0.0
  @primero = true
  
  @velocidadTiempo = Array.new
  @posicionTiempo = Array.new
  
  @sp.write("start\n")
  @capturar = true
end

def detenerCaptura
  @sp.write("stop\n")
  @capturar = false
  @sp.close()
end

def capturarDato
  posicionTiempo = Array.new
  velocidadTiempo = Array.new
  m = @sp.gets()
  m.chomp!
  dato = m.split(";")
  
  distancia = dato[0].to_f  
  tiempo = dato[1].to_f
#  puts "DEBUG: #{m}"
#  puts "DEBUG: #{distancia};#{tiempo}"
  
  if !distancia.nil? && !tiempo.nil?
    # distancia convertida a metros (100cm)
    @distancia = (distancia / 100).to_f
    # tiempo convertido a segundos (1000ms)
    @tiempo = (tiempo / 1000).to_f #+ @tiempo
    
    if !@primero
      @deltaDistancia = (@distanciaAnterior - @distancia).round(2)
      @deltaTiempo = (@tiempoAnterior - @tiempo).round(3)
      
      unless @deltaTiempo == 0
        @velocidad = (@deltaDistancia.to_f / @deltaTiempo.to_f).abs
      end
      puts "d: #{'%.02f' % @distancia} t: #{'%.03f' % @tiempo} v: #{'%.04f' % @velocidad}"
      #puts "....-----...."
    end
    
    posicionTiempo.push(@tiempo)
    posicionTiempo.push(@distancia)
    @posicionTiempo.push(posicionTiempo)
    
    velocidadTiempo.push(@tiempo)
    velocidadTiempo.push(@velocidad)
    @velocidadTiempo.push(velocidadTiempo)
    
    @distanciaAnterior = @distancia
    @tiempoAnterior = @tiempo
  end  
  @primero = false
end

def message_from()
  { "posTiempo" => @posicionTiempo, "velTiempo" => @velocidadTiempo }
end

EventMachine::WebSocket.start(:host => '0.0.0.0', :port => 8080) do |ws|
  ws.onopen { ws.send "hello client" }
  ws.onclose { puts "WebSocket cerrado" }
  
  ws.onmessage do |msg|
    if msg == "iniciarCaptura"
      iniciarCaptura
      puts "== capturando datos =="
      Thread.new do
        while(@capturar) do
          capturarDato
        end
      end
    elsif msg == "detenerCaptura"
      detenerCaptura
      puts "fin captura..."
      ws.send message_from().to_json
    else puts msg
    end    
  end
end

