#!/usr/bin/env bash
# forecast_weather.sh - Fetch weather forecast and output JSON for Waybar custom module

# Configuration
LATITUDE=23.763953
LONGITUDE=90.424419
CACHE_FILE="$HOME/.config/waybar/api_response.json"
CACHE_DURATION=900  # 15 minutes in seconds

# ===== UTILITY FUNCTIONS =====

# Determine if it's day or night based on current time and sunrise/sunset
get_is_day() {
    local datetime="$1"
    local sunset="$2"
    local sunrise="$3"

    local curr_sec=$(date -d "${datetime}" +%s)
    local sunrise_sec=$(date -d "${sunrise}" +%s)
    local sunset_sec=$(date -d "${sunset}" +%s)

    if (( curr_sec >= sunrise_sec && curr_sec < sunset_sec )); then
        echo 1
    else
        echo 0
    fi
}

# ===== WEATHER DATA FUNCTIONS =====

# Get weather description text from code
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

# Get weather icon with formatting based on code and day/night
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

# ===== DISPLAY FUNCTIONS =====

# Get temperature display with trend indicators
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
    
    # Temperature trend indicator
    if (( $(echo "$curr_diff_temp_2m > 0" | bc) )); then
        temp_display+="<span color='red' size='12000'>󰁞</span>"
    elif (( $(echo "$curr_diff_temp_2m < 0" | bc) )); then
        temp_display+="<span color='green' size='12000'>󰁆</span>"
    fi
    
    temp_display+="${temp_2m}°C"

    # Add feels-like temperature with trend
    formatted_diff=$(printf "%.1f" "$diff_temp")
    if (( $(echo "$diff_temp > 0" | bc) )); then
        temp_display+="[+${formatted_diff}"
    elif (( $(echo "$diff_temp < 0" | bc) )); then
        temp_display+="[${formatted_diff}"
    fi

    # Apparent temperature trend indicator
    if (( $(echo "$curr_diff_apparent_temp > 0" | bc) )); then
        temp_display+="<span color='red' size='12000'>󰁞</span>"
    elif (( $(echo "$curr_diff_apparent_temp < 0" | bc) )); then
        temp_display+="<span color='green' size='12000'>󰁆</span>"
    fi
    temp_display+="]"

    # Temperature color coding
    if (( $(echo "$temp_2m < 15" | bc) )); then
        temp_color="#3498db"  # Blue
    elif (( $(echo "$temp_2m < 20" | bc) )); then
        temp_color="#5dade2"  # Light blue
    elif (( $(echo "$temp_2m < 30" | bc) )); then
        temp_color="#58d68d"  # Green
    else
        temp_color="#ec7063"  # Red
    fi

    echo "<span color='${temp_color}'>${temp_display}</span>"
}

# Get humidity display with trend indicators
get_humidity_display() {
    local next_humidity="$1"
    local curr_humidity="$2"
    local diff_humidity display

    diff_humidity=$(echo "$next_humidity - $curr_humidity" | bc)
    display="<span size='11000'>💧</span>"

    if (( $(echo "$diff_humidity > 0" | bc) )); then
        display+="<span color='red' size='12000'>󰁞</span>"
    elif (( $(echo "$diff_humidity < 0" | bc) )); then
        display+="<span color='green' size='12000'>󰁆</span>"
    fi
    display+="${next_humidity}%"

    echo "<span color='#3498db'>${display}</span>"
}

# Get pressure display with trend indicators
get_pressure_display() {
    local next_pressure="$1"
    local curr_pressure="$2"
    local diff_pressure display

    diff_pressure=$(echo "$next_pressure - $curr_pressure" | bc)
    display="<span size='11000'>󰡴</span> "

    if (( $(echo "$diff_pressure > 0" | bc) )); then
        display+="<span color='red' size='12000'>󰁞</span>"
    elif (( $(echo "$diff_pressure < 0" | bc) )); then
        display+="<span color='green' size='12000'>󰁆</span>"
    fi
    display+="${next_pressure}atm"

    echo "<span color='#f7dc6f'>${display}</span>"
}

# Get precipitation display with trend indicators and probability
get_precipitation_display() {
    local next_precip="$1"
    local next_precip_prob="$2"
    local curr_precip="$3"
    local diff_precip display color

    diff_precip=$(echo "$next_precip - $curr_precip" | bc)
    display="<span size='11000'>☔</span>"

    if (( $(echo "$diff_precip > 0" | bc) )); then
        display+="<span color='red' size='12000'>󰁞</span>"
    elif (( $(echo "$diff_precip < 0" | bc) )); then
        display+="<span color='green' size='12000'>󰁆</span>"
    fi

    display+=$(printf "%.2f" "$next_precip")"mm"
    display+="<span size='10000'>[${next_precip_prob}%]</span>"

    color="#5dade2"
    echo "<span color='${color}'>${display}</span>"
}

