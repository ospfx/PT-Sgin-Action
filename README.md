# PT-Sgin-Action
PT站点Action自动签到保活  
PT站点签到，使用github action自动签到  
添加多站点需要在pt_sgin.yml添加  SITE0: ${{ secrets.SITE0 }}  
自行在setting中添加 Repository secrets  
   

|  名称  |                 含义                  |
| :----: | :-----------------------------------: |
| SITE0 | 网站数据 |
|    PUSHPLUS_TOKEN    | pushplus中的用户token，用于推送，非必需 |
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
        'cookie':'cf_clearance=xxx-xx-1.0.1.1-xx.xx; c_secure_uid=NDY3; c_secure_pass=xx; c_secure_ssl=xx%3D%3D; c_secure_tracker_ssl=xx%3D%3D; c_secure_login=xx%3D%3D; Hm_lvt_41bc5487f653d238d282d7de5990fd73=xx; HMACCOUNT=xx; Hm_lpvt_41bc5487f653d238d282d7de5990fd73=xx',
	}
]
````
