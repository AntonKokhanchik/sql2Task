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

DB[:cities].import ([:city_name, :city_country], [
    ['Erfurt','Germany'],
    ['San-Francisco', 'USA'],
    ['Capetown', 'South Africa'],
    ['Beijing(Pekin)', 'China'],
    ['Essen', 'Germany'],
    ['Hamburg', 'Germany'],
    ['Atlanta', 'USA']
    ])

DB[:students].import([:name,:surname, :course, :is_male, :city_id], [
    ['Mark', 'Schmidt', 3,true, 1],
    ['Helen', 'Hunt', 2, false, 2],
    ['Matumba', 'Zuko', 4, true, 3],
    ['Rin', 'Kupo', 4, false,3],
    ['Zhen', 'Chi Bao', 2, true, 4],
    ['Peter', 'Zimmer', 3, true, 5],
    ['Hanz', 'Mueller', 4, true, 6],
    ['Alisa', 'Kepler', 4, false, 1],
    ['Anna', 'Madavie', 2, false, 7]
    ])
# FIXME: syntax error, unexpected ',', expecting ')' in 40 line
