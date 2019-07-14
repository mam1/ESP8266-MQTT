
--get data from DHT22 sensor on <pin>
function rdDHT22()
    --read sensor
    status, temp, humi, temp_dec, humi_dec = dht.read(PIN)
    if status == dht.OK then
        temp = (temp*9)/5 + 32
    elseif status == dht.ERROR_CHECKSUM then
        print( " *** DHT Checksum error." )
    elseif status == dht.ERROR_TIMEOUT then
        print( " *** DHT timed out." )
    end
    return temp, humi 
end

function tupdate()
	local t, h

    t, h = rdDHT22()
    print("  DHT22 read -> t "..t.."  h "..h)
    print("    posting temperature "..tostring(t))
    post(CHANNEL_API_KEY,1,tostring(t))

	local htimer = tmr.create()
	htimer:register(delay/4, tmr.ALARM_SINGLE, hupdate)
	htimer:start()
end

function hupdate()

	local t, h

    t, h = rdDHT22(PIN)
    print("  DHT22 read -> t "..t.."  h "..h)
    print("    posting humidity "..tostring(h))
    post(CHANNEL_API_KEY,2,tostring(h))

end

	
function handle_mqtt_error(client, reason)
	print("mqtt connection error")
	tmr.create():alarm(10 * 1000, tmr.ALARM_SINGLE, do_mqtt_connect)
end

function do_mqtt_connect()
	print("connected to mqtt broker")
  mqtt:connect("server", function(client) print("connected") end, handle_mqtt_error)
end

function post()
	print("posting")
	print("initialise mqtt")

-- init mqtt client without logins, keepalive timer 120s
	m = mqtt.Client("clientid", 120)
	m:on("connect", function(client) print ("connected") end)
	m:on("offline", function(client) print ("offline") end)

	-- on publish message receive event
	m:on("message", function(client, topic, data)
	  	print(topic .. ":" )
	  	if data ~= nil then
	    	print(data)
	  	end
	end)

-- on publish overflow receive event
	m:on("overflow", function(client, topic, data)
	  print(topic .. " partial overflowed message: " .. data )
	end)

-- Connection to the mqtt server at the mqttport
	print("trying to connect ")

	m:connect(MQTTSERVER, MQTTPORT, 0, function(client)
  	print("connected")
  	
  -- Calling subscribe/publish only makes sense once the connection
  -- was successfully established. You can do that either here in the
  -- 'connect' callback or you need to otherwise make sure the
  -- connection was established (e.g. tracking connection status or in
  -- m:on("connect", function)).

 --  -- subscribe topic with qos = 0
 --  	client:subscribe("/topic", 0, function(client) print("subscribe success") end)
 --  -- publish a message with data = hello, QoS = 0, retain = 0
 --  	client:publish("/topic", "hello", 0, 0, function(client) print("sent") end)
	-- end,
	-- function(client, reason)
 --  		print("failed reason: " .. reason)
	end)

	

	print("&&&&&&&&&&& connected ... \nsensor <"..HOSTNAME.."> active")
	print("publishing to "..AMBIENT.."/"..CNAME.."/ ...")

	-- read sensor
	local t, h
	t, h = rdDHT22()
    print("  DHT22 read -> t "..t.."  h "..h)
	-- msg = string.format('{"sensor": "s1", "humidity": "%.2f", "temp": "%.3f", "ip": "%s", "vdd33": "%d", "rssi": %d}', h, t, ip, vdd33, RSSI) 
 --    print(msg)
 --    client:publish("sensor-readings", msg, 0, 0, function(client) print("sent") end)
	-- m:close()
end



local htimer = tmr.create()
	htimer:register(DELAY, tmr.ALARM_SINGLE, post)
	htimer:start()