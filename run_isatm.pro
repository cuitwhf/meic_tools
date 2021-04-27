;核算各污染物排放量 写入为ISAT.M能够识别的CSV文件并调用ISAT.M以生成可以直接输入CMAQ的排放源
;在此之前需要配置ISAT.M
pro run_isatm
;============================Update information============================
;Dec.16,2020 添加对各污染物排放系数的更改(根据结果调整清单)
;==========================================================================
;intdir.分配好的各污染物文件目录
intdir='F:\pythonProject\projectData\CMAQ\空间分配因子\污染物核算结果\201701\'
;pollution_name.需要核算的污染物名称.不可更改*
pollution_name=['SO2','NOx','VOC','CO','PM25','PMcoarse','NH3']
;departament
departament=['transportation','agriculture','residential','industry','power']
;时间分配谱目录
time_dir='F:\ISAT\dist\src\temporary\'
time_subdir=['成都市交通源时间分配谱','成都市农业源时间分配谱','成都市民用源时间分配谱','成都市工业源时间分配谱','成都市工业源时间分配谱']
;lines_n.最大序号 max(index)
lines_n=6952
;ISAT.M.运行目录
work_dir='F:\ISAT\dist\'
;consult_num.调整系数
;consult_num=[0.33,1.0,1.0,1.0,2.0*1.8,1.0,1.0]
consult_num=[1.0,1.0,1.0,1.0,1.0,1.0,1.0]

consult_num=double(consult_num)
header=['lon','lat','so2','no2','voc','co','pm25','pm10','nh3']
pollution_n=n_elements(pollution_name)
record_arr=fltarr(pollution_n,lines_n)
record_geog=fltarr(3,lines_n)
control_data=fltarr(1,lines_n)+1
departament_n=n_elements(departament)
for departament_i=0,departament_n-1 do begin
  for pollution_i=0,pollution_n-1 do begin
    file_list=file_search(intdir,'*'+departament[departament_i]+'*'+pollution_name[pollution_i]+'.txt',count=file_n)
    print,file_n,file_list
    ;print,file_list
    ;  if file_n lt 5 then begin
    ;    print,'WARN: File not complete.'
    ;  endif

    for file_i=0,file_n-1 do begin
      openr,1,file_list[file_i]
      temp_data=fltarr(4,lines_n)
      readf,1,temp_data
      free_lun,1
      record_arr[pollution_i,*]=record_arr[pollution_i,*]+temp_data[3,*]
      record_geog[0,*]=temp_data[0,*]
      record_geog[1,*]=temp_data[1,*]
      record_geog[2,*]=temp_data[2,*]
    endfor

  endfor

  so2_sum=record_arr[0,*]*consult_num[0]
  nox_sum=record_arr[1,*]*consult_num[1]
  voc_sum=record_arr[2,*]*consult_num[2]
  co_sum=record_arr[3,*]*consult_num[3]
  pm25_sum=record_arr[4,*]*consult_num[4]
  pmc_sum=record_arr[5,*]*consult_num[5]
  nh3_sum=record_arr[6,*]*consult_num[6]
  
  write_csv,work_dir+'src\emissions\area\AR.csv',[record_geog[1,*],record_geog[2,*],so2_sum,nox_sum,voc_sum,co_sum,pm25_sum,pm25_sum+pmc_sum,nh3_sum],header=header
  write_csv,work_dir+'src\control\areacontrol.csv',control_data,header=['AR']
  ;获取时间分配谱文件
  time_file=file_search(time_subdir[departament_i],'*.csv',count=time_n)
  for time_i=0,time_n-1 do file_copy,time_file[time_i],work_dir+'src\temporary\'+file_basename(time_file[time_i]),/overwrite
    
  cd,work_dir
  spawn,'area_inlinenew.exe'
  file_move,work_dir+'ARarea.nc',work_dir+departament[departament_i]+'.nc'
  print,'Finish:'+work_dir+departament[departament_i]+'.nc'
endfor







end