dofile("CxConfig.lc")
dofile("CxConnect.lc")
dofile("CxRest.lc")

CxConnect:setup()
CxConnect:connect()
CxConnect:setupNetworkEnable()