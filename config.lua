PIN=7
DELAY=600
ABORT_DELAY=30000
HOSTNAME="MQTT-DHT22-dryer"
TIMEOUT=100000    -- timeout to check the network status
EXSENSOR1="tempumid.lua"    -- module to run
MQTTSERVER="192.168.254.221"   -- mqtt broker address
MQTTPORT="1883"  -- mqtt broker port
MQTTQOS="0" -- qos used
CNAME="shop/dryer" -- Client name 
AMBIENT="258Thomas"  -- Ambient name
TTOPIC     = AMBIENT.."/"..CNAME.."/temperature"  -- Temperature topic
HTOPIC     = AMBIENT.."/"..CNAME.."/humidity"  -- Humidity topic 
STOPIC     = AMBIENT.."/"..CNAME.."/status"  -- Status topic
CTOPIC     = AMBIENT.."/"..CNAME.."/command" --Command topic   
MTOPIC     = AMBIENT.."/"..CNAME.."/monitor" --Monitor topic
