CxConnect = {
    --
    -- This class is useful for establishing a connection. First try to connect
    -- to the network saved in lan.net, but if for some reason it fails, it 
    -- will create a hotspot with the configuration saved in config.net
    -- 

    config = {
        setup = {},
        lan = {}
    }
}
    
function CxConnect:setup()
    --
    -- This function loads the network configuration saved in the configuration
    -- files into the object
    --

    -- Loading lan setup --
    self.config.lan = CxConfig.readConfig("lan.net")

    -- Loading config AP setup with defaults --
    self.config.setup = CxConfig.readConfig("setup.net") or 
    {
        ssid = "CxConnect",
        ip = "192.168.0.1",
        netmask = "255.255.255.0",
        gateway = "192.168.0.1",
        start = "192.168.0.200"
    }
end

function CxConnect:connect()
    --
    -- This function tries to establish a connection to the local WiFi network,
    -- if the configuration file is empty or does not exist, it will open the
    -- configuration network
    --

    -- If lan is not config, open AP --
    if self.config.lan == nil then
        self.openSetupNetwork()
        return 
    end

    -- Try connect to lan --
    wifi.setmode(wifi.STATION)

    self.config.lan.save = false
    self.config.lan.auto = true
    
    wifi.sta.config(self.config.lan)

    -- Setup hostname --
    if self.config.lan.hostname then
        wifi.sta.sethostname(self.config.lan.hostname)
    end

    -- Setup IP --
    if self.config.lan.ip then
        wifi.sta.setip(self.config.lan)
    end
    
    wifi.sta.connect()
end

function CxConnect:setupNetworkEnable()
    --
    -- This function starts the configuration network if the local network
    -- becomes disconnected and turns off the configuration network after 
    -- reconnection
    --

    wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, self.closeSetupNetwork)
    wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, self.openSetupNetwork)
end

function CxConnect:setupNetworkDisable()
    --
    -- This function stops the configuration network if the local network
    -- becomes disconnected and turns off the configuration network after 
    -- reconnection
    --

    wifi.eventmon.unregister(wifi.eventmon.STA_CONNECTED)
    wifi.eventmon.unregister(wifi.eventmon.STA_DISCONNECTED)
end

function CxConnect.openSetupNetwork()
    --
    -- This function starts the configuration network
    --

    wifi.setmode(wifi.STATIONAP)
    wifi.ap.config(CxConnect.config.setup)
    wifi.ap.setip(CxConnect.config.setup)
    wifi.ap.dhcp.config(CxConnect.config.setup)
    wifi.ap.dhcp.start()
end

function CxConnect.closeSetupNetwork()
    --
    -- This function stops the configuration network
    --

    wifi.setmode(wifi.STATION)
    wifi.ap.dhcp.stop()
end
