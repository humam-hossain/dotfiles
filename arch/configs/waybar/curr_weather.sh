#!/usr/bin/env bash
# weather.sh - Fetch current weather and output JSON for Waybar custom module

# Configuration: set your latitude and longitude here
LATITUDE=23.763953
LONGITUDE=90.424419
CACHE_FILE="$HOME/.config/waybar/api_response.json"
CACHE_DURATION=900  # 15 minutes in seconds

# Function to get weather text description
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

# Function to get weather icon based on weather code and day/night
get_weather_icon() {
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

# Function to get temperature display with color coding
get_temp_display() {
    local temp_2m="$1"
    local apparent_temp="$2"
    local temp_display temp_color diff_temp

    # Calculate difference between apparent and actual temperature
    diff_temp=$(echo "scale=1; $apparent_temp - $temp_2m" | bc -l)
    
    # Check if diff_temp is positive, negative, or zero
    if (( $(echo "$diff_temp > 0" | bc -l) )); then
        temp_display="$temp_2m°C[+$diff_temp]"
    elif (( $(echo "$diff_temp < 0" | bc -l) )); then
        temp_display="$temp_2m°C[$diff_temp]"
    else
        temp_display="$temp_2m°C"
    fi

    # Determine temperature color
    if (( $(echo "$temp_2m < 15" | bc -l) )); then
        temp_color="#3498db"  # Blue
    elif (( $(echo "$temp_2m < 20" | bc -l) )); then
        temp_color="#5dade2"  # Light blue
    elif (( $(echo "$temp_2m < 30" | bc -l) )); then
        temp_color="#58d68d"  # Green
    else
        temp_color="#ec7063"  # Red
    fi

    echo "<span color='${temp_color}'><span size='11000'>🌡️</span>${temp_display}</span>"
}

# Function to get humidity display
get_humidity_display() {
    local humidity="$1"
    echo "<span color='#3498db'>💧 ${humidity}%</span>"
}

# Function to get pressure display
get_pressure_display() {
    local surface_pressure="$1"
    local surface_pressure_atm=$(printf "%.2f" "$(echo "scale=4; $surface_pressure * 0.0009869233" | bc -l)")
    echo "<span color='#f7dc6f'><span size='11000'>󰡴</span> ${surface_pressure_atm}atm</span>"
}

# Function to get precipitation display
get_precipitation_display() {
    local precipitation="$1"
    echo "<span color='#5dade2'><span size='12000'>☔</span> ${precipitation}mm</span>"
}

# Get sunrise/sunset display
get_sun_times_display() {
    local sunrise_time="$1"
    local sunset_time="$2"
    
    local sunrise_text="<span color='#ffa700'><span size='12000'></span>  ${sunrise_time}</span>"
    local sunset_text="<span color='#5dade2'><span size='12000'></span>  ${sunset_time}</span>"
    
    echo "${sunrise_text} ${sunset_text}"
}

# Function to create detailed tooltip
create_tooltip() {
    local weather_icon="$1"
    local weather_text="$2"
    local temp_2m="$3"
    local apparent_temp="$4"
    local humidity="$5"
    local pressure_atm="$6"
    local precipitation="$7"
    local datetime_f="$8"

    local tooltip_text="<big>Current Weather</big>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
${weather_icon} Weather Code: $weather_text
🌡️ Temperature: ${temp_2m}°C (feels like ${apparent_temp}°C)
💧 Humidity: ${humidity}%
󰡴  Pressure: ${pressure_atm} atm
☔ Precipitation: ${precipitation}mm

Updated: ${datetime_f}
"
    echo "$tooltip_text"
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
# Main execution starts here

# Dependencies check
for cmd in curl jq bc; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "{\"text\":\" Missing $cmd\",\"class\":\"error\"}"
        exit 0
    fi
done

# Fetch weather data
response=$(fetch_weather_data)

if [[ -z "$response" || "$response" == "null" ]]; then
    echo "{\"text\":\" No data\",\"class\":\"error\"}"
    exit 0
fi

# Extract current weather data
datetime=$(jq -r '.current.time' <<< "$response")
datetime_f=$(date -d "$datetime" +'%Y-%m-%d %-I:%M%p')
is_day=$(jq -r '.current.is_day' <<< "$response")
weather_code=$(jq -r '.current.weather_code' <<< "$response")
apparent_temp=$(jq -r '.current.apparent_temperature' <<< "$response")
temp_2m=$(jq -r '.current.temperature_2m' <<< "$response")
humidity=$(jq -r '.current.relative_humidity_2m' <<< "$response")
surface_pressure=$(jq -r '.current.surface_pressure' <<< "$response")
precipitation=$(jq -r '.current.precipitation' <<< "$response")

# Extract sunrise/sunset data
sunrise=$(jq -r '.daily.sunrise[0]' <<< "$response")
sunset=$(jq -r '.daily.sunset[0]' <<< "$response")
sunrise_time=$(date -d "$sunrise" +'%-I:%M%p')
sunset_time=$(date -d "$sunset" +'%-I:%M%p')

# Generate display components using functions
weather_text=$(get_weather_text "$weather_code")
weather_code_display=$(get_weather_icon "$weather_code" "$is_day")
temp_text=$(get_temp_display "$temp_2m" "$apparent_temp")
humidity_text=$(get_humidity_display "$humidity")
pressure_text=$(get_pressure_display "$surface_pressure")
precipitation_text=$(get_precipitation_display "$precipitation")
sun_times_text=$(get_sun_times_display "$sunrise_time" "$sunset_time")

# Construct full display text
full_text="${weather_code_display}  ${temp_text} ${humidity_text} ${pressure_text} ${precipitation_text} ${sun_times_text}"

# Create tooltip
surface_pressure_atm=$(printf "%.2f" "$(echo "scale=4; $surface_pressure * 0.0009869233" | bc -l)")
tooltip_text=$(create_tooltip "$weather_code_display" "$weather_text" "$temp_2m" "$apparent_temp" "$humidity" "$surface_pressure_atm" "$precipitation" "$datetime_f")

# Generate final JSON output
output=$(jq -nc --arg text "$full_text" --arg tooltip "$tooltip_text" '{text: $text, tooltip: $tooltip}')

echo -n "$output"