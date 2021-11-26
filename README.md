# MEIC-Tools 介绍

此系列代码用于使用ISAT文件在处理清单过程中可能会遇到的多种问题。

# 第一步：创建清单网格

首先，需要注意的是，清单网格是用于直接输入CMAQ中的网格，不同于WRF格网，所以使用ISAT来重新生成。

清单网格的创建基于MCIP模型所输出的**GRIDDESC**来进行。

操作步骤如图所示：

![image](https://github.com/cuitwhf/meic_tools/blob/MEICT-2.0/png/生成网格.png)

具体的操作方式在ISAT的手册中有具体描写。

# 第二步：使用“NC转网格”功能矢量化MEIC清单

此处转换出来的清单属性表中包含“ID”和“NAME”字段。

**Note:此处的转换流程可以在"ISATv2018.pdf"的Page 8中可以看到**

具体操作如图所示：

![image](https://github.com/cuitwhf/meic_tools/blob/MEICT-2.0/png/NC转网格.png)

由于ISAT的视图界面还存在一些小问题，因此，我们后续的一些工作采用Arcmap来进行。

如图所示为Arcmap的显示结果：

![image](https://github.com/cuitwhf/meic_tools/blob/MEICT-2.0/png/Arcgis视图.png)

此处的“NAME”字段需要先删除，再新建“NAME”字段（文本型，长度10）。

另外，“NAME”字段本身包含的应该是MEIC中的编号，但是我在操作的时候发现，2017年的MEIC清单编号与“NAME”字段中并不匹配。

具体是怎样匹配的可以采用***meic_nc_to_tiff.pro***查看，输出的TIFF含有一个**index.tiff**和一个**a.tiff**

其中**index.tiff**中的编号对应MEIC清单NC文件中的索引，但是再使用此编号以前，确定**a.tiff**具有正确的空间分布情况。

![image](https://github.com/cuitwhf/meic_tools/blob/MEICT-2.0/png/agriculture_NH3_value.png)

如图所示，MEIC数据在NC中的编号，与ISAT转换出来的编号不是一一对应的。

![image](https://github.com/cuitwhf/meic_tools/blob/MEICT-2.0/png/判断编号对应关系.png)

# 第三步：
