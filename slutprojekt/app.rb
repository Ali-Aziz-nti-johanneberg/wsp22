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
    db.execute('INSERT INTO recipe (recipe_name) VALUES (?)',recipe_name)
    ingre_array = ingrediens_list.split(",")
    i = 0
    while i < ingre_array.length
        db.execute('INSERT INTO ingredients (ingredients_name) VALUES (?)',ingre_array[i].to_s)
        # Behöver lägga till i många till många tabel båda id för recipie och ingredienser.
        # Hur ska man ta reda på id om den får sitt id från sql cod.
        # Ide 1 skapa en variabler som börjar räkna från 0 ingredienser samma sak med reciept - går inte, hur ska den veta vad fär ingrediens den har?
        #Skapa en variable som har en array av alla ingredienser tillsammans med en varibel som räknar antalet reciept. 
        db.execute('INSERT INTO ingredients (ingredients_name) VALUES (?)',ingre_array[i].to_s)
        db.execute('INSERT INTO ingredients (ingredients_name) VALUES (?)',ingre_array[i].to_s)
        i += 1
    end

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