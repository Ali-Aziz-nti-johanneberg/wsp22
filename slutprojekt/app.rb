require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative './model.rb'

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

get('/showlogin') do
    slim(:login)
end

post('/login') do
    username = params[:username]
    password = params[:password]
    user_info(username)
    pwdigest = result["pwdigest"]
    id = result["id"]
    if BCrypt::Password.new(pwdigest) == password && username.empty? == false
        session[:id] = id
        redirect('/user')
    else
        "Invalid Username or Password"
    end
end

get('/recipes/new') do
    slim(:new)
end

post('/recipes') do
    id = session[:id].to_i
    recipe_name = params[:name_recipe]
    ingrediens_list = params[:name_ingrediens]
    p "#{ingrediens_list} and #{recipe_name}"
    add_into_recipie(recipe_name,id)
    ingre_array = ingrediens_list.split(",")
    ingrediens_database = ingrediens_database_show()
    i = 0
    while i < ingre_array.length
        if ingrediens_database.flatten.include?(ingre_array[i].to_s) == false
            add_into_ingredients(ingre_array,i)
        end
        insert_id_into_many(i,ingre_array)
        i += 1
    end
    redirect('/')
end


get('/recipes/:id') do
    id = params[:id]
    show = show_one_recipe(id)
    slim(:show,locals:{info:show})
end

post('/recipes/:id/delete') do
  id = params[:id].to_i
  delete_one_recipe(id)
  redirect('/')
end

get('/recipes/:id/edit') do
  id = params[:id].to_i
  result = edit_recipe(id)
  slim(:"edit",locals:{result:result})
end

post('/recipes/:id/update') do
  id = params[:id].to_i
  name = params[:name]
  update_recipe(id,name)
  redirect('/')
end

get('/register') do
    slim(:register)
end

post('/users/new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
    result = select_username(username)
    if result.empty?
        if (password == password_confirm)
            password_digest = BCrypt::Password.create(password)
            create_user(username,password_digest)
            redirect('/showlogin')
        else
            "Password do not match"
        end
    elsif username.empty?
        "Null"
    else
        "Username already taken"
    end
end

get('/user') do
    db = connect_to_db("db/db.db")
    id = session[:id].to_i
    if id == 1
        recipe_name = all_recipe()
    else
        recipe_name = all_recipe_by(id)
    end
    p "re är: #{recipe_name}"
    slim(:edit_user_index,locals:{rec:recipe_name})
end
