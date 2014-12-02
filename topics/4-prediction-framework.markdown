## Prediction Framework

A **prediction unit**, or a **forecast unit**, refers to an executable, say
`my_regression_model.sh`, that must be named
`$PWD/future_models/my_regression_model.sh`, where $PWD is the working directory
where `habbix` is run.

### Input

These units are invoked by `habbix sync`. In stdin, the unit receives a JSON
object (dubbed as an *Event*):

    { "value_type" : 0               // items.value_type (usually 0 or 3)
    , "clocks" : [<epochs>]          // list of epoch times (x values)
    , "values" : [<values>]          // y values
    , "last"   : [<epoch>,<value>]   // (time, value) of last tick in history
    , "draw_future" : [<epochs>]     // bounds within which to extrapolate future with model
    , "params" : { ... }             // Extra parameters, forecast-unit specific
    }

Additionally, the name of the model is passed as the first command line
parameter.

### Output

In exchange, another JSON object (dubbed *Result*) is expected in the stdout:

    { "clocks"  : [<epochs>]         // Extrapolated clock-value pairs
    , "values"  : [...]
    , "details" : {<obj>}            // Forecast-specific details (R^2 etc.), Format is free
    }

These `(clocks, values)` are inserted to the future of the original item.

`clocks` is a list of epoch timestamps (numbers). `values` are also numbers
(unsigned integers if `value_type == 3`, decimals with a precision of 4
(.1234) if `value_type == 0`).

stderr is ignored.

## Add predictions to habbix

`habbix configure -e <file>` registers the file `future_models/<file>` as a
prediction unit and assigns it a model id.

`habbix models` lists all registered models.

`habbix configure -i itemid -m <model>` 

`habbix sync --syncall` adds default item_futures to every item that does not
have any with some rndm modelid taken from the model table (after syncing other
zabbix tables to local db). Obviously adding the futures fails if no model had
been registered. (the tables are copied though).

## Run predictions

`habbix execute -p '{...}' <n>`
