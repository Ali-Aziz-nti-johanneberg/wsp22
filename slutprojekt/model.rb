def connect_to_db(path)
    db = SQLite3::Database.new(path)
    db.results_as_hash = true
    return db
end   

def add_into_recipe(recipe_name,id)
    db = SQLite3::Database.new("db/db.db")
    db.execute('INSERT INTO recipe (recipe_name,user_id) VALUES (?,?)',recipe_name,id)
end

def ingrediens_database_show()
    db = SQLite3::Database.new("db/db.db")
    ingrediens_database = db.execute('SELECT ingredients_name FROM ingredients')
    return ingrediens_database
end

def add_into_ingredients(ingre_array,i)
    db = SQLite3::Database.new("db/db.db")
    db.execute('INSERT INTO ingredients (ingredients_name) VALUES (?)',ingre_array[i].to_s)
end

def insert_id_into_many(i,ingre_array)
    db = SQLite3::Database.new("db/db.db")
    id_ing_temp = db.execute('SELECT id FROM ingredients WHERE ingredients_name = ?',ingre_array[i].to_s)
    #Select the id of every ingredient in the array from the tabel.
    id_rec_temp = db.execute('SELECT id FROM recipe WHERE id = (SELECT MAX(ID)  FROM recipe);')
    #Select id from the latest tabell recipe
    db.execute('INSERT INTO ingredients_recipes (ingredient_id, recipe_id) VALUES (?,?)',id_ing_temp, id_rec_temp)
    #Insert ingredient id and recipie id into relation tabel
end

def show_one_recipe(id)
    db = connect_to_db("db/db.db")
    return db.execute("SELECT ingredients_name FROM ingredients WHERE id IN (SELECT ingredient_id FROM ingredients_recipes WHERE recipe_id = ?)",id)
end

def delete_one_recipe(id)
    db = SQLite3::Database.new("db/db.db")
    db.execute("DELETE FROM recipe WHERE id = ?",id)
end

def update_recipe(id,name)
    db = SQLite3::Database.new("db/db.db")
    db.execute("UPDATE recipe SET recipe_name = ? WHERE Id = ? ",name,id)
end

def select_username(username)
    db = connect_to_db("db/db.db")
    result = db.execute("SELECT username FROM user WHERE username=?",username)
    return result
end

def create_user(username,password_digest)
    db = connect_to_db("db/db.db")
    db.execute('INSERT INTO user (username,pwdigest) VALUES (?,?)',username,password_digest)
end

def every_user()
    db = connect_to_db("db/db.db")
    result = db.execute("SELECT * FROM user WHERE id NOT IN (1)")
    return result
end


def delete_one_user(id)
    db = SQLite3::Database.new("db/db.db")
    temp = db.execute("Select id FROM recipe WHERE user_id = ?",id)
    db.execute("DELETE FROM ingredients_recipes WHERE recipe_id = ?",temp)
    db.execute("DELETE FROM recipe WHERE user_id = ?",id)
    db.execute("DELETE FROM user WHERE id = ?",id)
end


def selectiv_everything(argument,tabel,attribute)
    db = connect_to_db("db/db.db")
    result = db.execute("SELECT * FROM #{tabel} WHERE #{attribute} = ?",argument).first
    #Select everything from tabel that includes a spefic attribute
    return result
end
#Ifall det behövs för dry-kod


=begin
def user_info(username) # argument = username , tabel = user , attribute = username
    db = connect_to_db("db/db.db")
    result = db.execute('SELECT * FROM user WHERE username = ?',username).first
    return result
end

def edit_recipe(id) #argument = id , tabel = recipe , attribute = Id
    db = SQLite3::Database.new("db/db.db")
    result = db.execute("SELECT * FROM recipe WHERE Id = ?",id).first
    return result
end
=end
def all_recipe_by(id) #argument = id , tabel = recipe , attribute = user_id
    db = connect_to_db("db/db.db")
    result = db.execute("SELECT * FROM recipe WHERE user_id = ?",id)
    return result
end


def all_recipe() #argument = , tabel = recipe , attribute = 
    db = connect_to_db("db/db.db")
    result = db.execute("SELECT * FROM recipe")
    #Returns all recipes
    return result
end

def owner_id(id)
    db = connect_to_db("db/db.db")
    result = db.execute("SELECT user_id FROM recipe WHERE id=?",id.to_i).first
    return result
end