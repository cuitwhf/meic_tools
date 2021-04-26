# MEIC-Tools

MEIC清单是由清华大学MEIC团队经至下而上的调查，统计得出的中国多尺度面源排放清单。

本工具结合ISAT以及ISAT.M工具，对MEIC清单进行排放源强度分配，生成可以直接输入CMAQ的清单文件。

该工具开源，采用IDL8.5编写，编码格式为GB2312。

工具包括4中基本工具："meic_asc_to_tiff.pro","meic_emissions_grib_calc.pro","meic_merge.pro","run_isatm.pro"

## meic_asc_to_tiff.pro

MEIC清单的数据默认提供三种方式，分别是Netcdf格式、ASCII格式以及...（忘了）。

但三种不同格式的数据仅在格式上有所不同，其数据内容均完全一致。

该脚本仅使用ASCII格式数据，将ASCII格式数据转换成为Geotiff格式，一方面方便用户直接进行观察；另一方面供该工具的下一步网格排放源的计算。

脚本输入区在pro开头，如下：
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
其中，`outdir+file_basename(intfile,'.asc')+'.tif'`为输出文件名称，在此处进行命名自定义即可，但不建议更改。

Note:输出文件均为WGS-84等经纬度投影方式。

## meic_emissions_grib_calc.pro

该脚本根据ISAT输出的空间分配因子(ISAT经过分配以后会生成两种格式的因子表达方式，一种为.shp，另一种为.csv，本脚本只用到.csv格式。)

程序输入区位于程序头部，如下：
```
;pollution_name.污染物名称
;目前MEIC清单中的污染物共包含:
;BC.CB05_ALD2.CB05_ETH.CB05_ETHA.CB05_ETOH
;CB05_FORM.CB05_IOLE.CB05_ISOP.CB05_MEOH.CB05_NVOL.CB05_OLE.CB05_PAR
;CB05_TERP.CB05_TOL.CB05_UNR.CB05_XYL.CO.CO2.NH3.NOx.OC.PM2.5.PMcoarse.SO2.VOC
;ISAT所需污染物.SO2.NOx.VOC.CO.PM2.5.PM10.NH3
pollution_name=['SO2','NOx','VOC','CO','PM25','PMcoarse','NH3']
```
此处为需要处理的污染物名称，程序将逐个处理设置的污染物。该处参数在文件中的具体作用是根据设置参数寻找相同污染物的Geotiff文件，具体代码如下：
```
file_list=file_search(intdir,'*'+outname[outname_i]+'*'+pollution_name[pollution_i]+'.tif',count=count)
```
注释中列举了所有的MEIC清单污染物以及ISAT所需的污染物。
```
;intdir.MEIC清单目录.本清单是经过处理后的TIFF文件
intdir='F:\pythonProject\projectData\CMAQ\MEIC清单\201701\'
;distribution_dir.分配文件目录.此分配文件为由ISAT分配产生的CSV文件
distribution_dir='F:\pythonProject\projectData\CMAQ\空间分配因子\'
distribution_file=['移动源空间分配因子.csv','农业源空间分配因子.csv','居民源空间分配因子.csv','工业源空间分配因子.csv','工业源空间分配因子.csv']
;grid_file.网格文件.由MCIP产生的GRIDCRO2D文件.用于获取网格信息
grid_file='F:\ISAT\dist\src\met\GRIDCRO2D.nc'
;outdir.输出文件目录
outdir='F:\pythonProject\projectData\CMAQ\空间分配因子\污染物核算结果\201701\'
;outname.输出文件名称[department] [transportation|agriculture|residential|industry|power]
outname=['transportation','agriculture','residential','industry','power']
;grid_resolution.网格分辨率
;grid_resolution=0.03
```

