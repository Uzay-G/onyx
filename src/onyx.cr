require "./db"
require "yaml"
require "discordcr"
require "clear"

Clear::SQL.init("postgres://onyx:password@ip6-localhost/onyx", connection_pool_size: 5)

CONFIG = YAML.parse(File.read("./config.yaml"))
client = Discord::Client.new(token: CONFIG["discord_token"].to_s, client_id: CONFIG["client_id"].to_s.to_u64)

client.on_message_create do |message|
  author = message.author
  if message.content.starts_with? "~"
    user = nil
    if message.content == "~pin"
      begin
        user = User.query.find { id == author.id.value }
      rescue ex
        puts ex.message
      end
      if (user.nil?)
        begin
          user = User.new
          user.username = author.username
          user.id =  author.id.value
          user.save!
          puts user.username
        rescue ex
          puts ex.message
        end
      end
      begin
        quoted_text = client.get_channel_messages(channel_id: message.channel_id, limit: 2, around: message.id)[1]
        quote = Bookmark.new
        quote.id = quoted_text.id.value
        quote.body = quoted_text.content
        if (user)
          quote.user_id = user.id
          quote.author_name = quoted_text.author.username
        end
        if quote.save!
          client.create_message(message.channel_id, "Message saved!")
        end
      rescue ex
        puts ex.message
      end
    elsif message.content.starts_with? "~list"
      user = User.query.find { id == author.id.value }
      if (user.nil?)
        client.create_message(message.channel_id, "Message saved!")
      else
        quotes = Bookmark.query.where {user_id == author.id.value }
        quotes.each { |quote| client.create_message(message.channel_id, "From **#{quote.author_name}**\n #{quote.body} \n No: #{quote.id}")}
      end      
    elsif message.content.starts_with? "~delete"
      begin
        number = message.content.strip.split(" ")[1].to_i64
        bookmark = Bookmark.query.find { id == number }
        if (bookmark.nil?)
          client.create_message(message.channel_id, "Bookmark could not be found")
        else
          bookmark.delete
          client.create_message(message.channel_id, "Deleted this message from **#{bookmark.author_name}**\n > #{bookmark.body} has been deleted")
        end
      rescue ex
        puts ex.message
      end
    end
  end
end

client.run