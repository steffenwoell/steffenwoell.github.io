---
layout: post
title: Test markdown
subtitle: Each post also has a subtitle
---

You can write regular [markdown](https://www.markdowntutorial.com/) here.

**Bold text**

## Here is a secondary heading

A useless table:

| Number | Next number | Previous number |
| :------ |:--- | :--- |
| Five | Six | Four |
| Ten | Eleven | Nine |
| Seven | Eight | Six |
| Two | Three | One |

A code chunk:

~~~
var foo = function(x) {
  return(x + 5);
}
foo(3)
~~~

The same code with syntax highlighting:

```javascript
var foo = function(x) {
  return(x + 5);
}
foo(3)
```

The same code yet again but with line numbers:

{% highlight javascript linenos %}
var foo = function(x) {
  return(x + 5);
}
foo(3)
{% endhighlight %}

## Boxes
Add notification, warning and error boxes like this:

### Notification

{: .box-note}
**Note:** This is a notification box.

### Warning

{: .box-warning}
**Warning:** This is a warning box.

### Error

{: .box-error}
**Error:** This is an error box.
