from pyspark.sql import SparkSession
from contextlib import contextmanager
from pyspark.context import SparkContext
import sys


table_name = "foo_table"
database_name = "foo_db"
path = f"/opt/bitnami/spark/dwh/{database_name}/{table_name}"


class Context:
    def __init__(self, session: SparkSession, context: SparkContext):
        self.session = session
        self.context = context


@contextmanager
def spark():
    session = (
        SparkSession.builder.appName("Trying Hudi!")
        .config("spark.serializer", "org.apache.spark.serializer.KryoSerializer")
        .getOrCreate()
    )
    context = session.sparkContext
    try:
        yield Context(session=session, context=context)
    finally:
        session.stop()


def create_df(spark_session, spark_context):
    columns = ["language", "users_count"]
    data = [("Java", "20000"), ("Python", "100000"), ("Scala", "3000")]
    rdd = spark_context.parallelize(data)
    return spark_session.createDataFrame(rdd).toDF(*columns)


def get_hudi_config(table_name, database_name, path):
    return {
        "className": "org.apache.hudi",
        "hoodie.datasource.hive_sync.use_jdbc": "false",
        "hoodie.datasource.write.precombine.field": "language",
        "hoodie.datasource.write.recordkey.field": "users_count",
        "hoodie.datasource.hive_sync.auto_create_database": "true",
        "hoodie.table.name": table_name,
        "hoodie.consistency.check.enabled": "true",
        "hoodie.datasource.hive_sync.enable": "true",
        "hoodie.datasource.hive_sync.database": database_name,
        "hoodie.datasource.hive_sync.table": table_name,
        "hoodie.datasource.hive_sync.mode": "hms",
        "path": path,
        "hoodie.datasource.write.operation": "upsert",
        "hoodie.datasource.hive_sync.partition_fields": "users_count",
        "hoodie.datasource.write.partitionpath.field": "users_count",
        "hoodie.datasource.hive_sync."
        "partition_extractor_class": "org.apache.hudi.hive.MultiPartKeysValueExtractor",
        "hoodie.datasource.write.hive_style_partitioning": "true",
    }


def write_table():
    with spark() as context:
        df = create_df(context.session, context.context)
        config = get_hudi_config(
            table_name=table_name, database_name=database_name, path=path
        )
        # Check if local mode
        print(f"Running mode: {context.context.master}")

        # Persist the data and triggers sync to Hive metastore
        df.write.format("hudi").options(**config).mode("append").save()
        print(f"Persisted dataframe as Hudi table in {path}")


def read_table():
    with spark() as context:
        # List databases to verify that it has been created
        databases = context.session.catalog.listDatabases()
        print(f"Found DBs: {databases}")

        # Get the data
        print("Reading data using Hive metastore")
        context.session.sql(f"USE {database_name}")
        saved_data = context.session.sql(f"SELECT * FROM {table_name}")
        for row in saved_data.collect():
            print(f"Got data: {row.asDict(recursive=True)}")


if "--write" in sys.argv:
    write_table()

if "--read" in sys.argv:
    read_table()
