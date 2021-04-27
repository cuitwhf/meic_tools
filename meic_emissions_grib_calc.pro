;程序用于分配MEIC清单.分配因子结合ISAT输出结果 计算源排放
;Step.2
pro meic_emissions_grib_calc

;pollution_name.污染物名称
;目前MEIC清单中的污染物共包含:
;BC.CB05_ALD2.CB05_ETH.CB05_ETHA.CB05_ETOH
;CB05_FORM.CB05_IOLE.CB05_ISOP.CB05_MEOH.CB05_NVOL.CB05_OLE.CB05_PAR
;CB05_TERP.CB05_TOL.CB05_UNR.CB05_XYL.CO.CO2.NH3.NOx.OC.PM2.5.PMcoarse.SO2.VOC
;ISAT所需污染物.SO2.NOx.VOC.CO.PM2.5.PM10.NH3
pollution_name=['SO2','NOx','VOC','CO','PM25','PMcoarse','NH3']
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

dir_test=file_test(outdir,/directory)
if dir_test eq 0 then file_mkdir,outdir
;获取网格信息
ncfid=ncdf_open(grid_file)
ncdf_attget,ncfid,'NCOLS',col_n,/global
ncdf_attget,ncfid,'NROWS',row_n,/global
ncdf_close,ncfid
;print,col_n,row_n
;stop
outname_n=n_elements(outname)
for outname_i=0,outname_n-1 do begin
  pollution_n=n_elements(pollution_name)
  for pollution_i=0,pollution_n-1 do begin
    file_list=file_search(intdir,'*'+outname[outname_i]+'*'+pollution_name[pollution_i]+'.tif',count=count)
    if count eq 0 then begin;
      print,'Jump:'+pollution_name[pollution_i]+'.'+'Because this file does not exist.'
      continue
    endif

    ;获取MEIC清单数据并创建地理查找表
    meic_data=read_tiff(file_list[0],geotiff=meic_geog)
    res_info=meic_geog.(0)
    corner_info=meic_geog.(1)
    res_x=res_info[0]
    res_y=res_info[1]
    meic_data_size=size(meic_data)
    meic_lonarr=fltarr(meic_data_size[1],meic_data_size[2])
    meic_latarr=fltarr(meic_data_size[1],meic_data_size[2])
    for i=0,meic_data_size[1]-1 do meic_lonarr[i,*]=corner_info[3]+res_x*i
    for i=0,meic_data_size[2]-1 do meic_latarr[*,i]=corner_info[4]-res_y*i

    ;获取分配信息
    distribution_info=read_csv(distribution_dir+distribution_file[outname_i],header=header,count=info_n)
    index_info=distribution_info.(1)
    ratio_info=distribution_info.(4)
    lon_info=distribution_info.(6)
    lat_info=distribution_info.(7)
    col_info=distribution_info.(3)
    row_info=distribution_info.(2)
    lat_max=max(lat_info)
    lon_min=min(lon_info)

    ;建立3个数组
    ;meic_grid_id 用于将用到的meic网格进行编号 索引号从0开始
    ;ratio_arr 用于记录网格当前分配因子 用于后续统计
    ;smeic_grid_num 用于记录精细化后每个网格中的总量
    ratio_arr=fltarr(col_n,row_n)
    smeic_grid_num=fltarr(col_n,row_n)
    meic_grid_id=intarr(col_n,row_n)

    record=intarr(col_n,row_n,3)-1;第一层记录列 第二层记录行 第三层记录id
    id=0
    grid_scale=1.0
    for info_i=0,info_n-1 do begin
      col_i=col_info[info_i]-1
      row_i=row_info[info_i]-1
      temp_lon=lon_info[info_i]
      temp_lat=lat_info[info_i]
      temp_ratio=ratio_info[info_i]
      temp_index=index_info[info_i]
      ratio_arr[col_i,row_i]=temp_ratio
      distance=sqrt((meic_lonarr-temp_lon)^2+(meic_latarr-temp_lat)^2)
      min_distance=min(distance,pos)
      temp_col=pos mod meic_data_size[1]
      temp_row=pos/meic_data_size[1]
      temp_meic_value=meic_data[temp_col,temp_row]
      smeic_grid_num[col_i,row_i]=temp_meic_value*grid_scale
      pos=where(record[*,*,0] eq temp_col and record[*,*,1] eq temp_row,count)
      if count eq 0 then begin
        new_pos=where(record[*,*,0] eq -1)
        new_col=new_pos[0] mod col_n
        new_row=new_pos[0]/col_n
        record[new_col,new_row,0]=temp_col
        record[new_col,new_row,1]=temp_row
        record[new_col,new_row,2]=id
        meic_grid_id[col_i,row_i]=id
        ;print,meic_grid_id[col_i,row_i]
        id=id+1
      endif else begin
        if count ne 1 then begin
          print,'error:出现致命错误。'
        endif
        record_col=pos mod col_n
        record_row=pos/col_n
        meic_grid_id[col_i,row_i]=record[record_col,record_row,2]
        ;print,meic_grid_id[col_i,row_i]
      endelse
    endfor

    id_max=max(meic_grid_id)
    record_list=fltarr(id_max+1,3);第一行记录区块id编号 第二行记录对应id编号的ratio总和 第三行记录对应id编号的污染物总和
    for i=0,id_max do begin
      record_list[i,0]=i
      id_mask=(meic_grid_id eq i)*1.0
      record_list[i,1]=total(ratio_arr*id_mask)
      record_list[i,2]=total(smeic_grid_num*id_mask)
    endfor

    result=fltarr(col_n,row_n)
    ;逐像元分配污染物总量
    for col_i=0,col_n-1 do begin
      for row_i=0,row_n-1 do begin
        temp_ratio_arr=ratio_arr[col_i,row_i]
        temp_smeic_grid_num=smeic_grid_num[col_i,row_i]
        temp_meic_grid_id=meic_grid_id[col_i,row_i]
        pos=where(record_list[*,0] eq temp_meic_grid_id)
        total_ratio=record_list[pos,1]
        total_emis=record_list[pos,2]
        if total_ratio eq 0 then begin;*****
          result[col_i,row_i]=0
          ;result[col_i,row_i]=temp_smeic_grid_num
          ;print,'warning:total_ratio = 0 .'
          continue
        endif

        result[col_i,row_i]=(temp_ratio_arr/total_ratio)*temp_smeic_grid_num
      endfor
    endfor

    ;计算index
    openw,1,outdir+outname[outname_i]+pollution_name[pollution_i]+'.txt'
    for info_i=0,info_n-1 do begin
      col_i=col_info[info_i]-1
      row_i=row_info[info_i]-1
      temp_lon=lon_info[info_i]
      temp_lat=lat_info[info_i]
      ;temp_ratio=ratio_info[info_i]
      temp_index=index_info[info_i]
      printf,1,temp_index,temp_lon,temp_lat,result[col_i,row_i]
    endfor
    free_lun,1

    ;输出
;    geo_info={$
;      MODELPIXELSCALETAG:[grid_resolution,grid_resolution,0.0],$
;      MODELTIEPOINTTAG:[0.0,0.0,0.0,lon_min,lat_max,0.0],$
;      GTMODELTYPEGEOKEY:2,$
;      GTRASTERTYPEGEOKEY:1,$
;      GEOGRAPHICTYPEGEOKEY:4326,$
;      GEOGCITATIONGEOKEY:'GCS_WGS_1984',$
;      GEOGANGULARUNITSGEOKEY:9102,$
;      GEOGSEMIMAJORAXISGEOKEY:6378137.0,$
;      GEOGINVFLATTENINGGEOKEY:298.25722}
;    write_tiff,outdir+outname+pollution_name[pollution_i]+'.tiff',result,geotiff=geo_info,/float
    print,'Finish:',outdir+outname[outname_i]+pollution_name[pollution_i]+'.txt'

  endfor
endfor

end