#!/bin/bash

sgin_php="attendance.php"
user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36 Edg/131.0.0.0"

tg_notify() {
    [[ -z "$TG_BOT_TOKEN" || -z "$TG_USER_ID" ]] && return
    local thread_id=${TG_THREAD_ID:+"&message_thread_id=$TG_THREAD_ID"}
    curl -s -X POST "https://${TG_API_HOST:-api.telegram.org}/bot$TG_BOT_TOKEN/sendMessage" \
        -d "chat_id=$TG_USER_ID&parse_mode=HTML&text=✅ <b>$name</b> - $result$thread_id"
}

check_in() {
    check_site
    local response=$(curl -s -H "User-Agent: $user_agent" -H "Cookie: $cookie" -H "Referer: $url" "$url")
    [[ "$response" =~ (已签到|签到已得) ]] && { result="站点：$name - 重复签到 skip"; return; }
    [[ "$response" != *"控制面板"* ]] && { result="站点：$name - 未登录/cookie已过期"; return; }

    if [[ "$sgin_php" == "signed.php" ]]; then
        read signed_timestamp signed_token < <(get_token "$response")
        response=$(curl -s -H "User-Agent: $user_agent" -H "Cookie: $cookie" -H "referer: $url" -d "signed_timestamp=$signed_timestamp&signed_token=$signed_token" "$url/$sgin_php")
    else
        response=$(curl -s -H "User-Agent: $user_agent" -H "Cookie: $cookie" -H "referer: $url" "$url/$sgin_php")
    fi

    if [[ "$response" =~ "请勿重复刷新" ]]; then
        result="站点：$name - 重复签到"
    elif [[ "$response" =~ (签到已得|签到获得)[[:space:]]*([0-9]+) ]]; then
        result="站点：$name - 签到已得 ${BASH_REMATCH[2]}"
    else
        result="站点：$name - cookie已过期"
    fi
    echo "$result"
}

get_token() {
    echo "$1" | grep -oP 'signed_timestamp:\s*"\K[0-9]+' | tr '\n' ' '
    echo "$1" | grep -oP 'signed_token:\s*"\K[0-9a-f]+'
}

check_site() {
    local sites=("https://totheglory.im" "https://example2.com" "https://example3.com")
    for site in "${sites[@]}"; do
        [[ "$url" == "$site" ]] && { sgin_php="signed.php"; break; }
    done
}

process_sites() {
    command -v jq &>/dev/null || { echo "错误：jq 未安装，请先安装 jq。"; exit 1; }
    for i in $(seq 0 99); do
        eval "local site_data=\$SITE$i"
        [[ -z "$site_data" ]] && break
        name=$(echo "$site_data" | jq -r '.name')
        url=$(echo "$site_data" | jq -r '.url')
        cookie=$(echo "$site_data" | jq -r '.cookie')
        [[ -n "$url" && -n "$cookie" && -n "$name" ]] && { check_in; tg_notify; }
    done
}

process_sites
