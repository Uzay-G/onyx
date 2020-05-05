# onyx

Onyx is a Crystal bot that serves as a knowledge database and bookmarking client for discord.

[Invite the bot to your server](https://discord.com/api/oauth2/authorize?client_id=706904633695666177&permissions=0&scope=bot)

It saves user-specific bookmarks to save interesting messages you received for later.

# Usage

**`~help`** to get a list of all commands.
Run `~pin` to save the immediate previous message or do `~pin <message>` to save a specific message. (Supports code snippets and markdown)

`~delete <id>` to delete a specific bookmark.
`~deleteall`, pretty obvious
`~list` sends you a dm with all your bookmarks.

## Installation

Clone the github repository.

Run `shards install`

Create a `config.yaml` file with your `discord_token` and `client_id`.

Configure the postgres database based on the orm schema and the connection information at the start of `src/onyx.cr` and in `src/db.cr`.
And then do `crystal run src/onyx.cr` to launch your bot.

1. Fork it (<https://github.com/your-github-user/onyx/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Uzay-G](https://github.com/your-github-user) - creator and maintainer
