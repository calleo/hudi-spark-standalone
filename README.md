# Hudi Demo using Spark Standalone

Example that creates a dataframe and writes as Hudi table. Metadata is synced with a 
local Hive Metastore.

**Requires:** Make & Docker

### make run

Submits two separate jobs:

- First jobs writes data and sync it to the metastore
- Second jobs reads the data using Spark SQL

### make run_fail_1

This will try to submit one Spark job that first writes some data, syncs it to the 
metastore and then reads the data using Spark SQL. Before reading a new Spark session
will be created.

### make run_fail_2

This will try to submit one Spark job that first writes some data, syncs it to the 
metastore and then reads the data using Spark SQL. Both steps are performed using the
same Spark session.
