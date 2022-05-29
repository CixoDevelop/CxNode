-- Tests for CxRequest
print("Start testing on CxRequest class")

print("First test running...")
test_request = CxRequest:new()
test_request:addData("GET /UwU?OwO=,EwE=xyz HTTP/1.1\r\n")
test_request:addData("Content-Length: 10\r\n")
test_request:addData("Content-Type: plain/text\r\nUser-Agent: Test_UwU_parser\r\n\r\n")
test_request:addData("Body data!")

if test_request:body() ~= "Body data!" then
    print("Body load not work!")
    print("Error: " .. test_request:body())
end

if test_request:method() ~= "GET" then
    print("Method load not work!")
    print("Error: " .. test_request:method())
end

if test_request:path() ~= "/UwU" then
    print("Path load not work!")
    print("Error: " .. test_request:path())
end

if 
    test_request:getParam("OwO") ~= "" or
    test_request:getParam("EwE") ~= "xyz" or
    test_request:getParam("not") ~= nil
then
    print("GET param load not work!")
    print("Error: " .. (test_request:getParam("OwO") or "nil"))
    print("Error: " .. (test_request:getParam("EwE") or "nil"))
    print("Error: " .. (test_request:getParam("nil") or "nil"))
end

if
    test_request:headerParam("Content-Length") ~= "10" or
    test_request:headerParam("Content-Type") ~= "plain/text" or
    test_request:headerParam("User-Agent") ~= "Test_UwU_parser" or
    test_request:headerParam("Not-Found") ~= nil
then
    print("Header Param load not work!")
    print("Error: " .. (test_request:headerParam("Content-Length") or "nil"))
    print("Error: " .. (test_request:headerParam("Content-Type") or "nil"))
    print("Error: " .. (test_request:headerParam("User-Agent") or "nil"))
    print("Error: " .. (test_request:headerParam("Not-Found") or "nil"))
end

if test_request:isComplete() ~= true then
    print("Complete check not work!")
end

test_request = nil

print("First test complete!")

print()

print("Start testing on CxResponse class")
print("First test running...")

test_response = CxResponse:new()
test_response:status(test_response.STATUS.CODE_200)
test_response:addContent("UwU")
test_response:addContent("OwO")
test_response:headerParam("Server", "Lua Test")
test_response:headerParam("Connection", "Close")

print(test_response:complete())

print("First test complete!")

test_response = nil
