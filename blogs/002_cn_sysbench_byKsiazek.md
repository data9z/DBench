## SysBench: 简洁带来的“先进性” 

SysBench相对数据库老牌性能测试标准TPC要简单许多，也年轻约10年。然而它很快被开源数据库社区接受，被互联网公司用来作为基础（虽然不全面）标准测试。更重要的是，被云厂商青睐。

* 阿里云：

    * [PolarDB X Sysbench test, 2023-12-29](https://www.alibabacloud.com/help/en/polardb/polardb-for-xscale/sysbench-test)
    * [性能测试指导, 2023-08-24](https://www.alibabacloud.com/help/zh/rds/support/test-guidelines)    
    * [Testing I/O Performance with Sysbench,2019-04-18](https://www.alibabacloud.com/blog/testing-io-performance-with-sysbench_594709)

* 腾讯云：
    * [TDSQL PostgreSQL 版 Sysbench 测试说明，2022-09-02](https://cloud.tencent.com/document/product/1129/51752)

    * [云数据库 MySQL 白皮书(测试工具-SysBench 工具介绍),2022-03-24](https://www.tencentcloud.com/zh/pdf/document/236/35061)

* 华为云：
    * [Sysbench_分布式数据库中间件DDM_性能白皮书 - 华为云,2022-06-30](https://support.huaweicloud.com/intl/zh-cn/pwp-ddm/ddm_02_0001.html)
    * [测试方法_云数据库RDS - 性能白皮书 - 华为云, 2022-12-05](https://support.huaweicloud.com/pwp-rds/rds_swp_mysql_01.html)

---

那么为什么简单反而好呢？当时商业数据库如Oracle, DB2, SQL Server功能已经比较完善，它们可以比较轻松的通过TPC的严苛的要求。当然TPC本身也是为了商业数据库设计的。尤其明显是AP相关的TPC-H(22个查询)和TPC-DS（99个），大部分开源数据库(MySQL，PG）和大数据分析性引擎（如Spark, Hive, Impala)在云和云数据库刚刚兴起的时代（2010～2015）是运行成功率只有不到50%的。TP类的TPC-C和TPC-E可以运行在标准关系数据库上运行（MySQL和PG），但脱离TPC的运行/审计标准很远，也就失去其意义。

相关讨论比较多，我们这里借Krzysztof Ksiazek在2018发布的Blog[《How to Benchmark Performance of MySQL & MariaDB Using SysBench》](
https://severalnines.com/blog/how-benchmark-performance-mysql-mariadb-using-sysbench/)中的部分内容来诠释。如下为翻译内容，错误和不准确之处，请指正批评。

“
SysBench 流行的主要原因是它使用简单。没有先验知识的人可以在几分钟内开始使用它。默认情况下，它还提供涵盖大多数情况的基准测试 - OLTP 工作负载、只读或读写、主键查找和主键更新。所有这些都导致了 MySQL（直到 MySQL 8.0）的大部分问题。这也是 SysBench 在互联网上发布的不同基准测试和比较中如此受欢迎的原因。这些帖子帮助推广了这个工具，并使其成为 MySQL 的首选综合基准。

SysBench 的另一个好处是，从 0.5 版本开始并引入 LUA，任何人都可以准备任何类型的基准测试。我们已经提到了类似 TPCC 的基准([TPCC-like benchmark](https://github.com/Percona-Lab/sysbench-tpcc))，但任何人都可以制作一些类似于她的生产工作负载的东西。我们并不是说这很简单，这很可能是一个耗时的过程，但如果您需要准备自定义基准，那么拥有这种能力是有益的。

作为一个综合基准测试，SysBench 不是一个可用于调整 MySQL 服务器配置的工具（除非您使用自定义工作负载准备了 LUA 脚本，或者您的工作负载恰好与 SysBench 附带的基准测试工作负载非常相似）。它的伟大之处在于比较不同硬件的性能。您可以轻松比较**云提供商**提供的不同类型节点的性能以及它们提供的最大 QPS（每秒查询数）。了解该指标并了解您为给定节点支付的费用，您就可以计算更重要的指标 – QP$（每美元查询数）[^1]。这将使您能够确定在构建经济高效的环境时要使用的节点类型。当然，SysBench 也可用于初始调整和评估给定设计的可行性。假设我们建立了一个横跨全球（北美、欧盟、亚洲）的 Galera 集群。这样的设置每秒可以处理多少次插入？提交延迟是多少？进行概念验证是否有意义，或者网络延迟可能足够高，以至于即使是简单的工作负载也无法按您的预期工作。

压力测试呢？并不是每个人都迁移到云端，仍然有一些公司更愿意构建自己的基础设施。购买的每台新服务器都应该经历一个预热期，在此期间您将对其进行压力以查明潜在的硬件缺陷。在这种情况下，SysBench 也可以提供帮助。您可以通过执行使服务器超载的 OLTP 工作负载，也可以使用针对 CPU、磁盘和内存的专用基准测试。
”

[^1]: 译者按，NineData的DBench也采用了这个观点。不过因为是OLTP场景，关注到TPS/$ 而不是QPS。
