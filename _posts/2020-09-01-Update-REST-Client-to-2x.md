---
layout: post
title: Update REST Client to 2.x
date: 2020-09-01 19:40:00
comment_id: 96
categories: [REST, HTTP]
tags: [Request]
---

REST Client is a convenience tool to help sending HTTP request to the server for ruby. We are keep using the 1.6.7 version before, but we found [fastlane's gem](https://rubygems.org/gems/fastlane) required the lowest `rest-client` version is `1.8.0`. So we thought maybe it's time to update to use latest `rest-client` version now. And I'd like to memo how we successfully migrate to use the 2.1.0 `rest-client` in this article.

At first, I thought simply update `rest-client` gem version would be enough. But then I got a `400 BAD Request` error for it. After doing some research, it seems this is because there is something wrong in the request body part.

Let me post our 1.6.7 version script at here:

```ruby
url = "http://ourlink/api/post"
request_body = [
	['key_1', 'value_1'],
	['key_2', 'value_2'],
	['files', File.new('file_1_path', 'r')],
	['files', File.new('file_2_path', 'r')],
]
header = {
	'custom_token' => 'our_token_str'
}
res = RestClient.post(url, request_body, header)
```

It's easier to find the wrong part would be the `request_body` format. It seems start from 2.x, we couldn't directly use `[]`. Then we tried another format:

```ruby
request_body = {
	'key_1' => 'value_1',
	'key_2' => 'value_2',
	'files' => File.new('file_1_path', 'r'),
	'files' => File.new('file_2_path', 'r'),
}
```

This time we could successfully send the request, but after checking the response, we found there is only one file upload successfully. One of our `files` is missing. Yeah, the `file_2_path` replace the `file_1_path`. That is really not what we want. 😢

Then, we tried to change the body part as:

```ruby
request_body = {
	'key_1' => 'value_1',
	'key_2' => 'value_2',
	'files' => [File.new('file_1_path', 'r'), File.new('file_2_path', 'r')]
}
```

Then we start getting the `500 Internal Server` error now. It shows:

```s
{"result":false,"errorType":"NumberFormatException","errorMessage":"For input string: \"\"","statusCodeCode":500}
```

By reading the [`rest-client` Query Parameters](https://github.com/rest-client/rest-client#query-parameters) guideline, it seems if we directly pass array to a key, it will be transferred as `url?files[]=file_1&files[]=file_2`. But at here, we want the request to be `url?files=file_1&files=file_2`.

For getting `url?files=file_1&files=file_2` request, `rest-client` 2.x provide new [`ParamsArray`](https://www.rubydoc.info/gems/rest-client/RestClient/ParamsArray). So, changing the body part to ⬇️ will fix this 500 issue.

```ruby
request_body = RestClient::ParamsArray.new([
	[:key_1, 'value_1'],
	[:key_2, 'value_2'],
	[:files, File.new('file_1_path', 'r')],
	[:files, File.new('file_2_path', 'r')],
])
```

Now, the request should be successfully sent, and the request body format should be correct. 🎉

#### Reference

- <https://github.com/rest-client/rest-client>
- <https://www.rubydoc.info/gems/rest-client/RestClient/ParamsArray>
