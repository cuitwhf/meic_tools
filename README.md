# MEIC-Tools

MEIC清单是由清华大学MEIC团队经至下而上的调查，统计得出的中国多尺度面源排放清单。

本工具结合ISAT以及ISAT.M工具，对MEIC清单进行排放源强度分配，生成可以直接输入CMAQ的清单文件。

该工具开源，采用IDL8.5编写，编码格式为GB2312。

工具包括4中基本工具："meic_asc_to_tiff.pro","meic_emissions_grib_calc.pro","meic_merge.pro","run_isatm.pro"

# meic_asc_to_tiff.pro

## 介绍

MEIC清单的数据默认提供三种方式，分别是Netcdf格式、ASCII格式以及...（忘了）。

但三种不同格式的数据仅在格式上有所不同，其数据内容均完全一致。

该脚本仅使用ASCII格式数据，将ASCII格式数据转换成为Geotiff格式，一方面方便用户直接进行观察；另一方面供该工具的下一步网格排放源的计算。

```
;程序说明.此程序将从网站获取的asc格式的MEIC清单文件转换为栅格格式。
;Step.1
;asc文件所在目录
intdir='E:\pythonProject\projectData\CMAQ\MEIC清单\2017清单'
;tif文件输出目录
outdir='E:\pythonProject\projectData\CMAQ\MEIC清单\201707\'
```
