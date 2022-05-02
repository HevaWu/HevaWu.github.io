---
layout: post
title: Fix Cannot Specify Dot Executable Issue in VisualStudio Code PlantUML
date: 2022-05-02 15:00:00
comment_id: 214
categories: [VSCode]
tag: [PlantUML]
---

There is an issue when I open PlantUML with VSCode. It seems only happen when we install `graphviz` from `brew`. The warning is like:

```s
Dot Executable: /opt/local/bin/dot File does not exist
Cannot find Graphviz. You should try
...
```

## Solution

add ⬇️ to `settings.json` in VSCode

```json
"plantuml.commandArgs": [
    "-DGRAPHVIZ_DOT="{PATH_TO_GRAPHVIZ}/bin/dot",
]
```

in my case, the path is `/opt/homebrew/Cellar/graphviz/3.0.0/bin/dot`.

*If don't know where it is, we could check it by `brew info graphviz`.*

Then preview the PlantUML diagram again, the problem is solved.

#### References

- <https://github.com/qjebbs/vscode-plantuml/issues/94>
