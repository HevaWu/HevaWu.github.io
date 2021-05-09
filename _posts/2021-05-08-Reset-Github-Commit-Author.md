---
layout: post
title: Reset Github Commit Author
date: 2021-05-08 14:58:00
comment_id: 153
categories: [Github]
---

Sometimes, we might set commit author wrong. And I've met this issue recently.
I miss typed `git config --global user.mail` when I actually want to set `user.email`.

For fixing it, I searched some info online, and I'd like to sum up them at here.

## Reset ALL commits Author

Here is a nice blog for it: <https://mhagemann.medium.com/how-to-change-the-user-for-all-your-git-commits-ffefbacf2652>. Feel free to check it if you are interested in.

```s
$ git filter-branch --env-filter '
OLD_EMAIL="old@example.com"
NEW_NAME="new name"
NEW_EMAIL="new@example.com"
if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
  export GIT_COMMITTER_NAME="$NEW_NAME"
  export GIT_COMMITTER_EMAIL="$NEW_EMAIL"
fi
if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
  export GIT_AUTHOR_NAME="$NEW_NAME"
  export GIT_AUTHOR_EMAIL="$NEW_EMAIL"
fi'

# refresh all history
$ git push origin --force --all
```

## Reset One Specific Commit

- If this commit is on the top, we can solve it by:

```s
# Update `git config` first, then run ⬇️
$ git commit --amend --reset-author
```

- If this commit is on the middle, try rebase to solve it:

```s
$ git rebase -i -p <some HEAD before all of your bad commits>
$ git commit --amend --author "New Author Name <email@address.com>"
$ git rebase --continue
```

#### Reference

- <https://mhagemann.medium.com/how-to-change-the-user-for-all-your-git-commits-ffefbacf2652>
- <https://stackoverflow.com/questions/3042437/how-to-change-the-commit-author-for-one-specific-commit>
