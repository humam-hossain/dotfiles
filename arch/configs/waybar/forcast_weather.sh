#!/usr/bin/env bash
# Function to get temperature display and color
# Function to get weather icon, color, and size based on weather code and day/night

get_is_day() {
    local datetime="$1"
    local sunset="$2"
    local sunrise="$3"

    # Ensure all parameters are in ISO8601 format: YYYY-MM-DDTHH:MM
    # Convert to seconds since epoch for comparison
    local curr_sec=$(date -d "${datetime}" +%s)
    local sunrise_sec=$(date -d "${sunrise}" +%s)
    local sunset_sec=$(date -d "${sunset}" +%s)

    if (( curr_sec >= sunrise_sec && curr_sec < sunset_sec )); then
        echo 1
    else
        echo 0
    fi
}

get_weather_code_text() {
    local weather_code="$1"
    local is_day="$2"
    local weather_icon weather_color weather_size

    if [[ "$is_day" == 1 ]]; then
        case "$weather_code" in
            2|3)
                weather_icon="⛅"
                weather_color="white"
                weather_size="11000"
                ;;
            45|48)
                weather_icon="󰖑"
                weather_color="white"
                weather_size="12000"
                ;;
            51|53|55|56|57|61|63|65|66|67)
                weather_icon=""
                weather_color="white"
                weather_size="12000"
                ;;
            71|73|75|77)
                weather_icon="❄️"
                weather_color="white"
                weather_size="11000"
                ;;
            80|81|82|85|86)
                weather_icon="🌧️"
                weather_color="white"
                weather_size="11000"
                ;;
            95|96|99)
                weather_icon="⛈️"
                weather_color="white"
                weather_size="11000"
                ;;
            *)
                weather_icon="☀️"
                weather_color="yellow"
                weather_size="11000"
                ;;
        esac
    else
        case "$weather_code" in
            2|3)
                weather_icon="☁️"
                weather_color="white"
                weather_size="11000"
                ;;
            45|48)
                weather_icon="󰖑"
                weather_color="white"
                weather_size="12000"
                ;;
            51|53|55|56|57|61|63|65|66|67)
                weather_icon=""
                weather_color="white"
                weather_size="12000"
                ;;
            71|73|75|77)
                weather_icon="❄️"
                weather_color="white"
                weather_size="11000"
                ;;
            80|81|82|85|86)
                weather_icon="🌧️"
                weather_color="white"
                weather_size="11000"
                ;;
            95|96|99)
                weather_icon="⛈️"
                weather_color="white"
                weather_size="11000"
                ;;
            *)
                weather_icon="󰖔"
                weather_color="white"
                weather_size="12000"
                ;;
        esac
    fi

    echo "<span color='${weather_color}' size='${weather_size}'>${weather_icon}</span>"
}

get_weather_text() {
    local weather_code="$1"
    local weather_text
    case "$weather_code" in
        0)  weather_text="Clear sky" ;;
        1)  weather_text="Mainly clear" ;;
        2)  weather_text="Partly cloudy" ;;
        3)  weather_text="Overcast" ;;
        45) weather_text="Fog" ;;
        48) weather_text="Depositing rime fog" ;;
        51) weather_text="Drizzle(Light)" ;;
        53) weather_text="Drizzle(Moderate)" ;;
        55) weather_text="Drizzle(Dense)" ;;
        56) weather_text="Freezing Drizzle(Light)" ;;
        57) weather_text="Freezing Drizzle(Dense)" ;;
        61) weather_text="Rain(Slight)" ;;
        63) weather_text="Rain(Moderate)" ;;
        65) weather_text="Rain(Heavy)" ;;
        66) weather_text="Freezing Rain(Light)" ;;
        67) weather_text="Freezing Rain(Heavy)" ;;
        71) weather_text="Snow fall(Slight)" ;;
        73) weather_text="Snow fall(Moderate)" ;;
        75) weather_text="Snow fall(Heavy)" ;;
        77) weather_text="Snow grains" ;;
        80) weather_text="Rain showers(Slight)" ;;
        81) weather_text="Rain showers(Moderate)" ;;
        82) weather_text="Rain showers(Violent)" ;;
        85) weather_text="Snow showers(Slight)" ;;
        86) weather_text="Snow showers(Heavy)" ;;
        95) weather_text="Thunderstorm(Slight or moderate)" ;;
        96) weather_text="Thunderstorm with slight hail" ;;
        99) weather_text="Thunderstorm with heavy hail" ;;
        *)  weather_text="Unknown" ;;
    esac
    echo "$weather_text"
}