# Get visibility display with color coding
get_visibility_display() {
    local next_visibility="$1"
    local display color icon

    icon="󰈈"
    if (( $(echo "$next_visibility < 2" | bc) )); then
        icon="󰈉"
        color="#e74c3c"  # Red for poor visibility
    elif (( $(echo "$next_visibility < 10" | bc) )); then
        color="#f1c40f"  # Yellow for moderate visibility
    elif (( $(echo "$next_visibility < 30" | bc) )); then
        color="#2ecc71"  # Green for good visibility
    else
        color="blue"
    fi

    display="<span size='12000'>${icon}</span> "
    display+="${next_visibility}km"

    echo "<span color='${color}'>${display}</span>"
}

# Get sunrise/sunset display
get_sun_times_display() {
    local sunrise_time="$1"
    local sunset_time="$2"
    
    local sunrise_text="<span color='#ffa700'><span size='12000'></span>  ${sunrise_time}</span>"
    local sunset_text="<span color='#5dade2'><span size='12000'></span>  ${sunset_time}</span>"
    
    echo "${sunrise_text} ${sunset_text}"
}

# ===== TOOLTIP FUNCTIONS =====

# Create comprehensive tooltip with hourly forecast
get_tooltip() {
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
    
    local hourly_count=$(jq -r '.hourly.time | length' <<< "$response")
    local max_hours=$((hourly_count < 24 ? hourly_count : 24))
    
    # Tooltip header
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
    
    # Generate hourly forecast entries
    for ((i = 0; i < max_hours; i++)); do
        tooltip+=$(generate_hourly_entry "$response" "$i" "$sunrise" "$sunset")
    done
    
    tooltip+="
</tt>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"

    echo "$tooltip"
}

# Generate a single hourly forecast entry
generate_hourly_entry() {
    local response="$1"
    local i="$2"
    local sunrise="$3"
    local sunset="$4"
    
    # Extract hourly data
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

    # Get previous hour's values for comparison
    local prev_temp prev_apparent_temp prev_humidity prev_pressure prev_precipitation
    if (( i == 0 )); then
        prev_temp="$hour_temp"
        prev_apparent_temp="$hour_apparent_temp"
        prev_humidity="$hour_humidity"
        prev_pressure="$hour_pressure_atm"
        prev_precipitation="$hour_precipitation"
    else
        prev_temp=$(jq -r --argjson idx "$((i-1))" '.hourly.temperature_2m[$idx]' <<< "$response")
        prev_apparent_temp=$(jq -r --argjson idx "$((i-1))" '.hourly.apparent_temperature[$idx]' <<< "$response")
        prev_humidity=$(jq -r --argjson idx "$((i-1))" '.hourly.relative_humidity_2m[$idx]' <<< "$response")
        local prev_pressure_raw=$(jq -r --argjson idx "$((i-1))" '.hourly.surface_pressure[$idx]' <<< "$response")
        prev_pressure=$(echo "scale=4; $prev_pressure_raw * 0.0009869233" | bc | awk '{printf "%.2f", $0}')
        prev_precipitation=$(jq -r --argjson idx "$((i-1))" '.hourly.precipitation[$idx]' <<< "$response")
    fi
    
    # Generate display components
    local hour_weather_code_text=$(get_weather_code_text "$hour_weather_code" "$hour_is_day")
    local hour_temp_text=$(get_temp_display_and_color "$hour_temp" "$hour_apparent_temp" "$prev_temp" "$prev_apparent_temp")
    local hour_humidity_text=$(get_humidity_display "$hour_humidity" "$prev_humidity")
    local hour_pressure_text=$(get_pressure_display "$hour_pressure_atm" "$prev_pressure")
    local hour_precipitation_text=$(get_precipitation_display "$hour_precipitation" "$hour_precipitation_prob" "$prev_precipitation")
    local hour_visibility_text=$(get_visibility_display "$hour_visibility_km")
    local hour_weather_text=$(get_weather_text "$hour_weather_code")
    
    local entry=""
    
    # Add sunrise/sunset separators
    local sunrise_diff=$(( $(date -d "$hour_datetime" +%s) - $(date -d "$sunrise" +%s) ))
    local sunset_diff=$(( $(date -d "$hour_datetime" +%s) - $(date -d "$sunset" +%s) ))
    if (( sunrise_diff > 0 && sunrise_diff < 3600 )); then
        entry+="
        ──────────────────────────────── Sunrise: $(date -d "$sunrise" +'%-I:%M%p') ────────────────────────────────"
    elif (( sunset_diff > 0 && sunset_diff < 3600 )); then
        entry+="
        ──────────────────────────────── Sunset: $(date -d "$sunset" +'%-I:%M%p') ────────────────────────────────"
    fi

    entry+="
        ${hour_time}:  ${hour_weather_code_text} ${hour_weather_text} ${hour_temp_text} ${hour_humidity_text} ${hour_pressure_text} ${hour_precipitation_text} ${hour_visibility_text}"
    
    echo "$entry"
}

