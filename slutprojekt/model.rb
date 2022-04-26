module Model
    # Connect to spefic database/Sqlite
    def connect_to_db(path)
        db = SQLite3::Database.new(path)
        db.results_as_hash = true
        return db
    end   

    # Insert a new row in the recipe table
    #@param [String] name of the recipe
    #@Session [Integer] id of user
    def add_into_recipe(param,id)
        db = SQLite3::Database.new("db/db.db")
        db.execute('INSERT INTO recipe (recipe_name,user_id) VALUES (?,?)',param,id)
    end 

    # Select ingredients_name from ingredients
    # Return [Array] containing the data of all ingredients_name in the tabel ingredients
    def ingrediens_database_show()
        db = SQLite3::Database.new("db/db.db")
        ingrediens_database = db.execute('SELECT ingredients_name FROM ingredients')
        return ingrediens_database
    end

    # Attempts to insert a new row in the ingredients table
    # @params [String] ingre_array, an array containing added ingredients name
    # I [Integer] position in the array
    def add_into_ingredients(ingre_array,i)
        db = SQLite3::Database.new("db/db.db")
        db.execute('INSERT INTO ingredients (ingredients_name) VALUES (?)',ingre_array[i].to_s)
    end

    # Attempts to insert a new row in the ingredients_recipes table
    # @params [String] ingre_array, an array containing all added ingredients name
    # I [Integer] position in the array
    def insert_id_into_many(i,ingre_array)
        db = SQLite3::Database.new("db/db.db")
        id_ing_temp = db.execute('SELECT id FROM ingredients WHERE ingredients_name = ?',ingre_array[i].to_s)
        #Select the id of every ingredient in the array from the tabel.
        id_rec_temp = db.execute('SELECT id FROM recipe WHERE id = (SELECT MAX(ID)  FROM recipe);')
        #Select id from the latest tabell recipe
        db.execute('INSERT INTO ingredients_recipes (ingredient_id, recipe_id) VALUES (?,?)',id_ing_temp, id_rec_temp)
        #Insert ingredient id and recipie id into relation tabel
    end

    # Searches ingredients for any matching integer
    # @params [Integer] id of the user
    # @return [Hash] containing the data of all matching id
    def show_one_recipe(id)
        db = connect_to_db("db/db.db")
        return db.execute("SELECT ingredients_name FROM ingredients WHERE id IN (SELECT ingredient_id FROM ingredients_recipes WHERE recipe_id = ?)",id)
    end

    # Attempts to delete a row from the recipe table
    # @params [Integer] id, The recipe id
    def delete_one_recipe(id)
        db = SQLite3::Database.new("db/db.db")
        db.execute("DELETE FROM recipe WHERE id = ?",id)
    end


    # Attempts to update a row in the recipe table
    #@params [String] name, new name(Recipe)
    #@params [Integer] id, recipe id
    def update_recipe(id,name)
        db = SQLite3::Database.new("db/db.db")
        db.execute("UPDATE recipe SET recipe_name = ? WHERE Id = ? ",name,id)
    end

    # Searches user for any matching text
    # @params [String] username, username of the user 
    # @return [Hash] containing all the data of the follwing matching username
    def select_username(username)
        db = connect_to_db("db/db.db")
        result = db.execute("SELECT username FROM user WHERE username=?",username)
        return result
    end

    # Attempts to insert a new row in the user table    
    # @params [String] username, username of the new user
    # @params [String] password_digest, password of the new user
    def create_user(username,password_digest)
        db = connect_to_db("db/db.db")
        db.execute('INSERT INTO user (username,pwdigest) VALUES (?,?)',username,password_digest)
    end

    # Select everything from every user exept i=!
    # @return [Hash] containing the data of all user exepct one
    def every_user()
        db = connect_to_db("db/db.db")
        result = db.execute("SELECT * FROM user WHERE id NOT IN (1)")
        return result
    end

    # Attempts to delete a row from the table following tables recipe, ingredients_recipe, recipe and user
    # @param [Integer] id, The users's ID

    def delete_one_user(id)
        db = SQLite3::Database.new("db/db.db")
        temp = db.execute("Select id FROM recipe WHERE user_id = ?",id)
        db.execute("DELETE FROM ingredients_recipes WHERE recipe_id = ?",temp)
        db.execute("DELETE FROM recipe WHERE user_id = ?",id)
        db.execute("DELETE FROM user WHERE id = ?",id)
    end

    
    # Searches tabel for any matching argument within an atribute
    # @return [hash] containing the data of all matching argument
    def selectiv_everything(argument,tabel,attribute)
        db = connect_to_db("db/db.db")
        result = db.execute("SELECT * FROM #{tabel} WHERE #{attribute} = ?",argument).first
        #Select everything from tabel that includes a spefic attribute
        return result
    end
    #Ifall det behövs för dry-kod

    # Searches recipe for any matching integer
    # Session id [Integer], user's id
    # @return [hash] containing the data of all mathcing id
    def all_recipe_by(id)
        db = connect_to_db("db/db.db")
        result = db.execute("SELECT * FROM recipe WHERE user_id = ?",id)
        return result
    end

    # Selecting everything from recipe tabel
    # @return [hash] containing the data of all recipe
    def all_recipe()
        db = connect_to_db("db/db.db")
        result = db.execute("SELECT * FROM recipe")
        #Returns all recipes
        return result
    end

    # Searches recipe for any matching integer
    # "params [Integer] id, users id
    # @return [hash] containing the user_id from the recipe
    def owner_id(id)
        db = connect_to_db("db/db.db")
        result = db.execute("SELECT user_id FROM recipe WHERE id=?",id.to_i).first
        return result
    end
end