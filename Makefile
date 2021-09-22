build:
	docker build . -t hudi-spark-standalone:local

run: build
	( \
	docker run -u root:root hudi-spark-standalone:local spark-submit --packages org.apache.hudi:hudi-spark3-bundle_2.12:0.9.0 --conf 'spark.serializer=org.apache.spark.serializer.KryoSerializer' job.py --read;\
	docker run -u root:root hudi-spark-standalone:local spark-submit --packages org.apache.hudi:hudi-spark3-bundle_2.12:0.9.0 --conf 'spark.serializer=org.apache.spark.serializer.KryoSerializer' job.py --write;\
	)