get_temp_display_and_color() {
    local temp_2m="$1"
    local apparent_temp="$2"
    local curr_temp_2m="$3"
    local curr_apparent_temp="$4"

    local temp_display temp_color diff_temp curr_diff_temp_2m curr_diff_apparent_temp

    diff_temp=$(echo "$apparent_temp - $temp_2m" | bc)
    curr_diff_temp_2m=$(echo "$temp_2m - $curr_temp_2m" | bc)
    curr_diff_apparent_temp=$(echo "$apparent_temp - $curr_apparent_temp" | bc)

    temp_display="<span size='11000'>🌡️</span>"
    if (( $(echo "$curr_diff_temp_2m > 0" | bc -l) )); then
        temp_display+="<span color='red' size='12000'>󰁞</span>"
    elif (( $(echo "$curr_diff_temp_2m < 0" | bc -l) )); then
        temp_display+="<span color='green' size='12000'>󰁆</span>"
    fi
    temp_display+="${temp_2m}°C"

    # Format diff_temp to always show sign and one decimal
    formatted_diff=$(printf "%.1f" "$diff_temp")
    if (( $(echo "$diff_temp > 0" | bc -l) )); then
        temp_display+="[+${formatted_diff}"
    elif (( $(echo "$diff_temp < 0" | bc -l) )); then
        temp_display+="[${formatted_diff}"
    fi

    if (( $(echo "$curr_diff_apparent_temp > 0" | bc -l) )); then
        temp_display+="<span color='red' size='12000'>󰁞</span>"
    elif (( $(echo "$curr_diff_apparent_temp < 0" | bc -l) )); then
        temp_display+="<span color='green' size='12000'>󰁆</span>"
    fi
    temp_display+="]"

    if (( $(echo "$temp_2m < 15" | bc -l) )); then
        temp_color="#3498db"  # Blue
    elif (( $(echo "$temp_2m < 20" | bc -l) )); then
        temp_color="#5dade2"  # Light blue
    elif (( $(echo "$temp_2m < 30" | bc -l) )); then
        temp_color="#58d68d"  # Green
    else
        temp_color="#ec7063"  # Red
    fi

    echo "<span color='${temp_color}'>${temp_display}</span>"
}

get_humidity_display() {
    local next_humidity="$1"
    local curr_humidity="$2"
    local diff_humidity display color

    diff_humidity=$(echo "$next_humidity - $curr_humidity" | bc)
    display="<span size='11000'>💧</span>"

    if (( $(echo "$diff_humidity > 0" | bc -l) )); then
        display+="<span color='red' size='12000'>󰁞</span>"
    elif (( $(echo "$diff_humidity < 0" | bc -l) )); then
        display+="<span color='green' size='12000'>󰁆</span>"
    fi
    display+="${next_humidity}%"

    echo "<span color='#3498db'>${display}</span>"
}

get_pressure_display() {
    local next_pressure="$1"
    local curr_pressure="$2"
    local diff_pressure display

    diff_pressure=$(echo "$next_pressure - $curr_pressure" | bc)
    display="<span size='11000'>󰡴</span> "

    if (( $(echo "$diff_pressure > 0" | bc -l) )); then
        display+="<span color='red' size='12000'>󰁞</span>"
    elif (( $(echo "$diff_pressure < 0" | bc -l) )); then
        display+="<span color='green' size='12000'>󰁆</span>"
    fi
    display+="${next_pressure}atm"

    echo "<span color='#f7dc6f'>${display}</span>"
}

get_precipitation_display() {
    local next_precip="$1"
    local next_precip_prob="$2"
    local curr_precip="$3"
    local diff_precip display color

    diff_precip=$(echo "$next_precip - $curr_precip" | bc)
    display="<span size='11000'>☔</span>"

    if (( $(echo "$diff_precip > 0" | bc -l) )); then
        display+="<span color='red' size='12000'>󰁞</span>"
    elif (( $(echo "$diff_precip < 0" | bc -l) )); then
        display+="<span color='green' size='12000'>󰁆</span>"
    fi

    display+=$(printf "%.2f" "$next_precip")"mm"
    display+="<span size='10000'>[${next_precip_prob}%]</span>"

    color="#5dade2"
    echo "<span color='${color}'>${display}</span>"
}

