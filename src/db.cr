require "clear"

class User
  include Clear::Model
  column discord_id : UInt64
  column username : String
  has_many bookmarks : Bookmark
end

class Bookmark
  include Clear::Model
  column id : UInt64
  column author_name : String
  column text : String

  column user_id : UInt64
end
