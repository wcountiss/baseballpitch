crypto = require('crypto')

algorithm = 'aes-256-ctr'
password = process.env.ENCRYPT_PASSWORD

module.exports.encrypt = (text) ->
  cipher = crypto.createCipher(algorithm,password)
  crypted = cipher.update(text,'utf8','hex')
  crypted += cipher.final('hex');
  return crypted

module.exports.decrypt = (text) ->
  decipher = crypto.createDecipher(algorithm,password)
  dec = decipher.update(text,'hex','utf8')
  dec += decipher.final('utf8')
  return dec