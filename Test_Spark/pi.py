from pyspark.sql import SparkSession
from pyspark.sql.functions import col
from depstest import return_data, return_columns
import findspark

findspark.find()

if __name__ == "__main__":
    """
        Usage: pi [partitions]
    """
    spark = SparkSession.builder \
            .appName("In-Memory Pyspark Example") \
            .getOrCreate()

    try:
        data = return_data()
        columns = return_columns()
        df = spark.createDataFrame(data,columns=columns)
        df.show()

        filtered_df = df.filter(col("age") > 30)
        selected_df = filtered_df.select("name","age")
        selected_df.show()
    finally:
        spark.stop()