get_visibility_display() {
    local next_visibility="$1"
    local display color

    icon="󰈈"
    if (( $(echo "$next_visibility < 2" | bc -l) )); then
        icon="󰈉"
        color="#e74c3c"  # Red for poor visibility
    elif (( $(echo "$next_visibility < 10" | bc -l) )); then
        color="#f1c40f"  # Yellow for moderate visibility
    elif (( $(echo "$next_visibility < 30" | bc -l) )); then
        color="#2ecc71"  # Green for good visibility
    else
        color="blue"
    fi

    display="<span size='12000'>${icon}</span> "
    display+="${next_visibility}km"

    echo "<span color='${color}'>${display}</span>"
}

get_tooltip(){
    local response="$1"
    local sunrise="$2"
    local sunset="$3"
    local curr_temp="$4"
    local curr_apparent_temp="$5"
    local curr_humidity="$6"
    local curr_precipitation="$7"
    local curr_pressure="$8"
    local curr_datetime_f="$9"
    local curr_weather_code_text="${10}"
    local curr_weather_text="${11}"
    
    # Get array lengths
    local hourly_count=$(jq -r '.hourly.time | length' <<< "$response")
    
    # Start building tooltip
    local tooltip="<big><b>🌤️ Weather Forecast - 24 Hours</b></big>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Updated: ${curr_datetime_f}

<b>Current Weather:</b>
${curr_weather_code_text} Weather: ${curr_weather_text}
🌡️ Temperature: ${curr_temp}°C (feels like ${curr_apparent_temp}°C)
💧 Humidity: ${curr_humidity}%
☔ Precipitation: ${curr_precipitation}mm
󰡴 Pressure: ${curr_pressure}atm

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


<b>Hourly Forecast:</b>
<tt>"
    
    # Loop through each hour (limit to 24 hours to keep tooltip manageable)
    local max_hours=$((hourly_count < 24 ? hourly_count : 24))
    
    for ((i = 0; i < max_hours; i++)); do
        # Extract data for this hour
        local hour_datetime=$(jq -r --argjson idx "$i" '.hourly.time[$idx]' <<< "$response")
        local hour_time=$(date -d "${hour_datetime}" +'%-I:%M%p')
        local hour_weather_code=$(jq -r --argjson idx "$i" '.hourly.weather_code[$idx]' <<< "$response")
        local hour_temp=$(jq -r --argjson idx "$i" '.hourly.temperature_2m[$idx]' <<< "$response")
        local hour_apparent_temp=$(jq -r --argjson idx "$i" '.hourly.apparent_temperature[$idx]' <<< "$response")
        local hour_humidity=$(jq -r --argjson idx "$i" '.hourly.relative_humidity_2m[$idx]' <<< "$response")
        local hour_pressure=$(jq -r --argjson idx "$i" '.hourly.surface_pressure[$idx]' <<< "$response")
        local hour_pressure_atm=$(echo "scale=4; $hour_pressure * 0.0009869233" | bc | awk '{printf "%.2f", $0}')
        local hour_precipitation=$(jq -r --argjson idx "$i" '.hourly.precipitation[$idx]' <<< "$response")
        local hour_precipitation_prob=$(jq -r --argjson idx "$i" '.hourly.precipitation_probability[$idx]' <<< "$response")
        local hour_visibility=$(jq -r --argjson idx "$i" '.hourly.visibility[$idx]' <<< "$response")
        local hour_visibility_km=$(echo "scale=2; $hour_visibility / 1000" | bc | awk '{printf "%.1f", $0}')
        local hour_is_day=$(get_is_day "$hour_datetime" "$sunset" "$sunrise")

        # Get previous hour's values (or current if i==0)
        if (( i == 0 )); then
            prev_temp="$hour_temp"
            prev_apparent_temp="$hour_apparent_temp"
            prev_humidity="$hour_humidity"
            prev_pressure="$hour_pressure"
            prev_precipitation="$hour_precipitation"
        else
            prev_temp=$(jq -r --argjson idx "$((i-1))" '.hourly.temperature_2m[$idx]' <<< "$response")
            prev_apparent_temp=$(jq -r --argjson idx "$((i-1))" '.hourly.apparent_temperature[$idx]' <<< "$response")
            prev_humidity=$(jq -r --argjson idx "$((i-1))" '.hourly.relative_humidity_2m[$idx]' <<< "$response")
            prev_pressure=$(jq -r --argjson idx "$((i-1))" '.hourly.surface_pressure[$idx]' <<< "$response")
            prev_pressure=$(echo "scale=4; $prev_pressure * 0.0009869233" | bc | awk '{printf "%.2f", $0}')
            prev_precipitation=$(jq -r --argjson idx "$((i-1))" '.hourly.precipitation[$idx]' <<< "$response")
        fi
        
        # Generate display text for this hour
        local hour_weather_code_text=$(get_weather_code_text "$hour_weather_code" "$hour_is_day")
        local hour_temp_text=$(get_temp_display_and_color "$hour_temp" "$hour_apparent_temp" "$prev_temp" "$prev_apparent_temp")
        local hour_humidity_text=$(get_humidity_display "$hour_humidity" "$prev_humidity")
        local hour_pressure_text=$(get_pressure_display "$hour_pressure_atm" "$prev_pressure")
        local hour_precipitation_text=$(get_precipitation_display "$hour_precipitation" "$hour_precipitation_prob" "$prev_precipitation")
        local hour_visibility_text=$(get_visibility_display "$hour_visibility_km")
        local hour_weather_text=$(get_weather_text "$hour_weather_code")
        
        # Add this hour's data to tooltip
        # Add separator if within 60 minutes after sunrise or sunset for better readability
        local sunrise_diff=$(( $(date -d "$hour_datetime" +%s) - $(date -d "$sunrise" +%s) ))
        local sunset_diff=$(( $(date -d "$hour_datetime" +%s) - $(date -d "$sunset" +%s) ))
        if (( sunrise_diff > 0 && sunrise_diff < 3600 )); then
            tooltip+="
        ──────────────────────────────── Sunrise: $(date -d "$sunrise" +'%-I:%M%p') ────────────────────────────────"
        elif (( sunset_diff > 0 && sunset_diff < 3600 )); then
            tooltip+="
        ──────────────────────────────── Sunset: $(date -d "$sunset" +'%-I:%M%p') ────────────────────────────────"
        fi

        tooltip+="
        ${hour_time}:  ${hour_weather_code_text} ${hour_weather_text} ${hour_temp_text} ${hour_humidity_text} ${hour_pressure_text} ${hour_precipitation_text} ${hour_visibility_text}"
        
    done
    
    tooltip+="
</tt>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"

    echo "$tooltip"
}

