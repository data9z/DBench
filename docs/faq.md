## Benchmark Cloud Database (DBench) 云数据库性价比排行榜 FAQ 


### What is the goal of Benchmark Cloud Database (DBench)， 什么是云数据库性价比排行榜?

Benchmark Cloud Database(DBench) provides objective benchmarks and subjective information to developers, cloud customers, and other users to make informed decisions in choosing cloud databases on popular cloud platforms globally. Benchmark Cloud Database(DBench) 为开发者、云服务客户和其他用户提供客观基准测试和主观信息，以帮助他们在全球流行的云平台上选择云数据库时做出明智的决策。

NineData, as a company providing data management service on multi-cloud, regularly receives inquiry from customers about which cloud provider to host their mission critical databases. On one hand, the industrial standardized RDS satisfies roughly 80~90% of such customers; another hand, there are so many variations, from hardware, physical location, Cloud providers, price promotion/adjustments, that confusing everyone, even experts. Therefore, NineData decides to setup the framework, and provide the report from the cost-effectiveness perspective. NineData 作为一家在多云环境下提供数据管理服务的公司，经常收到客户关于选择哪个云提供商来托管其关键任务数据库的询问。一方面，行业标准的 RDS 大约满足了这些客户中的 80%~90% 的需求；另一方面，从硬件、物理位置、云提供商到价格促销/调整等方面都有许多变化，这使得包括数据库专家的每个人都感到困惑。因此，NineData 决定建立一个框架，并从成本效益的角度提供报告。

The DBench serves the cloud database price-performance information, just like the "google flight" or Ctrip for users to compare the air tickets from point A to point B. DBench 提供云数据库的价格性能信息，就像 google flight或携程一样，让用户能够比较从地点A到地点B的机票价格。


### Who can benefit from DBench? 谁能受益

A user who needs to choose cloud managed database on the right host. 需要选择云托管数据库的用户。


### What methodology DBench use? DBench 使用的方法

The DBench server leverages IaC (Terraform, REST API, etc.) for cloud resource provision with simple architecture of one VM and one enterprise-level DBMS on multiple cloud(currently, 5) and multiple geo-location(currently, 10+).  DBench 服务器利用基础设施即代码（Infrastructure as Code，简称IaC），例如 Terraform 和 REST API，来进行云资源的配置，拥有一个简单的架构，即在多个云平台（目前有5个）和多个地理位置（目前超过10个）上，每个位置部署一个虚拟机（VM）和一个企业级数据库管理系统（DBMS）。这种设置允许 DBench 测试和比较不同云平台和地理位置上的数据库性能和成本效益，为用户提供精确的数据支持他们做出决策。使用 IaC 方法可以确保环境的一致性和可重复性，简化了资源的部署和管理过程。

A industrial standard benchmark is performed with difference level of concurrency, and its productivity information, such as throughput and latency is collected. 执行工业标准的基准测试，包含不同的并发级别，并收集了其生产力信息，如吞吐量和延迟。

Supported by performance metrics, the report provides two key scores: the sweat spot of productivity, measured by throughput and latency, scaled by concurrency of each RDS each region; the price/cost ratio comparison across RDS of different cloud providers and regions. 报告依托性能指标，提供了两个关键评分：生产力的最佳点，通过各个区域的每个 RDS 的并发性来衡量吞吐量和延迟；不同云提供商和区域的 RDS 之间的价格/成本比较。

The benchmark(s) will be run regularly to capture the latest information, and to demonstrate the historical trend. 
基准测试将定期运行，以捕获最新信息并展示历史趋势。


### What assumptions DBench take? DBench采用的假设

* Database systems have matured. For example, the free/open sourced RDBMS, MySQL and PostgreSQL can satisfy majority of small-middle tier customers 数据库系统已经成熟。例如，免费/开源的关系数据库管理系统（RDBMS），如 MySQL 和 PostgreSQL，可以满足大多数中小型客户的需求。
* In cloud-era, OS and DBMS become standard parts. RDS(Relational Database Services) of each provider is built on top of the same code base of open source projects. For Database architecture perspective, the differentiators are minimal. This statement does not apply to proprietary DBMS. 在云计算时代，操作系统（OS）和数据库管理系统（DBMS）已成为标准部件。各个提供商的关系型数据库服务（RDS）都是建立在开源项目相同代码库的基础之上的。从数据库架构的角度看，差异化因素很小。（注意：这一说法不适用于专门定制的数据库管理系统）
* Customers of cloud database expect to the default setting as optimized one. If fine-tuning is required, the customers would choose to setup the database system themselves instead of paying a premium for an otherwise free database.  
云数据库的客户期望默认设置是经过优化的。如果需要准确细致的调优，客户会选择自己搭建数据库系统，而不是为本来就是免费的数据库支付额外费用。RDS也就没有出现的必要。
	
### Which benchmarks DBench use?	DBench采取哪些标准测试
	
