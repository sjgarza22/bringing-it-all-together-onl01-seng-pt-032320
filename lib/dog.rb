class Dog
    attr_accessor :id, :name, :breed

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(hash)
        new_dog = self.new(name: hash[:name], breed: hash[:breed])
        new_dog.save
        new_dog
    end

    def self.new_from_db(row)
        new_dog = self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        results = DB[:conn].execute(sql, id)[0]
        self.new(id: results[0], name: results[1], breed: results[2])
    end

    def self.find_or_create_by(name:, breed:)
        sql = "SELECT id FROM dogs WHERE name = ? AND breed = ?"
        results = DB[:conn].execute(sql, name, breed)[0]
        if results != nil
            self.find_by_id(results)
        else
            self.create({:name => name, :breed => breed})
        end
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        results = DB[:conn].execute(sql, name)[0]
        self.new_from_db(results)
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end