# ===== API AND CACHING FUNCTIONS =====

# Find next hour index in forecast data
find_next_hour_index() {
    local response="$1"
    local real_datetime=$(date +'%Y-%m-%dT%H:%M')
    
    jq -r --arg now "$real_datetime" '
        .hourly.time
        | to_entries
        | map(select(.value >= $now))
        | first
        | .key // empty
    ' <<< "$response"
}

# ===== DATA EXTRACTION FUNCTIONS =====

# Extract current weather data
extract_current_data() {
    local response="$1"
    
    # Check if response is valid JSON
    if ! echo "$response" | jq empty 2>/dev/null; then
        echo "Error: Invalid JSON response" >&2
        return 1
    fi
    
    # Extract values directly without associative array
    local datetime=$(echo "$response" | jq -r '.current.time // "N/A"')
    local is_day=$(echo "$response" | jq -r '.current.is_day // "N/A"')
    local weather_code=$(echo "$response" | jq -r '.current.weather_code // "N/A"')
    local temp=$(echo "$response" | jq -r '.current.temperature_2m // "N/A"')
    local apparent_temp=$(echo "$response" | jq -r '.current.apparent_temperature // "N/A"')
    local humidity=$(echo "$response" | jq -r '.current.relative_humidity_2m // "N/A"')
    local precipitation=$(echo "$response" | jq -r '.current.precipitation // "N/A"')
    local pressure=$(echo "$response" | jq -r '.current.surface_pressure // "N/A"')
    
    # Calculate atmospheric pressure (avoiding bc dependency)
    local pressure_atm="N/A"
    if [[ "$pressure" != "N/A" ]] && [[ "$pressure" =~ ^[0-9]+\.?[0-9]*$ ]]; then
        pressure_atm=$(awk "BEGIN {printf \"%.2f\", $pressure * 0.0009869233}")
    fi
    
    # Output as space-separated values
    echo "$datetime $is_day $weather_code $temp $apparent_temp $humidity $precipitation $pressure_atm"
}

# Extract forecast data for specific hour
extract_forecast_data() {
    local response="$1"
    local index="$2"
    
    local datetime=$(jq -r --argjson idx "$index" '.hourly.time[$idx]' <<< "$response")
    local time=$(date -d "${datetime}" +'%-I:%M%p')
    local weather_code=$(jq -r --argjson idx "$index" '.hourly.weather_code[$idx]' <<< "$response")
    local temp=$(jq -r --argjson idx "$index" '.hourly.temperature_2m[$idx]' <<< "$response")
    local apparent_temp=$(jq -r --argjson idx "$index" '.hourly.apparent_temperature[$idx]' <<< "$response")
    local humidity=$(jq -r --argjson idx "$index" '.hourly.relative_humidity_2m[$idx]' <<< "$response")
    local pressure=$(jq -r --argjson idx "$index" '.hourly.surface_pressure[$idx]' <<< "$response")
    local pressure_atm=$(echo "scale=4; $pressure * 0.0009869233" | bc | awk '{printf "%.2f", $0}')
    local precipitation=$(jq -r --argjson idx "$index" '.hourly.precipitation[$idx]' <<< "$response")
    local precipitation_prob=$(jq -r --argjson idx "$index" '.hourly.precipitation_probability[$idx]' <<< "$response")
    local visibility=$(jq -r --argjson idx "$index" '.hourly.visibility[$idx]' <<< "$response")
    local visibility_km=$(echo "scale=2; $visibility / 1000" | bc | awk '{printf "%.3f", $0}')
    
    echo "$datetime $time $weather_code $temp $apparent_temp $humidity $pressure_atm $precipitation $precipitation_prob $visibility_km"
}

