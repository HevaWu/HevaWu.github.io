---
layout: post
title: Add Blog Comments By Github Issues API
date: 2020-08-19 19:47:00
comment_id: 95
categories: [Github]
tags: [API]
---

## Motivation

When I start creating this blog pages, I'm using the [Disqus](https://disqus.com/) to manage the comments part. Though it is not my ideal management tools, but I don't know to pick which one at that time. For convenience, I searched on the web, and decide to use Disqus. But recently I start feeling Disqus is hard to manage and check the comments(And sometimes, I forgot my disqus account password XD). TBH, Disqus is a really nice system which provide some customizing things, such as Ads, ratings, reactions, etc. But for the basic plan, there is not so much things we could do. 😥

Then I start searching if there is other choice for my blog comments. And I find 2 nice blog-s which introduce Github Issues Comments.

- <https://artsy.github.io/blog/2017/07/15/Comments-are-on/>
- <https://aristath.github.io/blog/static-site-comments-using-github-issues-api>

These 2 blogs all introduced the Github Issues and sharing their code, and their css style also looks really nice! Since my blog are mostly about development things, I would suppose person who might visit my blog must have a github account. Besides, this blog is based on Github Pages. Thus, using Github Issues for the comments part actually really work for me. After some researching, I start changing my blog comments.

## Post Comment_id

We will use `comment_id` of each post to handle the issues id. So this should be same as the issues id where we will show this article comments.

```s
comment_id: 1
```

This will mean to show comments listed in `https://github.com/%user%/%repo%/issues/1`

## Github Issues