LATITUDE=23.763953
LONGITUDE=90.424419

# Dependencies check
for cmd in curl jq bc; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "{\"text\":\" Missing $cmd\",\"tooltip\":\"error\"}"
        exit 0
    fi
done

# Fetch and parse weather data using 'current' fields for temperature and humidity
if [[ -f "$HOME/.config/waybar/api_response.json" ]]; then
    response=$(cat "$HOME/.config/waybar/api_response.json")
else
    response=$(curl -s \
        "https://api.open-meteo.com/v1/forecast?latitude=${LATITUDE}&longitude=${LONGITUDE}&daily=sunrise,sunset&hourly=weather_code,temperature_2m,apparent_temperature,relative_humidity_2m,precipitation,precipitation_probability,visibility,surface_pressure&current=weather_code,temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,surface_pressure&timezone=auto&forecast_days=1")
    
    echo "[INFO] calling open-meteo api for first time" >&2
    echo "$response" > "$HOME/.config/waybar/api_response.json"
fi

if [[ -z "$response" ]]; then
    echo "{\"text\":\" No data\",\"tooltip\":\"error\"}"
    exit 0
fi

real_datetime=$(date +'%Y-%m-%dT%H:%M')
curr_datetime=$(jq -r '.current.time' <<< "$response")

# Check if data is older than 900 seconds (15 minutes), if so, refresh
real_sec=$(date -d "$real_datetime" +%s)
curr_sec=$(date -d "$curr_datetime" +%s)
if (( real_sec - curr_sec > 900 )); then
    response=$(curl -s \
        "https://api.open-meteo.com/v1/forecast?latitude=23.753&longitude=90.4379&daily=sunrise,sunset&hourly=weather_code,temperature_2m,apparent_temperature,relative_humidity_2m,precipitation,precipitation_probability,visibility,surface_pressure&current=is_day,weather_code,apparent_temperature,temperature_2m,relative_humidity_2m,surface_pressure,precipitation&timezone=auto&forecast_days=1")
    echo "[INFO] refreshing response" >&2
    echo "$response" > "$HOME/.config/waybar/api_response.json"
fi

real_datetime=$(date +'%Y-%m-%dT%H:%M')
real_datetime_f=$(date +'%Y-%m-%d %-I:%M%p')

sunrise=$(jq -r '.daily.sunrise[0]' <<< "$response")
sunset=$(jq -r '.daily.sunset[0]' <<< "$response")
sunrise_time=$(date -d "$sunrise" +'%-I:%M%p')
sunset_time=$(date -d "$sunset" +'%-I:%M%p')