# Fetch weather data with intelligent caching
fetch_weather_data() {
    local response
    
    # Check cache validity
    if [[ -f "$CACHE_FILE" ]]; then
        response=$(cat "$CACHE_FILE")
        local curr_datetime=$(jq -r '.current.time' <<< "$response")
        local real_datetime=$(date +'%Y-%m-%dT%H:%M')
        local real_sec=$(date -d "$real_datetime" +%s)
        local curr_sec=$(date -d "$curr_datetime" +%s)
        
        # Use cache if less than 15 minutes old
        if (( real_sec - curr_sec <= CACHE_DURATION )); then
            echo "$response"
            return
        fi
    fi

    # Fetch fresh data
    response=$(curl -s \
        "https://api.open-meteo.com/v1/forecast?latitude=${LATITUDE}&longitude=${LONGITUDE}&daily=sunrise,sunset&hourly=weather_code,temperature_2m,apparent_temperature,relative_humidity_2m,precipitation,precipitation_probability,visibility,surface_pressure&current=is_day,weather_code,apparent_temperature,temperature_2m,relative_humidity_2m,surface_pressure,precipitation&timezone=auto&temperature_unit=celsius&forecast_days=1")
    
    if [[ -n "$response" && "$response" != "null" ]]; then
        # Create cache directory and save response
        mkdir -p "$(dirname "$CACHE_FILE")"
        echo "$response" > "$CACHE_FILE"
        echo "[INFO] API data refreshed" >&2
    fi

    echo "$response"
}

# Check dependencies
check_dependencies() {
    for cmd in curl jq bc; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "{\"text\":\" Missing $cmd\",\"tooltip\":\"error\"}"
            exit 0
        fi
    done
}

# ===== MAIN EXECUTION =====

main() {
    # Check dependencies
    check_dependencies
    
    # Fetch weather data
    response=$(fetch_weather_data)
    
    if [[ -z "$response" || "$response" == "null" ]]; then
        echo "{\"text\":\" No data\",\"tooltip\":\"error\"}"
        exit 0
    fi

    # Extract sunrise/sunset data
    sunrise=$(jq -r '.daily.sunrise[0]' <<< "$response")
    sunset=$(jq -r '.daily.sunset[0]' <<< "$response")
    sunrise_time=$(date -d "$sunrise" +'%-I:%M%p')
    sunset_time=$(date -d "$sunset" +'%-I:%M%p')

    # Extract current weather data
    read -r curr_datetime curr_is_day curr_weather_code curr_temp curr_apparent_temp curr_humidity curr_precipitation curr_pressure <<< "$(extract_current_data "$response")"
    curr_datetime_f=$(date -d "$curr_datetime" +'%Y-%m-%d %-I:%M%p')

    # Get current weather display components
    curr_weather_code_text=$(get_weather_code_text "$curr_weather_code" "$curr_is_day")
    curr_weather_text=$(get_weather_text "$curr_weather_code")

    # Find next hour and extract forecast data
    next_hour_index=$(find_next_hour_index "$response")
    read -r next_hour_datetime next_hour_time next_hour_weather_code next_hour_temp next_hour_apparent_temp next_hour_humidity next_hour_pressure next_hour_precipitation next_hour_precipitation_prob next_hour_visibility <<< "$(extract_forecast_data "$response" "$next_hour_index")"

    # Determine if next hour is day or night
    next_hour_is_day=$(get_is_day "$next_hour_datetime" "$sunset" "$sunrise")

    # Generate display components for forecast
    sun_times_text=$(get_sun_times_display "$sunrise_time" "$sunset_time")
    forecast_weather_text=$(get_weather_code_text "$next_hour_weather_code" "$next_hour_is_day")
    forecast_temp_text=$(get_temp_display_and_color "$next_hour_temp" "$next_hour_apparent_temp" "$curr_temp" "$curr_apparent_temp")
    forecast_humidity_text=$(get_humidity_display "$next_hour_humidity" "$curr_humidity")
    forecast_pressure_text=$(get_pressure_display "$next_hour_pressure" "$curr_pressure")
    forecast_precipitation_text=$(get_precipitation_display "$next_hour_precipitation" "$next_hour_precipitation_prob" "$curr_precipitation")
    forecast_visibility_text=$(get_visibility_display "$next_hour_visibility")

    # Construct full display text
    full_text="${sun_times_text} | ${next_hour_time}: ${forecast_weather_text} ${forecast_temp_text} ${forecast_humidity_text} ${forecast_pressure_text} ${forecast_precipitation_text} ${forecast_visibility_text}"

    # Create comprehensive tooltip
    tooltip_text=$(get_tooltip "$response" "$sunrise" "$sunset" "$curr_temp" "$curr_apparent_temp" "$curr_humidity" "$curr_precipitation" "$curr_pressure" "$curr_datetime_f" "$curr_weather_code_text" "$curr_weather_text")

    # Generate and output final JSON
    output=$(jq -nc --arg text "$full_text" --arg tooltip "$tooltip_text" '{text: $text, tooltip: $tooltip}')
    echo -n "$output"
}

# Execute main function
main