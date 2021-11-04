# MEIC-Tools 介绍

此系列代码用于使用ISAT文件在处理清单过程中可能会遇到的多种问题。

# 第一步：创建清单网格

首先，需要注意的是，清单网格是用于直接输入CMAQ中的网格，不同于WRF格网，所以使用ISAT来重新生成。

清单网格的创建基于MCIP模型所输出的**GRIDDESC**来进行。

具体的操作方式在ISAT的手册中有具体描写。

# 第二步：使用“NC转网格”功能矢量化MEIC清单

此处转换出来的清单属性表中包含“ID”和“NAME”字段。

**Note:此处的转换流程可以在"ISATv2018.pdf"的Page 8中可以看到**

此处的“NAME”字段需要先删除，再新建“NAME”字段（文本型，长度10）。

另外，“NAME”字段本身包含的应该是MEIC中的编号，但是我在操作的时候发现，2017年的MEIC清单编号与“NAME”字段中并不匹配。

具体是怎样匹配的可以采用***meic_nc_to_tiff.pro***查看，输出的TIFF含有一个**index.tiff**和一个**a.tiff**

其中**index.tiff**中的编号对应MEIC清单NC文件中的索引，但是再使用此编号以前，确定**a.tiff**具有正确的空间分布情况。

![image](https://github.com/cuitwhf/meic_tools/blob/MEICT-2.0/png/agriculture_NH3_value.png)

如图所示，我们发现现在的**a.tiff**文件具有正确的空间分布。接下来我们需要核对**index.tiff**中的数值是否和“NAME”是一一对应的关系。

当然了，如果不是一一对应，你就想办法让他对应起来就可以了。ARCGIS里面的工具有很多可以做的。

启用ArcGIS中的“识别”工具，点击网格中的某点。若“NAME”和**index.tiff**的索引相同，则说明不需要进行进一步的处理，可以直接跳入第三步。

具体操作步骤见下图。

![image](https://github.com/cuitwhf/meic_tools/blob/MEICT-2.0/png/grid_judge.png)


# 第三步：
