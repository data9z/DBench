# DBench

**Price/Performance Benchmark for Cloud Database**


<a href="https://benchmark.ninedata.cloud/">Dashboard</a> • <a href="https://github.com/data9z/DBench"> Repo</a> • <a href="https://github.com/data9z/DBench/docs/faq.md"> FAQ</a> • <a href="https://github.com/data9z/DBench/docs/">Documentation</a> •

DBench is a regularly updated benchmark service focusing on the cost and performance perspective of cloud databases. 

> My (cloud-based) PostgreSQL/MySQL is better than others. 

This is a typical sales pitch without much supporting data. 

Thirty years ago, one might have needed to call up a travel agent to find a reasonable(hopefully the best price) flight from New York to San Francisco. Now, 'google flights' offers a better method within 10 seconds. 
On the other hand, despite claims cutting-edge technology, the industry' method of selecting the right cloud database is far behind. 
This is because all the cloud providers build and bill differently. Wouldn't an DevOP professional's life be easier if we could shop for databases like air tickets on 'google flights', and by the way, there's no need to limit ourselves to US-based Airlines. 


## Key features  

* Popular database systems running on cloud as managed-service, currently includes MySQL and PostgreSQL. 
* Major cloud providers worldwide, currently includes Alibaba Cloud, AWS, GCP, Huawei Cloud, and Tencent Cloud, with major regions in China, US, Japan and Singapore. 
* Utilize Terraform to provision cloud resource such as virtual machine(Linux), cloud database, with default configurations. 
* Utilize existing benchmark(s) to quantify and qualify the performance of the above services, which often called RDS.
* BI analysis and visualized dashboard of price/performance


## Reproducibility

We put our best effort to automate the whole benchmark system. With the terraform code and benchmark scripts, one can quickly spin up the test in 10~20 minutes. Each test will typically run one hour to obtain stable results. 

For users who like to examine the past results or further analyze the data, the raw data is available in the raw data folder of this repo. 

Please ref to <a href="https://github.com/data9z/DBench/docs/quickstart.md"> quickstart </a> for the simple steps. 

## Limitation

Same as any benchmark of any scenario, the simulation is not equal to real life result. Currently, DBench is using  <a href="https://en.wikipedia.org/wiki/Sysbench">sysbench</a> , an open-source tool and its OLTP testcase. This is a relatively simple one comparing to the ones from Transaction Processing Performance Council (TPC). 

Sysbench carries two unique benefits leading DBench to start with it. First, simple mechanism makes the test doable and repeatable. A 30~60minutes run of sysbench can produce reasonable indicators of throughput and latency on a cloud-managed database. This match the goal of DBench: comparing hundreds of RDS configurations on various cloud providers and many regions globally. TPC-C will require sophistical planning with a "stiff" cost, through <a href=https://benchmarksql.readthedocs.io/en/latest/>benchmarksql</a> helps a bit. Second, TPC was well-designed but before Cloud-era and not exactly reflect the new internet era. The cloud managed database simplified the administration effort and DevOps shift many programming logic out of Database engine(such as stored procedure, user-defined function, trigger) to middleware or application. This shift makes simpler database usage (sysbench) popular amongst high tech companies, such as Airbnb or Meta/Facebook.

To be clear, the benchmarks from TPC still carry their merits and DBench still lacks OLAP/HTAP scenarios. DBench should address them. Contributions and collaborations are welcome and highly appreciated. 
