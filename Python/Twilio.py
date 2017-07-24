from twilio.rest import Client

emergency_account_access_code = "RfP5XPc9FUBtBmQ7eMQ9AIptUgeJg3lOdnYKttZn"

ACCOUNT_SID = "ACb68adc9e3caabc74f3a63ca330955e6a"
AUTH_TOKEN = "475362ce624b1f248f7c2b24421ad003"

client = Client(ACCOUNT_SID, AUTH_TOKEN)

message = client.messages.create(
    body="",
    to="+16366149325",
    from_="+13143845859"
)

print(message.sid)
