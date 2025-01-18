import requests
import re
import os
import sys
import json
from json.decoder import JSONDecodeError

pushplus_token = os.environ.get("PUSHPLUS_TOKEN")
telegram_bot_token = os.environ.get("TELEGRAM_BOT_TOKEN","")
chat_id = os.environ.get("CHAT_ID","")
thread_id = os.environ.get("THREAD_ID","")
telegram_api_url = os.environ.get("TELEGRAM_API_URL","https://api.telegram.org")

def telegram_Bot(token,chat_id,thread_id=None,message):
    url = f'{telegram_api_url}/bot{token}/sendMessage'
    data = {
        'chat_id': chat_id,
        'message_thread_id': thread_id,
        'text': message
    }
    r = requests.post(url, json=data)
    response_data = r.json()
    msg = response_data['ok']
    print(f"telegram推送结果：{msg}\n")

def pushplus_ts(token, rw, msg):
    url = 'https://www.pushplus.plus/send/'
    data = {
        "token": token,
        "title": rw,
        "content": msg
    }
    r = requests.post(url, json=data)
    msg = r.json().get('msg', None)
    print(f'pushplus推送结果：{msg}\n')

def load_send():
    global send
    global hadsend
    cur_path = os.path.abspath(os.path.dirname(__file__))
    sys.path.append(cur_path)
    if os.path.exists(cur_path + "/notify.py"):
        try:
            from notify import send
            hadsend=True
        except:
            print("加载notify.py的通知服务失败，请检查~")
            hadsend=False
    else:
        print("加载通知服务失败,缺少notify.py文件")
        hadsend=False
load_send()


def parse_sites_from_env():
    sites = []
    site_index = 0
    while True:
        site_data = os.environ.get(f'SITE{site_index}')
        if not site_data:
            print("not site data")
            break
        try:
            site = json.loads(site_data)
            if 'url' in site and 'cookie' in site:
                sites.append(site)
            else:
                print(f"Skipping malformed SITE{site_index}: {site_data}")
        except json.JSONDecodeError:
            print(f"Invalid JSON in SITE{site_index}: {site_data}")
        site_index += 1
    return sites

def check_in(url, name, cookie):
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36 Edg/131.0.0.0',
        'Cookie': cookie
    }
    attendance_url = url + '/attendance.php'
    with requests.Session() as session:
        with session.get(attendance_url, headers=headers) as res:
            r = re.compile(r'请勿重复刷新')
            r1 = re.compile(r'签到已得[\s]*\d+')
            if r.search(res.text):
                message = ' 重复签到'
            elif r1.search(res.text):
                message = ' 签到成功'
            else:
                message = ' cookie已过期'
            result = f'{name} - {message}'
            print(result)
            return result

if __name__ == "__main__":
    sites = parse_sites_from_env()
    for site in sites:
        result = check_in(site['url'], site.get('name', 'Unknown'), site['cookie'])
        if telegram_bot_token and chat_id:
          telegram_Bot(telegram_bot_token, chat_id, thread_id, result)
        if pushplus_token:
          pushplus_ts(pushplus_token, result)
