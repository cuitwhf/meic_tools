pro meic_asc_to_tiff
;#>程序说明.此程序将从网站获取的asc格式的MEIC清单文件转换为栅格格式。
;Step.1
;#>asc文件所在目录
intdir='E:\pythonProject\projectData\CMAQ\MEIC清单\2017清单'
;#>tif文件输出目录
outdir='E:\pythonProject\projectData\CMAQ\MEIC清单\201707\'

dir_test=file_test(outdir,/directory)
if dir_test eq 0 then file_mkdir,outdir
file_list=file_search(intdir,'2017_7_*.asc',count=file_n)

for file_i=0,file_n-1 do begin
  intfile=file_list[file_i]
  openr,1,intfile
  lines_n=file_lines(intfile)
  ascdata=strarr(1,lines_n)
  readf,1,ascdata
  ;print,ascdata
  free_lun,1

  ;读取头文件
  ncols_info=ascdata[0]
  nrows_info=ascdata[1]
  xll_info=ascdata[2]
  yll_info=ascdata[3]
  res_info=ascdata[4]
  fillvalue_info=ascdata[5]
;  print,ncols_info
;  print,nrows_info
;  print,xll_info
;  print,yll_info
;  print,res_info
;  print,fillvalue_info
  ncols_info=strsplit(ncols_info,' ',/extract)
  nrows_info=strsplit(nrows_info,' ',/extract)
  xll_info=strsplit(xll_info,' ',/extract)
  yll_info=strsplit(yll_info,' ',/extract)
  res_info=strsplit(res_info,' ',/extract)
  fillvalue_info=strsplit(fillvalue_info,' ',/extract)
  ncols=ncols_info[1]
  nrows=nrows_info[1]
  xll=xll_info[1]
  yll=yll_info[1]
  res=res_info[1]
  fillvalue=fillvalue_info[1]
  ;print,ncols,nrows,xll,yll,res,fillvalue
  yll=double(yll)+double(res)*double(nrows)

  data=fltarr(ncols,nrows)
  ascdata=ascdata[6:lines_n-1]
  ;print,ascdata[0]

  ;help,strsplit(ascdata[1],' ',/extract)
  for i=0,nrows-1 do begin
    data[*,i]=strsplit(ascdata[i],' ',/extract)
  endfor
  geo_info={$
    MODELPIXELSCALETAG:[res,res,0.0],$
    MODELTIEPOINTTAG:[0.0,0.0,0.0,xll,yll,0.0],$
    GTMODELTYPEGEOKEY:2,$
    GTRASTERTYPEGEOKEY:1,$
    GEOGRAPHICTYPEGEOKEY:4326,$
    GEOGCITATIONGEOKEY:'GCS_WGS_1984',$
    GEOGANGULARUNITSGEOKEY:9102,$
    GEOGSEMIMAJORAXISGEOKEY:6378137.0,$
    GEOGINVFLATTENINGGEOKEY:298.25722}
  write_tiff,outdir+file_basename(intfile,'.asc')+'.tif',data,/float,geotiff=geo_info
  print,outdir+file_basename(intfile,'.asc')+'.tif'
endfor



end