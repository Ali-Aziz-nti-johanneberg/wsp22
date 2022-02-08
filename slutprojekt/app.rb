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
    db = connect_to_db("db/slut_pro_jekt.db")
    recipe_name = db.execute("SELECT * FROM recipes")
    p "re är: #{recipe_name}"
    slim(:home,locals:{rec:recipe_name})
end