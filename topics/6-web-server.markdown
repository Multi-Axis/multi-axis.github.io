---
title: Backend server (Gobbix)
date: 2014-12-12T00:00:00
---

This server (written in Go) handles passing data to and from html/javascript [front end](https://github.com/Multi-Axis/multi-axis-graphs/wiki/Server-view-front-end-notes) and dashboard to the [Habbix back end](https://github.com/Multi-Axis/multi-axis-graphs/blob/master/Doc/Habbix.md) and the [multi-axis database](https://github.com/Multi-Axis/multi-axis-graphs/blob/master/Doc/DatabaseAndData.md).

Server [source code.](https://github.com/Multi-Axis/multi-axis-graphs/blob/master/zab2.go)

Using `deploy.sh` to deploy the server is recommended. Compiling  requires [this postgres driver](https://github.com/lib/pq). Server does not start without a `habbix` binary present.

* URL:s ending with `[ip]:8080/dashboard` will lead to dashboard. 
* `[ip]:8080/static/` is used to deliver javascript and css files.
* `[ip]:8080/item/:server/:item` (for example *item/ohtu1/cpu*) leads to specific graphs for items.
* `[ip]:8080/api/:id` (for example *api/1*) is used to deliver JSON files.
* Incorrect URL:s will result in 404 errors.

The server can be configured to connect to a specific (local or piped) database with `-s :server-name`, and ordered to run Habbix (see below) with a specific configuration file with `-h :config-file-name`.

###Interaction with Habbix
The server does most of its thing by directly interacting with the database. However, it calls for Habbix in two cases:
* `habbix sync -i :id` after updating some item's parameters in the DB. This makes Habbix actually update the item-specific forecast.
* `habbix execute` (+stuff) to get forecast data *without* updating the database.
If Habbix execution fails for whatever reason the server logs it and carries on.

###Known issues and whatnot.

* `/dashboard` is used instead of `/` because using the latter occasionally had `itemHandler` to also call for `dashboardHandler` (?!)
* The server is *probably* protected against typical sql injection attacks, but will happily send all kinds of wacky stuff from front end's *"parameters"* field to the forecast models, as long as it is valid JSON, so be warned.
* Some errors are handled elegantly by `log.Fatal(err)`, e.g. server dies on purpose if something goes wrong. This *should* not include any actually common errors. Probably.
