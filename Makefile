build:
	docker build . -t hudi-spark-standalone:local

# Submits two spark jobs:
#  - First job writes data to foo_db.foo_table
#  - Second job reads data from foo_db.foo_table and outputs to standard out
run: build
	( \
	docker run -u root:root hudi-spark-standalone:local /bin/bash -c "spark-submit --packages org.apache.hudi:hudi-spark3-bundle_2.12:0.9.0 --conf 'spark.serializer=org.apache.spark.serializer.KryoSerializer' job.py";\
	)
