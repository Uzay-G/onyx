require "./db"
require "yaml"
require "discordcr"
require "clear"

Clear::SQL.init("postgres://onyx:password@ip6-localhost/onyx", connection_pool_size: 5)
Bothosting = CLient.init(token)
CONFIG = YAML.parse(File.read("./config.yaml"))
client = Discord::Client.new(token: CONFIG["discord_token"].to_s, client_id: CONFIG["client_id"].to_s.to_u64)

client.on_message_create do |message|
  author = message.author
  commands = message.content.strip.split(" ")
  if commands[0].starts_with? "~"
    BotHosting.send_commands(commands[0])
    user = nil
    if commands[0] == "~pin"
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
        quote = Bookmark.new
        quoted_text = nil
        if commands.size < 2
          quoted_text = client.get_channel_messages(channel_id: message.channel_id, limit: 2, around: message.id)[1]
          quote.id = quoted_text.id.value
          quote.body = quoted_text.content
        else
          quote.id = message.id.value
          quote.body = commands[1..-1].join(" ")
        end
        if (user)
          quote.user_id = user.id
          quote.author_name = quoted_text.nil? ? user.username : quoted_text.author.username
        end
        if quote.save!
          client.create_message(message.channel_id, "Message saved!")
        end
      rescue ex
        puts ex.message
      end

    elsif commands[0] == "~list"
      user = User.query.find { id == author.id.value }
      if (user.nil?)
        client.create_message(message.channel_id, "You don't have any bookmarks")
      else
        quotes = Bookmark.query.where {user_id == author.id.value }
        if quotes.nil?
          client.create_message(message.channel_id, "You don't have any bookmarks")
        else
          dm = client.create_dm(recipient_id: author.id.value)
          client.create_message(message.channel_id, "Bookmarks sent to dms!")
          quotes.each { |quote| client.create_message(dm.id.value, "From **#{quote.author_name}**\n #{quote.body} \n No: #{quote.id}")}
        end
      end      
    elsif commands[0] == "~delete"
      begin
        number = commands[1].to_i64
        bookmark = Bookmark.query.find { id == number }
        if (bookmark.nil?)
          client.create_message(message.channel_id, "Bookmark could not be found")
        elsif (author.id.value != bookmark.user_id)
          client.create_message(message.channel_id, "You aren't allowed to delete that bookmark")
        else
          bookmark.delete
          client.create_message(message.channel_id, "Deleted this message from **#{bookmark.author_name}**\n > #{bookmark.body} has been deleted")
        end
      rescue ex
        puts ex.message
      end
    elsif commands[0] == "~deleteall"
      user = User.query.find { id == author.id.value }
      if (user.nil?)
        client.create_message(message.channel_id, "You don't have any bookmarks.")
      else
        bookmarks = Bookmark.query.where { user_id == user.id }.to_delete.execute
        client.create_message(message.channel_id, "All bookmarks deleted. :cry:")
      end
    elsif commands[0] == "~help"
      help = "**~pin**, saves the last message to your bookmarks or specify text to save
**~delete <id>**, delete bookmark from your collection
**~deleteall**, delete your entire collection of bookmarks
**~list**, sends all your bookmarks to dms"
      client.create_message(message.channel_id, help)
    end
  end
end

client.run