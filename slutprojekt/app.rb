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
    db = connect_to_db("db/db.db")
    recipe_name = db.execute("SELECT * FROM recipe")
    p "re är: #{recipe_name}"
    slim(:index,locals:{rec:recipe_name})
end

get('/recipes/new') do
    slim(:new)
end

post('/recipes/new') do
    recipe_name = params[:name_recipe]
    ingrediens_list = params[:name_ingrediens]
    p "#{ingrediens_list} and #{recipe_name}"
    db = SQLite3::Database.new("db/db.db")
    db.execute('INSERT INTO recipe (recipe_name) VALUE (?)',recipe_name)
    redirect('/')
end


get('/recipes/:id') do
    id = params[:id]
    db = connect_to_db("db/db.db")
    recipe_show = db.execute("SELECT * FROM recipe WHERE id=?",id)[0]
    p "re är: #{recipe_show}"
    slim(:show,locals:{info:recipe_show})
end

get('/login') do
    slim(:login)
end