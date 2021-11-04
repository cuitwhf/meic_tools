function get_meic_varid,file_name,dstname
  ncfid=ncdf_open(file_name)
  ncvid=ncdf_varid(ncfid,dstname)
  ncdf_varget,ncfid,ncvid,data
  ncdf_close,ncfid
  return,data
end
pro meic_nc_to_tiff

file_name = 'G:\WRF-CMAQ\MEIC\2017\2017_9_agriculture_NH3.nc'

value = get_meic_varid(file_name,'z')
dimension = get_meic_varid(file_name,'dimension')
spacing = get_meic_varid(file_name,'spacing')
x_range = get_meic_varid(file_name,'x_range')
y_range = get_meic_varid(file_name,'y_range')

result = fltarr(dimension)
index = fltarr(dimension)
;help,result

for i = 0,n_elements(value)-1 do begin
  result[i]=value[i]
  index[i] = i
endfor

geo_info={$
  MODELPIXELSCALETAG:[spacing[0],spacing[1],0.0],$
  MODELTIEPOINTTAG:[0.0,0.0,0.0,x_range[0],y_range[1],0.0],$
  GTMODELTYPEGEOKEY:2,$
  GTRASTERTYPEGEOKEY:1,$
  GEOGRAPHICTYPEGEOKEY:4326,$
  GEOGCITATIONGEOKEY:'GCS_WGS_1984',$
  GEOGANGULARUNITSGEOKEY:9102,$
  GEOGSEMIMAJORAXISGEOKEY:6378137.0,$
  GEOGINVFLATTENINGGEOKEY:298.25722}
  
write_tiff,'G:\WRF-CMAQ\MEIC\a.tiff',result,geotiff=geo_info,/float
write_tiff,'G:\WRF-CMAQ\MEIC\index.tiff',index,geotiff=geo_info,/float
; 证实了这个编号 从左往右 从上往下开始编号
end