require "./db"
require "yaml"
require "discordcr"

CONFIG = YAML.parse(File.read("./config.yaml"))
client = Discord::Client.new(token: CONFIG["discord_token"].to_s, client_id: CONFIG["client_id"].to_s.to_u64)

client.on_message_create do |message|
  if message.content.starts_with? "~"
    author = message.author
    if message.content == "~pin"
      puts "dsadsdasd"
      user = User.query.find { discord_id == author.id }
      if (!user)
        user = User.new
        user.username = author.username
        user.discord_id =  author.id.value
        user.save!
      end
      quoted_text = client.get_channel_messages(channel_id: message.channel_id, limit: 2, around: message.id)[1]
      quote = Bookmark.new
      quote.id = quoted_text.id.value
      quote.text = quoted_text.content
      quote.user_id = user.discord_id
      if quote.save!
        client.create_message(message.channel_id, "Message saved!")
      end
    end
  end
end

client.run