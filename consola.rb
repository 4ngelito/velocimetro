require 'serialport'

@distancia = @tiempo = 0.0
@distanciaAnterior = @tiempoAnterior = 0.0
@deltaDistancia = @deltaTiempo = 0.0
@velocidad = 0.0
@primero = true

# Arreglo de datos para el envío
@velocidades = Array.new
@tiempos = Array.new
@posiciones = Array.new

@capturar = true

def iniciarCaptura
  port_str = '/dev/ttyACM0'
  baud_rate = 9600
  data_bits = 8
  stop_bits = 1
  parity = SerialPort::NONE
  @sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)
  @sp.write("start\n")
  @capturar = true
end

def detenerCaptura
  @sp.write("stop\n")
  @capturar = false
  @sp.close()
end

def capturarDato  
  m = @sp.gets()
  m.chomp!
  dato = m.split(";")
  
  distancia = dato[0].to_f  
  tiempo = dato[1].to_f  
  puts "DEBUG: #{m}"
  puts "DEBUG: #{distancia};#{tiempo}"
  
  if !distancia.nil? && !tiempo.nil?
    # distancia convertida a metros (100cm)
    @distancia = (distancia / 100).to_f
    # tiempo convertido a segundos (1000ms)
    @tiempo = (tiempo / 1000).to_f # + @tiempo
    
    if !@primero
      @deltaDistancia = (@distanciaAnterior - @distancia).round(2)
      @deltaTiempo = (@tiempoAnterior - @tiempo).round(3)
      
      unless @deltaTiempo == 0
        @velocidad = (@deltaDistancia.to_f / @deltaTiempo.to_f).abs
      end
      puts "d: #{'%.02f' % @distancia} t: #{'%.03f' % @tiempo} v: #{'%.04f' % @velocidad}"
      puts "....-----...."
    end
    
    @velocidades.push(@velocidad)
    @tiempos.push(@tiempo)
    @posiciones.push(@distancia)
    
    @distanciaAnterior = @distancia
    @tiempoAnterior = @tiempo
  end  
  @primero = false
end

i = 0
iniciarCaptura
while(@capturar) do
  capturarDato
  i += 1
  if i == 30 
    detenerCaptura
    
    puts "tiempos"
    @tiempos.each do |t|
      print "#{'%.03f' % t}, "
    end
    
    puts "\nposicion"
    @posiciones.each do |p|
      print "#{'%.03f' % p}, "
    end
    
    puts "\nvelocidades"
    @velocidades.each do |v|
      print "#{'%.03f' % v}, "
    end
  end
end

#while(true) do
#  m = sp.gets
#  m.chomp!
#  data = m.split(";")
#  
#  distancia = data[0].to_f
#  tiempo = data[1].to_f
#  
#  if !distancia.nil? && !tiempo.nil?
#    # distancia convertida a metros
#    distancia = distancia / 100
#    # tiempo convertido a segundos
#    tiempo = tiempo / 1000
#    
#    if !primero 
#      deltaDistancia = distanciaAnterior - distancia
#      deltaTiempo = tiempoAnterior - tiempo
#      
#      unless deltaTiempo == 0
#        velocidad = deltaDistancia.to_f / deltaTiempo.to_f
#      end
#      
#      puts "d: #{'%.03f' % distancia} t: #{'%.03f' % tiempo} v: #{'%.04f' % velocidad}"
#      puts "....-----...."
#    end
#    distanciaAnterior = distancia
#    tiempoAnterior = tiempo
#  end  
#  primero = false
#end
