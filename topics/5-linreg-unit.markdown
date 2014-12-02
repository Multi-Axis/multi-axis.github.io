---
title: Linreg Prediction Unit
date: 2014-12-12T00:00:00
---

The `linreg` unit takes one optional paramater, `pre_filter`:

    "pre_filter" :
         { "aggregate":      "min" | "max" | "avg"
         , "interval":       Number
         , "interval_start": Number 
         }

If this parameter is present then the input data is filtered.

`interval` and `interval_start` are in seconds; `interval` marks the length of
the interval the filter `aggragate` function is applied to. So to filter maximum
values for every hour you'd say `aggregate = "max"` and `interval = 3600`.

`interval_start` specifies interval start *boundaries*. In other words, it is
an offset added to every epoch value before determining the interval it belongs
to. So if for example `interval_start = 0` and `interval = 86400` (a day) then
the timeframe 00:00 - 23:59 (*UTC!*) form one interval; the boundaries are every
midnight (UTC).

To have filter boundaries eg. every day at 6:00 EEST (UTC+03:00), that is, 3:00
UTC, you would have `interval_start = -10800` and `interval = 86400`.
(`3 * 3600 = 10800`). Note that `interval_start` is negative, as it is an offset
*forward* in the original data values to match boundaries.

(Sidenote: `interval_start` := `interval_start` modulo `interval`)

The full filter example:
   
    "pre_filter" :
         { "aggregate":       "min"
         , "interval":        86400
         , "interval_start": -10800 
         }

If, either the first or last interval is *incomplete* that interval is discarded
when doing predictions. An incomplete interval here means that there it has a
subinterval at least half the length of the original that has no data points in
it.
