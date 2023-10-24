require '/usr/lib/perfsonar/logstash/ruby/lib/ratecache.rb'

# def register(params)
#     #Require one of these - preference given to values if given
#     @values = params["values"]
# end

def _parse_labels(label_str)
    label_obj = {}
    if not label_str.nil? then
        label_str.split(",").each do |label_pair|
            label_pair_arr = label_pair.split("=", 2)
            next if label_pair_arr.length() != 2
            label_obj[label_pair_arr[0]] = label_pair_arr[1].delete_prefix('"').delete_suffix('"')
        end
    end
    label_key = label_obj.sort.to_s
    return label_key,label_obj
end

def _filter(event)
    prom_data = event.get("[message]")
    if prom_data.nil? then
        return []
    end

    ####
    # The following will need to be configured externally
    meta_metrics = { 
        "node_uname_info" => "uname",
        "node_dmi_info "=> "dmi",
        "node_os_info" => "os"
    }
    skip_list = [ "^node_scrape_*", "^go_*" ]
    ####

    formatted_records = {}
    formatted_metadata = {}
    data_type_map = {}
    meta_id = event.get("[meta][id]")
    record_type = event.get("[type]")
    rate_key_prefix = "#{meta_id}::#{record_type}"
    curr_time = event.get("@timestamp").to_i
    prom_data.each_line do |prom_line|
        if type_matches = prom_line.match(/^\#\s*TYPE\s+([a-zA-Z_:][a-zA-Z0-9_:]*)\s+(\w+)\s*$/) then
            #we don't actually use this, but seems useful when support for histograms gets added
            data_type_map[type_matches[1]] = type_matches[2]
        elsif type_matches = prom_line.start_with?("#") then
            next
        elsif metric_matches = prom_line.match(/^([a-zA-Z_:][a-zA-Z0-9_:]*)({(([a-zA-Z_][a-zA-Z0-9_]*=.*),?)*})?\s+(.+)$/) then
            metric_name = metric_matches[1]
            skip_metric = false
            skip_list.each do |sl|
                if metric_name.match(Regexp.new(sl)) then
                    skip_metric = true
                    break
                end
            end
            next if skip_metric
            metric_labels = metric_matches[3]
            metric_value = { "val" => metric_matches[5].to_f }
            label_key, label_obj = _parse_labels(metric_labels)

            #Calculate the rate - currently bucket size not normalized
            rate_key = "#{rate_key_prefix}::#{metric_name}::#{label_key}"
            prev_rate = RateCache.get(rate_key)
            if prev_rate && prev_rate.key?("ts") && prev_rate.key?("v") then
                time_range = curr_time - prev_rate["ts"]
                metric_value["delta"] = metric_value["val"] - prev_rate["v"]
                metric_value["rate"] = metric_value["delta"]/time_range if time_range > 0
            end
            RateCache.put(rate_key, {"ts" => curr_time, "v" => metric_value["val"]})
            #Check if we want to use this as metadata or just normal metrics
            if meta_metrics.has_key?(metric_name) then
                formatted_metadata[meta_metrics[metric_name]] = label_obj
            else
                if not formatted_records.has_key?(label_key) then
                    formatted_records[label_key] = {
                        "meta" => { "id" => meta_id, "labels" => label_obj },
                        "values" => {}
                    }
                end
                formatted_records[label_key]["values"][metric_name] = metric_value
            end
        end
    end

    #Add metadata to records and format as logstash events
    event.set("[message]", nil)
    events = []
    formatted_records.each do |fr_k, fr_v|
        e = event.clone()

        formatted_metadata.each do |md_k, md_v|
            fr_v["meta"][md_k] = md_v
        end
        e.set("meta", fr_v["meta"])
        e.set("values", fr_v["values"] )
        events.append(e)
    end

    return events
end

##
# Handles exception in call to main _filter function.
# May want to get rid of this if causes performance issues,
# but provides catch-all so exception does not kill logstash
# and provides more helpful output when exceptions do occur.
def filter(event)
    #catch exception
    begin
        result = _filter(event)
        return result
    rescue => exception
        logger.error("Caught ruby exception in prometheus_parse.rb #{exception.message}")
        event.cancel()  
    end

    return [event]
end

