require "clear"

class User
  include Clear::Model
  column id : UInt64, primary: true
  column username : String
  has_many bookmarks : Bookmark
end

class Bookmark
  include Clear::Model
  column id : UInt64, primary: true
  column author_name : String
  column body : String

  column user_id : UInt64
end

# CREATE table users (
# id bigint PRIMARY KEY,
# username varchar(25)
# );