For showing Github Issues comments, basically, we only use this [List issue comments](https://developer.github.com/v3/issues/comments/#list-issue-comments) API. Here is the response example of it:

```json
[
  {
    "id": 1,
    "node_id": "MDEyOklzc3VlQ29tbWVudDE=",
    "url": "https://api.github.com/repos/octocat/Hello-World/issues/comments/1",
    "html_url": "https://github.com/octocat/Hello-World/issues/1347#issuecomment-1",
    "body": "Me too",
    "user": {
      "login": "octocat",
      "id": 1,
      "node_id": "MDQ6VXNlcjE=",
      "avatar_url": "https://github.com/images/error/octocat_happy.gif",
      "gravatar_id": "",
      "url": "https://api.github.com/users/octocat",
      "html_url": "https://github.com/octocat",
      "followers_url": "https://api.github.com/users/octocat/followers",
      "following_url": "https://api.github.com/users/octocat/following{/other_user}",
      "gists_url": "https://api.github.com/users/octocat/gists{/gist_id}",
      "starred_url": "https://api.github.com/users/octocat/starred{/owner}{/repo}",
      "subscriptions_url": "https://api.github.com/users/octocat/subscriptions",
      "organizations_url": "https://api.github.com/users/octocat/orgs",
      "repos_url": "https://api.github.com/users/octocat/repos",
      "events_url": "https://api.github.com/users/octocat/events{/privacy}",
      "received_events_url": "https://api.github.com/users/octocat/received_events",
      "type": "User",
      "site_admin": false
    },
    "created_at": "2011-04-14T16:00:49Z",
    "updated_at": "2011-04-14T16:00:49Z"
  }
]
```

We will find this response contains the `body`(comments message body), `user`(the person who post this comment), `create_at`(when this comment been added). 

## comments.html

After reading the API doc, we could start writing our `comments.html`. Put this under the `_includes` for reusing it later. Here is my scripts, you can also find it [at here](https://github.com/HevaWu/HevaWu.github.io/blob/master/_includes/comments.html):

```html
<script>
	const GH_API_URL = 'https://api.github.com/repos/HevaWu/HevaWu.github.io/issues/{{ page.comment_id }}/comments';

	let request = new XMLHttpRequest();
	request.open('GET', GH_API_URL, true, 'cb2f4de099485f543dd9', '51f265e652aebde62fdfd0b6499a6452f3f35329');
	request.onload = function () {
		if (this.status >= 200 && this.status < 400) {
			let response = JSON.parse(this.response);

			for (var i = 0; i < response.length; i++) {
				document.getElementById('gh-comments-list').appendChild(createCommentEl(response[i]));
			}

			if (0 === response.length) {
				document.getElementById('gh-comments-list').appendChild(noCommentEl());
			}
		} else {
			console.error(this);
		}
	};

	function noCommentEl() {
		let noComment = document.createElement('p')
		noComment.classList.add("gh-no-comment");
		noComment.innerText = "No comments found for this article."

		return noComment
	}

	function createCommentEl(response) {

		// Header

		let commentHeader = document.createElement('div');
		commentHeader.classList.add('comment-header');

		let user = document.createElement('a');
		user.setAttribute('href', response.user.url.replace('api.github.com/users', 'github.com'));
		user.classList.add('user');

		let userAvatar = document.createElement('img');
		userAvatar.classList.add('avatar');
		userAvatar.setAttribute('src', response.user.avatar_url);

		user.appendChild(userAvatar);
		user.appendChild(document.createTextNode(" " + response.user.login + " "))

		let commentDateWithURL = document.createElement('a');
		commentDateWithURL.setAttribute('href', response.html_url);
		commentDateWithURL.classList.add('comment-url');
		commentDateWithURL.innerHTML = response.created_at;

		commentHeader.appendChild(user);
		commentHeader.appendChild(document.createTextNode(" Commented On "));
		commentHeader.appendChild(commentDateWithURL);

		// Content

		let commentContents = document.createElement('div');
		commentContents.classList.add('comment-content');

		let commentContentP = document.createElement('p');
		commentContentP.innerHTML = response.body;

		commentContents.appendChild(commentContentP);

		// Append to li

		let comment = document.createElement('li');
		comment.setAttribute('data-created', response.created_at);
		comment.setAttribute('data-author-avatar', response.user.avatar_url);
		comment.setAttribute('data-user-url', response.user.url);

		comment.appendChild(commentHeader);
		comment.appendChild(commentContents);

		return comment;
	}
	request.send();
</script>

<div class="github-comments">
	<h2>Comments</h2>
	<ul id="gh-comments-list"></ul>
	<p id="leave-a-comment">
		Join the discussion for this article
		<a href="https://github.com/HevaWu/HevaWu.github.io/issues/{{ page.comment_id }}">at here</a>
		. Our comments is using Github Issues. All of posted comments will display at this page instantly.
	</p>
</div>
```

## Add Comments into Post

Now, we've created the `comments.html`, and we could prepare add it into the position where we want to show our comments.

{% raw %}
```html
<!-- Add Github issue comments. -->
  <div class="post-comment">
    {% if page.comment_id %}
      {% include comments.html %}
    {% endif %}
  </div>
```
{% endraw %}

## Test Comments

At this step, all of the basic settings are finished, the blog should be able to show the posted comments in the issue ticket. You can test this blog's comment [at this issue ticket](https://github.com/HevaWu/HevaWu.github.io/issues/95).

## CSS Style

After putting the `comments.html` in the post, it should be able to show comments now. You might also want to update the css style of it. Here is my css part around it:

```css
.github-comments ul {
  list-style-type: none;
  margin-left: 0em;
}

.github-comments ul li {
  margin-top: 1.5em;
}

.comment-header a {
  border-bottom: none;
}

.comment-content p {
  margin-top: 0em;
  margin-bottom: 0em;
  margin-left: 50px;
  padding-left: 10px;
  background-color: rgba(233, 232, 232, 0.623);
  border-radius: 4px;
  border-left: 2px solid rgba(122, 121, 121, 0.623);
}

#gh-comments-list img {
  border-radius: 15px;
  vertical-align: middle;
  max-width: 50px;
}

#gh-comments-list div {
  padding-left: 1em;
}
```

🎉🎉🎉🎉🎉🎉🎉

In the later, we could also add comment response of it. I will try to update it when I finished~

#### Reference

<https://developer.github.com/v3/issues/>

<https://artsy.github.io/blog/2017/07/15/Comments-are-on/>

<https://aristath.github.io/blog/static-site-comments-using-github-issues-api>
