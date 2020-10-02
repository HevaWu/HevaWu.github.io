---
layout: post
title: Add Project CHANGELOG
date: 2020-10-02 16:26:00
comment_id: 100
categories: [Github]
tags: [Changelog]
---

From <https://keepachangelog.com/en/1.0.0/>:

> What is a changelog?
> A changelog is a file which contains a curated, chronologically ordered list of notable changes for each version of a project.
> 
> Why keep a changelog?
> To make it easier for users and contributors to see precisely what notable changes have been made between each release (or version) of the project.
>
> Who needs a changelog?
> People do. Whether consumers or developers, the end users of software are human beings who care about what's in the software. When the software changes, people want to know why and how.

For easy managing and checking what we included in each release, we would like to add `CHANGELOG.md` into our project.

Here are the guideline principles:

> - Changelogs are for humans, not machines.
> - There should be an entry for every single version.
> - The same types of changes should be grouped.
> - Versions and sections should be linkable.
> - The latest version comes first.
> - The release date of each version is displayed.
> - Mention whether you follow Semantic Versioning.

After searching, we found a nice tool to auto-generate the `CHANGELOG.md` -> [github-changelog-generator](https://github.com/github-changelog-generator/github-changelog-generator).

## Setup

For how to install it:

```s
$ gem install github_changelog_generator
```

If the project is a Github project, we could simply run it by:

```s
$ github_changelog_generator -u github_project_namespace -p github_project
```

If the project is a Github Enterprise project, we need to also append github site url and api to it ⬇️, the github enterprise api document is [here](https://docs.github.com/en/enterprise-server@2.22/rest/reference/enterprise-admin#endpoint-urls)

```s
$ github_changelog_generator -u github_project_namespace -p github_project \
--github-site="https://github.yoursite.com" \
--github-api="https://github.yoursite.com/api/v3/"
```

## Option

For now, it should be able to generate the default template `CHANGELOG.md` in the project. However, we might want to add some custom settings into it. It would be easier to directly check all of options by using `--help` option. Here will only paste something I felt would be useful.

If we want to use the default templates, but want to change the section description, we could directly change them by:

```s
# Label
--summary-label [LABEL]      Set up custom label for the release summary section. Default is "".
--breaking-label [LABEL]     Set up custom label for the breaking changes section. Default is "**Breaking changes:**".
--enhancement-label [LABEL]  Set up custom label for enhancements section. Default is "**Implemented enhancements:**".
--bugs-label [LABEL]         Set up custom label for bug-fixes section. Default is "**Fixed bugs:**".
--deprecated-label [LABEL]   Set up custom label for the deprecated changes section. Default is "**Deprecated:**".
--removed-label [LABEL]      Set up custom label for the removed changes section. Default is "**Removed:**".
--security-label [LABEL]     Set up custom label for the security changes section. Default is "**Security fixes:**".
--issues-label [LABEL]       Set up custom label for closed-issues section. Default is "**Closed issues:**".
--header-label [LABEL]       Set up custom header label. Default is "# Changelog".
--pr-label [LABEL]           Set up custom label for pull requests section. Default is "**Merged pull requests:**".

# label list
--summary-labels x,y,z       Issues with these labels will be added to a new section, called "Release Summary". The section display only body of issues. Default is 'release-summary,summary'.
--breaking-labels x,y,z      Issues with these labels will be added to a new section, called "Breaking changes". Default is 'backwards-incompatible,breaking'.
--enhancement-labels  x,y,z  Issues with the specified labels will be added to "Implemented enhancements" section. Default is 'enhancement,Enhancement'.
--bug-labels  x,y,z          Issues with the specified labels will be added to "Fixed bugs" section. Default is 'bug,Bug'.
--deprecated-labels x,y,z    Issues with the specified labels will be added to a section called "Deprecated". Default is 'deprecated,Deprecated'.
--removed-labels x,y,z       Issues with the specified labels will be added to a section called "Removed". Default is 'removed,Removed'.
--security-labels x,y,z      Issues with the specified labels will be added to a section called "Security fixes". Default is 'security,Security'.

# Check labels
--include-labels  x,y,z      Of the labeled issues, only include the ones with the specified labels.
--exclude-labels  x,y,z      Issues with the specified labels will be excluded from changelog. Default is 'duplicate,question,invalid,wontfix'.
--issue-line-labels x,y,z    The specified labels will be shown in brackets next to each matching issue. Use "ALL" to show all labels. Default is [].
```

OR we could define the sections by ourself:
```s
# ex: --configure-sections '{"improvement": {"prefix":"Improvements:","labels":"feature","improve"}}'
--configure-sections [Hash, String]
								Define your own set of sections which overrides all default sections.
--add-sections [Hash, String]
								Add new sections but keep the default sections.
```

If we only want to handle the `unrelease` version:

```s
--unreleased-only            Generate log from unreleased closed issues only.
--[no-]unreleased            Add to log unreleased closed issues. Default is true.
--unreleased-label [label]   Set up custom label for unreleased closed issues section. Default is "**Unreleased:**".
--future-release [RELEASE-VERSION]
								Put the unreleased changes in the specified release number.
--release-branch [RELEASE-BRANCH]
								Limit pull requests to the release branch, such as master or release.
```

For adding specific rules:

```s
--[no-]issues                Include closed issues in changelog. Default is true.
--[no-]issues-wo-labels      Include closed issues without labels in changelog. Default is true.
--[no-]pr-wo-labels          Include pull requests without labels in changelog. Default is true.
--[no-]pull-requests         Include pull-requests in changelog. Default is true.
--[no-]filter-by-milestone   Use milestone to detect when issue was resolved. Default is true.
--[no-]author                Add author of pull request at the end. Default is true.
--[no-]compare-link          Include compare link (Full Changelog) between older version and newer version. Default is true.
--simple-list                Create a simple list from issues and pull requests. Default is false.

# Tags
--exclude-tags  x,y,z        Changelog will exclude specified tags
--since-tag  x               Changelog will start after specified tag.
--due-tag  x                 Changelog will end before specified tag.
```

## Troubleshooting

### `Bigdecimal` error

For me, I'm using ruby 2.7.0 in my env, so after I installed `github_changelog_generator` by gem. When I tried to run it, it shows me:

```s
1: from /Users/name/.rbenv/versions/2.7.0/lib/ruby/gems/2.7.0/gems/activesupport-4.2.11.3/lib/active_support/core_ext/object/duplicable.rb:106:in `<top (required)>'
/Users/name/.rbenv/versions/2.7.0/lib/ruby/gems/2.7.0/gems/activesupport-4.2.11.3/lib/active_support/core_ext/object/duplicable.rb:111:in `<class:BigDecimal>': undefined method `new' for BigDecimal:Class (NoMethodError)
```

For fixing this issue, I have to specific install `BigDecimal` by adding ⬇️ in my Gemfile.

```s
gem 'bigdecimal', '1.4.2'
```

Then call it by `bundle exec github_changelog_generator --options`, it will work well now.

#### Reference

- <https://github.com/github-changelog-generator/github-changelog-generator>
