# Detroit Roleplay Bot

## How To Use?

First if you doesn't have node js and npm in your computer, download it first.
After that, open the Discord-Bot directory in your terminal. And use `npm install`
to download all needed library/modules, all denpendecies is registiry in package.json.

After install all library, create `.env` in Discord-Bot directory, and fill the file
with this env configuration :

```env
# server discord config
DISCORD_BOT_TOKEN=discord_bot_token
CLIENT_ID=id_client_or_server

# register config
CHANNEL_REGISTER_ID=id_channel_register
ROLE_VERIFIED=role_to_give_if_user_make_account

# database mysql config
USERNAME_DB=username_database
PASSWORD_DB=password_database
DATABASE_NAME=name_database
HOST_DB=database_host
PORT_DB=3306 # default port of mysql
```

Change all the values with your server configuration. The default mysql port is 3066, change if it different.

After doing all that things, run `npm start`

And enjoy, your discord server bot working good.

## How To Make Bot Discord?
