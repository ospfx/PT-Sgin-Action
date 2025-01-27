#!/bin/bash

DEFAULT_API_HOST="api.telegram.org"
TG_API_HOST=${TG_API_HOST:-$DEFAULT_API_HOST}
sgin_php="attendance.php"

check_in() {
    local user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36 Edg/131.0.0.0"
    check_site
    local sgin_url="${url}/${sgin_php}"
    local response tip
    
    #防止重复签到
    response=$(curl -s -H "User-Agent: ${user_agent}" -H "Cookie: ${cookie}" -H "referer": ${url} ${url}")
    if [[ "$response" == *"已签到"* || "$response" == *"签到已得"* ]]; then
        tip=" 重复签到skip"
        result="站点：${name} - ${tip}"
        return 0
    elif [[ "$response" != *"控制面板"* ]]; then
        tip="未登录/cookie已过期"
        return 0
    fi
    
    if [[ "$sgin_php" == "signed.php" ]]; then
        read signed_timestamp signed_token < <(get_token)
        local post_data="signed_timestamp=${signed_timestamp}&signed_token=${signed_token}"
        response=$(curl -s -H "User-Agent: ${user_agent}" -H "Cookie: ${cookie}" -d "$post_data" "${sgin_url}")
    else
        response=$(curl -s -H "User-Agent: ${user_agent}" -H "Cookie: ${cookie}" "${sgin_url}")
    fi

    if [[ "$response" =~ 请勿重复刷新 ]]; then
        tip=" 重复签到"
    elif [[ "$response" =~ (签到已得|签到获得)[[:space:]]*([0-9]+) ]]; then
        local earned_points="${BASH_REMATCH[1]}"
        tip=" 签到已得${earned_points}"
    else
        tip=" cookie已过期"
    fi
    result="站点：${name} - ${tip}"
    echo "$result"
}

get_token() {
    signed_timestamp=$(echo "$response" | grep -oP 'signed_timestamp:\s*"\K[0-9]+')
    signed_token=$(echo "$response" | grep -oP 'signed_token:\s*"\K[0-9a-f]+')
}
check_site() {
    local sites=("https://totheglory.im" "https://example2.com" "https://example3.com")
    for site in "${sites[@]}"; do
        if [[ "$url" == "$site" ]]; then
            sgin_php="signed.php"
            break
        fi
}
process_sites() {
    for i in $(seq 0 99); do
        local site_var="SITE${i}"
        local site_data="${!site_var}"
        [ ! "$site_data" ] && break
        
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
