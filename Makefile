build:
	docker build . -t hudi-spark-standalone:local --progress plain

# Submits two spark jobs:
#  - First job writes data to foo_db.foo_table
#  - Second job reads data from foo_db.foo_table and outputs to standard out
run: build
	( \
	docker run -u root:root hudi-spark-standalone:local /bin/bash -c "spark-submit --packages org.apache.hudi:hudi-spark3-bundle_2.12:0.9.0,org.apache.derby:derbyclient:10.12.1.1 --conf 'spark.serializer=org.apache.spark.serializer.KryoSerializer' job.py --write && spark-submit --packages org.apache.hudi:hudi-spark3-bundle_2.12:0.9.0 --conf 'spark.serializer=org.apache.spark.serializer.KryoSerializer' job.py --read";\
	)

# This will write using one session, then tear it down and create a new session to read the table
run_fail_1: build
	( \
	docker run -u root:root hudi-spark-standalone:local /bin/bash -c "spark-submit --packages org.apache.hudi:hudi-spark3-bundle_2.12:0.9.0,org.apache.derby:derbyclient:10.12.1.1 --conf 'spark.serializer=org.apache.spark.serializer.KryoSerializer' job.py --write --read";\
	)

# This version till read/write using the same spark session
run_fail_2: build
	( \
	docker run -u root:root hudi-spark-standalone:local /bin/bash -c "spark-submit --packages org.apache.hudi:hudi-spark3-bundle_2.12:0.9.0,org.apache.derby:derbyclient:10.12.1.1 --conf 'spark.serializer=org.apache.spark.serializer.KryoSerializer' job.py --write-read";\
	)


shell: build
	docker run -u root:root -it hudi-spark-standalone:local /bin/bash
