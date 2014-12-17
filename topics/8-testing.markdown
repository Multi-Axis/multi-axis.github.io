---
title: Testing
date: 2014-12-12T00:00:00
---
Tester [source code.](https://github.com/Multi-Axis/multi-axis-graphs/blob/master/zab2_integration_test.go)

Tests are run automatically by [Travis](https://travis-ci.org/Multi-Axis/multi-axis-graphs/) when a new commit is pushed to project's github repo.

Testing is implemented by using the standard Go testing facilities to first initialize the testing by building and running zab2.go and connecting it and Habbix to a special test database, which is reset by Travis from a db dump before running the tests, and then sending a bunch of http queries to the server. Tests check if the received data matches the expected values (specified in various test slices [slice = kinda-array in Go]) before and after the test database is updated . Specifically:

* `TestWrongUrl` tests that faulty url:s receive 404 errors.
* `TestItemsFound` checks that various items (currently mem, cpu and swap) are found (http statuscode 200).
* `TestScales` checks that scales used by the front (and dashboard) to scale large numbers are returned properly.
* `TestDashBoard` checks if received dashboard html contains the specified servers or other data (note: see Issues below)
* `TestParams` checks the params field
* `TestThresholds` checks various threshold-related things
* `TestForecast` checks forecast data (also see Issues below)
* `TestModel` checks forecast model matches
* `TestUpdates` sends a POST and some updated values to the test server (like clicking "save" in the front app).
*  various `TestPostUpdateWhatevers` check if relevant fields in the DB are actually being updated by `TestUpdates`... (see Issues)

Configuring test data is simple if a bit cumbersome, since it's basically just copy pasting "good" values from correctly returned data (mostly JSON, some html) to various test slices (slice = kinda-array in go).

If multi-axis database receives some structural upgrades or new models need testing, the database dump the tests use should probably be updated. After that, some test data (certainly forecast data) must be reconfigured by hand, which is of course a pain.

### Important issues

Because of some problems with running Habbix in some systems, currently `TestPostUpdateForecast` and `TestPostUpdateDashboard` *do not actually test anything*. When these issues are resolved, expected post-update forecast data should be updated to the `new` fields of `forecasttests`. Similar changes are necessary in `dashboardtests` struct.
