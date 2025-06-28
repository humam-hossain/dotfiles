#!/usr/bin/env bash
# weather.sh - Fetch current weather and output JSON for Waybar custom module

# Configuration: set your latitude and longitude here
LATITUDE=23.763953
LONGITUDE=90.424419

# Dependencies check
for cmd in curl jq bc; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "{\"text\":\" Missing $cmd\",\"class\":\"error\"}"
        exit 0
    fi
done

# Fetch and parse weather data using 'current' fields for temperature and humidity
response=$(curl -s \
    "https://api.open-meteo.com/v1/forecast?latitude=${LATITUDE}&longitude=${LONGITUDE}&current=is_day,weather_code,apparent_temperature,temperature_2m,relative_humidity_2m,surface_pressure,precipitation&temperature_unit=celsius&timezone=auto")

if [[ -z "$response" ]]; then
    echo "{\"text\":\" No data\",\"class\":\"error\"}"
    exit 0
fi

# Extract fields
datetime=$(jq -r '.current.time' <<< "$response")
datetime_f=$(date -d "$datetime" +'%Y-%m-%d %-I:%M%p')

is_day=$(jq -r '.current.is_day' <<< "$response")
weather_code=$(jq -r '.current.weather_code' <<< "$response")
apparent_temp=$(jq -r '.current.apparent_temperature' <<< "$response")
temp_2m=$(jq -r '.current.temperature_2m' <<< "$response")
humidity=$(jq -r '.current.relative_humidity_2m' <<< "$response")
surface_pressure=$(jq -r '.current.surface_pressure' <<< "$response")
surface_pressure_atm=$(printf "%.2f" "$(echo "scale=4; $surface_pressure * 0.0009869233" | bc)")
precipitation=$(jq -r '.current.precipitation' <<< "$response")

# Fallback if parsing failed
if [[ -z "$is_day" || -z "$temp_2m" || -z "$apparent_temp" || -z "$humidity" || -z "$surface_pressure" || -z "$precipitation" || \
    "$is_day" == "null" || "$temp_2m" == "null" || "$apparent_temp" == "null" || "$humidity" == "null" || \
    "$surface_pressure" == "null" || "$precipitation" == "null" ]]; then
    echo "{\"text\":\" Parse error\",\"class\":\"error\"}"
    exit 0
fi

# Weather code categories:
# Clear: 
#   0: Clear sky (☀️ for day, 🌙 for night, Noto Emoji)
#   1: Mainly clear
# 
# Cloudy day "⛅" | night "☁️"
#   2: Partly cloudy 
#   3: Overcast
#
# Fog:
#   45: Fog "󰖑"
#   48: Depositing rime fog
#
# rain:  (day),  (night)
#   51: Drizzle: Light intensity
#   53: Drizzle: Moderate intensity
#   55: Drizzle: Dense intensity
#   56: Freezing Drizzle: Light intensity
#   57: Freezing Drizzle: Dense intensity
#   61: Rain: Slight intensity
#   63: Rain: Moderate intensity
#   65: Rain: Heavy intensity
#   66: Freezing Rain: Light intensity
#   67: Freezing Rain: Heavy intensity
#
# Snow: ❄️
#   71: Snow fall: Slight intensity
#   73: Snow fall: Moderate intensity
#   75: Snow fall: Heavy intensity
#   77: Snow grains
#
# Showers: 🌧️
#   80: Rain showers: Slight (🌦️)
#   81: Rain showers: Moderate (🌧️)
#   82: Rain showers: Violent (⛈️)
#   85: Snow showers: Slight (🌨️)
#   86: Snow showers: Heavy (❄️)
#
# Thunderstorm: ⛈️
#   95: Thunderstorm: Slight or moderate
#   96: Thunderstorm with slight hail
#   99: Thunderstorm with heavy hail

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

# day / night
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
            weather_icon=""
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
            weather_icon=""
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

# diff between apparent temperature and 2m temperature
diff_temp=$(echo "$apparent_temp - $temp_2m" | bc)
if (( $(echo "$diff_temp > 0" | bc -l) )); then
    temp_display="$temp_2m°C[+$diff_temp]"
elif (( $(echo "$diff_temp < 0" | bc -l) )); then
    temp_display="$temp_2m°C[$diff_temp]"
else
    temp_display="$temp_2m°C"
fi

# Determine temperature color (Pango markup colors)
if (( $(echo "$temp_2m < 15" | bc -l) )); then
    temp_color="#3498db"  # Blue
elif (( $(echo "$temp_2m < 20" | bc -l) )); then
    temp_color="#5dade2"  # Light blue
elif (( $(echo "$temp_2m < 30" | bc -l) )); then
    temp_color="#58d68d"  # Green
else
    temp_color="#ec7063"  # Red
fi

# Construct JSON output
# Using icons:  for temperature,  for humidity
weather_code="<span color='${weather_color}' size='${weather_size}'>${weather_icon}</span>"
temp_text="<span color='${temp_color}'><span size='11000'>🌡️</span>${temp_display}</span>"
humidity_text="<span color='#3498db'> ${humidity}%</span>"
pressure_text="<span color='#f7dc6f'><span size='11000'>󰡴</span> ${surface_pressure_atm}atm</span>"
precipitation_text="<span color='#5dade2'><span size='12000'>☔</span> ${precipitation}mm</span>"

full_text="${weather_code}  ${temp_text} ${humidity_text} ${pressure_text} ${precipitation_text}"

# Create detailed tooltip with proper escaping
tooltip_text="<big>Current Weather</big>
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
${weather_icon} Weather Code: $weather_text
🌡️ Temperature: ${temp_2m}°C (feels like ${apparent_temp}°C)
💧 Humidity: ${humidity}%
󰡴  Pressure: ${surface_pressure_atm} atm
☔ Precipitation: ${precipitation}mm

Updated: ${datetime_f}
"

output=$(jq -nc --arg text "$full_text" --arg tooltip "$tooltip_text" '{text: $text, tooltip: $tooltip}')

echo -n "$output"

