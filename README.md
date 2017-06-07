# docker-compose で Hubot + Slack 構築

## 実行手順

```
macOS%$ git clone https://github.com/kenzo0107/hubot-slack-on-docker.git
macOS%$ cd hubot-slack-on-docker
macOS%$ docker-compose up -d
```

## 起動確認

```
macOS%$ docker ps

CONTAINER ID        IMAGE                      COMMAND                  CREATED             STATUS              PORTS                              NAMES
12f77feb09b4        hubotslackondocker_hubot   "/bin/sh -c 'bash ..."   24 minutes ago      Up 24 minutes       6379/tcp, 0.0.0.0:8080->8080/tcp   hubotslackondocker_hubot_1
```

## テスト

```
macOS%$ curl \
-X POST \
-H "Content-Type: application/json" \
-d \
'{
 "webhookEvent":"jira:issue_updated",
 "comment":{
   "author":{
     "name":"himuko"
    },
    "body":"[~kenzo.tanaka] 東京03 秋山 ケンコバ 劇団ひとり"
 },
 "issue": {
   "key":"key",
   "fields":{
     "summary":"summary"
    }
  }
}' \
http://104.xxx.x.xxx:8080/hubot/jira-comment-dm
```

![Imgur](http://i.imgur.com/4vAO8cf.png)
