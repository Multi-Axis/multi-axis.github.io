----
title: Getting Started
date: 2014-12-12T00:00:00
----

## Database and habbix

- Create the database (`createdb -O multi-axis multiaxis`)
- Set `localDatabase` and `remoteDatabase` in `config.yaml` (for habbix)
- Run `habbix migratedb`.
- Sync local "meta" (that is, all but history tables) tables from zabbix:
  `habbix sync --syncall`.

The history tables are rather large (over 300k rows *with a single server*), so
it is not wise to sync all of them.

## First prediction unit

Now, the following may sound a bit confusing but please bear with me.  Because
**history is coupled with future**, you will need to define some means to
predict the future before syncing the history.  That is, some
("future-predicting!") executable(s) in `$PWD/forecast_models`. For now you may
want to copy or link the `linreg` binary from habbix:
        
     mkdir future_models
     cd future_models
     ln -s ~/.cabal/bin/linreg .

Then register it in the database: `habbix configure -e linreg`.  Refer to section
"Predictions" for more info on models.

Now you can register some items in the database. To see what items have any
history, you can e.g. do something like this on the **remote zabbix db** psql:

    zabbix=> select distinct itemid from history;
    zabbix=> select distinct itemid from history_uint;

You need to know the itemid you want to add. For example's sake let's have a
fictional items.itemid = 20000 and configure a prediction for it with the model
with modelid = 1:

    habbix configure -i 20000 -m 1

(Tip: List all models with `habbix models`.)

## Data synchronization with habbix

Now you can synchronize the history from the remote db and predict the future:

    habbix sync

That syncs only histories and futures; if you have added new hosts, you will
need to run habbix `sync --syncall` first.

## Web server

In a nutshell: run `go run zab2.go` at the root of the multi-axis-graphs repo.
You probably need to change db connection settings inside the go file to reflect
those in config.yaml.

### Optimizations

DB indices; increases dashboard performance manyfold.

    create index history_idx on history (itemid, clock);
    create index trend_idx on trend (itemid, clock);
    alter table trend drop column id;
    alter table history drop column id;
