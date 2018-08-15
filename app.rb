require 'sinatra'
require 'data_mapper'


DataMapper.setup(:default, 'sqlite:db/development.db')
DataMapper::Logger.new($stdout, :debug)

class Evento
    include DataMapper::Resource
    property :id, Serial
    property :participantes, Integer
    property :nombre, String
end

class Persona
    include DataMapper::Resource
    property :id, Serial
    property :nombre, String
    property :dinero, Integer
end

Evento.auto_upgrade!
Persona.auto_upgrade!
DataMapper.finalize

get '/' do
    @title = 'Crea el evento!'
    erb :index
end

post '/agregarParticipantes' do
    @title = params[:titulo]
    @cant = params[:participantes].to_i
    erb :agregarParticipantes
end

post "/crearEvento" do
    joda = Evento.new
    joda.participantes = 2
    joda.nombre = "caca"
    joda.save

    chabon = Persona.new
    chabon.id = joda.id
    chabon.nombre = params[:nombre]
    chabon.dinero = params[:dinero]
    chabon.save

    redirect '/'
end

get '/eventos' do
    @jodas = Evento.all
    erb :eventos
end

get '/evento/:id' do
    @personas = Persona.all
    @un_evento = Evento.get(params[:id])
    erb :evento
end





