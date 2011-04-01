xCache
============

Rails cache helper. Binds to models, invalidates on object update and helps vith etag cacheing

Models would idealy have updated_at field. If they have it, update invalidates cache, automaticly.

If there is no updated_at fields invalidate with calling @object.xcache


Example
=======

Examples say it all

Full HAML example, view
=================
	- xcache @product do
		foo

	- xcache @product :list_item do
		foo

In controller for cache invalidation
====================================
@product.xcache # clears cache for object


In controller for fresh_when helper
===================================
return if xcache @product, @user, @foo, ....

Send list of objects. plugin finds last updated time, checks browser cache time and serves from browser cache unless modfied
http://www.checkupdown.com/status/E304.html


How many functions I have to remember? Just 1, there is one function "xcache" to dominate all usage
- in template replaces cache tag
- as model instance method, clears model cache
- as controller method helps with rails fresh_when method


Copyright (c) 2011 [Dino Reic (dux)], released under the MIT license
http://twitter.com/dux

