;�������ڷ���MEIC�嵥.�������ӽ��ISAT������ ����Դ�ŷ�
;Step.2
pro meic_emissions_grib_calc

;pollution_name.��Ⱦ������
;ĿǰMEIC�嵥�е���Ⱦ�ﹲ����:
;BC.CB05_ALD2.CB05_ETH.CB05_ETHA.CB05_ETOH
;CB05_FORM.CB05_IOLE.CB05_ISOP.CB05_MEOH.CB05_NVOL.CB05_OLE.CB05_PAR
;CB05_TERP.CB05_TOL.CB05_UNR.CB05_XYL.CO.CO2.NH3.NOx.OC.PM2.5.PMcoarse.SO2.VOC
;ISAT������Ⱦ��.SO2.NOx.VOC.CO.PM2.5.PM10.NH3
pollution_name=['SO2','NOx','VOC','CO','PM25','PMcoarse','NH3']
;intdir.MEIC�嵥Ŀ¼.���嵥�Ǿ���������TIFF�ļ�
intdir='F:\pythonProject\projectData\CMAQ\MEIC�嵥\201701\'
;distribution_dir.�����ļ�Ŀ¼.�˷����ļ�Ϊ��ISAT���������CSV�ļ�
distribution_dir='F:\pythonProject\projectData\CMAQ\�ռ��������\'
distribution_file=['�ƶ�Դ�ռ��������.csv','ũҵԴ�ռ��������.csv','����Դ�ռ��������.csv','��ҵԴ�ռ��������.csv','��ҵԴ�ռ��������.csv']
;grid_file.�����ļ�.��MCIP������GRIDCRO2D�ļ�.���ڻ�ȡ������Ϣ
grid_file='F:\ISAT\dist\src\met\GRIDCRO2D.nc'
;outdir.����ļ�Ŀ¼
outdir='F:\pythonProject\projectData\CMAQ\�ռ��������\��Ⱦ�������\201701\'
;outname.����ļ�����[department] [transportation|agriculture|residential|industry|power]
outname=['transportation','agriculture','residential','industry','power']
;grid_resolution.����ֱ���
;grid_resolution=0.03

dir_test=file_test(outdir,/directory)
if dir_test eq 0 then file_mkdir,outdir
;��ȡ������Ϣ
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

    ;��ȡMEIC�嵥���ݲ�����������ұ�
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

    ;��ȡ������Ϣ
    distribution_info=read_csv(distribution_dir+distribution_file[outname_i],header=header,count=info_n)
    index_info=distribution_info.(1)
    ratio_info=distribution_info.(4)
    lon_info=distribution_info.(6)
    lat_info=distribution_info.(7)
    col_info=distribution_info.(3)
    row_info=distribution_info.(2)
    lat_max=max(lat_info)
    lon_min=min(lon_info)

    ;����3������
    ;meic_grid_id ���ڽ��õ���meic������б�� �����Ŵ�0��ʼ
    ;ratio_arr ���ڼ�¼����ǰ�������� ���ں���ͳ��
    ;smeic_grid_num ���ڼ�¼��ϸ����ÿ�������е�����
    ratio_arr=fltarr(col_n,row_n)
    smeic_grid_num=fltarr(col_n,row_n)
    meic_grid_id=intarr(col_n,row_n)

    record=intarr(col_n,row_n,3)-1;��һ���¼�� �ڶ����¼�� �������¼id
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
          print,'error:������������'
        endif
        record_col=pos mod col_n
        record_row=pos/col_n
        meic_grid_id[col_i,row_i]=record[record_col,record_row,2]
        ;print,meic_grid_id[col_i,row_i]
      endelse
    endfor

    id_max=max(meic_grid_id)
    record_list=fltarr(id_max+1,3);��һ�м�¼����id��� �ڶ��м�¼��Ӧid��ŵ�ratio�ܺ� �����м�¼��Ӧid��ŵ���Ⱦ���ܺ�
    for i=0,id_max do begin
      record_list[i,0]=i
      id_mask=(meic_grid_id eq i)*1.0
      record_list[i,1]=total(ratio_arr*id_mask)
      record_list[i,2]=total(smeic_grid_num*id_mask)
    endfor

    result=fltarr(col_n,row_n)
    ;����Ԫ������Ⱦ������
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

    ;����index
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

    ;���
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