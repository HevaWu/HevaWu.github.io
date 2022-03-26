---
layout: post
title: Transfer Audio Memo to Text File
date: 2022-01-23 20:00:00
comment_id: 202
categories: [Audio]
tags: [Automatic Speech Recognition]
---

Sometimes, we have some audio memo, and might want to transfer it to text in the later. For a single file, it might easy to handle. But for large amount of files, let's say 100 files, I feel it is really hard to me to check it one by one. So I try to search if there is any tools can help me.

In my case, I need a tool to transfer "Chinese" audio memo, so I pick [`Tencent Cloud API`](https://github.com/TencentCloud/tencentcloud-sdk-python) `ASR`(Automatic Speech Recognition) one at here. There might be other convenience tools. I will try to compare them if I have time later.

`Tencent Cloud API` support both website and SDK.

## Website ASR

For the website one, here is the link: <https://console.cloud.tencent.com/asr/demonstr>.

Step also simple:

- Select file source: local or URL
- Select what kind of audio it is: phone or not-phone
- Select engine model: there is list of language types
- Select channel number: single or double
- Select type of result: list of choice, like including timestamp or not
- Upload file if file source is local, OR input URL address if source is URL

Once upload success, it is okay to `Start Recognition`. After waiting for a while, the result file is downloadable.

## SDK

There are list of SDK-s: <https://cloud.tencent.com/document/api/1093/37823#SDK>. And I pick [Python SDK](https://github.com/TencentCloud/tencentcloud-sdk-python) this time. My code is at here: <https://github.com/HevaWu/ASRRunner>

Basic flow is 2 parts:

1. Send ASR request, and get `TaskId` from response
2. Use 1's `TaskId` to retrieve/download result

Here is some core part:

### Send ASR request

```py
from tencentcloud.common import credential
from tencentcloud.common.profile.client_profile import ClientProfile
from tencentcloud.common.profile.http_profile import HttpProfile
from tencentcloud.common.exception.tencent_cloud_sdk_exception import TencentCloudSDKException
from tencentcloud.asr.v20190614 import asr_client, models

# set up request params
# https://cloud.tencent.com/document/api/1093/37823
secret_id =  os.environ.get("TENCENTCLOUD_SECRET_ID")
secret_key = os.environ.get("TENCENTCLOUD_SECRET_KEY")

cred = credential.Credential(
    secret_id,
    secret_key)

httpProfile = HttpProfile()
httpProfile.endpoint = "asr.tencentcloudapi.com"

clientProfile = ClientProfile()
clientProfile.httpProfile = httpProfile
clientProfile.signMethod = "TC3-HMAC-SHA256"
client = asr_client.AsrClient(cred, "ap-shanghai", clientProfile)

req = models.CreateRecTaskRequest()
params = {
    "EngineModelType":"16k_en",
    "ChannelNum":1,
    "ResTextFormat":0,
    "SourceType":1,
    "Data": encodestr
    }
req._deserialize(params)

# send request and get response json
resp = client.CreateRecTask(req)
resp_json_str = resp.to_json_string()
```

### Retrieve/Download Result

```py
# setup request params
# https://cloud.tencent.com/document/api/1093/37822
cred = credential.Credential(
    self.secret_id,
    self.secret_key)
httpProfile = HttpProfile()
httpProfile.endpoint = "asr.tencentcloudapi.com"

clientProfile = ClientProfile()
clientProfile.httpProfile = httpProfile
client = asr_client.AsrClient(cred, "ap-shanghai", clientProfile)

# send request and get response json
req = models.DescribeTaskStatusRequest()
params = '{"TaskId":' + str(self.task_id) +'}'
req.from_json_string(params)

resp = client.DescribeTaskStatus(req)
resp_json_str = resp.to_json_string()
```

### Limitations

If we'd like to send the API to process the file, there is a file size limitation. While the error message said 10MB, based on my test, it should be `5MB`.

So if local file is out of limitation, 2 choice, **split the file** OR use **Website one to handle it**.

#### References

- <https://cloud.tencent.com/document/api/1093/37823>
- My Code: <https://github.com/HevaWu/ASRRunner>
