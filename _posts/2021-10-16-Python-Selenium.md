---
layout: post
title: Python Selenium
date: 2021-10-16 20:21:00
comment_id: 197
categories: [Web, Python]
tags: [Selenium, WebCrawling]
---

Some memo of use Python Selenium to parse website.

## Driver Service

Use [geckodriver](https://github.com/mozilla/geckodriver) to interact with browsers.

## Sleep

use `time.sleep()` to tell browser to pause thread execution. We might want to give a time delay before load the next page.

## Open the website

use `driver.get(link)`

## Find element

use `find_element(By)` and `find_elements(By)`

## Type to textField

use `send_keys()`

## Perform click action

use `click`

## Get element text or attributes

use `.text` or `.get_attribute()` for an element, ex:

```python
# get text from an element
driver.find_element(By.CLASS_NAME, 'className').text

# get a href from an element
driver.find_element(By.CSS_SELECTOR, 'a').get_attribute('href')
```

## Window handle

use `current_window_handle` to find current handling window if open multi-windows

## Scroll to element

- use `WebDriverWait().until(EC.presence_of_element_located)` to be sure element is located
- use `driver.execute_script("window.scrollTo(0, 1400)")` to set window scroll to
- use `ActionChains()` to connect multiple actions
  - use `actions.move_to_element().perform()` to move to the element

## Navigate back and forward

- use `driver.navigate().to`
- use `driver.navigate().back()`
- use `driver.navigate().forward()`

## Close and Quit

- use `close` to close current window
- use `quit` to quit the driver

## Troubleshooting

### 1. `capabilities` and `executable_path` warning

Switch to use Service can solve the warning. ex:

```python
from selenium.webdriver.firefox import service

firefox_service = service.Service(executable_path="/usr/local/bin/geckodriver")
driver = webdriver.Firefox(service=firefox_service)
```

### 2. `find_element_by_xxx('')` or `find_elements_by_xxx('')` is deprecated

This function can be replaced by using `find_element(By.xxx, '')` and `find_elements(By.xxx, '')`, ex:

```python
from selenium.webdriver.common.by import By

driver.find_elements(By.CLASS_NAME, 'result-cassette__list')
```

#### References

- <https://github.com/SeleniumHQ/Selenium>
- <https://www.selenium.dev/selenium/docs/api/py/api.html>