In the initial stage, the DBench will focus  on OLTP workload: Sysbench (https://en.wikipedia.org/wiki/Sysbench). 在初始阶段，采用sysbench的OLTP案例 

TPC-C (https://tpc.org/） and  customized benchmark  are under development)。 TPC-C 和自定义基准测试正在开发中。

### Which cloud providers Benchmark Cloud Database (DBench) test? DBench支持哪些云厂商？

Currently, we support the following providers: AWS, Alibaba, GCP, Huawei, Tencent. DBench现在支持亚马逊，阿里，谷歌，华为，腾讯。


Please note that DBench may expand or change the list of cloud providers it tests over time to reflect changes in market trends and user needs. 请注意，DBench 可能会随时间扩展或更改其测试的云提供商列表，以反映市场趋势和用户需求的变化。

	
### Which database configurations does DBench choose? DBench 选择哪些数据库配置？





**Default** configuration with the following "ideas". 默认配置包括以下“理念”。

The project is currently in primary stage. It evaluates two open source Database: PostgreSQL and MySQL(initial released on March 20, 2024， Spring equinox 春分) with target configuration to satisfy small-med enterprise customers, typically (not dedicated) RDS instance with 4vCPU16GB or 8vCPUC32GB. 该项目目前处于初级阶段。它评估了两个开源数据库：PostgreSQL 和 MySQL（初始发布于2024年3月20日，春分）, 目标配置是满足中小型企业客户的需求，通常是4vCPU16GB或8vCPU32GB的（非专有）RDS实例。

As the assumptions discussed above, no tuning is performed except for matching hardware resource (CPU, memory, IO, network) so that no obvious bottleneck. For example, AWS charges IOPS separately, which may inadvertently lead inadequate IO resource.  根据上述假设，除了匹配硬件资源（CPU、内存、IO、网络）以避免明显的瓶颈外，不进行任何调整。例如，AWS 单独收取 IOPS 费用，这可能无意中导致 IO 资源不足。

Another constrain is the cost, which is almost among the top consideration of CIOs. The annual cost of the RDS will be kept within $8K ~ $15K. 另一个限制因素是成本，这几乎是首席信息官（CIOs）最关心的考虑因素之一。项目的初级阶段，将控制RDS的年度成本在8000美元到15000美元之间。


### How to understand the report? 如何理解此报告


The report shows output(in term of TPS, transaction per second), ROI (TPS/month-cost) under full productivity situation according the latency and resource usage. In layman's term, within a fix (range) of budget, how much horsepower from a RDS instance one can purchase on each Cloud. 报告根据延迟和资源使用情况，在全速生产力状况下显示输出（以每秒事务数，TPS，为单位）和投资回报率（ROI，即TPS/月成本）。简单来说，就是在固定（范围内）的预算下，可以在每个云平台上购买的RDS实例的产出。








### Can I repeat the benchmark analysis, are you open source? 我可以重复基准分析吗？你们是开源的吗？



YES. https://github.com/data9z/DBench

Although DBench does not cover all variants, the methodology, documents and most importantly, the scripts with instruction can be found at GitHub with Apache 2.0. 
是的。尽管 DBench 没有涵盖所有变体，但方法论、文档以及带有说明的脚本可以在 https://github.com/data9z/DBench 公开，并且采用的开放类许可证 Apache 2.0。

To develop a customized benchmark to march a particular workload, please contact us at support@ninedata.cloud.  要开发一个定制的基准测试以匹配特定的工作负载，请通过 support@ninedata.cloud 与我们联系。



### What's the limitation of the current stage of the DBench project? DBench项目的局限性

First of all, the initial release(as of March, 2024) is rudimentary, please take it with a grain of salt, and performance tuning is an Art. Due to the virtually unlimited variables, DBench strives to provide a **reasonable** choice of cloud database from price-performance perspective, but not necessarily the perfect choice. 首先，最初的版本（截至2024年3月）是基础的，请抱着怀疑的态度看待，而性能调优是一门艺术。由于变量几乎无限，DBench 努力从价格性能的角度提供一个**合理**的云数据库选择，但不一定是完美的选择。

Currently, DBench is limited to `sysbench`, with a simple testcase OLTP scenario. Please treat it as an indicator instead of Comprehensive performance analysis that mimic real world scenario. 目前，DBench 仅限于使用 sysbench，并采用了一个简单的在线事务处理（OLTP）场景作为测试用例。请将其视为一个指标，而不是模拟现实世界场景的全面性能分析。

The resource provision script can be used as a base-line for your reference.资源配置脚本可以作为您参考的基线。


### Database is a sophisticated system, why DBench does not fine-tune the system before running the analysis.数据库是一个复杂的系统，为什么 DBench 在运行分析之前不对系统进行调优？

The purpose of cloud and managed-Database (such as RDS) is to offload the borden of database maintenance, operation and tuning to Cloud provider. Therefore, customer can focus the skillset of their IT team to their core business. If customers have to spend their valuable resource to figure out how to best use a RDS， they'd better build a self-managed database instead of paying 40%~300% extra for an open source(and free) database system. 
云托管数据库（如 RDS）的目的是将数据库的维护、操作和调优的负担转移给云提供商。因此，客户可以将其 IT 团队的技能集中在他们的核心业务上。如果客户必须花费宝贵的资源来弄清楚如何最好地使用 RDS，那么他们最好建立一个自我管理的数据库，而不是为一个开源且免费的数据库系统支付40%~300% 的额外费用。

Hence, It is up to the cloud providers to setup a RDS  "ready out of the box". A customer who purchase a car from dealership will not tuning a car before drive. 因此，设置一个开箱即用的 RDS是云提供商的职责。如同从4S店购买汽车的客户在驾驶之前不会对汽车进行调整的。




### How to request that DBench supports additional database, a new hosting provider, a new region or configuration? 如何建议DBench支持更多的数据库、一个新的云服务商、新的地区或配置？

Any comments or suggestion, please email support@ninedata.cloud or open issues at https://github.com/data9z/DBench. 我们真诚感谢您的批评和建议，请致函到support@ninedata.cloud 或 在https://github.com/data9z/DBench 开问题单。
