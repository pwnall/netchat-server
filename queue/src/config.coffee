fs     = require('fs')

filepath = "#{__dirname}/config.json"

console.log "Running from configuration file #{filepath.split('/').pop()}"

# Read the config file to pass along to the individual transports
try
  config = fs.readFileSync(filepath, 'utf8')
  config = JSON.parse(config)
catch err
  console.log 'Unable to parse config.json'
  process.exit(1)

# make sure no one accidentally modifies config
config = exports.config = Object.freeze(config)