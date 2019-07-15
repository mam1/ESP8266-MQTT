 
--get data from DHT22 sensor
function rdDHT22(pin)
    --read sensor
    status, temp, humi, temp_dec, humi_dec = dht.read(pin)
    if status == dht.OK then
        temp = (temp*9)/5 + 32
    elseif status == dht.ERROR_CHECKSUM then
        print( " *** DHT Checksum error." )
    elseif status == dht.ERROR_TIMEOUT then
        print( " *** DHT timed out." )
    end
    return temp, humi 
end
		
-- MQTT connection error
function handle_mqtt_error(client, reason)
	print("*** mqtt connection error")

	if reason == mqtt.CONN_FAIL_SERVER_NOT_FOUND then
		print("    There is no broker listening at the specified IP Address and Port")
	elseif reason == mqtt.CONN_FAIL_NOT_A_CONNACK_MSG then
		print("    The response from the broker was not a CONNACK as required by the protocol")
	elseif reason == mqtt.CONN_FAIL_DNS	 then
		print("    DNS Lookup failed")
	elseif reason == mqtt.CONN_FAIL_TIMEOUT_RECEIVING	then
		print("    Timeout waiting for a CONNACK from the broker")
	elseif reason == mqtt.CONN_FAIL_TIMEOUT_SENDING	then
		print("    Timeout trying to send the Connect message")
	elseif reason == mqtt.CONNACK_ACCEPTED	then
		print("    No errors. Note: This will not trigger a failure callback.")
	elseif reason == mqtt.CONNACK_REFUSED_PROTOCOL_VER	then
		print("    The broker is not a 3.1.1 MQTT broker.")
	elseif reason == mqtt.CONNACK_REFUSED_ID_REJECTED	then
		print("    The specified ClientID was rejected by the broker. (See mqtt.Client())")
	elseif reason == mqtt.CONNACK_REFUSED_SERVER_UNAVAILABLE	then
		print("    The server is unavailable.")
	elseif reason == mqtt.CONNACK_REFUSED_BAD_USER_OR_PASS	then
		print("    The broker refused the specified username or password.")
	elseif reason == mqtt.CONNACK_REFUSED_NOT_AUTHORIZED	then
		print("    The username is not authorized.")
	else print("    unknown reason  <"..reason..">")
	end

	tmr.create():alarm(10 * 1000, tmr.ALARM_SINGLE, do_mqtt_connect)
end

-- connect to MQTT broker
function do_mqtt_connect()
	-- init mqtt client without logins, keepalive timer 120s
	print("initialise mqtt client")
	m = mqtt.Client("clientid", 120)

-- -- register callback fuctions
-- 	m:on("connect", function(client) print ("connected!") end)
-- 	m:on("offline", function(client) print ("offline") end)

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

	-- connect to broker
	print("connecting to mqtt broker")
  	m:connect(MQTTSERVER, MQTTPORT, 0, post,handle_mqtt_error)
end

function post()
	print("MQTT broker connected")

-- read sensor
	local t, h, topic

	t, h = rdDHT22(PIN)
    print("  DHT22 read -> t "..t.."  h "..h)

-- publish readings


	if m:publish(TTOPIC, t, MQTTQOS, 0) then
		print("successfull temperature publish")
	end
	if m:publish(HTOPIC, h, MQTTQOS, 0) then
		print("successfull humidity publish")
	end

    m:close();

end

-- -- init mqtt client without logins, keepalive timer 120s
-- 	print("initialise mqtt")
-- 	m = mqtt.Client("clientid", 120)

-- -- register callback fuctions
-- 	m:on("connect", function(client) print ("connected!") end)
-- 	m:on("offline", function(client) print ("offline") end)

-- 	-- on publish message receive event
-- 	m:on("message", function(client, topic, data)
-- 	  	print(topic .. ":" )
-- 	  	if data ~= nil then
-- 	    	print(data)
-- 	  	end
-- 	end)

-- -- on publish overflow receive event
-- 	m:on("overflow", function(client, topic, data)
-- 	  print(topic .. " partial overflowed message: " .. data )
-- 	end)

-- -- Connect to the mqtt server at the mqttport
-- 	print("connect to MQTT broker")

-- 	m:connect(MQTTSERVER, MQTTPORT, 0, function(client)
--   	print("connected")
  	
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
	-- end)

	-- m:on("connect", function(client) print ("connected!") end)
	-- m:on("offline", function(client) print ("offline") end)

	-- read sensor

	-- msg = string.format('{"sensor": "s1", "humidity": "%.2f", "temp": "%.3f", "ip": "%s", "vdd33": "%d", "rssi": %d}', h, t, ip, vdd33, RSSI) 
 --    print(msg)
 --    client:publish("sensor-readings", msg, 0, 0, function(client) print("sent") end)
	-- m:close()


-- **************************************************************** 

local htimer = tmr.create()
	htimer:register(DELAY, tmr.ALARM_AUTO, do_mqtt_connect)
	htimer:start()