# current
curr_datetime=$(jq -r '.current.time' <<< "$response")
curr_datetime_f=$(date -d "$curr_datetime" +'%Y-%m-%d %-I:%M%p')
curr_is_day=$(jq -r '.current.is_day' <<< "$response")
curr_weather_code=$(jq -r '.current.weather_code' <<< "$response")
curr_weather_code_text=$(get_weather_code_text "$curr_weather_code" "$curr_is_day")
curr_weather_text=$(get_weather_text "$curr_weather_code")
curr_temp=$(jq -r '.current.temperature_2m' <<< "$response")
curr_apparent_temp=$(jq -r '.current.apparent_temperature' <<< "$response")
curr_humidity=$(jq -r '.current.relative_humidity_2m' <<< "$response")
curr_precipitation=$(jq -r '.current.precipitation' <<< "$response")
curr_pressure=$(jq -r '.current.surface_pressure' <<< "$response")
curr_pressure=$(echo "scale=4; $curr_pressure * 0.0009869233" | bc | awk '{printf "%.2f", $0}')

# Find the next index in hourly_time based on current time
next_hour_index=$(jq -r --arg now "$real_datetime" '
    .hourly.time
    | to_entries
    | map(select(.value >= $now))
    | first
    | .key // empty
' <<< "$response")

next_hour_datetime=$(jq -r --argjson idx "$next_hour_index" '.hourly.time[$idx]' <<< "$response")
next_hour_time=$(date -d "${next_hour_datetime}" +'%-I:%M%p')
next_hour_weather_code=$(jq -r --argjson idx "$next_hour_index" '.hourly.weather_code[$idx]' <<< "$response")
next_hour_temp=$(jq -r --argjson idx "$next_hour_index" '.hourly.temperature_2m[$idx]' <<< "$response")
next_hour_apparent_temp=$(jq -r --argjson idx "$next_hour_index" '.hourly.apparent_temperature[$idx]' <<< "$response")
next_hour_humidity=$(jq -r --argjson idx "$next_hour_index" '.hourly.relative_humidity_2m[$idx]' <<< "$response")
next_hour_pressure=$(jq -r --argjson idx "$next_hour_index" '.hourly.surface_pressure[$idx]' <<< "$response")
next_hour_pressure=$(echo "scale=4; $next_hour_pressure * 0.0009869233" | bc | awk '{printf "%.2f", $0}')
next_hour_precipitation=$(jq -r --argjson idx "$next_hour_index" '.hourly.precipitation[$idx]' <<< "$response")
next_hour_precipitation_prob=$(jq -r --argjson idx "$next_hour_index" '.hourly.precipitation_probability[$idx]' <<< "$response")
next_hour_visibility=$(jq -r --argjson idx "$next_hour_index" '.hourly.visibility[$idx]' <<< "$response")
next_hour_visibility=$(echo "scale=2; $next_hour_visibility / 1000" | bc | awk '{printf "%.3f", $0}')
next_hour_is_day=$(get_is_day "$next_hour_datetime" "$sunset" "$sunrise")

# text
sunrise_text="<span color='#ffa700'><span size='12000'></span>  ${sunrise_time}</span>"
sunset_text="<span color='#5dade2'><span size='12000'></span>  ${sunset_time}</span>"

# Use get_temp_display_and_color for next hour temperature
forcast_weather_text=$(get_weather_code_text "$next_hour_weather_code" "$next_hour_is_day")
forcast_temp_text=$(get_temp_display_and_color "$next_hour_temp" "$next_hour_apparent_temp" "$curr_temp" "$curr_apparent_temp")
forcast_humidity_text=$(get_humidity_display "$next_hour_humidity" "$curr_humidity")
forcast_pressure_text=$(get_pressure_display "$next_hour_pressure" "$curr_pressure")
forcast_precipitation_text=$(get_precipitation_display "$next_hour_precipitation" "$next_hour_precipitation_prob" "$curr_precipitation")
forcast_visibility_text=$(get_visibility_display "$next_hour_visibility")

full_text="${sunrise_text} ${sunset_text} | ${next_hour_time}: ${forcast_weather_text} ${forcast_temp_text} ${forcast_humidity_text} $forcast_pressure_text $forcast_precipitation_text $forcast_visibility_text"

# Create detailed tooltip with proper escaping
tooltip_text=$(get_tooltip "$response" "$sunrise" "$sunset" "$curr_temp" "$curr_apparent_temp" "$curr_humidity" "$curr_precipitation" "$curr_pressure" "$curr_datetime_f" "$curr_weather_code_text" "$curr_weather_text")

output=$(jq -nc --arg text "$full_text" --arg tooltip "$tooltip_text" '{text: $text, tooltip: $tooltip}')

echo -n "$output"