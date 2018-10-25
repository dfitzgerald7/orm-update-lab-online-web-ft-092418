require_relative "../config/environment.rb"
require "pry"

class Student
  attr_accessor :name, :grade, :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(name, grade)
    self.name = name
    self.grade = grade
  end

  def self.create_table
    sql = <<-SQL
          CREATE TABLE IF NOT EXISTS students(id INTEGER PRIMARY KEY, name TEXT, grade INTEGER)
          SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE students")
  end

  def save
    if self.id
      sql = "UPDATE students SET name = ?, grade = ?"
      DB[:conn].execute(sql, self.name, self.grade)
    else
      sql = <<-SQL
        INSERT INTO students (name, grade) VALUES (?, ?)
      SQL

      student = DB[:conn].execute(sql, self.name, self.grade)

      @id = DB[:conn].execute("SELECT id FROM students ORDER BY id DESC LIMIT 1")[0][0]
      student
    end
  end

  def self.create(name, grade)
    self.new(name, grade).tap{|stu| stu.save}
  end

  def self.new_from_db(row)
    self.new(row[1], row[2]).tap{|stu| stu.save}
  end

  def self.find_by_name(name)
  #  binding.pry
    stu_arr = DB[:conn].execute("SELECT * FROM students WHERE name = ?", name)[0]
    stu = self.new(stu_arr[1], stu_arr[2])
    stu.id = stu_arr[0]
    stu
  end

  def update
    DB[:conn].execute("UPDATE students SET name = ?, grade = ? WHERE id = ?", self.name, self.grade, self.id)
  end

end
