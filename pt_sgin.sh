#!/bin/bash

DEFAULT_API_HOST="api.telegram.org"
TG_API_HOST=${TG_API_HOST:-$DEFAULT_API_HOST}

check_in() {
    local user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36 Edg/131.0.0.0"
    local attendance_url="${url}/attendance.php"
    
    local response tip
    response=$(curl -s -H "User-Agent: ${user_agent}" -H "Cookie: ${cookie}" "${attendance_url}")

    # Check for patterns本次签到获得
    if [[ "$response" =~ (签到已得|请勿重复刷新) ]]; then
        tip=" 重复签到"
    elif [[ "$response" =~ 签到获得[[:space:]]*([0-9]+) ]]; then
        local earned_points="${BASH_REMATCH[1]}"
        tip=" 签到已得${earned_points}"
    else
        tip=" cookie已过期"
    fi
    
    result="站点：${name} - ${tip}"
    echo "$result"
}

process_sites() {
    for i in $(seq 0 99); do
        local site_var="SITE${i}"
        local site_data="${!site_var}"
        [[ -n "$site_data" ]] && break

        local name url cookie
        name=$(echo "$site_data" | jq -r '.name')
        url=$(echo "$site_data" | jq -r '.url')
        cookie=$(echo "$site_data" | jq -r '.cookie')
        if [[ -n "$url" && -n "$cookie" && -n "$name" ]]; then
            check_in
            [[ -n "$TG_BOT_TOKEN" && -n "$TG_USER_ID" ]] && curl -s -X POST "https://${TG_API_HOST}/bot${TG_BOT_TOKEN}/sendMessage" -d chat_id=${TG_USER_ID} -d message_thread_id=${TG_THREAD_ID} -d parse_mode=HTML -d text="✅ <b>${name}</b> -${result}"
        else
            echo "错误：SITE${i} 的 url 或 cookie 缺失，跳过处理。"
        fi
    done
}

process_sites
