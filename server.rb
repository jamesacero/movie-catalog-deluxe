require 'sinatra'
require 'pry'
require 'shotgun'
require 'pg'

def db_connection
  begin
    connection = PG.connect(dbname: "movies")
    yield(connection)
  ensure
    connection.close
  end
end

def get_actors
  db_connection do |conn|
    actors = conn.exec('SELECT name FROM actors').to_a
  end
end

def get_actors_details(actor_name)
  db_connection do |conn|
    actor_details = conn.exec_params('SELECT actors.name, movies.title, cast_members.character FROM movies JOIN
    cast_members ON movies.id = cast_members.movie_id JOIN actors ON actors.id = cast_members.actor_id WHERE actors.name = ($1)',[actor_name]).to_a
  end
end

def get_movies
  db_connection do |conn|
    movies = conn.exec('SELECT title, year, rating, genres.name AS "genre", studios.name AS "studio" FROM movies JOIN genres ON
    movies.genre_id = genres.id JOIN studios ON movies.studio_id = studios.id').to_a
  end
end

def get_movie_details
end

get "/movies" do
  erb :'movies/index', locals: {movies: get_movies}
end

get "/movies/:id" do
  erb :'movies/show'
end

get "/actors" do
  erb :'actors/index', locals: {actors: get_actors}
end

get "/actors/:id" do
  actor_name = params[:id]
  erb :'actors/show', locals: {actor_details: get_actors_details(actor_name)}
end
