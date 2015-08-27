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
    actors = conn.exec('SELECT id, name FROM actors ORDER BY name').to_a
  end
end

def get_actors_details(actor_id)
  db_connection do |conn|
    actor_details = conn.exec_params('SELECT actors.name, movies.id AS "movie_id", movies.title, cast_members.character FROM movies JOIN
    cast_members ON movies.id = cast_members.movie_id JOIN actors ON actors.id = cast_members.actor_id WHERE actors.id = ($1)',[actor_id]).to_a
  end
end

def get_movies
  db_connection do |conn|
    movies = conn.exec('SELECT movies.id, title, year, rating, genres.name AS "genre", studios.name AS "studio" FROM movies JOIN genres ON
    movies.genre_id = genres.id LEFT OUTER JOIN studios ON movies.studio_id = studios.id ORDER BY title').to_a
  end
end

def get_movie_details(movie_id)
  db_connection do |conn|
    movie_details = conn.exec_params('SELECT title, genres.name AS "genre", studios.name AS "studio", actors.id AS "actor_id", actors.name AS "actor", cast_members.character AS "role"
    FROM movies JOIN genres ON movies.genre_id = genres.id JOIN studios ON movies.studio_id = studios.id JOIN cast_members
    ON movies.id = cast_members.movie_id JOIN actors ON actors.id = cast_members.actor_id WHERE movies.id = ($1)', [movie_id]).to_a
  end
end

get "/movies" do
  erb :'movies/index', locals: {movies: get_movies}
end

get "/movies/:id" do
  movie_id = params[:id]
  erb :'movies/show', locals: {movie_details: get_movie_details(movie_id)}
end

get "/actors" do
  erb :'actors/index', locals: {actors: get_actors}
end

get "/actors/:id" do
  actor_id = params[:id]
  erb :'actors/show', locals: {actor_details: get_actors_details(actor_id)}
end
