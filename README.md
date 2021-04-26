# MEIC-Tools

MEIC清单是由清华大学MEIC团队经至下而上的调查，统计得出的中国多尺度面源排放清单。

本工具结合ISAT以及ISAT.M工具，对MEIC清单进行排放源强度分配，生成可以直接输入CMAQ的清单文件。

该工具开源，采用IDL8.5编写，编码格式为GB2312。

工具包括4中基本工具："meic_asc_to_tiff.pro","meic_emissions_grib_calc.pro","meic_merge.pro","run_isatm.pro"

# meic_asc_to_tiff.pro

MEIC清单的数据默认提供三种方式，分别是Netcdf格式、ASCII格式以及...（忘了）。

但三种不同格式的数据仅在格式上有所不同，其数据内容均完全一致。

该脚本仅使用ASCII格式数据，将ASCII格式数据转换成为Geotiff格式，一方面方便用户直接进行观察；另一方面供该工具的下一步网格排放源的计算。

脚本输入区在pro开头，如下。
```
;程序说明.此程序将从网站获取的asc格式的MEIC清单文件转换为栅格格式。
;Step.1
;asc文件所在目录
intdir='E:\pythonProject\projectData\CMAQ\MEIC清单\2017清单'
;tif文件输出目录
outdir='E:\pythonProject\projectData\CMAQ\MEIC清单\201707\'
```
共有两个输入参数：

1.*intdir*：该参数为MEIC清单的ASCII码文件所在的目录。后缀名为'.asc'.程序将依据asc来对目录中的文件进行查找并处理，因此需确保该目录中不含有以.asc结尾的其他文件。

2.*outdir*：该参数为处理后的Geotiff输出目录，所有文件的名称默认以原始名称的Basename.tif进行命名.

若有需求对命名进行修改.参考：
```
write_tiff,outdir+file_basename(intfile,'.asc')+'.tif',data,/float,geotiff=geo_info
     
print,outdir+file_basename(intfile,'.asc')+'.tif'
```
其中，`outdir+file_basename(intfile,'.asc')+'.tif'为输出文件名称，在此处进行命名自定义即可。
