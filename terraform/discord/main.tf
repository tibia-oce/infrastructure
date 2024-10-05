data "discord_local_image" "serverIcon" {
    file = var.server_icon_file
}

resource "discord_server" "my_server" {
    depends_on = [
      data.discord_local_image.serverIcon
    ]
    name = var.server_name
    region = var.server_region
    default_message_notifications = 0
    icon_data_uri = data.discord_local_image.serverIcon.data_uri
}

data "discord_server" "createdServerInfo" {
    server_id = discord_server.my_server.id
}

resource "discord_invite" "inviteMe" {
    channel_id = discord_text_channel.general.id
    max_age = 0
}

resource "discord_category_channel" "defaultCategory" {
    depends_on = [
      data.discord_server.createdServerInfo
    ]
    name = "General"
    position = 0
    server_id = data.discord_server.createdServerInfo.id
}

resource "discord_category_channel" "categoryChannel" {
    depends_on = [
      data.discord_server.createdServerInfo
    ]
    name = var.category_name
    position = 1
    server_id = data.discord_server.createdServerInfo.id
}

resource "discord_text_channel" "general" {
    depends_on = [
        discord_category_channel.categoryChannel
    ]
    
    name = "general"

    position = 0

    server_id = data.discord_server.createdServerInfo.id
    category = discord_category_channel.defaultCategory.id
}

resource "discord_text_channel" "textChannels" {
    depends_on = [
        discord_category_channel.categoryChannel
    ]
    
    count = var.create_text_channels ? length(var.text_channels) : 0

    name = lower(var.text_channels[count.index])

    position = count.index + 1

    server_id = data.discord_server.createdServerInfo.id
    category = discord_category_channel.categoryChannel.id
}

resource "discord_voice_channel" "voiceChannels" {
    depends_on = [
        discord_category_channel.categoryChannel
    ]
    
    count = var.create_voice_channels ? length(var.voice_channels) : 0

    name = lower(var.voice_channels[count.index])

    position = count.index + length(var.text_channels) + 1

    server_id = data.discord_server.createdServerInfo.id
    category = discord_category_channel.categoryChannel.id
}

output "server_name" {
    value = discord_server.my_server.name
}
output "server_id" {
    value = discord_server.my_server.id
}

output "invite_info" {
    value = discord_invite.inviteMe.id
}
