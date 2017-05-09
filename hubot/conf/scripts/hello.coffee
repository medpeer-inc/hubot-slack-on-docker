# Description:
#   Test
#
# Commands:
#   hubot hello - Say "Hi"

module.exports = (robot) ->
  robot.respond /HELLO$/i, (msg) ->
    # robot.brain.set msg.message.user.name, "test"
    msg.send "Hi"
