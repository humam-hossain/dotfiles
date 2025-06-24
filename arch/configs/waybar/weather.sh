#!/bin/bash

# Set API details
API_KEY="s4pMSAgGyyOUFrF5jAzulZw8bCQGGbJz"
# API_KEY="p9NcxfksSb9F3UaAcnGjuftKfAvYhiQI"
LOCATION_KEY="28081"

# Get API response
API_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" "http://dataservice.accuweather.com/currentconditions/v1/${LOCATION_KEY}?apikey=${API_KEY}&details=true")

# Check curl success
if [[ $? -ne 0 ]]; then
    echo '{"text":" API Error","tooltip":"Connection failed"}'
    exit 1
fi

# Extract status and content
HTTP_STATUS=$(echo "$API_RESPONSE" | grep "HTTP_STATUS:" | cut -d':' -f2)
API_CONTENT=$(echo "$API_RESPONSE" | grep -v "HTTP_STATUS:")

if [[ "$HTTP_STATUS" == "200" ]]; then
    # Extract all data points
    WEATHER_TEXT=$(echo "$API_CONTENT" | jq -r '.[0].WeatherText')
    IS_DAYTIME=$(echo "$API_CONTENT" | jq -r '.[0].IsDayTime')
    REAL_FEEL=$(echo "$API_CONTENT" | jq -r '.[0].RealFeelTemperature.Metric.Value | round')
    HUMIDITY=$(echo "$API_CONTENT" | jq -r '.[0].RelativeHumidity')
    WIND_SPEED=$(echo "$API_CONTENT" | jq -r '.[0].Wind.Speed.Metric.Value | round')
    WIND_DIR=$(echo "$API_CONTENT" | jq -r '.[0].Wind.Direction.Localized')
    UV_INDEX=$(echo "$API_CONTENT" | jq -r '.[0].UVIndex')
    UV_TEXT=$(echo "$API_CONTENT" | jq -r '.[0].UVIndexText')
    PRESSURE_MB=$(echo "$API_CONTENT" | jq -r '.[0].Pressure.Metric.Value')
    PRESSURE_ATM=$(echo "$PRESSURE_MB / 1013.25" | bc -l | awk '{printf "%.2f", $1}')
    PRESSURE_TREND=$(echo "$API_CONTENT" | jq -r '.[0].PressureTendency.LocalizedText')
    # Convert boolean to Day/Night
    if [[ "$IS_DAYTIME" == "true" ]]; then
        DAY_NIGHT=""
    else
        DAY_NIGHT="󰖔"
    fi

    if [[ "$IS_DAYTIME" == "Rising" ]]; then
        P_TREND="󰔵"
    elif [[ "$IS_DAYTIME" == "steady" ]]; then
        P_TREND="󰔴"
    else
        P_TREND="󰔳"
    fi

    # Create text and tooltip with ALL data points
    TEXT=$(jq -n \
        --arg dn "$DAY_NIGHT" \
        --arg wt "$WEATHER_TEXT" \
        --arg rt "$REAL_FEEL" \
        --arg hu "$HUMIDITY" \
        --arg ws "$WIND_SPEED" \
        --arg wd "$WIND_DIR" \
        --arg uv "$UV_INDEX" \
        --arg uvt "$UV_TEXT" \
        --arg pa "$PRESSURE_ATM" \
        --arg pt "$P_TREND" \
        --arg ppt "$PRESSURE_TREND" \
        '{
            text: "\($dn) \($wt) |  \($rt)°C |  \($hu)% |  \($ws)km/h \($wd) | 󰡴 \($pa)atm\($pt)",
            tooltip: "Weather: \($wt)\nTemperature: \($rt)°C\nHumidity: \($hu)%\nWind: \($ws)km/h \($wd)\nUV: \($uv) (\($uvt))\nPressure: \($pa)atm (\($ppt))"
        }' | jq -c .)

    echo "$TEXT"
else
    echo "{\"text\":\" Error $HTTP_STATUS\",\"tooltip\":\"API request failed\"}"
fi