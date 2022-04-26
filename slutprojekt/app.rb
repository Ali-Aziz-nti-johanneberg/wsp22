require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative './model.rb'

enable :sessions

include Model

#Outside counter
failed_attempt = 0


# Check the user's authorization
# @param [Integer] id, The recipe id
# @see Model#owner_id
def authorization(id)
    owner = owner_id(id)
    if owner["user_id"] != session[:id]
        if 1 !=session[:id]
            info = "unauthorized access"
            session[:info] = info
            redirect('/error')
        end
    end
end


# Display Landing Page 
get('/') do 
    db = connect_to_db("db/db.db")
    recipe_name = db.execute("SELECT * FROM recipe")
    p "re är: #{recipe_name}"
    id = session[:id].to_i
    slim(:index,locals:{rec:recipe_name})
end

# Displays a login form
get('/showlogin') do
    slim(:login)
end

# Attempts login and updates the session
#
# @param [String] username, The username
# @param [String] password, The password

post('/login') do
    session[:time] = 0
    if failed_attempt < 2
        username = params[:username]
        password = params[:password]
        result = selectiv_everything(username,"user","username")
        if result == nil
            pwdigest = "/n"
        else 
            pwdigest = result["pwdigest"]
            id = result["id"]
        end
        if pwdigest != "/n" && BCrypt::Password.new(pwdigest) == password && username.empty? == false
            session[:id] = id
            redirect('/user')
        else
            if failed_attempt < 1
                failed_attempt += 1
                p "#{failed_attempt} failed attempt"
                "Invalid Username or Password"
                redirect("showlogin")
            else
                failed_attempt += 1
                session[:info] = "Unexpected spam"
                redirect('/error')
            end
        end
    else 
        sleep(15)
        p "Done waiting"
        failed_attempt = 0
        redirect("showlogin")
    end
end

# Displays an adding/insert form
get('/recipes/new') do
    slim(:new)
end

# Creates a new recipe and redirects to '/'
#
# @param [String] recipe_name, The title of the article
# @param [String] ingrediens_list, The content of the article
#
# @see Model#add_into_recipe
# @see Model#ingrediens_database_show
post('/recipes') do
    id = session[:id].to_i
    recipe_name = params[:name_recipe]
    ingrediens_list = params[:name_ingrediens]
    p ingrediens_list.include?(",")
    if ingrediens_list.include?(",") == false
        "Seperate the ingrediens through putting -> , <--"
        "Example"
        "Potato-4st,milk-500ml"
    else
        p "#{ingrediens_list} and #{recipe_name}"
    add_into_recipe(recipe_name,id)
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
end

# Displays a single recipe
#
# @param [Integer] :id, the ID of the recipe
# @see Model#show_one_recipe
get('/recipes/:id') do
    id = params[:id]
    show = show_one_recipe(id)
    slim(:show,locals:{info:show})
end

# Deletes an existing recipie and redirects to '/'
#
# @param [Integer] :id, The ID of the recipe
# @see Model#delete_one_recipe
post('/recipes/:id/delete') do
  id = params[:id].to_i
  authorization(id)
  delete_one_recipe(id)
  redirect('/')
end

# Displays a edit form
#@see Model#selectiv_everything
get('/recipes/:id/edit') do
  id_now = params[:id].to_i
  authorization(id_now)
  result = selectiv_everything(id_now,"recipe","Id")
  slim(:"edit",locals:{result:result})
end

# Updates an existing recipe and redirects to '/'
#
# @param [Integer] :id, The ID of the article
# @param [String] name, The new name of the recipe
#
# @see Model#update_recipe
post('/recipes/:id/update') do
  id = params[:id].to_i
  authorization(id)
  name = params[:name]
  update_recipe(id,name)
  redirect('/')
end

# Displays a register form
get('/register') do
    slim(:register)
end

# Attempts to register
#
# @param [String] username, The username
# @param [String] password, The password
# @param [String] repeat-password, The repeated password
#
# @see Model# select_username
# @see Model# create_user
post('/users/new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
    result = select_username(username)
    if result.empty? && password.empty == false
        if (password == password_confirm)
            password_digest = BCrypt::Password.create(password)
            create_user(username,password_digest)
            redirect('/showlogin')
        else
            "Password do not match"
        end
    elsif username.empty?
        "Invalid username or password"
    else
        "Username already taken"
    end
end

# Displays every article connected to the user
#
# @param [Integer] id, the ID of the article
# @see Model#all_recipe
# @see Model#all_recipe_by
get('/user') do
    id = session[:id].to_i
    if id == 1
        recipe_name = all_recipe()
    else
        recipe_name = all_recipe_by(id)
    end
    p "re är: #{recipe_name}"
    slim(:edit_user_index,locals:{rec:recipe_name})
end

# Displays every user
#
# @see Model#every_user
get('/users') do
    if session[:id] == 1
        user_list = every_user()
    else
        info = "unauthorized access"
        session[:info] = info
        redirect('/error')
    end
    slim(:index_admin,locals:{rec:user_list})
end


# Deletes an existing user and redirects to '/'
#
# @param [Integer] :id, The ID of the user
# @see Model#delete_one_user
post('/users/:id/delete') do
    id = params[:id].to_i
    delete_one_user(id)
    redirect('/')
end

# Displays an error message
get('/error') do
    time = Time.now
    session[:time] = time
    "#{session[:info]}"
end
