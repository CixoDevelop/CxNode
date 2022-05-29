-- Simple tests for CxConfig.lua --

CxConfig.writeConfig("test.cnf", {UwU = "OwO", OwO = "UwU"})

if CxConfig.readConfig("test.cnf").UwU ~= "OwO" then
    print("CxConfig not work!")
end

if CxConfig.readConfig("test.cnf").OwO ~= "UwU" then
    print("CxConfig not work!")
end

CxConfig.writeConfig("test.cnf")
