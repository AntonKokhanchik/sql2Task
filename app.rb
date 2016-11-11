# require 'faker'
require 'sequel'
# require 'sqlite3'
require 'mysql2'
require 'yaml'
require 'hash_dot'

# берём файл конфигураций
@config = YAML.load_file('config.yml').to_dot

# подключаем базу
DB = Sequel.connect(
    :adapter => 'mysql2',
    :host => @config.db_host,
    :database => @config.db_name,
    :user => @config.db_user,
    :password => @config.db_password)

# создаём таблицы
# drop_table? удаляет таблицу, если она уже есть
DB.drop_table? :students
DB.drop_table? :cities

DB.create_table :cities do
    primary_key :city_id
    String :city_name, :null=>false
    String :city_country, :null=>false
end

DB.create_table :students do
    primary_key :student_id
    String :name, :null=>false
    String :surname, :null=>false
    Integer :course, :null=>false
    TrueClass :is_male, :null=>false
    foreign_key :city_id, :cities, :null=>false
end

students = DB[:students]
cities = DB[:cities]

cities.import(
  [:city_name, :city_country],
  [ ['Erfurt','Germany'],
    ['San-Francisco', 'USA'],
    ['Capetown', 'South Africa'],
    ['Beijing(Pekin)', 'China'],
    ['Essen', 'Germany'],
    ['Hamburg', 'Germany'],
    ['Atlanta', 'USA'] ] )


students.import(
  [:name,:surname, :course, :is_male, :city_id],
  [ ['Mark', 'Schmidt', 3,true, 1],
    ['Helen', 'Hunt', 2, false, 2],
    ['Matumba', 'Zuko', 4, true, 3],
    ['Rin', 'Kupo', 4, false,3],
    ['Zhen', 'Chi Bao', 2, true, 4],
    ['Peter', 'Zimmer', 3, true, 5],
    ['Hanz', 'Mueller', 4, true, 6],
    ['Alisa', 'Kepler', 4, false, 1],
    ['Anna', 'Madavie', 2, false, 7] ] )

# 1) вывести количество студентов
temp = students.count(:name)
puts "Всего #{temp} студентов\n\n"

# 2) сколько студенток-девочек приехало учиться и на
# каких они курсах
temp = students.where(:is_male=>false)
puts "Девушки:"
temp.all do |girl|
  puts "#{girl[:name]} #{girl[:surname]}, #{girl[:course]} курс"
end
puts "Всего: #{temp.count(:name)}\n\n"

# 3) сколько студентов приехало учиться из Германии
temp = cities.where(:city_country=>'Germany').select(:city_id)
temp = students.where(:city_id=>temp)
puts "Студентов из Германии: #{temp.count(:name)}\n\n"

# 4) сколько студентов младше четвертого курса
# у нас обучаются (не включая сам 4 курс)
temp = students.where{course < 4}
puts "Студентов младше 4 курса: #{temp.count(:name)}"

# 5) необходимо перевести Анну со 2 на 3 курс, а
#  Питера за неуспеваемость на второй курс
students.where(:name=>'Anna').update(:course=>3)
students.where(:name=>'Peter').update(:course=>2)
