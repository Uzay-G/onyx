require "yaml"
require "discordcr"

CONFIG = YAML.parse(File.read("./config.yaml"))
client = Discord::Client.new(token: CONFIG["discord_token"].to_s, client_id: CONFIG["client_id"].to_s.to_u64)
client.run