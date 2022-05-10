require 'json'

def filter(event)
    message = event.get("[message]")
    event.remove("[message]")

    original_event = JSON.parse(message)
    original_event.each do |fieldname, value|
        event.set(fieldname, value)
    end
    
    return [event]
end
