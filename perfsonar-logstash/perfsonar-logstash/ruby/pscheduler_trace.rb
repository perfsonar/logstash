def filter(event)
    paths = event.get("[result][paths]")
    ip_version = event.get("[test][spec][ip-version]")
    if paths and paths.respond_to?('length') and paths.length() > 0 then
        #only look at first path for now, multipath is not this use case 
        hop_ips = []
        hop_asns = []
        hop_asos = []
        path_mtu  = nil
        success_count = 0
        error_count = 0
        paths[0].each do |hop|
            #IP
            if hop["ip"] then
                hop_ips.push(hop["ip"])
                success_count += 1
            else
                # Add zero (non-global) address to indicate missing info for hop
                if ip_version == 4
                  hop_ips.push("0.0.0.0")
                end  
                if ip_version == 6
                    hop_ips.push("::")
                end                  
                error_count += 1
                #next
            end
            
            #ASN
            if hop["as"] then
                if hop["as"]["number"] then
                    hop_asns.push(hop["as"]["number"])
                end
                
                if hop["as"]["owner"] then
                    hop_asos.push(hop["as"]["owner"])
                end
            else
              # Add zero number (non-valid) number to indicate missing info for hop
              hop_asns.push(0)
              # Add "not-available" to indicate missing info for hop
              hop_asos.push("n/a")
            end
            
            #Path MTU
            begin
                if hop["mtu"] and (!path_mtu or hop["mtu"] < path_mtu) then
                    path_mtu = hop["mtu"]
                end
            rescue
                #ignore integer errors and similar
            end
        end
        
        #update event
        event.set("[@metadata][result][hop][count]", success_count + error_count)
        event.set("[@metadata][result][hop][success_count]", success_count)
        event.set("[@metadata][result][hop][error_count]", error_count)
        event.set("[@metadata][result][hop][ip]", hop_ips)
        # Apply traditional * for missing hop
        event.set("[@metadata][result][hop][ip_str]", hop_ips.join(" ").gsub(/^0.0.0.0 /, "* ").gsub(/ 0.0.0.0 /, " * ").gsub(/ 0.0.0.0$/," *").gsub(/^:: /, "* ").gsub(/ :: /, " * ").gsub(/ ::$/," *"))
        event.set("[@metadata][result][hop][as_number]", hop_asns)
        # Apply traditional * for missing hop
        event.set("[@metadata][result][hop][as_number_str]", hop_asns.join(" ").gsub(/^0 /, "* ").gsub(/ 0 /, " * ").gsub(/ 0$/," *")) 
        event.set("[@metadata][result][hop][as_organization]", hop_asos)
        event.set("[@metadata][result][hop][as_organization_str]", hop_asos.join(" "))
        if path_mtu then
            event.set("[@metadata][result][mtu]", path_mtu)
        end
        event.set("[@metadata][result][json]", paths)
    end
    
    return [event]
end
