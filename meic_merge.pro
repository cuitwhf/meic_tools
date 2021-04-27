;Step.3 �ϲ������ŷ�Դ
pro meic_merge

;Step.2����ļ�Ŀ¼
clac_outdir='G:\pythonProject\projectData\CMAQ\�ռ��������\��Ⱦ�������\201707\'
;���Ŀ¼
output_dir='G:\pythonProject\projectData\CMAQ\�ռ��������\��Ⱦ�������\201707\'
;��Ⱦ������ ���ڲ�ѯ�ļ�·��
pollution_name=['SO2','NOx','VOC','CO','PM25','PMcoarse','NH3']

for pollution_i=0,n_elements(pollution_name)-1 do begin
  file_list=file_search(clac_outdir,'*'+pollution_name[pollution_i]+'.txt',count=count)
  output_name=output_dir+'Total_'+pollution_name[pollution_i]+'.txt'

  for file_i=0,count-1 do begin
    file_name=file_list[file_i]
    if file_i eq 0 then begin
      line_n=file_lines(file_name)
      ;print,line_n
      data=fltarr(4,line_n) 
      pollution_sum=fltarr(1,line_n)   
    endif
    openr,1,file_name
      readf,1,data
    free_lun,1  
    pollution_sum=pollution_sum+data[3,*] 
  endfor
  
  for line_i=0,line_n-1 do begin
    openw,1,output_name,width=8000
      printf,1,data[0,line_i],data[1,line_i],data[2,line_i],pollution_sum[0,line_i]
      ;print,data[0,line_i],data[1,line_i],data[2,line_i],pollution_sum[0,line_i]
    free_lun,1
  endfor
  print,'Finish:'+output_name,count
endfor

end