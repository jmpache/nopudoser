require 'sinatra'
require 'data_mapper'

DataMapper.setup(:default, 'sqlite:db/development.db')
DataMapper::Logger.new($stdout, :debug)

class Evento
    include DataMapper::Resource
    property :id, Serial
    property :nombre, String

    has n, :personas
end

class Persona
    include DataMapper::Resource
    property :id, Serial
    property :nombre, String
    property :evento_id, Integer
    property :total, Integer

    belongs_to :evento
    has n, :gastos
end

class Gasto
    include DataMapper::Resource
    property :id, Serial
    property :descripcion, String
    property :dinero, Integer
    property :persona_id, Integer

    belongs_to :persona
end

Evento.auto_upgrade!
Persona.auto_upgrade!
Gasto.auto_upgrade!
DataMapper.finalize

@@evento_activo = nil
@@ultima_persona = nil

get '/' do
    @title = 'Crea el evento!'
    erb :index
end

post '/crear_evento' do
    joda = Evento.new
    joda.nombre = params[:titulo]
    joda.save

    @@evento_activo = joda
    redirect '/agregar_participantes'
end

get "/agregar_participantes" do
    @joda = Evento.get(@@evento_activo.id)
    erb :agregar_participantes
end

post "/agregar_participantes" do
    joda = Evento.get(@@evento_activo.id)
    chabon = joda.personas.new
    chabon.nombre = params[:nombre]
    chabon.save
    joda.save

    @@ultima_persona = chabon
    redirect '/agregar_participantes'
end

post "/cargar_gasto" do
    gastado = Gasto.new
    gastado.dinero = params[:importe].to_i
    gastado.persona_id = params[:id].to_i
    gastado.descripcion = params[:descripcion]
    gastado.save
    
    redirect '/agregar_participantes'
end

get '/eventos' do
    @jodas = Evento.all
    erb :eventos
end

get '/evento/:id' do
    @un_evento = Evento.get(params[:id])
    @personitas = Persona.all
    @moneda = Gasto.all

    erb :evento
end


# una vista de calcuo, que sume los gastos, y los divida por personas