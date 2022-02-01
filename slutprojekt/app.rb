require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions

def connect_to_db(path)
    db = SQLite3::Database.new(path)
    db.results_as_hash = true
    return db
end   

get('/') do
    slim(:home)
end
