from twilio.rest import TwilioRestClient

emergency_account_access_code = "RfP5XPc9FUBtBmQ7eMQ9AIptUgeJg3lOdnYKttZn"

ACCOUNT_SID = "ACb68adc9e3caabc74f3a63ca330955e6a"
AUTH_TOKEN = "475362ce624b1f248f7c2b24421ad003"

client = TwilioRestClient(ACCOUNT_SID, AUTH_TOKEN)

body_message = raw_input("Message Body: ")

message = client.messages.create(
    body="what time will you be home?",
    to="+16366149325",
    from_="+16367289229"
)

print(message.sid)