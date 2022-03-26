---
layout: post
title: AmazonJP Books Parser
date: 2020-07-11 20:35:00
comment_id: 89
categories: [Web]
tags: [Selenium, MongoDB]
---

Sometimes, when we finished read one book, we might want to find some similar books we might interested in for later reading. So, for achieving this, I would like to auto-parse some Amazon JP Books data for analzing the relationships between books.

For Amazon JP books part, they provide the detail book information, such as, title, author, publisher, ISBN-10, iSBN- 13, editor reviews, person who read this book also reads, etc.

We all know if we just manually collect these information it would take so much time, for one book, if you would like to collect these information, you might take at least 2 minutes. So, could you auto-parsing these book information? The answer is YES! And this article is about how to use Python to achieve our parsing goal.

## Selenium

In python, there is a library called `selenium`, which contains some webdrivers and you could call the drivers to auto-running the browser and let it collect the information you want.

### webdriver

`selenium` is really a useful tool, it contains many drivers, ex: Chrome, Firefox, etc. For setting the driver, you could write it as:

```python
from selenium import webdriver

# this geckodriver here is `FireFox` browser
driver = webdriver.Firefox(capabilities=cap, executable_path='Your driver path ex:geckodriver')
```

### find_element

Normally, if we want to parse an element in the HTML, if you could successfully find the element class, id, or xpath, you could use `find_element_by_xpath`, `find_elements_by_class_name`, etc. `selenium` provide lots of find element method, you could find all of them at: <https://selenium-python.readthedocs.io/locating-elements.html>

Here is an example:

```python
def _parseISBN13(self, driver):
	try:
		return driver.find_element_by_xpath('//*[@id="detail_bullets_id"]/table/tbody/tr/td/div/ul/li[5]').text.split(':', 1)[1].strip().replace('-', '')
	except Exception as e:
		print("Parsing Book ISBN-13 Failed: ", self.link, e)
		return ""
```

**Note: When we use `xpath` to find an element, for Amazon JP site, sometimes the same element in different book page have different xpath. It would happen in some places, if you are using xpath, please be careful 😜**

### Some Tricky

It would be easier to only simple get the elements the site already showing, but for some case(ex: people who read this book might also reads), if we would like to get whole list, we need to click `>` to change to show next page book information.

This `click` could also be done by `selenium`, if the session could be visible when you first open the page **without scroll**. We could simple only trigger the `click` by:

```python
next_btn = driver.find_element_by_xpath('//*[@id="a-autoid-12"]')
next_btn.click()
```

Then it would be fine. But, sometimes, the button might not directly visible, it might need to be shown by scrolling page. If we didn't scroll page to show the element, the button click action might not be triggered successfully, which means you might only be able to get the first page information only.

For avoiding this, we'd better to set to scrolling the page to specific position for showing the button element first, then click the button. Here is the code:

```python
last_height = driver.execute_script("return document.body.scrollHeight")
# We might need to change this scrollTo value to some proper places, please test in your browser
driver.execute_script("window.scrollTo(0, 1400);")

headereElement = driver.find_element_by_xpath('//*[@id="a-autoid-12"]')
actions = ActionChains(driver)
actions.move_to_element(headereElement).perform()
next_btn = driver.find_element_by_xpath('//*[@id="a-autoid-12"]')
next_btn.click()
```

### driver running effect

![similarBook](/images/2020-07-11-AmazonJP-Books-Parser/similarBook.gif)

## MongoDB/PyMongo

After collecting data, we could save it to mongoDB. We could use `pymongo` to help connecting to the MongoDB database. Here is code:

```python
def _save_to_mongoDB(id):
    print("** Start Saving: ", id)
    myclient = pymongo.MongoClient("mongodb://10.231.184.114:27017/")
    mydb = myclient["book"]
    mycol = mydb["book"]

    myquery = { "_id": id }

    try:
        with open(f'./books/{id}.json', 'r', encoding='utf8') as f:
            data = json.load(f)
    except Exception as e:
        print("Saving Failed: ", e)
        return

    _newValues = {
         "_id": data["ISBN-13"],
         "title": data["title"],
         "publisher": data["publisher"],
         "writer": data["writer"],
         "editorialReviews": data["editorialReviews"],
         "ISBN-10": data["ISBN-10"],
         "category": data["category"],
         "rate": data["rate"],
         "reviewedPerson": data["reviewedPerson"],
         "similarBookList": data["similarBookList"],
         "tags": data["tags"],
         "author_intro": data["author-intro"]
        }

    try:
        mycol.insert_one(_newValues)
    except Exception as e:
        newValues = { "$set": _newValues }
        mycol.update_one(myquery, newValues)
    print("** Finish Saving: ", id)
```

If you would like to collect more books data from different site, such as: Honto, etc. You might need to checking, and do some data filtering & joining.

## Next

After saving & processing data, we could put it to some private server with some api-s, and create an App to call api to get the book lists you want. We will talk this in next article.

## Project Link

You could check the whole code at: <https://github.com/HevaWu/AmazonJPBookParser>
