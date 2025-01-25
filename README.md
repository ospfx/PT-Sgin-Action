# PT-Sgin-Action
PT站点 Action/青龙面板 自动签到保活 
PT站点签到，使用github action自动签到  
自行在setting中添加 Repository secrets  


|  名称  |                 含义                  |
| :----: | :-----------------------------------: |
| SITEx | 网站数据 |
| TG_API_HOST | tg反代地址，国内网络环境需要 |
| TELEGRAM_BOT_TOKEN | 电报token，非必需 |
| CHAT_ID | 电报chatid，非必需 |
| THREAD_ID | 电报超级群组话题id，非必需 |
| TELEGRAM_API_URL | 代理api，非必需 |

SITE0 - SITEn
````
[
    {
        'name':'ptxxx',
        'url':'https://ptxxx.xx', 
        'cookie':'xx=xxx-xx-xxxx-xx.xx; xx=xxxx; xx=xx; xx=xxxxxx; xx=xxxxxxx; xx=xxxxxxx; xx=xx; xx=xx; xx=xx',
	}
]
````
