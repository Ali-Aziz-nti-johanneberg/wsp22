def connect_to_db(path)
    db = SQLite3::Database.new(path)
    db.results_as_hash = true
    return db
end   

def user_info(username)
    db = connect_to_db("db/db.db")
    result = db.execute('SELECT * FROM user WHERE username = ?',username).first
    return result
end

def add_into_recipie(recipe_name,id)
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

def edit_recipe(id)
    db = SQLite3::Database.new("db/db.db")
    result = db.execute("SELECT * FROM recipe WHERE Id = ?",id).first
    return result
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

def all_recipe()
    db = connect_to_db("db/db.db")
    result = db.execute("SELECT * FROM recipe")
    return result
end

def all_recipe_by(id)
    db = connect_to_db("db/db.db")
    result = db.execute("SELECT * FROM recipe WHERE user_id = ?",id)
    return result
end

