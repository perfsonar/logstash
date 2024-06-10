require 'socket'
require 'resolv'

def parse_endpoint(endpoint)
    # Sometimes endpoints aren't just straight-up hostnames or ips. 
    #  In cases like 'disk-to-disk' they can be URLs or host:port
    #  This function extracts just the hostname or IP in that case
    if !endpoint then
        return
    end
    
    if URI.regexp().match(endpoint) then
        #handle case where its a URL
        begin
            endpoint = URI.parse(endpoint).host
        rescue
        end
    elsif URI.regexp().match("http://" + endpoint) then
        #hacky way to handle host:port variations
        begin
            endpoint = URI.parse("http://" + endpoint).host
        rescue
        end
    end
    
    #remove square brackets
    endpoint = endpoint.sub("[", "")
    endpoint = endpoint.sub("]", "")
    
    return endpoint
end

def get_ips(address, ipversion=nil)
    result = {
        'ipv4' => nil,
        'hostname_v4' => nil,
        'ipv6' => nil,
        'hostname_v6' => nil
    }
    is_hostname = !Regexp.union([Resolv::IPv4::Regex, Resolv::IPv6::Regex]).match?(address)
    
    # Try getaddrinfo first. It looks in /etc/hosts hen falsback to DNS
    # If a hostname has both IPv4 and IPv6 addresses, but only one set is in hosts file
    # then it will not try DNSS and you will not get all the addresses.
    begin
        #note: reverse lookups with getaddrinfo don't seem to consistently work so don't even bother
        addrinfo = Socket.getaddrinfo(address, nil)
        addrinfo.each do |ai|
            if ai[0] == 'AF_INET' then
                result['ipv4'] = ai[3]
                #result['hostname_v4'] = ai[2]
            elsif ai[0] == 'AF_INET6' then
                result['ipv6'] = ai[3]
                #remove scope id since not compatible with elastic ip type
                result['ipv6'] = result['ipv6'].gsub(/%\d+?/,"")
                #result['hostname_v6'] = ai[2]
            end
        end

        # If we didn't get ipv4 or ipv6 (when version specified) from getaddrinfo, then try DNS
        if ipversion == 4 and is_hostname and result['ipv4'].nil? then
            Resolv::DNS.open do |dns|
                dns_res = dns.getresources(address, Resolv::DNS::Resource::IN::A).map(&:address)
                if dns_res.length > 0 then
                    result['ipv4'] = "#{dns_res[0]}"
                end
            end
        elsif ipversion == 6 and is_hostname and result['ipv6'].nil? then
            Resolv::DNS.open do |dns|
                dns_res = dns.getresources(address, Resolv::DNS::Resource::IN::AAAA).map(&:address)
                if dns_res.length > 0 then
                    result['ipv6'] = "#{dns_res[0]}"
                end
            end
        end
    rescue
    end
    
    #do reverse lookups after we settled on addresses
    # if we were given a hostname, just use that
    if result['ipv4'] then
        begin
            if is_hostname then
                result['hostname_v4'] = address
            else
                result['hostname_v4'] = Resolv.new.getname result['ipv4']
            end
        rescue
        end
    end
    if result['ipv6'] then
        begin
            if is_hostname then
                result['hostname_v6'] = address
            else
                result['hostname_v6'] = Resolv.new.getname result['ipv6']
            end
        rescue
        end
    end
    
    return result
end

def handle_observer(event, input_address, ipversion)
    address = get_ips(input_address, ipversion)
    
    if ipversion == 6 or (!ipversion and address['ipv6']) then
        event.set("[meta][observer][ip]", address['ipv6'])
        event.set("[meta][observer][hostname]", address['hostname_v6'])
    elsif ipversion == 4 or (!ipversion and address['ipv4']) then
        event.set("[meta][observer][ip]", address['ipv4'])
        event.set("[meta][observer][hostname]", address['hostname_v4'])
    end
end

def handle_pair(event, input_source, input_dest, ipversion)
    source = get_ips(input_source, ipversion)
    dest = get_ips(input_dest, ipversion)
    
    if ipversion == 6 or (!ipversion and source['ipv6'] and dest['ipv6']) then
        event.set("[meta][source][ip]", source['ipv6'])
        event.set("[meta][source][hostname]", source['hostname_v6'])
        event.set("[meta][destination][ip]", dest['ipv6'])
        event.set("[meta][destination][hostname]", dest['hostname_v6'])
        event.set("[meta][ip_version]", 6)
    elsif ipversion == 4 or (!ipversion and source['ipv4'] and dest['ipv4']) then
        event.set("[meta][source][ip]", source['ipv4'])
        event.set("[meta][source][hostname]", source['hostname_v4'])
        event.set("[meta][destination][ip]", dest['ipv4'])
        event.set("[meta][destination][hostname]", dest['hostname_v4'])
        event.set("[meta][ip_version]", 4)
    end

    #Make sure we always have a hostname - fallback to IP if not set
    if event.get("[meta][source][ip]") and not event.get("[meta][source][hostname]") then
        event.set("[meta][source][hostname]", event.get("[meta][source][ip]"))
    end
    if event.get("[meta][destination][ip]") and not event.get("[meta][destination][hostname]") then
        event.set("[meta][destination][hostname]", event.get("[meta][destination][ip]"))
    end
end

def handle_source(event, input_address, ipversion)
    address = get_ips(input_address, ipversion)
    
    if ipversion == 6 or (!ipversion and address['ipv6']) then
        event.set("[meta][source][ip]", address['ipv6'])
        event.set("[meta][source][hostname]", address['hostname_v6'])
        event.set("[meta][ip_version]", 6)
    elsif ipversion == 4 or (!ipversion and address['ipv4']) then
        event.set("[meta][source][ip]", address['ipv4'])
        event.set("[meta][source][hostname]", address['hostname_v4'])
        event.set("[meta][ip_version]", 4)
    end

    #Make sure we always have a hostname - fallback to IP if not set
    if event.get("[meta][source][ip]") and not event.get("[meta][source][hostname]") then
        event.set("[meta][source][hostname]", event.get("[meta][source][ip]"))
    end
end

def filter(event)
    source = parse_endpoint(event.get("[test][spec][source]"))
    dest = parse_endpoint(event.get("[test][spec][dest]"))
    observer = event.get("[@metadata][ps_observer]")
    if not observer then
        observer = parse_endpoint(event.get("[pscheduler][task_href]"))
    end
    
    ipversion = event.get("[test][spec][ip-version]")

    #handle observer
    handle_observer(event, observer, ipversion)
    
    #handle source and dest
    if source and dest then
        handle_pair(event, source, dest, ipversion)
    elsif dest then
        #if no source, assume it's observer
        handle_pair(event, observer, dest, ipversion)
    elsif source then
        handle_source(event, source, ipversion)
    end
    
    return [event]
end
