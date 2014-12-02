# Habbix

## Configuration

Copy the file `config.default.yaml` to `./config.yaml` and edit the parameters
in it.

We require access to two databases, our own "local" database and the zabbix,
"remote", database **Make sure both databases are reachable.** Although most
commands use only the local db. The only exceptions are `sync` (both) and
`trend` (remote only) commands.

### Crontab

```crontab

# Sync only trends and history
*/5 * * * * sh -c 'cd /home/ohtu && .cabal/bin/habbix sync -q'

# Sync new hosts too, and add them a default future
*/30 * * * * sh -c 'cd /home/ohtu && .cabal/bin/habbix sync --syncall -q'
```

## Usage

Running `habbix --help`:

    habbix [COMMAND] ... [OPTIONS]
    
    Commands:
      hosts      List all hosts and groups except templates
      apps       List available "metric groups" for the Host ID
      items      List available "metrics" in the metric group App ID>
      history    Print history data for <itemid>
      trends     Print trend data for the REMOTE item
      future     List all item futures
      models     List available future models
      migratedb  Create or update the local DB schema
      sync       Synchronize remote db with local and run futures
      configure  Configure the predictions in database
      execute    Execute item_future.ID but only output the results, instead of
                 modifying database
      compare    Compare predictions from knowing A to an actual history B
    
    Common flags:
      -c --config=FILE       yaml config file (default: ./config.yaml)
      -h --human --outhuman  Human-readable JSON output
      -j --json --outjson    Bare JSON output
      -? --help              Display help message
      -V --version           Print version information
      -v --verbose           Loud verbosity
      -q --quiet             Quiet verbosity

Habbix subcommands can be broken up into categories:

- Modify the database (`migratedb sync configure`)
- Just fetch info from database (`hosts apps items history future models`)
- Forecasting (does *not* modify the db in any way) (`execute compare`)

Run `habbix subcommand --help` to see additional parameters.

STDOUT is always json and by default formatted human-readable (`--human`). You
can output bare json without newlines with (`--json`).

### `habbix migratedb`

Creates the local database schema. (Or migrates if it exists already)

### `habbix sync`

Populate or update local db with data from remote db: `habbix sync`.

Update the future of a specific item_future.id: `habbix sync -i 2`.

Careful with the populate/update outputs when running with --`verbose`! There
is a lot of sql debug msgs.

### `habbix trend`

This command uses the **remote** database and outputs an sql transaction that
can be used to insert a data set into some other table. It outputs the
transaction to stdout. Example:

```shell
$ habbix trends 23687 \       # replace number with an items.itemid in zabbix db
     --sql \                  # required. output as a transaction
     --config myconfig.yaml \ # optional. set some other config that ./config.yaml
     --asitem 1 --ashost 1    # required. itemid and hostid used in the output (only)
BEGIN;
INSERT INTO hosts VALUES (1, 'ohtu1', 0, 1, 'ohtu1');
INSERT INTO items VALUES (1, 0, 1, 'CPU $2 time', 'system.cpu.util[,idle]', 'The time the CPU has spent doing nothing.', '0');
INSERT INTO trend VALUES 
   (1, 1410501600, 94.0244, 98.8033, 99.2991),
   (1, 1410505200, 98.8481, 99.0174, 99.1656),
   (1, 1410508800, 98.7310, 99.0362, 99.2322),
   ...
COMMIT;
```

You can pipe the output straight to `psql` or to a file first.

## Futures

History synchronization is done for items present in the `item_future` table.
You need to add items to this table yourself. Note that we couple history with
future: when adding an `item` to be synced, you must specify a future prediction
model for it.

Available prediction models are stored in `future_model` table.
`future_model.name` describes a binary in
`$PWD/forecast_models/$future_model.name`, that gets executed every time a
synchronization is done. The prediction program is fed a `Event` JSON object in
its standard input, and a `Result` JSON object is expected as standard output.

## Static linking?

Very tricky, because haskell package `postgresql-libpq` requires `pq` library
which requires `krb5` library, and linking (recentish) `krb5` statically is
unsupported and won't work.

