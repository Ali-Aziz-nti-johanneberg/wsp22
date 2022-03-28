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
    id = session[:id].to_i
    slim(:index,locals:{rec:recipe_name})
end

get('/recipes/new') do
    slim(:new)
end

post('/recipes') do
    recipe_name = params[:name_recipe]
    ingrediens_list = params[:name_ingrediens]
    p "#{ingrediens_list} and #{recipe_name}"
    db = SQLite3::Database.new("db/db.db")
    db.execute('INSERT INTO recipe (recipe_name) VALUES (?)',recipe_name)   
    ingre_array = ingrediens_list.split(",")
    ingrediens_database = db.execute('SELECT ingredients_name FROM ingredients')
    i = 0
    while i < ingre_array.length
        if ingrediens_database.flatten.include?(ingre_array[i].to_s) == false
            db.execute('INSERT INTO ingredients (ingredients_name) VALUES (?)',ingre_array[i].to_s)
        end
        id_ing_temp = db.execute('SELECT id FROM ingredients WHERE ingredients_name = ?',ingre_array[i].to_s)
        p id_ing_temp
        id_rec_temp = db.execute('SELECT id FROM recipe WHERE id = (SELECT MAX(ID)  FROM recipe);')
        p id_rec_temp
        db.execute('INSERT INTO ingredients_recipes (ingredient_id, recipe_id) VALUES (?,?)',id_ing_temp, id_rec_temp)
        i += 1
    end

    redirect('/')
end


get('/recipes/:id') do
    id = params[:id]
    db = connect_to_db("db/db.db")
    db.results_as_hash = true
    show = db.execute("SELECT ingredients_name FROM ingredients WHERE id IN (SELECT ingredient_id FROM ingredients_recipes WHERE recipe_id = ?)",id)
    slim(:show,locals:{info:show})
end

post('/recipes/:id/delete') do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/db.db")
  db.execute("DELETE FROM recipe WHERE id = ?",id)
  redirect('/')
end

get('/recipes/:id/edit') do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/db.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM recipe WHERE Id = ?",id).first
  slim(:"edit",locals:{result:result})
end

post('/recipes/:id/update') do
  id = params[:id].to_i
  name = params[:name]
  db = SQLite3::Database.new("db/db.db")
  db.execute("UPDATE recipe SET recipe_name = ? WHERE Id = ? ",name,id)
  redirect('/')
end

get('/register') do
    slim(:register)
end

post('/users/new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
    if (password == password_confirm)
        password_digest = BCrypt::Password.create(password)
        db = connect_to_db("db/db.db")
        db.execute('INSERT INTO user (username,pwdigest) VALUES (?,?)',username,password_digest)
        redirect('/login')
    end
end

get('/showlogin') do
    slim(:login)
end

post('/login') do
    username = params[:username]
    password = params[:password]
    db = connect_to_db("db/db.db")
    result = db.execute('SELECT * FROM user WHERE username = ?',username).first
    pwdigest = result["pwdigest"]
    id = result["id"]

    if BCrypt::Password.new(pwdigest) == password
        session[:id] = id
        redirect('/')
    else
        "Invalid Username or Password"
    end
end