require 'faker'
require 'sequel'
require 'sqlite3'
require 'mysql2'
require 'yaml'

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
# create_table! удаляет таблицу, если она уже есть
DB.create_table! :cities do
    primary_key :city_id
    string :city_name :null=>false
    string :city_country :null=>false
end

DB.create_table! :students do
    primary_key :student_id
    string :name :null=>false
    string :surname :null=>false
    string :gender :null=>false
    foreign_key :city_id, :cities, :null=>false
end
