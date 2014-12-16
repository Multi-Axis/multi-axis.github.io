---
title: Java prediction unit
date: 2014-12-12T00:00:00
---

[Javadoc for the java prediction unit.](http://multi-axis.github.io/javaunit/apidocs) This also includes the apidocs for the functionaljava library since at the time of this writing the version numbers for the current stable library don't match with those of the apidocs hosted upstream.

The `leastSquares` process that can be invoked as an argument to `ForecastProcess.main` takes one optional paramater, `pre_filter`:

    "pre_filter" : "DailyMin" | "DailyMax" | "DailyAvg"
