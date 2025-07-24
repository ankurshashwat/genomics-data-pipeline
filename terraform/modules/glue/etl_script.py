import sys
from awsglue.transforms import *  # type: ignore
from awsglue.utils import getResolvedOptions  # type: ignore
from pyspark.context import SparkContext
from awsglue.context import GlueContext  # type: ignore
from awsglue.job import Job  # type: ignore
from pyspark.sql.functions import col

# Parse job arguments
args = getResolvedOptions(sys.argv, ['JOB_NAME', 'input_path', 'output_path'])

# Initialize contexts
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

# Read the full file line by line
raw_lines = spark.read.text(args['input_path'])

# Remove metadata lines starting with ##
non_meta_lines = raw_lines.filter(~col("value").startswith("##"))

# Extract header line that starts with #CHROM
header_line = (
    non_meta_lines
    .filter(col("value").rlike("^#CHROM\\b"))
    .limit(1)
    .collect()
)

# If header not found, raise error
if not header_line:
    raise ValueError("No valid VCF header line found (e.g. starting with '#CHROM')")

# Parse header
header = header_line[0]['value'].lstrip('#').split('\t')

# Filter out all lines starting with #
data_lines = non_meta_lines.filter(~col("value").startswith("#"))

# Convert each data line to list of fields
data_rdd = data_lines.rdd.map(lambda row: row.value.split('\t')) \
    .filter(lambda cols: len(cols) == len(header))  # Filter malformed rows

# Create DataFrame with proper header
df = spark.createDataFrame(data_rdd, header)

# Debug info
print("Parsed schema:")
df.printSchema()
print("Sample rows:")
df.show(5, truncate=False)

# Required columns
required_columns = ["CHROM", "POS", "REF", "ALT", "QUAL", "sample1", "sample2"]
missing_columns = [col for col in required_columns if col not in df.columns]
if missing_columns:
    raise ValueError(f"Missing required columns: {missing_columns}")

# Transform and cast
transformed_df = df.select(
    df["CHROM"].cast("string"),
    df["POS"].cast("int"),
    df["REF"].cast("string"),
    df["ALT"].cast("string"),
    df["QUAL"].cast("float"),
    df["sample1"].cast("string"),
    df["sample2"].cast("string")
)

# Write output partitioned by CHROM
transformed_df.write.partitionBy("CHROM") \
    .parquet(args['output_path'], mode="overwrite")

# Commit job
job.commit()